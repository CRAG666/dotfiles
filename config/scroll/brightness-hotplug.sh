#!/usr/bin/env bash
set -euo pipefail

self="$(dirname "$(readlink -f "$0")")/brightness.sh"

fingerprint() {
    scrollmsg -t get_outputs -r 2>/dev/null |
        jq -r '[.[] | select(.active) | .name] | sort | join(",")' 2>/dev/null
}

prev="$(fingerprint)"
scrollmsg -t subscribe -m '["output"]' 2>/dev/null | while read -r _; do
    cur="$(fingerprint)"
    [[ "$cur" == "$prev" ]] && continue
    prev="$cur"
    "$self" init
done
