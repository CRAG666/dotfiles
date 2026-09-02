#!/usr/bin/env bash
# Literature Connector: find shortest citation paths between two papers.
# Usage: ./connect.sh <from_id_or_doi> <to_id_or_doi> [extend]
# extend: 0 (default, direct graph) or 5 (larger search, slower)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"
check_deps

FROM="${1:?Usage: ./connect.sh <from_id_or_doi> <to_id_or_doi> [extend]}"
TO="${2:?Usage: ./connect.sh <from_id_or_doi> <to_id_or_doi> [extend]}"
EXTEND="${3:-0}"

FROM_ID=$(resolve_id "$FROM")
TO_ID=$(resolve_id "$TO")

curl -s -m 300 "${API}/connector?from=${FROM_ID}&to=${TO_ID}&extend=${EXTEND}" | jq -r '
  . as $c |
  ($c.papers | map({key: .id, value: {title, doi, published_year}}) | from_entries) as $idx |
  if ($c.paths | length) == 0 then
    "No citation path found between these papers (searched \($c.papers_searched) papers). Try extend=5."
  else
    "Paths: \($c.num_paths) | Max hops: \($c.max_hops) | Papers searched: \($c.papers_searched)\n",
    ($c.paths[:10] | to_entries[] |
      "Path \(.key + 1):",
      (.value | to_entries[] | "  \(.key + 1). \($idx[.value].title) (\($idx[.value].published_year)) [\(.value)]"),
      "")
  end'
