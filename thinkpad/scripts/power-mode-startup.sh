#!/bin/sh

script_dir=$(dirname "$(readlink -f "$0")")

if [ -d "/sys/class/power_supply/AC" ]; then
	status=$(cat /sys/class/power_supply/AC/online)

	rfkill block bluetooth
	if [ "$status" -eq 1 ]; then
		"$script_dir/power-mode.sh" ac
	else
		"$script_dir/power-mode.sh" battery
	fi
else
	logger "No se pudo encontrar información sobre el cargador."
fi
