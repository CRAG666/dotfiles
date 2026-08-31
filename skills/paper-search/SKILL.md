---
name: paper-search
description: Search high-quality scientific papers via the OpenAlex API and download their open-access PDFs. Use when the user asks to find, search, review, or download scientific papers, articles, literature, "papers científicos", "artículos", "literatura", state of the art, or citations on a topic. Covers filtering by citations, year, open access, journal quality (DOAJ/core), and downloading PDFs with fallbacks.
---

# Paper Search (OpenAlex)

Search scholarly works with the OpenAlex REST API (free, no key) and download open-access PDFs. Run everything with curl + jq via Bash.

## Search

Base endpoint: `https://api.openalex.org/works`

Always append `&mailto=eduardorodolfo1@gmail.com` (polite pool: faster, more reliable).

Core parameters:
- `search=<terms>` — relevance search over title, abstract, and fulltext. URL-encode spaces as `%20`.
- `filter=` — comma-separated AND conditions:
  - `is_oa:true` — only open access (required if the goal is downloading)
  - `cited_by_count:>N` — citation floor (quality proxy; scale to field and recency)
  - `from_publication_date:YYYY-MM-DD` / `to_publication_date:YYYY-MM-DD`
  - `type:article` — exclude editorials, datasets, paratext
  - `primary_location.source.is_in_doaj:true` — indexed in DOAJ (quality signal for OA journals)
  - `primary_location.source.is_core:true` — CORE journal list (stronger quality signal)
  - `language:en` (or `es`)
  - `title_and_abstract.search:<terms>` — as a filter, when fulltext matches are too noisy
- `sort=cited_by_count:desc` — most cited first; omit for relevance order (default when `search` is used). `relevance_score:desc` is explicit relevance.
- `per-page=25` (max 200), `page=N`
- `select=id,doi,title,publication_year,cited_by_count,type,primary_location,best_oa_location,open_access,authorships` — keeps responses small

Example — top-cited OA papers since 2020:

```
curl -s 'https://api.openalex.org/works?search=TERMS&filter=is_oa:true,type:article,cited_by_count:%3E50,from_publication_date:2020-01-01&sort=cited_by_count:desc&per-page=25&select=id,doi,title,publication_year,cited_by_count,best_oa_location,primary_location&mailto=eduardorodolfo1@gmail.com'
```

Note: `%3E` is the URL-encoded `>`. Single-quote the URL (zsh globs `?` and `&`).

Present results to the user as a compact list: title, first author, year, venue, citations, DOI. Ask or infer which to download.

## Quality heuristics

- High citations relative to age (a 2024 paper with 100 citations outranks a 2010 paper with 300).
- `best_oa_location.version == "publishedVersion"` beats `submittedVersion` (preprint).
- Venue with `is_in_doaj: true` or `is_core: true`; be skeptical of repository-only sources for "high quality" requests.
- For recent/emerging topics, drop the citation floor and sort by relevance instead.

## Download

For each selected work, try in order:

1. `best_oa_location.pdf_url`
2. `open_access.oa_url`
3. Every `locations[].pdf_url` (fetch the work by id with `select=locations` if needed)
4. If any location is PMC: `https://europepmc.org/articles/PMC<id>?pdf=render` — serves the PDF directly; use this instead of ncbi.nlm.nih.gov, which fronts a JS proof-of-work page

Known curl blockers (verified 2026-08): MDPI (Akamai 403), Wiley and ScienceDirect (Cloudflare JS), PMC (proof-of-work), IEEE document pages (Radware; direct `ielx7` PDF URLs DO work). Routing through an institutional proxy does not help — the challenges are browser-side JS, not IP entitlement. For those, list the URL for manual browser download.

```
curl -sL -A "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36" -o "FILE.pdf" "PDF_URL"
```

The browser User-Agent is required — many publishers 403 the default curl UA.

Verify each file starts with `%PDF` (`head -c 5 FILE.pdf`); an HTML login/captcha page means that URL failed — try the next fallback, and if all fail report the landing page URL to the user instead of keeping a broken file.

Name files `<first-author-lastname>-<year>-<short-slug>.pdf`, lowercase, hyphens. Download into the directory the user indicates; default to `./papers/` under the current project.

## Related lookups

- Work by DOI: `https://api.openalex.org/works/https://doi.org/10.xxxx/yyyy`
- Papers citing a work: `filter=cites:W123...`
- References of a work: field `referenced_works` on the work object
- Author search: `https://api.openalex.org/authors?search=NAME`
