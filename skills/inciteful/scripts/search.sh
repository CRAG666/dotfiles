#!/usr/bin/env bash
# Search papers by keyword on Inciteful (OpenAlex-backed, fast title search)
# Usage: ./search.sh "query" [limit]

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"
check_deps

QUERY="${1:?Usage: ./search.sh \"query\" [limit]}"
LIMIT="${2:-10}"

ENCODED=$(jq -rn --arg q "$QUERY" '$q | @uri')

curl -s -m 60 "$API/paper/search?q=${ENCODED}" | jq -r --argjson limit "$LIMIT" '
  if (type == "array" and length == 0) then "No results. Try broader terms, or use the OpenAlex-based paper-search skill."
  else
    .[0:$limit] | to_entries[] |
    "\(.key + 1). [\(.value.num_cited_by) cites] (\(.value.published_year)) \(.value.title)",
    "   Authors: \([.value.author[:3][].name] | join(", "))",
    "   Journal: \(.value.journal // "N/A")",
    "   DOI: \(.value.doi // "N/A")",
    "   ID: \(.value.id)",
    ""
  end'
