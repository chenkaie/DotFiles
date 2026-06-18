---
name: camera-release-summary
description: Generate a customer-facing SQA release summary for any camera service (rant, bartleby, or others) from a RELEASES.md or changelog file. Looks up Jira tickets, collapses intermediate versions, and outputs a structured markdown file with test commands, QA tips, and a priority test matrix. Use when user says "summarize releases", "release notes for X to Y", "create release summary", "SQA notes", or specifies a version range like "3.2.10 to 3.3.7" for rant, bartleby, or any other camera service.
---

# Skill: camera-release-summary

Generate a customer-facing SQA release summary for a specified version range of any camera service
(rant, bartleby, framework_app, etc.) from its changelog file.

## Inputs

The user provides:
- **service**: the service name — e.g. `rant`, `bartleby`, `framework_app`
- **from_version**: start version (exclusive) — e.g. `3.2.10`
- **to_version**: end version (inclusive) — e.g. `3.3.7`

If the service is not explicitly stated, infer it from the current workspace (check `Cargo.toml`,
`RELEASES.md` header, or the repo name).

## Service-specific defaults

| Service     | Changelog file  | Log file                    | Config path                              | Restart command                    |
|-------------|-----------------|----------------------------|------------------------------------------|------------------------------------|
| rant        | `RELEASES.md`   | `/var/log/rant.log`         | `/mnt/media/etc/rant/config.toml`        | `systemctl restart rant`           |
| bartleby    | `RELEASES.md`   | `/var/log/bartleby.log`     | `/mnt/media/etc/bartleby/config.toml`    | `systemctl restart bartleby`       |
| other       | `RELEASES.md`   | `/var/log/<service>.log`    | `/mnt/media/etc/<service>/config.toml`   | `systemctl restart <service>`      |

Use the correct paths for the service throughout all SSH commands in the output.

## Workflow

### 1. Read the changelog

Read the full changelog file from the workspace root. Extract only the version sections that fall
within the range `(from_version, to_version]` (excluding `from_version` itself, including
`to_version`).

### 2. Extract Jira tickets

Grep the extracted sections for ticket IDs matching `VID-\d+`. Look up each ticket in Jira using
the Atlassian search tools to get the ticket title/summary. Run all lookups in parallel.

Jira base URL: `https://vivint.atlassian.net/browse/`

### 3. Synthesize customer-facing themes

Collapse all intermediate version details into grouped customer-facing themes. Do NOT list every
version separately — group changes by feature area. Derive the categories from the actual changes;
the list below is a starting point, not exhaustive:

- **New Features** — new capabilities (e.g. HLS DVR, multi-user streaming, new camera support)
- **DVR Playback / Recording Stability** — seek/scrub freezes, race conditions, thread blocking
- **Clip Export Reliability** — export failures, format detection, /tmp cleanup
- **Format Migration** — legacy→HLS transition, migration scheduling, fallback behavior
- **Disk / Storage Management** — cleanup, orphaned DB rows, space thresholds
- **DataChannel / Metadata Responsiveness** — latency, background workers
- **Live Viewer Efficiency** — idle frame suppression, audio artifacts, watchdog
- **Observability / Metrics** — Memfault metrics, log improvements
- **Platform / Dependency Upgrades** — WebRTC, GStreamer, Rust edition, gRPC

Merge, split, or rename categories to match the actual content. Drop categories that have no
changes in the range.

### 4. Structure each section

For each theme section:

```markdown
## N. Theme Title (Type)

**Jira:** [VID-XXXXX](https://vivint.atlassian.net/browse/VID-XXXXX) — Ticket title
[VID-YYYYY](https://vivint.atlassian.net/browse/VID-YYYYY) — Ticket title

Plain-English description of what was fixed or added and why it matters to the customer.

**What to verify:**
- Observable behavior SQA should confirm (bullet per check)
- ...

> **QA tip — <short label>:** Include this block only when a test requires hardware state that is
> slow or hard to reach (e.g. waiting for a scheduled time window, filling disk, reproducing a race
> condition). Provide concrete config knobs or SSH one-liners that let QA shortcut directly to the
> relevant state without waiting.
>
> ```bash
> # Force condition immediately
> ssh root@<CAMERA> "sed -i 's/some_config = .*/some_config = \"value\"/' /mnt/media/etc/<service>/config.toml"
> ssh root@<CAMERA> 'systemctl restart <service>'
>
> # Restore default after testing
> ssh root@<CAMERA> "sed -i 's/some_config = .*/some_config = \"default\"/' /mnt/media/etc/<service>/config.toml"
> ssh root@<CAMERA> 'systemctl restart <service>'
> ```

```bash
# Step-by-step verification commands
ssh root@<CAMERA> '...'
# Expected: what success looks like
```
```

Only include the QA tip block when there is a genuine shortcut worth documenting. Omit it for
straightforward UI-driven tests.

### 5. Add summary table

At the top of the document (after the scope header), include:

```markdown
| # | Section | Jira | Type |
|---|---------|------|------|
| 1 | Theme name | [VID-XXXXX](url) | New Feature / Bug Fix / Infrastructure |
| 2 | Theme name | — | Bug Fix |
```

### 6. Add Priority Test Matrix

Before the standard footers, append:

```markdown
## Priority Test Matrix

| Area | Priority | Jira |
|------|----------|------|
| Most critical customer-visible item | High | [VID-XXXXX](url) |
| Secondary item | High | [VID-XXXXX](url) · [VID-YYYYY](url) |
| Internal/observability item | Low | — |
```

Priority assignment:
- **High**: data loss, playback failure, export hang, connection drops, format migration correctness
- **Medium**: latency degradation, UI state mismatch, audio artifacts, disk cleanup correctness
- **Low**: observability, metrics, internal config changes, dependency bumps

### 7. Add standard footers

Always append after the Priority Test Matrix:

```markdown
## Supported Camera Types

All items above apply to: `DBC300` (bagheera), `ODC300` (hyrax), `DBC350` (bumblebee),
`ODC350` (hornet), `ODC400` (hummingbird), `IDC350` (coati).

---

## Quick On-Device Diagnostics Reference

\```bash
# Follow live logs
ssh root@<CAMERA> 'tail -F /var/log/<service>.log'

# Check installed version
ssh root@<CAMERA> 'RPM_ETCCONFIGDIR=/etc/rpm-custom rpm -qa | grep <service>'

# Check /tmp for leftover export files
ssh root@<CAMERA> 'ls -lh /tmp/*.mp4 2>/dev/null'

# Check /mnt/media free space (core dumps can fill it)
ssh root@<CAMERA> 'df -h /mnt/media'

# Adjust log verbosity
ssh root@<CAMERA> 'vi /mnt/media/etc/<service>/log4rs.yml'
\```
```

Substitute `<service>` with the actual service name (e.g. `rant`, `bartleby`).

### 8. Write output file

Write the result to:
```
release<from_version>-<to_version>.md
```
in the workspace root (same directory as the changelog).

Example: rant `3.2.10` → `3.3.7` produces `release3.2.10-3.3.7.md`.

## Rules

- **Exclude** `from_version` itself; it is the baseline.
- **Collapse** intermediate versions — do not give each version its own section.
- **Only reference Jira tickets** that appear in the extracted version range.
- **Tickets with no customer impact** (pure internal/CI changes) may be noted briefly but should
  not get their own top-level section.
- Use `<CAMERA>` as the placeholder for camera IP or UUID in all SSH commands.
- Use correct service-specific paths (log file, config file, restart command) throughout.
- Do not invent test cases; base everything on the actual changes in the changelog.
- After writing the file, confirm the output path to the user.
