#!/bin/bash

theme="$HOME/.config/rofi/colors/catppuccin.rasi"
get_random_color() {
	current_color=$(awk '/selected:/ {print $2}' $theme)
	while true; do
		random_color=${colors[$RANDOM % ${#colors[@]}]}
		if [ "$random_color" != "$current_color" ]; then
			break
		fi
	done
	echo "$random_color"
}

mapfile -t colors <"$HOME/.config/rofi/colors/colors.txt"

random_color=$(get_random_color)

sed -i "s/selected:.*$/selected: $random_color;/" $theme
