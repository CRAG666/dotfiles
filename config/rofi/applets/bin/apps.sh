#!/usr/bin/env bash

## Author  : Aditya Shakya (adi1090x)
## Github  : @adi1090x
#
## Applets : Favorite Applications

# Import Current Theme
source "$HOME"/.config/rofi/applets/shared/theme.bash
theme="$type/$style"

# Theme Elements
prompt='Applications'
mesg="Installed Packages : $(pacman -Q | wc -l) (pacman)"

if [[ ("$theme" == *'type-1'*) || ("$theme" == *'type-3'*) || ("$theme" == *'type-5'*) ]]; then
	list_col='1'
	list_row='6'
elif [[ ("$theme" == *'type-2'*) || ("$theme" == *'type-4'*) ]]; then
	list_col='6'
	list_row='1'
fi

# CMDs (add your apps here)
rofirun=~/.config/rofi/run.sh
term_cmd='footclient'
file_cmd='footclient yazi'
disk_cmd='gnome-disks'
calendar_cmd="$rofirun calendar"
wifi_cmd="$rofirun wifi"
bluetooth_cmd="$rofirun bluetooth"

# Options
layout=$(cat ${theme} | grep 'USE_ICON' | cut -d'=' -f2)
if [[ "$layout" == 'NO' ]]; then
	option_1="󰋊 Disk <span weight='light' size='small'><i>($disk_cmd)</i></span>"
	option_2="󰂰 Bluetooth <span weight='light' size='small'><i>($bluetooth_cmd)</i></span>"
	option_3=" Wifi <span weight='light' size='small'><i>($wifi_cmd)</i></span>"
	option_4=" Files <span weight='light' size='small'><i>($file_cmd)</i></span>"
	option_5=" Terminal <span weight='light' size='small'><i>($term_cmd)</i></span>"
	option_6=" Calendar <span weight='light' size='small'><i>($calendar_cmd)</i></span>"
else
	option_1="󰋊"
	option_2="󰂰"
	option_3=""
	option_4=""
	option_5=""
	option_6=""
fi

# Rofi CMD
rofi_cmd() {
	rofi -theme-str "listview {columns: $list_col; lines: $list_row;}" \
		-theme-str 'textbox-prompt-colon {str: "";}' \
		-dmenu \
		-p "$prompt" \
		-mesg "$mesg" \
		-markup-rows \
		-theme ${theme}
}

# Pass variables to rofi dmenu
run_rofi() {
	echo -e "$option_1\n$option_2\n$option_3\n$option_4\n$option_5\n$option_6" | rofi_cmd
}

# Execute Command
run_cmd() {
	if [[ "$1" == '--opt1' ]]; then
		${disk_cmd}
	elif [[ "$1" == '--opt2' ]]; then
		${bluetooth_cmd}
	elif [[ "$1" == '--opt3' ]]; then
		${wifi_cmd}
	elif [[ "$1" == '--opt4' ]]; then
		${file_cmd}
	elif [[ "$1" == '--opt5' ]]; then
		${term_cmd}
	elif [[ "$1" == '--opt6' ]]; then
		${calendar_cmd}
	fi
}

# Actions
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
$option_6)
	run_cmd --opt6
	;;
esac
