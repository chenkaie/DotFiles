---
name: amba-oryx-export-muxer-diagnose
description: Use when diagnosing Ambarella Oryx export muxer H.264/H.265 captures, test_oryx_data_export output, DVR frame corruption, SPS/PPS/IDR fair-clip decoding, or SmartRC/QPM ROI capture validation on camera DUTs.
---

# Ambarella Oryx Export Muxer Diagnose

Use this skill for export-muxer validation on Ambarella camera DUTs, especially when checking whether exported elementary streams are genuinely corrupt or only fail due to capture-start artifacts.

## Default DUT And Export

- Default DUT IP: `192.168.10.99`, unless the user gives another IP.
- Default user: `root`.
- Fallback binary (for DUTs where `test_oryx_data_export` is absent): `~/.claude/skills/amba-oryx-export-muxer-diagnose/test_oryx_data_export`

Before running the export, check whether the binary exists on the DUT. If it is missing from `/mnt/media/`, deploy it first:

```bash
ssh root@<dut-ip> "ls /mnt/media/test_oryx_data_export 2>/dev/null || echo MISSING"
# If MISSING:
scp ~/.claude/skills/amba-oryx-export-muxer-diagnose/test_oryx_data_export \
    root@<dut-ip>:/mnt/media/test_oryx_data_export
ssh root@<dut-ip> "chmod +x /mnt/media/test_oryx_data_export"
```

- Export command pattern:
  ```bash
  ssh root@<dut-ip> "rm -f /tmp/<prefix>*; timeout -s INT <seconds+5> /mnt/media/test_oryx_data_export -v 7 -f /tmp/<prefix>; rc=\$?; sync; printf 'capture_rc=%s\n' \$rc; ls -l /tmp/<prefix>*"
  ```
- Export file naming is `<prefix>_video_<stream>_<clock>.h264` for AVC streams.
- If `capture_rc=0` but no files are created, inspect framework logs for `Wait video data timeout` and check whether video packets are reaching the export client.

## Tigerguard Usage

Some DUTs are only reachable through Tigerguard. If direct `ssh` hangs through `ProxyCommand tigerguard %h %p`, use `tiger run` instead:

```bash
tiger run <uuid> -t <timeout-seconds> -c "uptime; <command>"
```

For export tests through Tigerguard, make the tool timeout comfortably longer than the device-side capture duration. If the wrapper times out, immediately check for completed files and stale exporters before discarding the run:

```bash
tiger run <uuid> -t 60 -c "uptime; ps | grep -E 'test_oryx_data_export|<prefix>' | grep -v grep || true; ls -lh /tmp/<prefix>* 2>/dev/null || true; dmesg | tail -40"
```

For large capture files, package on the DUT and upload to the HTTP file server, then download locally:

## GStreamer RicinStreamSrc Export-Muxer Capture

Use this when the user wants to validate the Bartleby/GStreamer-style source path. `ricinstreamsrc` reads from the Oryx export muxer by default (`read-from-export-muxer=true`), so it is a useful cross-check against `test_oryx_data_export`.

On camera DUTs, run GStreamer through the runtime wrapper so library and plugin paths are set correctly:

```bash
ssh root@<dut-ip> "/usr/bin/exec.sh gst-inspect-1.0 ricinstreamsrc"
```

Important properties:

- `stream=<id>` is the stream selector, not `stream-id`.
- `read-from-export-muxer=true` is the default but set it explicitly for clarity.
- Common active ODC350/Hornet streams are `0` (`1920x1080`), `1` (`1280x720`), and `2` (`720x400`).

Three-stream simultaneous raw H.264 capture pattern:

```bash
ssh root@<dut-ip> "rm -f /mnt/media/<prefix>_stream{0,1,2}_<seconds>s.h264; \
  /usr/bin/exec.sh gst-launch-1.0 -e \
    ricinstreamsrc stream=0 read-from-export-muxer=true ! h264parse disable-passthrough=true ! queue max-size-buffers=0 max-size-time=0 max-size-bytes=0 ! filesink location=/mnt/media/<prefix>_stream0_<seconds>s.h264 \
    ricinstreamsrc stream=1 read-from-export-muxer=true ! h264parse disable-passthrough=true ! queue max-size-buffers=0 max-size-time=0 max-size-bytes=0 ! filesink location=/mnt/media/<prefix>_stream1_<seconds>s.h264 \
    ricinstreamsrc stream=2 read-from-export-muxer=true ! h264parse disable-passthrough=true ! queue max-size-buffers=0 max-size-time=0 max-size-bytes=0 ! filesink location=/mnt/media/<prefix>_stream2_<seconds>s.h264 \
    >/tmp/<prefix>_gst.log 2>&1 & \
  wrapper=\$!; sleep 5; gstpid=\$(pidof gst-launch-1.0); echo gstpid=\$gstpid; \
  sleep <seconds>; kill -INT \$gstpid; wait \$wrapper; rc=\$?; \
  echo capture_rc=\$rc; ls -lh /mnt/media/<prefix>_stream{0,1,2}_<seconds>s.h264"
```

Prefer this background/`kill -INT` pattern over wrapping a foreground SSH command with a local tool timeout. If SSH/tool execution times out first, `gst-launch-1.0` can keep running on the DUT. Always check and stop leftovers before starting a new run:

```bash
ssh root@<dut-ip> "pidof gst-launch-1.0 || true; ps | grep '[g]st-launch' || true"
ssh root@<dut-ip> "kill -INT <gstpid>"
```

Copy and analyze the GStreamer outputs the same way as raw export muxer files:

