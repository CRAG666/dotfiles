#!/usr/bin/env bash
API="https://graph.incitefulmed.com/openalex"

check_deps() {
  for cmd in curl jq; do
    command -v "$cmd" >/dev/null || { echo "error: $cmd is required" >&2; exit 1; }
  done
}

# Accepts OpenAlex W-id, bare DOI, "doi:..." or doi.org URL; prints W-id.
# Inciteful's own DOI lookup is unreliable, so DOIs are resolved via OpenAlex.
resolve_id() {
  local id="$1"
  if [[ "$id" =~ ^W[0-9]+$ ]]; then
    echo "$id"
    return
  fi
  local doi="$id"
  [[ "$doi" =~ ^https?://(dx\.)?doi\.org/ ]] && doi="${doi#*doi.org/}"
  [[ "$doi" =~ ^doi: ]] && doi="${doi#doi:}"
  local encoded
  encoded=$(jq -rn --arg q "$doi" '$q | @uri')
  local wid
  wid=$(curl -s -m 30 "https://api.openalex.org/works/doi:${encoded}" | jq -r 'if .id then .id | sub("https://openalex.org/"; "") else empty end' 2>/dev/null)
  [[ -n "$wid" ]] || { echo "error: could not resolve '$id' to an OpenAlex ID" >&2; exit 1; }
  echo "$wid"
}

# "10.123/x, W123, https://doi.org/10.456/y" -> "ids[]=W123&ids[]=W456..."
id_params() {
  local ids=""
  IFS=',' read -ra toks <<< "$1"
  for tok in "${toks[@]}"; do
    tok=$(echo "$tok" | xargs)
    [[ -n "$tok" ]] && ids+="ids[]=$(resolve_id "$tok")&"
  done
  [[ -n "$ids" ]] || { echo "error: no paper ids given" >&2; exit 1; }
  echo "${ids%&}"
}

# Generic row formatter for query results: headline field first, rest indented.
# $1: max rows to show (server ignores SQL LIMIT and caps at 50).
format_rows() {
  local max="${1:-50}"
  jq -r --argjson max "$max" '
    def val($v):
      if ($v | type) == "array" then
        (if ($v | length) > 0 and ($v[0] | type) == "object" and ($v[0] | has("name"))
         then ([$v[:3][].name] | join(", ")) + (if ($v | length) > 3 then ", et al." else "" end)
         else ($v | tostring) end)
      elif ($v | type) == "number" then
        (if $v == ($v | floor) then $v else (($v * 1000 | round) / 1000) end)
      else $v end;
    if (type == "array" and length == 0) then "No results."
    elif type == "array" then
      .[0:$max] | to_entries[] | .key as $i | .value as $row |
      ($row.title // $row.author_name // $row.affiliation // $row.journal // ($row | tostring)) as $head |
      "\($i + 1). \($head)",
      ($row | to_entries
             | map(select(.key != "title" and .key != "author_name" and .key != "affiliation" and .key != "journal"))
             | .[]
             | "   \(.key): \(val(.value))")
    else . end'
}
