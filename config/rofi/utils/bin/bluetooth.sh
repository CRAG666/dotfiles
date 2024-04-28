#!/usr/bin/env bash

# Get Bluetooth status
status=$(bluetoothctl show)

# Get connected device info
dev_now_info=$(bluetoothctl info "$dev_now")

# Functions
options() {
	dev_now="$(echo "$dev_now_info" | grep Name | cut -d ' ' -f 2-)"
	dev_battery="$(echo "$dev_now_info" | grep 'Battery Percentage' | awk '{print $(NF)}' | tr -d '()')"
	dev_mac=$(echo "$dev_now_info" | head -n 1 | cut -d ' ' -f 2)
	dev_know=$(bluetoothctl devices | grep Device | cut -d ' ' -f 3-)
	[ -n "$dev_now" ] && title="$dev_now" || title='Bluetooth'
	[ -n "$dev_battery" ] && message=$(echo -e " $dev_battery%")

	# Function to check power, connection, and others
	# status_options <icon-on> <icon-off>
	status_options  
}

device_connected() {
	if echo "$dev_now_info" | grep -q "Connected: yes"; then
		return 0
	else
		return 1
	fi
}

handle_option() {
	case $1 in
	'connection')
		# No device connected
		if [[ -z "$dev_now" ]]; then
			# check recent device disconnected
			if [[ -z "$dev_mac_tmp" ]]; then
				# Known devices menu
				element_list=$dev_know
				menu_list
			else
				dev_tmp=$(bluetoothctl connect "$dev_mac_tmp")
				if [[ $dev_tmp =~ "Failed" ]]; then
					menu_list
				fi
			fi
		else
			bluetoothctl disconnect "$dev_mac"
			# Temp mac variable to reconnect
			dev_mac_tmp=$dev_mac
		fi
		;;
	'power')
		if [[ $status =~ "Powered: no" ]]; then
			bluetoothctl power on >/dev/null &
		else
			bluetoothctl power off >/dev/null &
		fi
		;;
	'list')
		if [[ $status =~ 'Powered: yes' ]]; then
			notify-send -i bluetooth-connected -a "Bluetooth" "Scanning devices" -h string:x-dunst-stack-tag:'bluetooth' -t 10000
			bluetoothctl --timeout 10 scan on >/dev/null &
			sleep 0.5

			element_list=$(bluetoothctl devices | cut -d ' ' -f 3-)
			menu_list
		else
			notify-send -i bluetooth-poweron -a "Bluetooth" "Power up controller before!" -h string:x-dunst-stack-tag:'bluetooth'
		fi
		;;
	*)
		exit
		;;
	esac
	main_menu
}

element_option() {
	if [[ -n "$chosen" ]]; then
		device=$(bluetoothctl devices | grep "$chosen" | cut -d ' ' -f 2)
		notify-send -i bluetooth-poweron -t 4000 -a "Bluetooth" "Connecting to: $chosen" -h string:x-dunst-stack-tag:'bluetooth'
		[[ ! "$chosen" =~ "$dev_know" ]] && bluetoothctl pair "$device" >/dev/null
		bluetoothctl connect "$device" >/dev/null
		if [[ $(bluetoothctl info) =~ "Name: $chosen" ]]; then
			notify-send -i bluetooth-poweron -t 4000 -a "Bluetooth" "Connected to: $chosen" -h string:x-dunst-stack-tag:'bluetooth'
			exit
		else
			message="<span color='#f7768e'>Error in connection</span>"
			menu_list
		fi
	fi
}

check_case() {
	case $chosen in
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
icon=''
icon_type='scan'
icon_current='know-alt'

source "$HOME/.config/rofi/utils/bin/base.sh"

case $1 in
--status)
	pass
	;;
*)
	main_menu
	;;
esac
