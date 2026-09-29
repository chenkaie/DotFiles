---
name: rebase-onto-target
description: Fetch origin and rebase the current branch onto its GitLab MR's target branch, then force-push. Use when the user asks to "rebase onto the target branch", "rebase onto origin", "sync this branch", or similar, without necessarily naming the target branch explicitly.
---

# Workflow

Step 1: Resolve the target ref. Do not guess a branch name from context or assume
`main`/`master`.

```bash
glab api "projects/:id/merge_requests/:iid" 2>/dev/null | python3 -c "import json,sys; print(json.load(sys.stdin)['target_branch'])"
```

If `glab api "projects/:id/merge_requests/:iid"` doesn't resolve directly (no `:id`/`:iid`
shorthand in this glab version), use `glab mr view --output json` for the current
branch instead and read `.target_branch` from that.

If there is no open MR for the current branch (fresh branch, not yet pushed as an
MR), stop and ask the user which branch to rebase onto — do not fall back to
`main`/`master` silently, and do not rebase onto the branch's own `@{upstream}`
(that usually just tracks the same-named remote branch, not the MR's actual
target, and silently rebasing onto the wrong ref is worse than asking).

Step 2: `git fetch origin`.

Step 3: If the working tree has uncommitted changes, stash them with a
descriptive message before rebasing:

```bash
git stash push -m "pre-rebase stash: <short reason>"
```

Do not discard uncommitted changes without stashing first, even if they look like
unrelated build-tool noise (e.g. a regenerated lockfile) — stash first, decide
what to do with the stash after the rebase succeeds (see Step 6).

Step 4: Rebase onto the resolved target:

```bash
git rebase origin/<target_branch>
```

Step 5: **On conflict — stop.** Do not resolve conflicts automatically. Report:

- Which commit(s) conflict and on which files.
- The conflicting hunks (`git diff` on each conflicted file).

Leave the repo in the mid-rebase state and ask the user how to proceed (resolve
manually, `git rebase --abort`, or take one side). Never force-push a
conflicted/aborted rebase state.

Step 6: If the rebase completes cleanly, restore the stash (if one was created in
Step 3):

```bash
git stash pop
```

If popping the stash itself conflicts, report that clearly and let the user
decide (drop it, resolve it, or keep it stashed) — do not silently drop a stash
that fails to pop cleanly.

Step 7: If the rebase was clean (and the stash, if any, popped or was handled per
Step 6), force-push:

```bash
git push --force-with-lease
```

Use `--force-with-lease`, never a bare `--force`. Invoking this skill by name
already carries the user's intent to push if the rebase is clean — do not ask
again before this push. Only stop and ask if Step 5 or Step 6 surfaced a problem.

Step 8: Report a short summary: the resolved target branch, the number of
commits carried over, whether a stash was involved and how it was resolved, and
the final push result (new remote SHA / "no-op, already up to date").

## Notes

- This skill is specifically for the common "keep my MR branch current with its
  target" rebase, not a general-purpose rebase tool. If the user names an
  explicit target branch directly in their request, use that instead of
  resolving it from the MR (skip Step 1 in that case).
- `--force-with-lease` (not `--force`) protects against clobbering someone else's
  push to the same branch that happened between your last fetch and this push.
  If the lease check fails, stop and report it — do not retry with a bare
  `--force` to push through it.
