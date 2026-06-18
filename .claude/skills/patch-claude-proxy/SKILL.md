---
name: patch-claude-proxy
description: Patch the claude-code binary to route Vertex API traffic through http://localhost:13128 proxy, scoped only to ANTHROPIC_VERTEX_BASE_URL traffic. Use when user says "patch claude", "apply proxy patch", "claude upgrade", or "patch claude.exe". Also handles copying the patched binary as a versioned backup.
---

# patch-claude-proxy

Patches the `claude.exe` SEA (Single Executable Application) binary in-place
so that Vertex API traffic is routed through `http://localhost:13128` **only**,
without affecting any other HTTPS traffic in the process.

## What the patch does

Replaces the proxy env-reader function (historically named `vp`, `rS`, or `PR`
depending on version) with a scoped version:

```js
// BEFORE
function PR(H=process.env){return H.https_proxy||H.HTTPS_PROXY||H.http_proxy||H.HTTP_PROXY}

// AFTER
function PR(){return process.env.ANTHROPIC_VERTEX_BASE_URL&&"http://localhost:13128"}
```

This function is the **single chokepoint** all proxy logic flows through
(`getProxyFetchOptions`/`s3`, `configureGlobalAgents`, etc.). When
`ANTHROPIC_VERTEX_BASE_URL` is not set, it returns `undefined` → direct
connection.

## Patch script location

`/home/kent/Project/Issues/claude_https_proxy/patch-claude.py`

Versioned backup binaries are stored in the same folder as
`claude-<version>-patched.exe`.

## Workflow

### Step 1 — Determine current binary state

```python
python3 /home/kent/Project/Issues/claude_https_proxy/patch-claude.py --verify
```

Output will be:
- `status : patched` → nothing to do
- `status : original` → ready to patch
- `status : unknown` → function was renamed in this version (see Step 3)

### Step 2 — Apply the patch (if status is "original")

```python
python3 /home/kent/Project/Issues/claude_https_proxy/patch-claude.py
```

### Step 3 — Handle "unknown" status (function renamed after upgrade)

Find the current function name:

```python
python3 -c "
import re
data = open('/home/kent/.nvm/versions/node/v20.19.3/lib/node_modules/@anthropic-ai/claude-code/bin/claude.exe','rb').read()
for m in re.finditer(rb'function \w+\(H=process\.env\)\{return H\.https_proxy\|\|H\.HTTPS_PROXY', data):
    print(repr(data[m.start():m.start()+150]))
"
```

Then update the `OLD`/`NEW` constants in `patch-claude.py` with the new function name:

```python
# Calculate correct padding
OLD_len = len(b'function XX(H=process.env){return H.https_proxy||H.HTTPS_PROXY||H.http_proxy||H.HTTP_PROXY}')
NEW_body = b'function XX(){return process.env.ANTHROPIC_VERTEX_BASE_URL&&"http://localhost:13128"}'
padding = OLD_len - len(NEW_body)
print(f'need {padding} spaces of padding')
```

Update `patch-claude.py` replacing `XX` with the actual function name found, and set padding accordingly.

### Step 4 — Copy patched binary as versioned backup

```bash
# Get version
VERSION=$(claude --version 2>/dev/null | awk '{print $1}')
cp /home/kent/.nvm/versions/node/v20.19.3/lib/node_modules/@anthropic-ai/claude-code/bin/claude.exe \
   /home/kent/Project/Issues/claude_https_proxy/claude-${VERSION}-patched.exe
```

## After every `npm update -g @anthropic-ai/claude-code`

1. Run `--verify` → if "original", patch directly
2. If "unknown", find the new function name, update `patch-claude.py`, then patch
3. Copy versioned backup

## Reverting

```python
python3 /home/kent/Project/Issues/claude_https_proxy/patch-claude.py --revert
```

## Key technical facts

- Binary: `~/.nvm/versions/node/v20.19.3/lib/node_modules/@anthropic-ai/claude-code/bin/claude.exe`
- The JS is embedded as a plain-text blob inside the ELF — **patch must be exact same byte length**
- The proxy function name has changed across versions: `vp` → `rS` → `PR` (track with `--verify`)
- Native `fetch()` (used by Vertex SDK) ignores `proxy`/`agent` fields; only `HTTPS_PROXY` env var works via undici's `EnvHttpProxyAgent`
- Patching `vp`/`rS`/`PR` scopes it without setting any global env vars
