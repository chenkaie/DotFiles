---
name: atlassian-summarize
description: Search Atlassian Confluence and Jira for content matching a keyword or statement, then produce a structured summary of all relevant findings
---

## What I Do

Given a keyword, topic, or natural language statement from the user, I:

1. Search Confluence and Jira using `atlassian_searchAtlassian` with the provided query
2. Fetch full content for the top 3–5 most relevant results
3. Run follow-up searches with refined or related terms if initial results are sparse
4. Synthesize everything into a clean, structured summary

---

## Workflow

### Step 1 — Broad Search

Use `atlassian_searchAtlassian` with the user's keyword or statement verbatim as the query.
Run multiple searches in parallel when the topic has multiple angles (e.g., "watchdog hardware" and "watchdog software").

### Step 2 — Fetch Full Content

For **Confluence pages**: call `atlassian_getConfluencePage` with `contentFormat: "markdown"`.
For **Jira issues**: call `atlassian_getJiraIssue` or `atlassian_fetchAtlassian` with the ARI from search results.
Fetch the top results in parallel to minimize latency.

### Step 3 — Follow-Up Searches (if needed)

If initial results are too broad, too narrow, or reveal related subtopics, run 1–2 additional
`atlassian_searchAtlassian` calls with refined terms derived from the first pass
(e.g., a component name, subsystem name, or related feature discovered in the results).

### Step 4 — Produce the Summary

Organize the output with the following structure:

```
## Summary: <keyword or statement>

### Key Findings
- Bullet-point distillation of the most important facts across all sources

### Sources Found
| Title | Type | URL |
|-------|------|-----|
| ...   | Page | ... |

### Detailed Breakdown
#### <Source Title>
- Core content summary (3–8 bullet points)
- Decisions, action items, or open questions recorded in this source

### Gaps / Open Questions
- Anything the sources did not answer or that appears unresolved
```

---

## Rules

- **Always** use `atlassian_searchAtlassian` as the primary search tool unless the user explicitly
  says "use CQL" or "use JQL" — in that case use `atlassian_searchConfluenceUsingCql` or
  `atlassian_searchJiraIssuesUsingJql` instead.
- Fetch page/issue content in **markdown** format for cleaner output.
- Run independent fetches and searches **in parallel** to maximize efficiency.
- Prefer **depth** (full page content) over breadth (many shallow snippets).
- If the search returns both Confluence pages and Jira issues, cover both in the summary.
- Do not invent or guess URLs. Only link to URLs returned by the Atlassian tools.
- Keep the summary factual and objective — do not editorialize beyond what the sources say.

---

## When to Use Me

Load this skill when the user asks to:

- "summarize everything about `<topic>` in Confluence"
- "collect all Atlassian info on `<keyword>`"
- "what do we know about `<statement>` across Jira and Confluence"
- "gather and summarize `<topic>` from Atlassian"
