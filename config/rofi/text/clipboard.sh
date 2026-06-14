#!/usr/bin/env bash

theme="style_2"
dir="$HOME/.config/rofi/text"

rofi -modi clipboard:~/.config/rofi/text/img -show clipboard -show-icons -theme "$dir/$theme"
