#!/bin/bash

icon_menu="~/.config/rofi/utils/rasi/iconmenu.rasi"
list_menu="~/.config/rofi/utils/rasi/listmenu.rasi"

# Functions
status_options() {
	# utils status elements
	active=''
	urgent=''

	# Options
	## power
	if [[ "$status" =~ disable ]] || [[ "$status" =~ 'Powered: no' ]]; then
		#[ -n "$urgent" ] && urgent+=",2" || urgent="-u 2"
		power=''
		options="$power"
		message='Poweroff'
	else
		[ -n "$active" ] && active+=",2" || active="-u 2"
		power=''

		## connection
		if [[ $status =~ full ]] || [[ -n "$dev_now" ]]; then
			[ -n "$active" ] && active+=",0" || active="-a 0"
			[ -n "$current_dev" ] && [ -z "$message" ] && message=" $current_dev"
			connection=$1
		else
			message='Disconnected'
			connection=$2
		fi

		list=''
		cancel=""

		options="$connection\n$list\n$power"
	fi

}

rofi_cmd() {
	cmd='rofi -p "$title" -dmenu -theme-str "textbox-prompt-colon {str: \"$icon\"; }" $active $urgent'
	if [ $1 == 'icon' ]; then
		[ -z "$selected_row" ] && selected_row='0'
		cmd+=' -theme $icon_menu -selected-row  "$selected_row"'
	elif [ $1 == 'list' ]; then
		[ -z "$selected_row" ] && selected_row='1'
		cmd+=' -theme $list_menu -selected-row  "$selected_row" -i'
	fi
	[ -n "$message" ] && cmd+=' -mesg "$message"'
	[ -n "$window_opt" ] && cmd+=' -theme-str "window {$window_opt}"'
	[ -n "$cover_opt" ] && cmd+=' -theme-str "coverbox {$cover_opt}"'
	[ -n "$inputbar_opt" ] && cmd+=' -theme-str "inputbar {$inputbar_opt}"'
	[ -n "$message_opt" ] && cmd+=' -theme-str "textbox {$message_opt}"'
	[ -n "$listview" ] && cmd+=' -theme-str "listview {$listview_opt}"'
	[ -n "$lines" ] && cmd+=' -theme-str "listview {lines: $lines; }"'
	eval "$cmd"
}

menu_list() {
	# utils variables
	active=''
	urgent="-u 0"

	# Menu options
	back='Back\0icon\x1fback-user'
	exit_opt='Exit\0icon\x1fexit-user'

	# Lines count
	[ -n "$element_list" ] && lines=$(echo -e "$element_list" | wc -l)
	((lines += 1))
	if [ $lines -gt 12 ]; then
		lines=12
	fi

	n=1
	while read line; do
		if [[ "$current" == "$line" ]] || [[ "$dev_now" == "$line" ]]; then
			[ -n "$active" ] && active+=",$n" || active="-a $n"
			elements+="${line%:*}\0icon\x1f$icon_current\x1fmeta\x1f${line#*:}\n"
		else
			elements+="${line%:*}\0icon\x1f$icon_type\x1fmeta\x1f${line#*:}\n"
		fi
		((n += 1))
	done < <(echo -e "$element_list")

	options="$back\n$elements"

	# utils command
	chosen=$(echo -en "$options" | rofi_cmd 'list')
	sleep 0.2
	[ -z "$chosen" ] && exit
	case "$chosen" in
	'Back')
		lines=''
		message=''
		;;
	'Exit')
		exit 0
		;;
	*)
		elements=''
		element_option "$chosen"
		;;
	esac
}

main_menu() {
	# Options
	options

	# utils command
	chosen="$(echo -e "$options" | rofi_cmd 'icon')"

	sleep 0.2
	[ -n "$chosen" ] && check_case
}
