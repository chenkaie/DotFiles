---
name: mr-wrapup
description: Wrap up a GitLab MR — build, deploy & verify on device(s), then generate/update the MR description with full documentation.
---

You are a wrap-up agent. The user wants to finalize an MR.

Optional arguments: `$ARGUMENTS` (MR number override, e.g. `/mr-wrapup 71`).
If no argument is given, auto-detect the open MR for the current branch via `glab mr view`.

---

## PHASE 1 — UNDERSTAND CHANGES

1. Run `git log <base-branch>..HEAD --oneline` to list all commits on this branch.
2. Run `git diff <base-branch>..HEAD --stat` to see which files changed.
3. Read the full diff (`git diff <base-branch>..HEAD`) to understand what was added, removed, or modified.
4. Run `glab mr view [MR_NUMBER]` to read the current MR title, description, and any review comments.
5. Identify the change categories present (schema, API, build tooling, tests, config, etc.) — only document sections that are actually relevant.

---

## PHASE 2 — DOCUMENTATION BUILD CHECK (camera-build repo)

Applies specifically to the **camera-build** repo (detect via `scripts/activate-docs-env` +
`mkdocs.yml` at repo root). Skip this phase entirely for other repos (bartleby, rant, ...)
that don't have this tooling.

Run this whenever the branch touches any `docs/**/*.md` file — check with
`git diff <base-branch>..HEAD --name-only | grep '^docs/'` — even if the MR is primarily a
code change with incidental doc updates. CI's `build-docs` job runs the same checks and will
hard-fail the pipeline if skipped; catching it locally first is much faster than a
round-trip through CI.

1. Activate the docs environment once per shell (creates/reuses a local `.docs.venv`):
   ```bash
   source scripts/activate-docs-env
   ```
2. Run the same check CI runs:
   ```bash
   docs-check
   ```
   This runs, in order: Prettier formatting check, markdownlint, and a **strict-mode**
   `mkdocs build` (warnings are fatal in strict mode — a clean build with 0 warnings is
   required, not just 0 errors).
3. **If Prettier/markdownlint report issues** (most common: `MD060/table-column-style` —
   Markdown table pipes not aligned to the style markdownlint expects): run the auto-fixer,
   then re-check:
   ```bash
   docs-format
   docs-check
   ```
4. **If the strict `mkdocs build` step aborts** with `Doc file '...' contains a link '...',
   but the target '...' is not found among documentation files` — this is a structural issue,
   not a formatting one, and `docs-format` will not fix it. The near-universal cause in this
   repo: **a Markdown link pointing outside `docs/` to a source file** (a `.bb`/`.bbappend`
   Yocto recipe, a `.rs`/`.py` source file, etc.). MkDocs's strict link validator only
   resolves links against files it tracks inside `docs_dir` (`docs/`) — a relative link that
   walks up and out of `docs/` into `yocto/`, `src/`, etc. will **always** report "target not
   found," no matter how many `../` segments are used. Adjusting the `../` count does not fix
   it (this looks like an off-by-one path bug but isn't one — don't waste time recalculating
   relative depth).
   - **Fix**: remove the hyperlink; use a plain backtick-quoted path instead. Same
     information for the reader, no broken link, and it survives any future MkDocs
     `docs_dir`/`use_directory_urls` config changes.
     ```diff
     - [`foo.bb`](../../../yocto/meta-vivint-camera-lite/recipes-core/foo.bb)
     + `yocto/meta-vivint-camera-lite/recipes-core/foo.bb`
     ```
5. Repeat steps 3-4 and re-run `docs-check` until it passes with **0 errors and 0 warnings**
   before proceeding to Phase 6 (create/update the MR). A doc-only fix belongs in its own
   small commit/diff, not silently folded into an unrelated code commit.

---

## PHASE 3 — BUILD

1. Determine the build command from project context (e.g. `echo ./build.sh | ./shell.sh` for bartleby).
2. Run a **release** (stripped) build.
3. Locate the output binary (typically `artifacts/<version>/aarch64/bartleby-aarch64` or `target/aarch64-unknown-linux-gnu/release/<binary>`).
4. If the build fails, stop here and report the errors — do not proceed to deploy.

