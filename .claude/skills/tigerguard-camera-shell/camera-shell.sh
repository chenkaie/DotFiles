#!/usr/bin/env bash

# README
#
# Purpose:
# - Keep one long-lived camera shell alive behind a local FIFO so commands can be
#   fed incrementally without reconnecting each time.
# - Use this when the remote target is a camera reachable with the normal local
#   workflow `ssh root@<uuid>` and that ssh path is transparently backed by a
#   ProxyCommand such as tigerguard/Iroh.
# - This script is self-contained. It does not rely on any separate helper.
#
# Mental model:
# - `start` launches one persistent remote `/bin/sh` in the background and
#   attaches its stdin to a named pipe.
# - `send` writes a command into that pipe.
# - `send --wait` appends a hidden completion marker after the command, waits for
#   that marker to appear in the log, and prints only that command's output.
# - `tail` follows the session log. By default it hides internal completion
#   markers. Use `tail --raw` to see the unfiltered log.
# - `logs` creates or reuses a dedicated `<session>-log` shell, starts
#   `tail -F /var/log/rant.log` inside it, and then attaches local tailing to
#   that log session so the main shell is not blocked.
#
# Defaults and naming:
# - `--host` is the camera UUID or host string used with `ssh root@<host>`.
# - If `--host` is omitted, the script falls back to `CAMERA_HOST`.
# - If `--name` is omitted, the session name becomes `cam-<host>` with unsafe
#   characters normalized to `_`.
# - For `status`, `tail`, `send`, and `stop`, you may provide only `--name` to
#   operate on an already-known session without repeating the host.
#
# Files created per session under `${TMPDIR:-/tmp}/iroh-shell-sessions/<name>/`:
# - `in.fifo`: stdin pipe for the long-lived remote shell
# - `out.log`: combined stdout/stderr log from the remote shell plus local send
#   annotations
# - `pid`: local PID of the background ssh process
# - `command.txt`: original start command used to create the session
# - `send.lock`: local flock file used to serialize sends
#
# Examples:
# - Start a session:
#   `~/.claude/skills/tigerguard-camera-shell/camera-shell.sh start --host 6a7cdff2-dda3-4f63-bed1-6877959b5ec2`
# - Send a command and wait for its output:
#   `~/.claude/skills/tigerguard-camera-shell/camera-shell.sh send --host 6a7cdff2-dda3-4f63-bed1-6877959b5ec2 --wait hostname`
# - Follow a running session by environment default:
#   `CAMERA_HOST=6a7cdff2-dda3-4f63-bed1-6877959b5ec2 ~/.claude/skills/tigerguard-camera-shell/camera-shell.sh tail`
# - Reuse an existing session by explicit name:
#   `~/.claude/skills/tigerguard-camera-shell/camera-shell.sh status --name tiger`
#
# Important behavior notes:
# - `send` calls are serialized with a local lock. Do not bypass the wrapper and
#   write directly into the FIFO if you also rely on `send --wait`.
# - The raw on-disk log intentionally keeps internal completion markers for
#   debugging. Normal `tail` output filters them.
# - `send --wait --timeout N <cmd>` fails if the completion marker does not show
#   up within N seconds.
# - Commands containing shell metacharacters may be rejected by one-shot remote
#   execution layers (for example tigerguard direct exec). Starting one remote
#   `/bin/sh` and then feeding commands through stdin avoids that limitation.

set -euo pipefail

SESSION_ROOT="${TMPDIR:-/tmp}/iroh-shell-sessions"
DEFAULT_HOST="${CAMERA_HOST:-}"

usage() {
  printf '%s\n' \
    "Usage:" \
    "  $0 start [--host UUID] [--name SESSION]" \
    "  $0 send [--host UUID] [--name SESSION] [--wait] [--timeout SEC] <command...>" \
    "  $0 tail [--host UUID] [--name SESSION] [--lines N] [--raw]" \
    "  $0 logs [--host UUID] [--name SESSION] [--lines N] [--raw]" \
    "  $0 status [--host UUID] [--name SESSION]" \
    "  $0 stop [--host UUID] [--name SESSION]" \
    "" \
    "Defaults:" \
    "  --host uses CAMERA_HOST when set" \
    "  --name defaults to cam-<host>" \
    "" \
    "Examples:" \
    "  $0 start --host 6a7cdff2-dda3-4f63-bed1-6877959b5ec2" \
    "  $0 send --host 6a7cdff2-dda3-4f63-bed1-6877959b5ec2 --wait hostname" \
    "  $0 logs --host 6a7cdff2-dda3-4f63-bed1-6877959b5ec2" \
    "  CAMERA_HOST=6a7cdff2-dda3-4f63-bed1-6877959b5ec2 $0 tail"
}

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

