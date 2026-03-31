#!/bin/bash

marks=($(scrollmsg -t get_marks | jq -r '.[]'))
theme="$HOME/.config/rofi/text/style_2"
generate_marks() {
	for mark in "${marks[@]}"; do
		echo "$mark"
	done
}

mark=$( (generate_marks) | rofi -p "Switch to mark" -dmenu -theme "$theme")
[[ -z $mark ]] && exit

scrollmsg "[con_mark=\b$mark\b]" focus
