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

Step 5: **ASK** to push changes or post comments to GitLab. This will be done manually.

## Permissions

Bash commands allowed except:
- git push (any form) - DENIED
- glab mr note/comment/approve/merge/close/reopen/update - DENIED