default_session_name() {
  local host="$1"
  printf 'cam-%s\n' "${host//[^A-Za-z0-9._-]/_}"
}

session_dir() {
  local name="$1"
  printf '%s/%s\n' "$SESSION_ROOT" "$name"
}

fifo_path() {
  local dir="$1"
  printf '%s/in.fifo\n' "$dir"
}

log_path() {
  local dir="$1"
  printf '%s/out.log\n' "$dir"
}

pid_path() {
  local dir="$1"
  printf '%s/pid\n' "$dir"
}

cmd_path() {
  local dir="$1"
  printf '%s/command.txt\n' "$dir"
}

lock_path() {
  local dir="$1"
  printf '%s/send.lock\n' "$dir"
}

log_size() {
  local log="$1"
  if [[ -f "$log" ]]; then
    wc -c < "$log"
  else
    printf '0\n'
  fi
}

print_log_delta() {
  local log="$1"
  local start_size="$2"
  local marker="$3"

  local start_byte=$((start_size + 1))
  tail -c "+${start_byte}" "$log" | while IFS= read -r line; do
    [[ "$line" == "$marker" ]] && continue
    printf '%s\n' "$line"
  done
}

wait_for_marker() {
  local log="$1"
  local marker="$2"
  local timeout_secs="$3"
  local waited=0

  while true; do
    if [[ -f "$log" ]] && grep -Fq "$marker" "$log"; then
      return 0
    fi

    if (( timeout_secs > 0 && waited >= timeout_secs * 10 )); then
      return 1
    fi

    sleep 0.1
    waited=$((waited + 1))
  done
}

read_pid() {
  local dir="$1"
  local pid_file
  pid_file="$(pid_path "$dir")"

  [[ -f "$pid_file" ]] || return 1

  local pid
  IFS= read -r pid < "$pid_file" || return 1
  [[ "$pid" =~ ^[0-9]+$ ]] || return 1
  printf '%s\n' "$pid"
}

session_running() {
  local dir="$1"
  local pid

  pid="$(read_pid "$dir")" || return 1
  kill -0 "$pid" 2>/dev/null
}

record_command() {
  local dir="$1"
  shift

  : > "$(cmd_path "$dir")"
  printf '%q ' "$@" >> "$(cmd_path "$dir")"
  printf '\n' >> "$(cmd_path "$dir")"
}

run_session() {
  local dir="$1"
  shift

  local fifo log
  fifo="$(fifo_path "$dir")"
  log="$(log_path "$dir")"

  exec 3<> "$fifo"
  printf '[local %(%Y-%m-%dT%H:%M:%S%z)T] session started\n' -1 >> "$log"
  exec "$@" <&3 >> "$log" 2>&1
}

resolve_session() {
  SESSION_HOST="$DEFAULT_HOST"
  SESSION_NAME=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --host)
        [[ $# -ge 2 ]] || die "missing value for --host"
        SESSION_HOST="$2"
        shift 2
        ;;
      --name)
        [[ $# -ge 2 ]] || die "missing value for --name"
        SESSION_NAME="$2"
        shift 2
        ;;
      --help|-h|help)
        usage
        exit 0
        ;;
      *)
        break
        ;;
    esac
  done

  if [[ -z "$SESSION_NAME" && -n "$SESSION_HOST" ]]; then
    SESSION_NAME="$(default_session_name "$SESSION_HOST")"
  fi

  REMAINING_ARGS=("$@")
}

