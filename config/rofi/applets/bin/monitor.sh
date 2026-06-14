#!/usr/bin/env bash

source "$HOME"/.config/rofi/applets/shared/theme.bash
theme="$type/$style"
hyprmonitor=$HOME/.config/hypr/monitors.conf

# Theme Elements
prompt='Monitor Settings'
mesg="Change Settings monitor"
list_col='1'
list_row='3'
win_width='120px'

# Options
layout=$(cat ${theme} | grep 'USE_ICON' | cut -d'=' -f2)
if [[ "$layout" == 'NO' ]]; then
	option_1="󱄄 Home"
	option_2="󱋆 Work"
	option_3="󰶐 Monitor Off"
else
	option_1="󱄄 "
	option_2="󱋆 "
	option_3="󰶐 "
fi

# Rofi CMD
rofi_cmd() {
	rofi -theme-str "window {width: $win_width;}" \
		-theme-str "listview {columns: $list_col; lines: $list_row;}" \
		-theme-str 'textbox-prompt-colon {str: "";}' \
		-dmenu \
		-p "$prompt" \
		-mesg "$mesg" \
		-markup-rows \
		-theme ${theme}
}

# Pass variables to rofi dmenu
run_rofi() {
	echo -e "$option_1\n$option_2\n$option_3" | rofi_cmd
}

home_config() {
	sed -i '/#primary$/s/.*/monitor = eDP-1,1920x1080@60,-1920x0,1,bitdepth,10 #primary/' $hyprmonitor
	hyprctl reload
}

work_config() {
	sed -i '/#primary$/s/.*/monitor = eDP-1,1920x1080@60,1920x0,1,bitdepth,10 #primary/' $hyprmonitor
	hyprctl reload
}

monitoroff() {
	nmonitors=$(hyprctl monitors | grep Monitor | wc -l)
	if [ "$nmonitors" -ge 2 ]; then
		sed -i '/#primary$/s/.*/monitor = eDP-1,disable #primary/' $hyprmonitor
		hyprctl reload
	fi
}

# Execute Command
run_cmd() {
	if [[ "$1" == '--opt1' ]]; then
		home_config
	elif [[ "$1" == '--opt2' ]]; then
		work_config
	elif [[ "$1" == '--opt3' ]]; then
		monitoroff
	fi
}

chosen="$(run_rofi)"
case ${chosen} in
$option_1)
	run_cmd --opt1
	;;
$option_2)
	run_cmd --opt2
	;;
$option_3)
	run_cmd --opt3
	;;
esac
