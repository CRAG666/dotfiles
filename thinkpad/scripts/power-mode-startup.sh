#!/bin/sh

if [ -d "/sys/class/power_supply/AC" ]; then
	status=$(cat /sys/class/power_supply/AC/online)

	if [ "$status" -eq 1 ]; then
		/home/think-crag/Git/dotfiles/thinkpad/scripts/power-mode.sh ac
	else
		/home/think-crag/Git/dotfiles/thinkpad/scripts/power-mode.sh battery
	fi
else
	logger "No se pudo encontrar información sobre el cargador."
fi