start_session() {
  resolve_session "$@"
  set -- "${REMAINING_ARGS[@]}"
  [[ $# -eq 0 ]] || die "start does not accept extra arguments"

  [[ -n "$SESSION_HOST" ]] || die "missing --host and CAMERA_HOST is not set"
  [[ -n "$SESSION_NAME" ]] || die "could not derive session name"

  local dir fifo log pid_file pid
  dir="$(session_dir "$SESSION_NAME")"
  fifo="$(fifo_path "$dir")"
  log="$(log_path "$dir")"
  pid_file="$(pid_path "$dir")"

  mkdir -p "$SESSION_ROOT"
  mkdir -p "$dir"

  if session_running "$dir"; then
    pid="$(read_pid "$dir")"
    die "session '$SESSION_NAME' is already running with pid $pid"
  fi

  rm -f "$fifo"
  mkfifo "$fifo"
  : > "$log"
  record_command "$dir" ssh "root@${SESSION_HOST}" /bin/sh

  nohup "$0" __run "$dir" ssh "root@${SESSION_HOST}" /bin/sh >/dev/null 2>&1 &
  pid=$!
  printf '%s\n' "$pid" > "$pid_file"

  sleep 0.2
  if ! kill -0 "$pid" 2>/dev/null; then
    die "session '$SESSION_NAME' failed to start; inspect $log"
  fi

  printf 'started session %s\n' "$SESSION_NAME"
  printf '  pid: %s\n' "$pid"
  printf '  fifo: %s\n' "$fifo"
  printf '  log: %s\n' "$log"
}

send_session() {
  resolve_session "$@"
  set -- "${REMAINING_ARGS[@]}"

  local wait_for_output=0
  local timeout_secs=30
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --wait)
        wait_for_output=1
        shift
        ;;
      --timeout)
        [[ $# -ge 2 ]] || die "missing value for --timeout"
        [[ "$2" =~ ^[0-9]+$ ]] || die "--timeout must be an integer number of seconds"
        timeout_secs="$2"
        shift 2
        ;;
      *)
        break
        ;;
    esac
  done

  [[ $# -gt 0 ]] || die "missing command to send"
  [[ -n "$SESSION_NAME" ]] || die "missing --name and could not derive session name from host"

  local dir fifo log payload start_size marker token lock_file
  dir="$(session_dir "$SESSION_NAME")"
  fifo="$(fifo_path "$dir")"
  log="$(log_path "$dir")"
  lock_file="$(lock_path "$dir")"

  session_running "$dir" || die "session '$SESSION_NAME' is not running"
  [[ -p "$fifo" ]] || die "missing fifo for session '$SESSION_NAME'"

  payload="$*"
  exec 9> "$lock_file"
  flock 9

  printf '[local %(%Y-%m-%dT%H:%M:%S%z)T] $ %s\n' -1 "$payload" >> "$log"

  if (( wait_for_output )); then
    start_size="$(log_size "$log")"
    token="$$-$RANDOM-$(date +%s)"
    marker="__OPENCODE_SESSION_DONE__:${token}:0"
    {
      printf '%s\n' "$payload"
      printf "printf '__OPENCODE_SESSION_DONE__:%s:0\\n'\n" "$token"
    } > "$fifo"

    if ! wait_for_marker "$log" "$marker" "$timeout_secs"; then
      printf 'timed out waiting for command output after %ss\n' "$timeout_secs" >&2
      print_log_delta "$log" "$start_size" "$marker" >&2 || true
      flock -u 9
      exit 1
    fi

    print_log_delta "$log" "$start_size" "$marker"
    flock -u 9
    return 0
  fi

  printf '%s\n' "$payload" > "$fifo"
  flock -u 9
}

tail_session() {
  resolve_session "$@"
  set -- "${REMAINING_ARGS[@]}"

  local lines=50
  local raw=0
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --lines)
        [[ $# -ge 2 ]] || die "missing value for --lines"
        lines="$2"
        shift 2
        ;;
      --raw)
        raw=1
        shift
        ;;
      *)
        die "unknown tail argument: $1"
        ;;
    esac
  done

  [[ -n "$SESSION_NAME" ]] || die "missing --name and could not derive session name from host"

  local dir log
  dir="$(session_dir "$SESSION_NAME")"
  log="$(log_path "$dir")"
  [[ -f "$log" ]] || die "missing log for session '$SESSION_NAME'"

  if (( raw )); then
    exec tail -n "$lines" -F "$log"
  fi

  exec tail -n "$lines" -F "$log" | grep -v '^__OPENCODE_SESSION_DONE__:'
}

status_session() {
  resolve_session "$@"
  set -- "${REMAINING_ARGS[@]}"
  [[ $# -eq 0 ]] || die "status does not accept extra arguments"
  [[ -n "$SESSION_NAME" ]] || die "missing --name and could not derive session name from host"

  local dir pid
  dir="$(session_dir "$SESSION_NAME")"

  printf 'session: %s\n' "$SESSION_NAME"
  printf 'dir: %s\n' "$dir"

  if session_running "$dir"; then
    pid="$(read_pid "$dir")"
    printf 'state: running\n'
    printf 'pid: %s\n' "$pid"
  else
    printf 'state: stopped\n'
  fi

  if [[ -f "$(cmd_path "$dir")" ]]; then
    printf 'command: '
    while IFS= read -r line; do
      printf '%s\n' "$line"
    done < "$(cmd_path "$dir")"
  fi

  printf 'fifo: %s\n' "$(fifo_path "$dir")"
  printf 'log: %s\n' "$(log_path "$dir")"
}

stop_session() {
  resolve_session "$@"
  set -- "${REMAINING_ARGS[@]}"
  [[ $# -eq 0 ]] || die "stop does not accept extra arguments"
  [[ -n "$SESSION_NAME" ]] || die "missing --name and could not derive session name from host"

  local dir fifo pid
  dir="$(session_dir "$SESSION_NAME")"
  fifo="$(fifo_path "$dir")"

  if ! session_running "$dir"; then
    rm -f "$fifo" "$(pid_path "$dir")"
    printf 'session %s is already stopped\n' "$SESSION_NAME"
    return 0
  fi

  pid="$(read_pid "$dir")"
  if [[ -p "$fifo" ]]; then
    printf 'exit\n' > "$fifo" || true
  fi

  for _ in {1..20}; do
    if ! kill -0 "$pid" 2>/dev/null; then
      break
    fi
    sleep 0.1
  done

  if kill -0 "$pid" 2>/dev/null; then
    kill "$pid" 2>/dev/null || true
  fi

  rm -f "$fifo" "$(pid_path "$dir")"
  printf 'stopped session %s\n' "$SESSION_NAME"
}

logs_session() {
  resolve_session "$@"
  set -- "${REMAINING_ARGS[@]}"

  local lines=50
  local raw=0
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --lines)
        [[ $# -ge 2 ]] || die "missing value for --lines"
        lines="$2"
        shift 2
        ;;
      --raw)
        raw=1
        shift
        ;;
      *)
        die "unknown logs argument: $1"
        ;;
    esac
  done

  [[ -n "$SESSION_HOST" ]] || die "missing --host and CAMERA_HOST is not set"
  [[ -n "$SESSION_NAME" ]] || die "missing --name and could not derive session name from host"

  local base_name="$SESSION_NAME"
  local log_name="${base_name}-log"
  local log_dir
  log_dir="$(session_dir "$log_name")"

  if ! session_running "$log_dir"; then
    "$0" start --host "$SESSION_HOST" --name "$log_name"
    sleep 1
    "$0" send --name "$log_name" "tail -F /var/log/rant.log"
    sleep 0.2
  fi

  if (( raw )); then
    exec "$0" tail --name "$log_name" --lines "$lines" --raw
  fi

  exec "$0" tail --name "$log_name" --lines "$lines"
}

main() {
  [[ $# -gt 0 ]] || {
    usage
    exit 1
  }

  case "$1" in
    --help|-h|help)
      usage
      exit 0
      ;;
  esac

  local command="$1"
  shift

  case "$command" in
    start)
      start_session "$@"
      ;;
    send)
      send_session "$@"
      ;;
    tail)
      tail_session "$@"
      ;;
    logs)
      logs_session "$@"
      ;;
    status)
      status_session "$@"
      ;;
    stop)
      stop_session "$@"
      ;;
    __run)
      [[ $# -gt 1 ]] || die "internal error: __run requires a session dir and command"
      run_session "$@"
      ;;
    *)
      die "unknown command: $command"
      ;;
  esac
}

main "$@"
