---
name: mr-fix
description: Fix GitLab MR unresolved comments
---

# Workflow

Step 1: Run this command to get unresolved comments for a MR (script must be in `$PATH`):

```bash
glab-unresolved.sh <MR_URL>
```

Step 2: For each unresolved comment, evaluate and act:

- **Actionable code feedback** (bug, logic error, missing edge case, style violation, naming) → Fix it.
- **Question or clarification request** → Read the code to understand the context, then fix the underlying concern if one exists.
- **Subjective/opinion-based** (architecture preference, "I would do it differently") → Skip. Note it in your summary.
- **Already resolved by other changes** → Skip. Note it in your summary.

Step 3: Commit your fixes as a NEW commit (never amend HEAD). Group related fixes into a single commit when they address the same concern. Use this commit message format:

```
fix: address MR review feedback

- <brief description of each fix>
```

Step 4: After all comments are processed, print a summary:

```
## MR Review Fix Summary
- Fixed: <count> comments
  - <file:line> — <what was fixed>
- Skipped: <count> comments
  - <reason> — <comment excerpt>
```

Step 5: **ASK** for permission to push the new fix commit. Never treat a request to
run this skill as permission to push.

Step 6: After the user approves and the push succeeds, reply to every addressed
review comment in its original inline discussion/thread. Each reply must include:

- What changed to address that specific comment.
- The fix commit SHA.
- The relevant verification result.

Reply separately in each corresponding thread; do not replace these replies with
one top-level MR comment. For skipped comments, reply only when the user asks to
post the explanation.

Step 7: After replying in a thread, resolve that thread.

Resolve only threads you actually addressed — either fixed in code, or answered
with concrete evidence. Do NOT resolve threads you skipped as subjective or
opinion-based unless the user says to.

List unresolved threads and their IDs:

```bash
glab api "projects/<project_id>/merge_requests/<mr_iid>/discussions" --paginate \
  | jq -r '.[] | select(.resolvable==true and .resolved==false) | .id'
```

Resolve one thread:

```bash
glab api "projects/<project_id>/merge_requests/<mr_iid>/discussions/<discussion_id>" \
  --method PUT --field resolved=true
```

Notes:

- A `PUT` can time out at the client/MCP layer but still apply server-side.
  Re-check state before retrying; the call is idempotent, so a retry is safe.
- Remember to resolve any top-level discussion you created yourself — those also
  count against the MR's unresolved-thread gate.

Step 8: Verify, then report. Confirm every targeted thread now reports
`resolved: true`:

```bash
glab api "projects/<project_id>/merge_requests/<mr_iid>/discussions" --paginate \
  | jq -r '.[] | select(.resolvable==true)
           | "\(.resolved)\t\(.notes[0].position.new_path // "top-level")\t\(.notes[0].position.new_line // "-")"'
```

Report any thread that failed to resolve, and list threads left unresolved on
purpose along with the reason.

## Permissions

Bash commands allowed except:
- git push (any form) without explicit user approval - DENIED
- glab mr note/comment without explicit user approval - DENIED
- glab mr approve/merge/close/reopen/update - DENIED

Explicitly ALLOWED:
- Resolving discussions you replied to, via
  `glab api .../discussions/<id> --method PUT --field resolved=true`
