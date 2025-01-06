#!/bin/bash

LOW_BATTERY_THRESHOLD=30
HIGH_BATTERY_THRESHOLD=80
TEMP_DIR="/tmp/battery_monitor"
CHARGING_FLAG="$TEMP_DIR/is_charging"
NOTIFIED_LOW_FLAG="$TEMP_DIR/has_been_informed_low"
NOTIFIED_HIGH_FLAG="$TEMP_DIR/has_been_informed_over_80"

mkdir -p "$TEMP_DIR"

while true; do
	battery_info=$(acpi -b)
	if [[ -z "$battery_info" ]]; then
		echo "Error: No se puede obtener información de la batería. ¿Está instalado 'acpi'?"
		sleep 10
		continue
	fi

	battery_level=$(echo "$battery_info" | grep -P -o '[0-9]+(?=%)')
	is_charging=$(echo "$battery_info" | grep -c "Charging")

	if [[ $is_charging -eq 1 && ! -f $CHARGING_FLAG ]]; then
		touch $CHARGING_FLAG
		rm -f $NOTIFIED_LOW_FLAG
		notify-send -u normal "Charging" "The charger is on."
	elif [[ $is_charging -eq 0 && -f $CHARGING_FLAG ]]; then
		rm -f $CHARGING_FLAG
		rm -f $NOTIFIED_HIGH_FLAG
		notify-send -u normal "Discharging" "The charger is off."
	fi

	if [[ $is_charging -eq 1 && $battery_level -ge $HIGH_BATTERY_THRESHOLD && ! -f $NOTIFIED_HIGH_FLAG ]]; then
		notify-send -u normal "Battery above ${HIGH_BATTERY_THRESHOLD}%." "You may unplug the charger."
		touch $NOTIFIED_HIGH_FLAG
	fi

	if [[ $is_charging -eq 0 && $battery_level -lt $LOW_BATTERY_THRESHOLD && ! -f $NOTIFIED_LOW_FLAG ]]; then
		notify-send -u critical "Battery low (${battery_level}%)." "Plug in the charger."
		touch $NOTIFIED_LOW_FLAG
	fi

	sleep 3
done
