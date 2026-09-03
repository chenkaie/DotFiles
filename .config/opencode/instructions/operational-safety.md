# Operational Safety and Context Management

These rules capture durable agent-workflow lessons that apply regardless of model vendor.

## Verification is required, not implied

- After editing files, run the smallest relevant verification before reporting completion.
- Prefer this order when applicable: `lsp_diagnostics` for touched files -> targeted tests -> typecheck -> lint -> build.
- If a requested check cannot be run, say so explicitly and report the blocking reason.
- Never imply success from a file write alone. A successful write only means bytes reached disk.

## Re-read before editing; do not trust stale context

- Before editing any file, read the current file contents in the same work session unless you just read them.
- In long or complex sessions, re-read the target files and their immediate dependencies before making another round of edits.
- Treat previous summaries, memory, and old tool output as hints, not ground truth.

## Large files must be read in chunks

- If a file is large, read it in multiple slices with `offset` and `limit` instead of assuming one read captured the whole file.
- For files above roughly 500 lines, use `grep` or `lsp_symbols` first to identify the relevant region, then read the surrounding sections.
- If a read result says the file ended, you may treat that slice sequence as complete. Otherwise keep reading until the relevant region is fully covered.

## Search output may be partial

- Treat grep, web, GitHub, and tool previews as potentially truncated unless they clearly show complete coverage.
- If results look unexpectedly sparse, refine the query, narrow the scope, paginate, or run a second search from another angle.
- Do not claim a search found "only" a small number of matches unless the tool output proves the search was complete.

## Separate exploration, execution, and verification

- Use read-only exploration first to understand the codebase and existing patterns before editing.
- When the task is non-trivial, split discovery, implementation, and verification into explicit phases.
- Keep the verifier mindset adversarial: try to falsify the change, not just confirm that it looks reasonable.

## Parallelize independent work

- When a task spans multiple independent files, modules, or search angles, launch parallel background agents and direct searches early.
- Use explore agents for internal codebase discovery and librarian agents for external docs or OSS examples.
- If more than 5 independent files or modules are involved, prefer decomposition over carrying the full task in one thread.

## GitLab interaction boundaries

- When fixing MR issues, make code changes and commit them. Do not push without explicit approval.
- Reply in the original inline thread for each comment you address, including what changed, the commit SHA, and the verification result.
- Resolving a thread you replied to is allowed. Resolve only threads actually addressed — fixed in code, or answered with concrete evidence.
- Do not resolve threads skipped as subjective or opinion-based unless the user says to.
- Never `approve`, `merge`, `close`, or `reopen` an MR on the user's behalf.
- Report what was fixed, what was skipped and why, and which threads were resolved.

## Keep instruction files high value

- Put reusable behavior rules here, not one-off task notes.
- Prefer concrete operational rules over vague preferences.
- When adding a new instruction, make the expected action and verification behavior explicit.
