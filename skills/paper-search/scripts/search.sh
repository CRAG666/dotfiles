#!/usr/bin/env bash
# Search OpenAlex for academic papers
# Usage: ./search.sh "query" [limit] [sort] [page]
# Sort: relevance (default), cites, date

set -euo pipefail

for cmd in curl jq; do
  command -v "$cmd" >/dev/null || { echo "error: $cmd is required" >&2; exit 1; }
done

QUERY="${1:?Usage: ./search.sh \"query\" [limit] [sort] [page]}"
LIMIT="${2:-10}"
SORT_KEY="${3:-relevance}"
PAGE="${4:-1}"
MAILTO="${PAPER_SEARCH_MAILTO:-paper-search@example.com}"

case "$SORT_KEY" in
  relevance) SORT="relevance_score:desc" ;;
  cites)     SORT="cited_by_count:desc" ;;
  date)      SORT="publication_date:desc" ;;
  *)         SORT="$SORT_KEY" ;;
esac

ENCODED=$(jq -rn --arg q "$QUERY" '$q | @uri')

URL="https://api.openalex.org/works?search=${ENCODED}&per_page=${LIMIT}&page=${PAGE}&sort=${SORT}&mailto=${MAILTO}"

OFFSET=$(( (PAGE - 1) * LIMIT ))

curl -s "$URL" | jq -r --argjson offset "$OFFSET" '
  "Total results: \(.meta.count // "?") | Page \(.meta.page // "?")/\(((.meta.count // 0) / (.meta.per_page // 1) | ceil)) | Showing \(.meta.per_page // "?") per page\n",
  (.results // [] | to_entries[] |
    "\(.key + 1 + $offset). [\(.value.cited_by_count) cites] (\(.value.publication_year)) \(.value.title)",
    "   Authors: \([.value.authorships[:3][].author.display_name] | join(", "))",
    "   DOI: \(.value.doi // "N/A")",
    "   URL: \(.value.primary_location.landing_page_url // .value.id // "N/A")",
    "   OpenAlex ID: \(.value.id // "N/A")",
    (if .value.abstract_inverted_index then
      "   Abstract: \([.value.abstract_inverted_index | to_entries[] | .key as $w | .value[] | {pos: ., word: $w}] | sort_by(.pos) | [.[].word] | join(" ") | .[0:250])..."
    else
      "   Abstract: N/A"
    end),
    ""
  )
'
