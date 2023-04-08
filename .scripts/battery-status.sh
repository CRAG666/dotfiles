#!/bin/bash
while true; do
	# export DISPLAY=:0.0
	battery_level=$(cat /sys/class/power_supply/BAT0/capacity)
	on_ac_power=$(cat /sys/class/power_supply/AC/online)
	if [ "$on_ac_power" -eq 1 ]; then
		if [ "$battery_level" -ge 95 ]; then
			notify-send "Battery Full" "Level: $battery_level% "
			paplay /usr/share/sounds/freedesktop/stereo/suspend-error.oga
		fi
	else
		if [ "$battery_level" -le 20 ]; then
			notify-send --urgency=CRITICAL "Battery Low" "Level: $battery_level%"
			paplay /usr/share/sounds/freedesktop/stereo/suspend-error.oga
		fi
	fi
	sleep 60
done
