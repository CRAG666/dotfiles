#!/usr/bin/env bash

style="$($HOME/.config/rofi/applets/menu/style.sh)"

dir="$HOME/.config/rofi/applets/menu/configs/$style"
rofi_command="rofi -theme $dir/powermenu.rasi"

uptime=$(uptime -p | sed -e 's/up //g')
cpu=$(sh ~/.config/rofi/bin/usedcpu)
memory=$(sh ~/.config/rofi/bin/usedram)

# Options
shutdown=""
reboot=""
lock=""
suspend=""
logout=""

# Confirmation
confirm_exit() {
	rofi -dmenu\
		-i\
		-no-fixed-num-lines\
		-p "Are You Sure? : "\
		-theme $HOME/.config/rofi/applets/styles/confirm.rasi
}

# Message
msg() {
	rofi -theme "$HOME/.config/rofi/applets/styles/message.rasi" -e "Available Options  -  yes / y / no / n"
}

# Variable passed to rofi
options="$shutdown\n$reboot\n$lock\n$suspend\n$logout"

chosen="$(echo -e "$options" | $rofi_command -p "祥  $uptime  |     $cpu  |  ﬙  $memory " -dmenu -selected-row 2)"
case $chosen in
    $shutdown)
		ans=$(confirm_exit &)
		if [[ $ans == "yes" || $ans == "YES" || $ans == "y" || $ans == "Y" ]]; then
			poweroff -i
		elif [[ $ans == "no" || $ans == "NO" || $ans == "n" || $ans == "N" ]]; then
			exit 0
        else
			msg
        fi
        ;;
    $reboot)
		ans=$(confirm_exit &)
		if [[ $ans == "yes" || $ans == "YES" || $ans == "y" || $ans == "Y" ]]; then
			reboot -i
		elif [[ $ans == "no" || $ans == "NO" || $ans == "n" || $ans == "N" ]]; then
			exit 0
        else
			msg
        fi
        ;;
    $lock)
		if [[ -f /usr/bin/i3lock ]]; then
			screensave_corrupter
		elif [[ -f /usr/bin/betterlockscreen ]]; then
			betterlockscreen -l
		fi
        ;;
    $suspend)
		ans=$(confirm_exit &)
		if [[ $ans == "yes" || $ans == "YES" || $ans == "y" || $ans == "Y" ]]; then
			systemctl suspend
		elif [[ $ans == "no" || $ans == "NO" || $ans == "n" || $ans == "N" ]]; then
			exit 0
        else
			msg
        fi
        ;;
    $logout)
		ans=$(confirm_exit &)
		if [[ $ans == "yes" || $ans == "YES" || $ans == "y" || $ans == "Y" ]]; then
			if [[ "$XDG_SESSION_DESKTOP" == "Openbox" ]]; then
				openbox --exit
			elif [[ "$XDG_SESSION_DESKTOP" == "bspwm" ]]; then
				bspc quit
			elif [[ "$XDG_SESSION_DESKTOP" == "i3" ]]; then
				i3-msg exit
			elif [[ "$XDG_SESSION_DESKTOP" == "sway" ]]; then
				swaymsg exit
			fi
		elif [[ $ans == "no" || $ans == "NO" || $ans == "n" || $ans == "N" ]]; then
			exit 0
        else
			msg
        fi
        ;;
esac
