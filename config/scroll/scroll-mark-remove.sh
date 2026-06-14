#!/bin/bash

marks=($(scrollmsg -t get_tree | jq -c 'recurse(.nodes[]?) | recurse(.floating_nodes[]?) | select(.focused==true) | {marks} | .[]' | jq -r '.[]'))
theme="$HOME/.config/rofi/text/style_2"

generate_marks() {
	for mark in "${marks[@]}"; do
		echo "$mark"
	done
}

remove_marks() {
	echo $marks
	for mark in "${marks[@]}"; do
		scrollmsg unmark "$mark"
	done
}

mark=$( (generate_marks) | rofi -p "Remove a mark (leave empty to clear all)" -dmenu -theme "$theme")
if [[ -z $mark ]]; then
	remove_marks
	exit
fi
scrollmsg unmark "$mark"
