#!/usr/bin/env bash

~/.config/rofi/text/ramdom_color.sh

theme="style_icon"
dir="$HOME/.config/rofi/text"
rofi -combi-modi window,drun -theme "$dir/$theme" -show combi
