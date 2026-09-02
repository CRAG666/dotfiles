#!/usr/bin/env bash
# Get details for a single paper by OpenAlex ID or DOI (incl. direct citation lists)
# Usage: ./paper.sh "W2607348396" or ./paper.sh "10.1016/j.copsyc.2017.04.020"

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"
check_deps

ID="${1:?Usage: ./paper.sh <OpenAlex_ID or DOI>}"
WID=$(resolve_id "$ID")

curl -s -m 60 "$API/paper/${WID}" | jq -r '
  "\(.title)\n",
  "Year:      \(.published_year)",
  "Journal:   \(.journal // "N/A")",
  "DOI:       \(.doi // "N/A")",
  "OpenAlex:  \(.id)",
  "Citations: \(.num_cited_by) | References: \(.num_citing)",
  "",
  "Authors:",
  (.author[] | "  - \(.name)\(if .institution then " (\(.institution.name))" else "" end)"),
  "",
  "PDF links:",
  (if (.pdf_urls | length) > 0 then .pdf_urls[] | "  - \(.)" else "  (none)" end),
  "",
  "Sample references (papers this one cites, \(.num_citing) total):",
  (.citing[:10][]? | "  - \(.)"),
  "",
  "Sample citations (papers citing this one, \(.num_cited_by) total):",
  (.cited_by[:10][]? | "  - \(.)")'
