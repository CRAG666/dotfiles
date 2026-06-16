#!/usr/bin/env bash

set -euo pipefail

sleep 10
if scrollmsg -t get_outputs -r |
	jq -e 'any(.[]; (.make // "") | contains("Shenzhen KTC"))' >/dev/null 2>&1; then
	brightnessctl --device=intel_backlight set 0
fi
