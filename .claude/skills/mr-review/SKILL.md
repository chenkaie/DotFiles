---
name: mr-review
description: Quick GitLab MR review — checkout, analyze the diff, fix confirmed issues locally, and (after asking permission) publish concise inline findings with suggested patches.
---

# Quick MR Code Review

Lightweight review of a GitLab MR. Checks out the branch, analyzes the diff, fixes issues directly in source, and — after asking the user for permission — publishes confirmed findings as inline GitLab discussions. Uses the authenticated `glab` CLI.

> For comprehensive workflows (resolving reviewer comments or git commit/rebase help), use the `gitlab-review-kiran` agent instead.

## Workflow

### Step 0: Validate repo context (bail out if wrong repo)

This step is **mandatory** when a full GitLab URL is given. A bare MR ID (e.g. `!42`) skips this check.

**Parse the project namespace from the URL argument:**

Given `https://gitlab.com/NAMESPACE/PROJECT/-/merge_requests/ID`, extract `NAMESPACE/PROJECT`.

**Get the current repo's project path from glab (no raw `git` calls):**

```bash
glab repo view --output json --jq .path_with_namespace
# → company/camera/camera-build
```

This returns the bare `NAMESPACE/PROJECT` path directly. Do not use `git remote get-url`, `git status`, or `git branch` for this step. Use `glab` for all repo/MR context (see "Use glab, not raw git" below).

**Compare the two project paths:**

- If they **match** → proceed to Step 1.
- If they **do not match** → **STOP IMMEDIATELY** and output:

```
❌ Repo mismatch detected.

  MR URL project : company/camera/camera-soc-yocto
  Current repo   : company/camera/camera-build

Please cd into the correct repository before running this command.
  cd /path/to/camera-soc-yocto
```

Do **not** continue past this point if there is a mismatch.

---

### Step 1: Identify the MR

Parse the MR ID or URL from `$ARGUMENTS`. If not provided, detect the open MR for the current branch.

```bash
glab mr view <MR_ID>
```

### Step 2: Checkout the MR branch

**2a. Preflight the git protocol.** `glab mr checkout` does not fetch through `origin`. It builds its own fetch URL from glab's `git_protocol` setting. An SSH `origin` does not help if glab is set to HTTPS. A per-host value in `~/.config/glab-cli/config.yml` (`hosts: <host>: git_protocol`) overrides the global value.

```bash
glab config get git_protocol --host <host>     # must print "ssh"
```

If it prints `https`, git needs HTTPS credentials for the fetch. `GITLAB_TOKEN` is used by glab only, not by git, and glab (as of v1.114) has no git credential helper. Unless a `credential.helper` is configured, git will prompt for a username. Do not run the checkout in that state. Tell the user and offer to run `glab config set git_protocol ssh --host <host>`. Change the config only after the user approves. Check that SSH works with `ssh -o BatchMode=yes -T git@<host>`.

**2b. Check out non-interactively.** Run the checkout through Bash, with prompts disabled and a timeout. Do not use the `glab_mr_checkout` MCP tool, because it has no way to disable prompts. If git prompts inside that tool, it hangs until the request times out.

```bash
GIT_TERMINAL_PROMPT=0 GIT_SSH_COMMAND="ssh -o BatchMode=yes" timeout 120 glab mr checkout <MR_ID>
```

Confirm that `git log -1 --format=%H` matches `diff_refs.head_sha` from Step 1.

If `glab mr checkout` fails, **do not fall back to raw `git fetch` / `git checkout -b` / `git log`**. Those commands can trigger interactive credential prompts, and they bypass glab's authentication. Instead:

1. Report the exact error to the user. `could not read Username for 'https://...'` or `Authentication failed` means the protocol is HTTPS (see 2a). Offer to switch it to SSH, then retry.
2. Meanwhile, continue the review read-only through the API. This needs no local checkout:

```bash
glab mr view <MR_ID> --output json --jq '.diff_refs'          # base_sha / head_sha
glab mr diff <MR_ID> --color=never                             # full diff
glab api "projects/:id/merge_requests/<MR_ID>/commits"         # commit list (replaces git log base..head)
glab api "projects/:id/merge_requests/<MR_ID>/diffs?per_page=100"   # per-file diffs / stat (replaces git diff --stat)
glab api "projects/:id/repository/files/<url-encoded-path>/raw?ref=<head_sha>"   # full source at MR head, for context
```

Step 5 (local fixes) needs a real checkout. If checkout is unavailable, record fixes as proposed diffs in the findings instead of editing files.

### Step 3: Analyze the diff

```bash
glab mr diff <MR_ID> --color=never
```

Read the full diff **and** surrounding source files for context — don't review the diff in isolation.

### Step 4: Review for issues

Prioritize by impact:

| Priority     | Category       | Examples                                                   |
|--------------|----------------|------------------------------------------------------------|
| 🔴 Critical  | Security       | Injection, exposed secrets, unsafe operations              |
| 🔴 Critical  | Bugs           | Logic errors, null handling, off-by-one, race conditions   |
| 🟠 High      | Error handling | Missing checks, silent failures, unhandled edge cases      |
| 🟡 Medium    | Performance    | Inefficient loops, unnecessary allocations, blocking calls |
| 🟡 Medium    | Code quality   | Duplication, excessive complexity, poor naming             |
| 🟢 Low       | Style          | Typos, formatting, minor readability improvements          |

### Step 5: Fix issues in the source code

For each fix:

1. Read surrounding context and related call sites before editing
2. Make the minimal change that addresses the issue
3. Verify with diagnostics on changed files

### Step 6: Publish inline findings

