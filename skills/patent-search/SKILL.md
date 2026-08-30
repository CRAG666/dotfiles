---
name: patent-search
description: Prior art patent search via Google Patents' JSON endpoint and Lens.org, with PDF download. Use when the user asks to search patents, prior art, "anterioridad", "patentes ancla", freedom-to-operate, novelty context, or patent landscaping. Covers query syntax, CPC filtering, date/status filters, anchor-patent matrices, and downloading patent PDFs.
---

# Patent Search (Google Patents + Lens.org)

## Google Patents — JSON endpoint (no key)

`https://patents.google.com/xhr/query?url=<ENCODED>&exp=`

`<ENCODED>` is a query string (`q=...&num=50&page=0...`) URL-encoded **twice** for the q value: encode the query text as a component, prepend `q=`, then encode the whole thing again as the `url` parameter value. In Python:

```python
inner = "q=" + urllib.parse.quote(query, safe="") + "&num=50&page=0"
full = "https://patents.google.com/xhr/query?url=" + urllib.parse.quote(inner, safe="") + "&exp="
```

Query syntax (same as patents.google.com search box):
- Juxtaposition = AND: `(wearable) (emotion)` · `OR` explicit · quoted phrases
- `CPC=A61B5/165` (classification; A61B5/165 = evaluating emotional/psychological state), `country:US`, `status:GRANT`, `type:PATENT`, `assignee:Empatica`, `inventor:...`
- Date params go in the inner query string, not in q: `&before=priority:20180101`, `&after=priority:20000101`, `&sort=new|old` (omit for relevance)
- For prior art searches do NOT lower-bound the date — anything published before the priority date counts.

Response: `.results.total_num_results` and `.results.cluster[].result[]`, each with `.patent.{publication_number,title,snippet,assignee,inventor,priority_date,filing_date,grant_date,publication_date,pdf,family_metadata}`. `num` caps at 100/page, `page` for paging. Titles/snippets carry `<b>` tags — strip them.

Retry with `curl --retry 5 --retry-delay 2 --retry-all-errors`; the endpoint throttles bursts.

## PDF download

`.patent.pdf` is a path relative to `https://patentimages.storage.googleapis.com/` — direct curl works, no challenge. Verify `%PDF` magic bytes. Name files `US1234567B2-assignee-slug.pdf`.

If the record lacks a pdf path, US grants are also served by `https://image-ppubs.uspto.gov/dirsearch-public/print/downloadPdf/<number>` (bare number, no US/kind code; verified working). The patent HTML page (`patents.google.com/patent/...`) 503-throttles after many requests — prefer the XHR endpoint or USPTO.

Full text/claims of one patent: `https://patents.google.com/patent/<PUBNUM>/en` (HTML, curl-friendly) — claims are in the `<section itemprop="claims">` block.

## Lens.org

The API (`https://api.lens.org/patent/search`) needs a Bearer token — free for individual scholarly use on request (lens.org/lens/user/subscriptions). If the user has `LENS_TOKEN`, POST `{"query": {...elastic DSL...}, "size": 50}`.

Without a token the SPA cannot be scraped: generate hand-off URLs instead, `https://www.lens.org/lens/search/patent/list?q=<urlencoded boolean query>`, and record them as manual-execution queries in the deliverable.

## Anchor matrix (prior art deliverable)

For each anchor candidate record: publication number, title, assignee, priority date, status (grant/application), jurisdiction, which claim concepts overlap the idea under evaluation, and a relevance note. Prefer granted patents with early priority; keep one member per family (note `family_metadata` siblings). Save the queries used (exact strings + hit counts + date) alongside the matrix for reproducibility.
