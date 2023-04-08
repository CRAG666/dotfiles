#!/usr/bin/env bash

theme="style_2"
dir="$HOME/.config/rofi/text"
styles=("$(ls -p --hide="colors.rasi" "$dir"/styles)")
color="${styles[$(($RANDOM % 10))]}"

# comment this line to disable random colors
#sed -i -e "s/@import .*/@import \"$color\"/g" $dir/styles/colors.rasi

# comment these lines to disable random style
#themes=($(ls -p --hide="launcher.sh" --hide="styles" $dir))
#theme="${themes[$(( $RANDOM % 7 ))]}"

if [[ "$XDG_SESSION_DESKTOP" == "wlroots" ]]; then
	# clipman pick --tool=CUSTOM --tool-args="rofi -p \
	#    pick -dmenu -i -theme \
	#    $dir/'$theme' -lines 10"
	cliphist list | rofi -p \
		pick -dmenu -i -theme \
		"$dir/$theme" -lines 10 | cliphist decode | wl-copy
else
	rofi -modi "clipboard:greenclip print" \
		-show clipboard \
		-run-command '{cmd}' \
		-theme "$dir/""$theme"
fi
