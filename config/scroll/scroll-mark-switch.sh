#!/bin/bash

theme="$HOME/.config/rofi/text/style_2"

entries=$(scrollmsg -t get_tree | jq -r '
	[.. | objects | select(.marks? and (.marks | length > 0))]
	| .[]
	| (.app_id // .window_properties.class // "?") as $app
	| .marks[] | "\(.)\t\($app)"
')

[[ -z "$entries" ]] && exit 0

selection=$(echo "$entries" | awk -F'\t' '{printf "%-20s  %s\n", $1, $2}' | rofi -p "Switch to mark" -dmenu -theme "$theme")
[[ -z $selection ]] && exit

mark=$(echo "$selection" | awk '{print $1}')
scrollmsg "[con_mark=\b$mark\b]" focus
