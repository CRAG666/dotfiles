#!/usr/bin/env bash
# Run arbitrary SQL over the citation network built around seed paper(s).
# Usage: ./query.sh <id1[,id2,...]> <sql-file>  or  ./query.sh <ids> "SELECT ..."
#
# Schema (DuckDB dialect):
#   papers(paper_id, doi, title, authors, journal, published_year, num_authors,
#          num_cited_by, num_citing, adamic_adar, cocite, page_rank, distance)
#     distance = 0 for the seed papers, 1 for their direct refs/citations, ...
#   authors(paper_id, author_id, name, affiliation, affiliation_id, ror,
#           sequence, partial_page_rank, published_year)
#   title_search('keyword phrase') -> table of matching paper_ids

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"
check_deps

SEEDS="${1:?Usage: ./query.sh <id1[,id2,...]> <sql-file | \"SELECT ...\">}"
SQLARG="${2:?Usage: ./query.sh <id1[,id2,...]> <sql-file | \"SELECT ...\">}"

if [[ -f "$SQLARG" ]]; then
  SQL=$(cat "$SQLARG")
else
  SQL="$SQLARG"
fi

PARAMS=$(id_params "$SEEDS")
curl -s -m 300 -X POST "${API}/query?${PARAMS}&prune=10000" \
  -H 'Content-Type: text/plain' --data-binary "$SQL" | format_rows
