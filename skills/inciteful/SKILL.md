---
name: inciteful
description: Citation-network literature discovery via Inciteful (incitefulmed.com/academic). Find similar papers, key papers by PageRank, reviews, top authors/institutions/journals around seed papers, and shortest citation paths between two papers. Free, no API key.
---

Discover academic literature through citation-network analysis instead of keyword matching alone. Inciteful builds a citation graph around one or more seed papers and ranks the network by similarity (co-citation + Adamic-Adar), PageRank, and recency. IDs are OpenAlex IDs, so results interop with the `paper-search` skill (use its `paper.sh` for abstracts, which Inciteful does not return).

## Setup

Requires `bash`, `curl`, and `jq` (the scripts check and report missing ones).

The scripts live in `scripts/` inside this skill directory (the folder containing this SKILL.md). Resolve all paths relative to that skill directory, not the current working directory. Run them with `bash` so no executable bit is required:

```
bash <skill-dir>/scripts/search.sh ...
```

If the skill directory is unknown, locate it (covers the usual harness skill roots):

```
find ~/.claude ~/.agents ~/.pi/agent ~/.cursor ~/.codex -path "*inciteful/scripts/search.sh" 2>/dev/null | head -1
```

## Workflow

1. `search.sh` → find the seed paper(s) and grab their OpenAlex IDs (or pass DOIs anywhere IDs are accepted).
2. `discover.sh` → analyze the citation network around the seeds.
3. Iterate: add promising papers from the results as extra seeds (comma-separated) to sharpen the network.
4. `connect.sh` when bridging two fields, `export.sh` to collect references.

## Search papers by keyword

```
bash <skill-dir>/scripts/search.sh "query" [limit]
```

Fast title search returning id, DOI, authors, journal, and citation count.

## Analyze the network around seed papers

```
bash <skill-dir>/scripts/discover.sh <id1[,id2,...]> [analysis] [limit] [min_year] [max_year] ["keywords"]
```

- `analysis`: `similar` (default), `important`, `reviews`, `recent`, `authors`, `upcoming`, `institutions`, `journals`
- Seeds accept OpenAlex IDs, bare DOIs, or DOI URLs (resolved via OpenAlex).
- The recommendation from Inciteful: add at least 3–5 seeds for a well-focused network.
- Use `keywords` (e.g. `"heart rate variability"`) to filter network papers by title match when results feel off-topic.

Analysis semantics:

| Analysis | Surfaces |
|---|---|
| `similar` | papers citing the same literature as the seeds (biases newer) |
| `important` | highest PageRank in the network (biases seminal older works) |
| `reviews` | papers citing the most network papers (likely reviews/surveys) |
| `recent` | most important papers from the last 3 years |
| `authors` / `upcoming` | top authors by partial PageRank / new authors (< 10 years) |
| `institutions` / `journals` | top institutions and journals for the field |

## Look up a paper

```
bash <skill-dir>/scripts/paper.sh <OpenAlex_ID or DOI>
```

Returns authors with institutions, PDF links, and samples of its references and citations.

## Connect two papers (Literature Connector)

```
bash <skill-dir>/scripts/connect.sh <from> <to> [extend]
```

Finds shortest citation paths between two papers. Use `extend=5` if no path is found initially (slower).

## Run raw SQL on the network

```
bash <skill-dir>/scripts/query.sh <ids> "SELECT ..."     # or a .sql file
```

Tables: `papers(paper_id, doi, title, authors, journal, published_year, num_cited_by, num_citing, adamic_adar, cocite, page_rank, distance)` and `authors(paper_id, name, affiliation, partial_page_rank, ...)`, plus `title_search('kw')`. `distance` = 0 for seeds, 1 for their direct neighbors. Examples: papers citing 50+ network papers (`reviews` logic), most-cited papers excluding the seeds, author overlap between fields.

## Export citations

```
bash <skill-dir>/scripts/export.sh <id1[,id2,...]> [bib|ris]
```

## Tips

- Queries build a live citation graph server-side; allow 5–60 s for `discover.sh`/`query.sh`.
- For a literature review: `search.sh` → `discover.sh similar` and `important` → add 3–5 of the best papers as seeds → `reviews` + `recent` → `export.sh ... bib`.
- No abstracts from Inciteful; feed IDs into the `paper-search` skill for abstracts and full metadata.
