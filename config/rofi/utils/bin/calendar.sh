#!/bin/bash

# Options
options() {
	active='-a 1'
	urgent=''
	window_opt="location: north; width:320px;"
	message_opt="font: \"Iosevka 19\";"
	extra_opt="-selected-row 1"

	prev=''
	next=''
	list=''

	options="$prev\n$next"
}

# Display info menu
info_menu() {
	back=''
	exit_opt=''
	options="$back\n$exit_opt"
	active='-a 0'
	urgent='-u -1'

	message=$(cal "$(date +%Y %m)") # Preload current month's calendar
	message_opt="font: \"Iosevka 13\"; horizontal-align: 0;"
	chosen=$(echo -e "$options" | rofi_cmd 'info')

	case $chosen in
	$back)
		message=$(cal | sed -z "s|\s$TODAY\s| <u><b>$TODAY</b></u> |1")
		main_menu $icon_menu
		;;
	*)
		exit
		;;
	esac
}

# Handle navigation actions
handle_action() {
	if [ "$DIFF" -ge 0 ]; then
		message=$(cal "+$DIFF months")
	else
		message=$(cal "$((-DIFF)) months ago")
	fi
}

# Check chosen action
check_case() {
	case $chosen in
	$next)
		DIFF=$((DIFF + 1))
		handle_action
		;;
	$prev)
		DIFF=$((DIFF - 1))
		handle_action
		;;
	$list)
		info_menu
		;;
	*)
		exit
		;;
	esac
	today_check
	main_menu
}

# Check if today falls within displayed month
today_check() {
	if [[ "$message" =~ "$CURRENT_MONTH" ]]; then
		message=$(cal | sed -z "s|\s$TODAY\s| <u><b>$TODAY</b></u> |1")
	fi
}

# Load resources
source "$HOME/.config/rofi/utils/bin/base.sh"

# Initialize variables
DIFF=0
TODAY=$(date '+%-d')
CURRENT_MONTH=$(cal | head -1)
message=$(cal | sed -z "s|\s$TODAY\s| <u><b>$TODAY</b></u> |1")

title='Calendar'
icon=''
icon_menu='~/.config/rofi/utils/rasi/calendar.rasi'

# Main menu
case $1 in
--status)
	pass
	;;
*)
	main_menu
	;;
esac
