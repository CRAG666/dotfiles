#!/usr/bin/env bash
# Run a citation-network analysis around seed paper(s): similar, important,
# reviews, recent, authors, upcoming, institutions, journals.
# Usage: ./discover.sh <id1[,id2,...]> [analysis] [limit] [min_year] [max_year] ["keywords"]
# Analyses:
#   similar      papers citing the same literature as the seeds (adamic_adar + co-citation)
#   important    highest PageRank in the network (tends to surface seminal older papers)
#   reviews      papers citing the most network papers (likely reviews)
#   recent       most important papers from the last 3 years
#   authors      top authors in the network by partial PageRank
#   upcoming     top authors who started publishing within the last 10 years
#   institutions top institutions in the network by PageRank
#   journals     most relevant journals for the network

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"
check_deps

SEEDS="${1:?Usage: ./discover.sh <id1[,id2,...]> [analysis] [limit] [min_year] [max_year] [\"keywords\"]}"
ANALYSIS="${2:-similar}"
LIMIT="${3:-20}"
MIN_YEAR="${4:-}"
MAX_YEAR="${5:-}"
KEYWORDS="${6:-}"

FILTERS="p.distance >= 1"
[[ -n "$MIN_YEAR" ]] && FILTERS+=" AND p.published_year >= ${MIN_YEAR}"
[[ -n "$MAX_YEAR" ]] && FILTERS+=" AND p.published_year <= ${MAX_YEAR}"
if [[ -n "$KEYWORDS" ]]; then
  KW=$(jq -rn --arg q "$KEYWORDS" '$q')
  FILTERS+=" AND p.paper_id IN (SELECT paper_id FROM title_search('${KW}'))"
fi

case "$ANALYSIS" in
  similar)
    SQL="SELECT paper_id, doi, authors, title, journal, adamic_adar + COALESCE(cocite, 0) AS similarity, published_year, num_cited_by
FROM papers p
WHERE ${FILTERS}
AND (adamic_adar > 0 OR cocite > 0)
ORDER BY similarity DESC, page_rank DESC
LIMIT ${LIMIT}" ;;
  important)
    SQL="SELECT paper_id, doi, authors, title, journal, page_rank, num_cited_by, published_year
FROM papers p
WHERE ${FILTERS}
ORDER BY page_rank DESC, adamic_adar DESC
LIMIT ${LIMIT}" ;;
  reviews)
    SQL="SELECT paper_id, doi, authors, p.journal, title, p.num_citing, num_cited_by, p.published_year
FROM papers p
LEFT JOIN (
  SELECT num_citing, published_year, journal, COUNT(*)
  FROM papers p
  WHERE num_citing > 10
  GROUP BY 1, 2, 3
  HAVING COUNT(*) > 8
  ORDER BY 4 DESC
  LIMIT 10
) b ON b.num_citing = p.num_citing AND b.published_year = p.published_year AND b.journal = p.journal
WHERE b.num_citing IS NULL
AND ${FILTERS}
ORDER BY p.num_citing DESC, adamic_adar DESC, num_cited_by DESC
LIMIT ${LIMIT}" ;;
  recent)
    SQL="SELECT paper_id, doi, authors, title, journal, page_rank, num_cited_by, published_year
FROM papers p
WHERE p.published_year > (strftime('%Y', 'now') - 3)
AND ${FILTERS}
ORDER BY page_rank DESC, adamic_adar DESC
LIMIT ${LIMIT}" ;;
  authors)
    SQL="SELECT name AS author_name, SUM(a.partial_page_rank) AS total_page_rank, COUNT(*) AS num_papers
FROM papers p
JOIN authors a ON p.paper_id = a.paper_id
WHERE ${FILTERS}
GROUP BY name
ORDER BY total_page_rank DESC
LIMIT ${LIMIT}" ;;
  upcoming)
    SQL="SELECT name AS author_name, SUM(a.partial_page_rank) AS total_page_rank, COUNT(*) AS num_papers
FROM papers p
JOIN authors a ON p.paper_id = a.paper_id
WHERE ${FILTERS}
GROUP BY name
HAVING MIN(a.published_year) > (strftime('%Y', 'now')) - 10
ORDER BY total_page_rank DESC
LIMIT ${LIMIT}" ;;
  institutions)
    SQL="SELECT affiliation, SUM(page_rank) AS total_page_rank, COUNT(*) AS num_papers
FROM papers p
JOIN (
  SELECT paper_id, affiliation, affiliation_id
  FROM authors
  GROUP BY affiliation_id, affiliation, paper_id
) a ON p.paper_id = a.paper_id
WHERE ${FILTERS}
AND a.affiliation <> ''
GROUP BY a.affiliation_id, a.affiliation
ORDER BY SUM(page_rank) DESC
LIMIT ${LIMIT}" ;;
  journals)
    SQL="SELECT journal, SUM(page_rank) AS total_page_rank, COUNT(*) AS num_papers
FROM papers p
WHERE ${FILTERS}
AND journal <> ''
AND journal NOT LIKE '%ebook%'
GROUP BY journal
ORDER BY SUM(page_rank) DESC
LIMIT ${LIMIT}" ;;
  *)
    echo "error: unknown analysis '$ANALYSIS' (similar|important|reviews|recent|authors|upcoming|institutions|journals)" >&2
    exit 1 ;;
esac

PARAMS=$(id_params "$SEEDS")
echo "Analysis: $ANALYSIS | Seeds: $PARAMS | Filters: ${FILTERS}" >&2
curl -s -m 300 -X POST "${API}/query?${PARAMS}&prune=10000" \
  -H 'Content-Type: text/plain' --data-binary "$SQL" | format_rows "$LIMIT"