Before posting, fetch all existing MR discussions (`glab api projects/:id/merge_requests/:iid/discussions --paginate`) and compare their file, line, title, and substance against the confirmed findings. Do not post a duplicate even if an existing discussion is resolved or outdated.

**ASK before posting.** Once the confirmed findings (and any fixes) are ready, present the list of intended comments (file:line + one-line summary of each finding, and whether a fix/diff is attached) and ask the user to confirm before creating any inline comments. Do not post anything until the user explicitly approves. If the user approves only a subset, post only those.

Always use `glab mr note create` (or the equivalent `mr_note_create` tool) for every comment, anchored or not. **Never use `glab mr note --message`** — it is deprecated and has been observed to print a plausible-looking `#note_<id>` URL for a note that was never actually created server-side (see Step 6b). If a top-level, non-anchored comment is needed, call `mr_note_create` with no `file`/`line`/`reply` — do not fall back to the deprecated command.

For every confirmed issue, post one comment (or a small reply thread, see below) that includes:

1. **Impact statement**: the concrete impact and the exact condition that triggers it.
2. **A real diff, always** — not just a prose description or an inline code snippet. Generate it from the actual change (`git diff -- <file>` for a fixed issue, scoped to the relevant hunk) and paste it as a fenced ` ```diff ` block. This applies whether or not the fix is representable as a single-line GitLab `suggestion`.
3. **A GitLab `suggestion` block in addition**, only when the whole fix is safely expressible as one contiguous range in one file. Skip it (diff-only) when the fix spans multiple functions, files, or call sites — an isolated `suggestion` applied there would leave the tree in a broken/incomplete state.
4. For a **confirmed-but-unfixed** issue (needs author input, too invasive for a same-session drive-by, etc.), still post the impact + suggested direction, but explicitly state **"No diff attached — not fixed"** so the reviewer isn't left guessing whether a patch exists.
5. Do not post speculative findings, subjective style preferences, or issues that require an unverified assumption.
6. Keep related symptoms and fixes in one discussion rather than posting several top-level comments for the same root cause — if a fix cascades into a second file (e.g. a signature change), reply in the same discussion thread noting the second file's diff and that the two must move together, rather than opening a new discussion for it.

If a confirmed issue cannot be anchored to a changed line (the file isn't part of this MR's diff at all, e.g. a dependency that should have been updated alongside it), do not silently skip it: post it as a top-level `mr_note_create` comment (no `file`/`line`) with the same impact + diff format, and note in the final summary that it was posted as a general comment rather than an inline one, with the reason.

### Step 6b: Verify every comment actually landed

Tool-reported URLs are not proof of success — confirm each note exists before including it in the summary or trusting it in a later reply:

```bash
glab api "projects/:id/merge_requests/:iid/notes" --paginate | python3 -c "
import json, sys
ids = {n['id'] for n in json.load(sys.stdin)}
print([i for i in EXPECTED_IDS if i not in ids])   # should be empty
"
```

If a note is missing despite a reported success URL, re-post it via `mr_note_create` (never retry with the deprecated `--message` path) and re-verify.

Record the URL of every discussion/note confirmed to exist.

### Step 7: Report summary

```
## MR Review Summary

**MR**: !<MR_ID> — <title>
**Branch**: <source> → <target>

### Fixed (<count>)
- `<file>:<line>` — <what was fixed and why>

### Noted but not fixed (<count>)
- <description> — <reason skipped (subjective, out of scope, needs discussion)>

### Inline comments posted (<count>)
- `<file>:<line>` — <brief finding> — diff attached: yes/no — <discussion URL>

### Not posted (<count>)
- <finding> — <duplicate or speculative — not "no changed-line anchor": those go as general comments instead, see Step 6>

### Clean areas
- <areas reviewed that looked good>
```

## Rules

- **Use glab, not raw git**, for repo identity, fetching, checkout, commit lists, and diffs: `glab repo view`, `glab mr view`, `glab mr checkout`, `glab mr diff`, `glab api`. Raw `git fetch` / `git checkout` / `git log <range>` / `git remote` can prompt for credentials interactively, so do not use them. Always run `glab mr checkout` with `GIT_TERMINAL_PROMPT=0` and a timeout after the Step 2a protocol preflight, never through the MCP checkout tool. If glab checkout fails, follow the Step 2 fallback, which reviews through the API without prompting. Local-only `git diff -- <file>` on your own uncommitted fixes (Step 6) is still fine.
- **ASK** before posting any inline finding to GitLab — present the intended comments first and wait for explicit approval; the skill invocation does not by itself authorize posting
- Every confirmed finding gets a real diff attached (fixed) or an explicit "not fixed, no diff" note (unfixed) — never just prose. See Step 6.
- Always post via `mr_note_create` / `glab mr note create`; never `glab mr note --message` (deprecated, can silently no-op while reporting a fake success URL)
- Always verify posted notes exist via the notes/discussions API (Step 6b) before reporting their URLs
- A missing diff line (file not in the MR's diff) is not a reason to skip a finding — post it as a general comment instead
- **ASK** before pushing changes to GitLab
- **ASK** to amend existing commits — fixes stay as unstaged changes for the user to review
- Fix bugs and clear issues; skip subjective style preferences
- When unsure if something is a bug, read the surrounding code and tests before deciding
- Group related fixes when they address the same concern
- Never resolve existing discussions unless the user explicitly requests it

## Permissions

Bash commands allowed except:
- git push (any form) - DENIED
- glab mr approve/merge/close/reopen/update - DENIED

Creating inline MR discussions/comments for confirmed findings requires asking the user first (Step 6) — do not post without explicit approval. Updating a comment created during the current review is allowed only to correct formatting or factual mistakes.
