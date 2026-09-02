---
name: paper-search
description: Search for academic papers by keyword, or look up a specific paper by DOI or OpenAlex ID. Powered by OpenAlex (250M+ works, free, no API key).
---

Search for academic papers and get details including title, authors, citation count, DOI, abstract, and open access links.

## Setup

Requires `bash`, `curl`, and `jq` (the scripts check and report missing ones).

The scripts live in `scripts/` inside this skill directory (the folder containing this SKILL.md). Resolve all paths relative to that skill directory, not the current working directory. Run them with `bash` so no executable bit is required:

```
bash <skill-dir>/scripts/search.sh ...
```

If the skill directory is unknown, locate it (covers the usual harness skill roots):

```
find ~/.claude ~/.agents ~/.pi/agent ~/.cursor ~/.codex -path "*paper-search/scripts/search.sh" 2>/dev/null | head -1
```

## Search by keyword

```
bash <skill-dir>/scripts/search.sh "query" [limit] [sort] [page]
```

- `limit`: results per page (default 10, max 200)
- `sort`: `relevance` (default), `cites`, or `date`
- `page`: page number for pagination (default 1)

## Look up a specific paper

```
bash <skill-dir>/scripts/paper.sh <DOI_URL or OpenAlex_ID>
```

- Accepts DOI URLs like `https://doi.org/10.3390/brainsci8020020`
- Or OpenAlex IDs like `W2789811475`
- Returns full details: authors, abstract, concepts, open access PDF link, related works

## Tips

- Use `relevance` (default) for topical searches, `cites` for landmark papers.
- Be specific with queries — "bilingual cognitive advantages executive function" beats "bilingualism brain".
- Use `paper.sh` to get the full abstract when search results show "Abstract: N/A".
- The `related_works` IDs from `paper.sh` can be fed back into `paper.sh` to explore the citation graph.
- When the user asks for scientific backing: search broadly first, pick the most relevant/cited papers, then use `paper.sh` for full details and cite as (Author, Year, Journal).
- Optionally set `PAPER_SEARCH_MAILTO` to an email address to join OpenAlex's polite pool (more stable rates).
