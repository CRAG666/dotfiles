#!/usr/bin/env bash
# Export papers to BibTeX or RIS
# Usage: ./export.sh <id1[,id2,...]> [bib|ris]

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"
check_deps

SEEDS="${1:?Usage: ./export.sh <id1[,id2,...]> [bib|ris]}"
FORMAT="${2:-bib}"

[[ "$FORMAT" == "bib" || "$FORMAT" == "ris" ]] || { echo "error: format must be bib or ris" >&2; exit 1; }

PARAMS=$(id_params "$SEEDS")
curl -s -m 60 "${API}/export/${FORMAT}?${PARAMS}"
