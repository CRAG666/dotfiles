#!/bin/bash

marks=($(scrollmsg -t get_tree | jq -c 'recurse(.nodes[]?) | recurse(.floating_nodes[]?) | select(.focused==true) | {marks} | .[]' | jq -r '.[]'))
theme="$HOME/.config/rofi/text/confirm.rasi"

if [[ ${#marks[@]} -gt 0 ]]; then
	scrollmsg "unmark" "${marks[0]}"
else
	mark=$(rofi -dmenu -i -no-fixed-num-lines -p "Add new mark:" -theme "$theme" -theme-str 'window { width: 400px; }')
	if [[ -z $mark ]]; then
		exit
	fi
	scrollmsg "mark --add" "$mark"
fi
