---
name: tigerguard-camera-shell
description: tigerguard, camera UUID, ssh root@UUID, scp root@UUID, Iroh-backed camera shell. Use ONLY when the user is accessing a camera via a UUID-style Tigerguard/Iroh SSH or SCP target; do not use for raw IP-address targets.
---

# Tigerguard Camera Shell

Use this skill when the user wants to access a camera through the normal local workflow `ssh root@<uuid>` or `scp ... root@<uuid>` and that SSH path is transparently backed by Tigerguard/Iroh.

Do not use this skill for cameras addressed by raw IP address.

This skill exists to avoid repeated one-shot reconnects and to standardize on a persistent camera shell helper.

The helper script is bundled directly in this skill directory:

- `camera-shell.sh`

When using this skill, prefer invoking it by absolute path inside the skill directory so the workflow does not depend on the current repository layout.

Canonical path:

```text
~/.claude/skills/tigerguard-camera-shell/camera-shell.sh
```

## Use This First

Prefer this wrapper instead of issuing raw repeated `ssh root@<uuid> <cmd>` commands:

- `~/.claude/skills/tigerguard-camera-shell/camera-shell.sh`: self-contained persistent camera shell wrapper for UUID/host-based sessions

Default preference:

1. Use `~/.claude/skills/tigerguard-camera-shell/camera-shell.sh` for camera access.

## Why

The user's `ssh root@<uuid>` is backed by SSH config like:

```sshconfig
Host *-*-*-*-*
  User root
  LogLevel quiet
  StrictHostKeyChecking no
  UpdateHostKeys no
  UserKnownHostsFile /dev/null
  ProxyCommand tigerguard %h %p
```

So to the shell it still looks like SSH, but transport is actually provided by Tigerguard/Iroh underneath.

One-shot direct execution may reject some shell metacharacters depending on Tigerguard validation. Starting one persistent remote `/bin/sh` and then feeding commands via stdin avoids that limitation.

## Recommended Workflow

### Start a camera session

```bash
~/.claude/skills/tigerguard-camera-shell/camera-shell.sh start --host <camera-uuid>
```

Or with an explicit session name:

```bash
~/.claude/skills/tigerguard-camera-shell/camera-shell.sh start --host <camera-uuid> --name cam1
```

Or set a default camera once for the shell session:

```bash
export CAMERA_HOST=<camera-uuid>
~/.claude/skills/tigerguard-camera-shell/camera-shell.sh start
```

### Run a command and wait for bounded output

```bash
~/.claude/skills/tigerguard-camera-shell/camera-shell.sh send --host <camera-uuid> --wait hostname
~/.claude/skills/tigerguard-camera-shell/camera-shell.sh send --host <camera-uuid> --wait whoami
~/.claude/skills/tigerguard-camera-shell/camera-shell.sh send --host <camera-uuid> --wait 'journalctl -u rant -n 50'
```

If the session already has a known name, prefer reusing that name:

```bash
~/.claude/skills/tigerguard-camera-shell/camera-shell.sh send --name cam-<camera-uuid> --wait hostname
```

### Follow output continuously

For `tail -f` or `tail -F` style log-following, prefer the dedicated `logs` subcommand so the main interactive shell is not blocked.

```bash
~/.claude/skills/tigerguard-camera-shell/camera-shell.sh logs --host <camera-uuid>
```

This automatically:

- creates or reuses a dedicated `<session>-log` session
- runs `tail -F /var/log/rant.log` inside that log session
- attaches local tailing to that log session output

```bash
~/.claude/skills/tigerguard-camera-shell/camera-shell.sh tail --host <camera-uuid>
```

Or by session name:

```bash
~/.claude/skills/tigerguard-camera-shell/camera-shell.sh tail --name cam-<camera-uuid>
```

### Check or stop a session

```bash
~/.claude/skills/tigerguard-camera-shell/camera-shell.sh status --host <camera-uuid>
~/.claude/skills/tigerguard-camera-shell/camera-shell.sh stop --host <camera-uuid>
```

## Known Good Patterns

Use `send --wait` for most iterative commands because it:

- serializes command writes
- waits for command completion
- prints only that command's output block

Examples:

```bash
~/.claude/skills/tigerguard-camera-shell/camera-shell.sh send --host <camera-uuid> --wait 'systemctl status rant'
~/.claude/skills/tigerguard-camera-shell/camera-shell.sh send --host <camera-uuid> --wait 'journalctl -u rant -n 100'
~/.claude/skills/tigerguard-camera-shell/camera-shell.sh send --host <camera-uuid> --wait 'df -h /mnt/media'
~/.claude/skills/tigerguard-camera-shell/camera-shell.sh send --host <camera-uuid> --wait 'cat /etc/rant/config.toml'
```

For long-running commands or log followers, do not use `--wait` unless you also set a deliberate timeout.

Prefer `logs` over manually sending `tail -F /var/log/rant.log` into the main shell session.

Examples:

```bash
~/.claude/skills/tigerguard-camera-shell/camera-shell.sh logs --host <camera-uuid>
~/.claude/skills/tigerguard-camera-shell/camera-shell.sh logs --name cam-<camera-uuid>
```

## Timeouts

For commands that may stall, use:

```bash
~/.claude/skills/tigerguard-camera-shell/camera-shell.sh send --host <camera-uuid> --wait --timeout 10 'sleep 2'
```

If timeout expires, the helper reports failure and returns non-zero.

## File Locations And Behavior

The underlying helper stores session state under:

```text
/tmp/iroh-shell-sessions/<session-name>/
```

Important files:

- `in.fifo`: stdin for the remote shell
- `out.log`: combined stdout/stderr log
- `pid`: local background process PID
- `command.txt`: original start command
- `send.lock`: local serialization lock

Normal `tail` hides internal completion markers. The raw on-disk log may still contain them.

## Agent Guidance

When the user asks to connect to a camera, inspect logs on a camera, run iterative camera commands, or keep a shell alive through Tigerguard, and the target is a UUID-style host name rather than a raw IP address:

1. Prefer `~/.claude/skills/tigerguard-camera-shell/camera-shell.sh`.
2. Reuse an existing named session when practical.
3. Prefer `send --wait` for bounded commands.
4. Use `logs` for `/var/log/rant.log` streaming output.
5. Use `tail` for following an existing session log.
6. Avoid falling back to repeated raw `ssh root@<uuid> <cmd>` unless there is a specific reason.

## Verification Expectations

After editing or creating these helpers, verify with at least:

```bash
bash -n ~/.claude/skills/tigerguard-camera-shell/camera-shell.sh
~/.claude/skills/tigerguard-camera-shell/camera-shell.sh --help
```

When feasible, also verify against a live camera session with:

```bash
~/.claude/skills/tigerguard-camera-shell/camera-shell.sh start --host <camera-uuid> --name test-cam
~/.claude/skills/tigerguard-camera-shell/camera-shell.sh send --name test-cam --wait hostname
~/.claude/skills/tigerguard-camera-shell/camera-shell.sh stop --name test-cam
```
