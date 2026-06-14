#!/usr/bin/env bash
# Run once at login: if the "Shenzhen KTC" monitor is connected, turn the
# laptop backlight off (brightnessctl --device=intel_backlight set 0).
# Launched from the scroll config via `exec`.

set -euo pipefail

sleep 10
if scrollmsg -t get_outputs -r |
	jq -e 'any(.[]; (.make // "") | contains("Shenzhen KTC"))' >/dev/null 2>&1; then
	brightnessctl --device=intel_backlight set 0
fi
