#!/bin/bash

marks=($(scrollmsg -t get_tree | jq -r 'recurse(.nodes[]?) | recurse(.floating_nodes[]?) | select(.focused==true) | .marks[]'))
theme="$HOME/.config/rofi/text/style_2"

mark=$(printf '%s\n' "${marks[@]}" | rofi -p "Remove a mark (leave empty to clear all)" -dmenu -theme "$theme")
if [[ -z $mark ]]; then
	for m in "${marks[@]}"; do scrollmsg unmark "$m"; done
	exit
fi
scrollmsg unmark "$mark"