```bash
mkdir -p /tmp/opencode/<case>/gst_run1
scp root@<dut-ip>:'/mnt/media/<prefix>_stream*_*.h264' /tmp/opencode/<case>/gst_run1/
python3 /home/kent/Project/Issues/DVR_Frame_Corruption/analyze_raw_h264.py /tmp/opencode/<case>/gst_run1/*.h264
```

## Capture Analysis

Copy files locally and extract fair Annex-B clips that start at an in-band SPS/PPS/IDR sequence:

```bash
mkdir -p /tmp/opencode/<case>/run1
scp root@<dut-ip>:'/tmp/<prefix>*.h264' /tmp/opencode/<case>/run1/
python3 /home/kent/Project/Issues/DVR_Frame_Corruption/analyze_raw_h264.py --max-bytes 25000000 /tmp/opencode/<case>/run1/*.h264
```

When avoiding false positives is the priority, generate decode-clean clips in one pass. These clips start at the first SPS/PPS/IDR sequence, remove SEI NALs, and trim the end at the last complete slice NAL (`type 1` or `type 5`):

```bash
mkdir -p /tmp/opencode/<case>/decode_clean
python3 /home/kent/Project/Issues/DVR_Frame_Corruption/analyze_raw_h264.py \
  --max-bytes 25000000 \
  --decode-clean \
  --out-dir /tmp/opencode/<case>/decode_clean \
  /tmp/opencode/<case>/run1/*.h264
```

Decode the fair clips strictly:

```bash
for f in /tmp/oryx_reader_test/fair_decode/<prefix>*.from_sps_idr.h264; do
  ffmpeg -v error -xerror -i "$f" -f null -
done
```

Decode the generated decode-clean clips strictly. These are the preferred hard-corruption verdict artifacts when raw or fair clips only fail on startup SEI/access-unit or capture-stop truncation noise:

```bash
for f in /tmp/opencode/<case>/decode_clean/*.decode_clean.h264; do
  ffmpeg -v error -xerror -i "$f" -f null -
done
```

When files are full raw captures, also decode originals to catch startup/EOS anomalies separately from fair-start corruption checks:

```bash
for f in /tmp/opencode/<case>/run1/*.h264; do
  ffmpeg -v error -xerror -i "$f" -f null -
done
```

## Avoid False Failures

Raw Oryx exports often start mid-stream before SPS/PPS. If original-file decode reports only `non-existing PPS 0 referenced`, `missing picture in access unit`, or `no frame` at startup, treat that as a capture-start artifact and rely on fair SPS/IDR-start clips before calling it corruption.

Raw Oryx exports may also contain SEI-only access units before the first IDR on some streams. If ffmpeg reports only `missing picture in access unit` or `no frame` at startup, generate `--decode-clean` clips and retry before calling it corruption.

If `--max-bytes` truncates a fair clip at a parameter-set boundary, ffmpeg may also report `missing picture in access unit`. The `--decode-clean` output handles this by trimming the clip so it ends at the last slice NAL (`type 1` or `type 5`).

Use decode-clean clips as a false-positive filter, not as the only evidence. Always keep and, when feasible, decode the original raw captures too. Decode-clean intentionally discards startup data before the first clean IDR, SEI NALs, and trailing incomplete non-slice data; it can miss corruption that exists only in those discarded regions. It should still catch real frame corruption in valid video payload after the first clean IDR, such as bad CABAC, invalid macroblock/slice data, missing refs after IDR, or corrupt decoded frames.

Do not dismiss these as artifacts:

- `corrupt decoded frame`
- `error while decoding MB ...`
- `cabac decode of qscale diff failed`
- `left block unavailable for requested intra mode`
- `top block unavailable for requested intra mode`
- `bytestream -5`, `bytestream -6`, `bytestream -8`, `bytestream -9`, `bytestream -11`, `bytestream -14`

## SmartRC/QPM Notes

- Keep SmartRC ROI enabled when validating a real ROI fix; disabling ROI can hide QPM corruption.
- On CV25 Hornet/ODC350 style configs, verify `qpm_max_matrix_num` does not exceed the driver/DSP command support. The CV25 hornet build uses `IAV_ROI_NUM_FOR_IPB_FRAMES = 3`, and H.264 command setup handles QPM matrix counts `1`, `2`, or `3`.
- If `qpm_max_matrix_num = 5`, H.264 QPM address setup can fall into the unsupported/default path and invalidate the test.
- `qpm_max_matrix_num = 2` is the safer rootfs mitigation value used by Cooper/DBC variants and validated on ODC350 export captures while keeping SmartRC_V3 ROI/QPM enabled.
- When validating override-based configs, check both the override and the active rootfs file. A `/tmp/oryx_override/video/boot_resource.acs` override is volatile across reboot; if the DUT reboots, the override disappears and the active `/etc/oryx/video/boot_resource.acs` may be a different QPM value.
- Record config hashes with `sha1sum /etc/oryx/video/boot_resource.acs /etc/oryx/video/features.acs /lib/modules/5.4.90/extra/iav.ko`. If an override path is used, include its hash too.

## Report Format

Include these facts in the final report:

- DUT IP and uptime after validation.
- Module/config identifiers, if relevant.
- Capture duration and run count.
- Export `capture_rc` and file sizes.
- Capture path used: `test_oryx_data_export` or `ricinstreamsrc`/GStreamer.
- Analyzer output location.
- Whether strict ffmpeg passed on original files and on fair-start clips; mention SEI-strip and slice-end trimming if used.
- Any unrelated platform noise, such as SD-card F2FS errors, separately from export corruption results.