---

## PHASE 4 — DEPLOY & VERIFY

For each configured device:

1. Stop the service (`systemctl stop <service>`).
2. SCP the binary to the correct deploy path.
   - Note: some devices use a symlink target (e.g. `bartleby.fix`) — deploy to the real file, not the symlink.
   - Note: if the root filesystem is full, deploy to `/mnt/media/usr/bin/` instead.
3. Start the service (`systemctl start <service>`).
4. Wait ~15 seconds for startup.
5. Check `systemctl is-active <service>` **3 times**, ~10 seconds apart.
6. After each check, grab the last 5 journal lines (`journalctl -u <service> -n 5 --no-pager`) to confirm no crash loop or fatal errors.
7. Record: device IP, pass/fail for each of 3 checks, PID stability, any notable log lines.

If any device fails 2+ checks or shows a crash loop, stop and report before updating the MR.

---

## PHASE 5 — PROJECT-SPECIFIC VERIFICATION

After confirming the service is healthy, run any project-specific sanity checks that are relevant to the changes:

- For database schema changes: query the relevant tables to confirm correct structure and data.
- For API changes: exercise the changed endpoints or methods if feasible via SSH.
- Document the actual output observed.

---

## PHASE 6 — GENERATE MR DESCRIPTION

Write a comprehensive MR description. Only include sections that apply to the actual changes.

### Structure

```
## Summary
One or two sentences: what this MR does and why.

## Motivation
Why was this change needed? What problem does it solve?
Skip if obvious from Summary.

## Schema  (if DB tables/indexes/triggers changed)
DDL with comments explaining the design decisions.
Explain the purpose of each constraint, index, and trigger.

## State Lifecycle  (if a state machine was introduced/changed)
ASCII diagram + table showing each state and the exact transition condition.

## Public API  (if public methods/functions were added or changed)
Table of new/changed methods with a one-line description each.

## Integration  (if application code in main.rs / entry point changed)
Prose describing where in the startup/shutdown flow new code runs.

## Legacy / Migration Handling  (if backwards compat or data migration logic was added)
Explain the one-time / idempotent logic and guards.

## Build Improvements  (if build tooling changed)
List the new gates (fmt, deny, clippy, etc.) and any dependency bumps with rationale.

## Sample Queries / Outputs  (for DB or observable outputs)
Show the actual commands and representative output for each meaningful case.

## Test Steps
- Unit test command (exact shell command)
- Integration test steps (stop → mutate → start → verify, with exact commands)
- Build & deploy commands (with correct paths for this build)

## Verification (YYYY-MM-DD)
Table of devices × 3 checks with active/failed status.
Note PID stability and any notable observations.
Notable log output if relevant.

Closes <JIRA-TICKET>
```

### Rules for the description
- Use precise, technical language — no marketing fluff.
- Show actual observed output (real timestamps, real row data) not made-up examples.
- Every command must be copy-pasteable and use the correct paths for this build version.
- If a section doesn't apply, omit it entirely — don't write placeholder text.
- Keep the `Closes <TICKET>` line at the bottom.

---

## PHASE 7 — UPDATE THE MR

1. Run `glab mr update <MR_NUMBER> --description "$(cat <<'EOF' ... EOF)"` with the generated description.
2. Confirm the update succeeded.
3. Print the MR URL.

---

## DELIVERY CHECKLIST

Before finishing, confirm:
- [ ] (camera-build repo, if `docs/**/*.md` changed) `docs-check` passes with 0 errors and 0 warnings
- [ ] Build succeeded (release binary, not debug)
- [ ] All devices passed 3/3 checks
- [ ] No crash loops or fatal errors observed
- [ ] MR description updated with accurate, copy-pasteable content
- [ ] Observed outputs in the description match what was actually seen on device
- [ ] `Closes <TICKET>` line present
- [ ] MR URL printed for the user

## Permissions

Bash commands allowed except:
- git push --force (any form) - DENIED
- glab mr merge/close/delete - DENIED
