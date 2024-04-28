#!/usr/bin/env bash

source "$HOME"/.config/rofi/applets/shared/theme.bash
theme="$type/$style"
hyprmonitor=$HOME/.config/hypr/monitors.conf

# Theme Elements
prompt='Screenshot'
mesg="DIR: $(xdg-user-dir PICTURES)/Screenshots"
list_col='1'
list_row='5'
win_width='120px'

# Options
layout=$(cat ${theme} | grep 'USE_ICON' | cut -d'=' -f2)
if [[ "$layout" == 'NO' ]]; then
	option_1="󰍹  3840x2160@59.94Hz"
	option_2="󱡶  2560x1440@144.00Hz"
	option_3="󰹑  auto"
	option_4="󰷜 Monitor On"
	option_5="󰶐  Monitor Off"
else
	option_1="󰍹"
	option_2="󱡶"
	option_3="󰹑"
	option_4="󰷜"
	option_5="󰶐"
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
	echo -e "$option_1\n$option_2\n$option_3\n$option_4\n$option_5" | rofi_cmd
}

fullres() {
	sed -i '/#second$/s/.*/monitor=HDMI-A-1,3840x2160@59.94Hz,0x0,1.2 #second/' $hyprmonitor
	hyprctl reload
	hyprctl reload
}

fullhz() {
	sed -i '/#second$/s/.*/monitor=HDMI-A-1,2560x1440@144.00Hz,0x0,1 #second/' $hyprmonitor
	hyprctl reload
	hyprctl reload
}

autores() {
	sed -i '/#second$/s/.*/monitor=,preferred,0x0,1 #second/' $hyprmonitor
	hyprctl reload
	hyprctl reload
}

autores() {
	sed -i '/#second$/s/.*/monitor=,preferred,0x0,1 #second/' $hyprmonitor
	hyprctl reload
	hyprctl reload
}

monitoron() {
	sed -i '/#primary$/s/.*/monitor = eDP-1,highrr,auto,1 #primary/' $hyprmonitor
	hyprctl reload
}

monitoroff() {
	nmonitors=$(hyprctl monitors | grep Monitor | wc -l)
	if [ "$nmonitors" -eq 2 ]; then
		sed -i '/#primary$/s/.*/monitor = eDP-1,disable #primary/' $hyprmonitor
		hyprctl reload
	fi
}

# Execute Command
run_cmd() {
	if [[ "$1" == '--opt1' ]]; then
		fullres
	elif [[ "$1" == '--opt2' ]]; then
		fullhz
	elif [[ "$1" == '--opt3' ]]; then
		autores
	elif [[ "$1" == '--opt4' ]]; then
		monitoron
	elif [[ "$1" == '--opt5' ]]; then
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
$option_4)
	run_cmd --opt4
	;;
$option_5)
	run_cmd --opt5
	;;
esac
