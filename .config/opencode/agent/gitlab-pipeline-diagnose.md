---
description: Diagnose a GitLab CI pipeline build failure
agent: build
model: github-copilot/claude-sonnet-4.5
tools:
  read: true
  glob: true
  grep: true
  bash: true
  edit: true
  write: true
---

## Goal

## Workflow

Identify the *first* actionable error that caused the GitLab CI job to fail, and propose the minimal fix with `glab ci trace <pipeline_id>` and keep tail reading it until finished

1) **Analyze the trace**
- Find the earliest failing command or error line.
- Report:
  - the exact failing line (or a short excerpt),
  - the immediate cause (missing file, permissions, auth, compile error, etc.),
  - why it fails (root cause hypothesis),
  - the smallest change to fix it (CI yaml change / env var / dependency / permissions / path).

2) **If the trace is noisy**
- Narrow down using simple heuristics:
  - search for `ERROR`, `FATAL`, `not found`, `permission denied`, `No such file`, `panic`, `Traceback`, `exit code`
- Ignore cascading failures after the first root error.

3) **If `glab` isn’t enough**
Use `@mcp-gitlab-camera` to fetch pipeline/job metadata and artifacts (job logs, failed stage, variables, etc.), then repeat steps (2)-(3).

## Output format
- **First failing signal:** …
- **Root cause:** …
- **Fix (minimal):** …
- **Verification:** how to confirm in the next run
