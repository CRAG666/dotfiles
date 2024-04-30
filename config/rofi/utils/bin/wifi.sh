#!/bin/bash

options() {
	title='Wireless'
	icon=''
	status=$(nmcli g)
	current=$(nmcli -t -f NAME c show --active | grep -v lo)
	interface=$(ip -br a | awk '!/lo/{print $1}')
	ipv4=$(ip -4 -br a | awk '!/lo/{print $3}')
	ipv6=$(ip -6 -br a | awk '!/lo/{print $3}')

	# Function to check power, connection and others
	# Arg1 <icon-on> Arg2 <icon-offve>
	status_options '' ''
	echo current: $interface
	[ -n "$current" ] && title="$current" || title="$interface"
	[ -n "$ipv4" ] && message+="$ipv4"
	[ -n "$ipv6" ] && message+="\n$ipv6"
	message=$(echo -e "$message")
}

scanning_opt() {
	notify-send -i "$icon_name" -a "Wireless" "Scanning networks" -t 10000 -h string:x-dunst-stack-tag:"$title"
	nmcli -f SSID dev wifi | tail -n +2 | sed '/^--/d' >"$path/wifi_list" # SSID,BARS

	# List variable passed to utils
	element_list=$(cat "$path/wifi_list")
	title=$(nmcli -t -f NAME c show --active | grep -v lo)
}

handle_option() {
	case $1 in
	connection)
		message=''
		if [[ $status =~ disconnected ]]; then
			nmcli dev connect wlp82s0 >/dev/null
			sleep 1
		else
			nmcli dev disconnect wlp82s0 >/dev/null
		fi
		;;
	list)
		scanning_opt
		rm "$path/wifi_list"
		# utils list menu function.
		menu_list
		;;
	power)
		if [[ $status =~ disabled ]]; then
			nmcli radio wifi on >/dev/null
			sleep 3
		else
			nmcli radio wifi off >/dev/null
		fi
		;;
	*)
		exit
		;;
	esac
	main_menu
}

element_option() {
	net_ssid=$(echo "$chosen" | xargs)
	[ -n "$net_ssid" ] || exit
	if [[ "$know" =~ "$net_ssid" ]]; then
		notify-send -i "$icon_name" -a "Wireless" "Connecting to $net_ssid" -t 100000 -h string:x-dunst-stack-tag:"$title"
		nmcli device wifi connect "$net_ssid" && notify-send -i "$icon_name" -a "Wireless" "Connected to $net_ssid" -t 4000 -h string:x-dunst-stack-tag:"$title"
	else
		passphrase=$(confirm_pass)
		if [[ -n "$passphrase" ]]; then
			notify-send -i "$icon_name" -a "Wireless" "Connecting to $net_ssid" -t 100000 -h string:x-dunst-stack-tag:"$title"
			connection_err=$(nmcli device wifi connect "$net_ssid" password "$passphrase" 2>&1)
			if [[ -z "$connection_err" ]]; then
				notify-send -i "$icon_name" -a "Wireless" "Connected to $net_ssid" -t 4000 -h string:x-dunst-stack-tag:"$title"
			else
				message="<span color='#f7768e'>Error ${connection_err##*:}</span>"
				menu_list
			fi
		else
			message="<span color='#f7768e'>Error, empty input</span>"
			menu_list
		fi
	fi
	sleep 0.5
	if ! nmcli -t -f NAME c show --active | grep -q "$net_ssid"; then
		message="<span color='#f7768e'>Error ${connection_err##*:}</span>"
		menu_list
	else
		notify-send -i "$icon_name" -a "Wireless" "Connected to $net_ssid" -t 10000 -h string:x-dunst-stack-tag:"$title"
		exit 0
	fi
}

confirm_pass() {
	rofi -dmenu \
		-i \
		-password \
		-p "Wireless" \
		-mesg "Connecting to: $chosen" \
		-theme confirm.rasi
}

check_case() {
	case "$chosen" in
	$connection)
		handle_option 'connection'
		;;
	$list)
		handle_option 'list'
		;;
	$power)
		handle_option 'power'
		;;
	$cancel)
		exit
		;;
	*)
		exit
		;;
	esac
}

# Resources
icon_name='wifi-high' # Notification
icon_type='wifi'      # Listview icon
icon_current="know-alt"

# Lists
know=$(nmcli -f NAME connection show)

source "$HOME/.config/rofi/utils/bin/base.sh"

case $1 in
--status)
	pass
	;;
*)
	main_menu
	;;
esac
