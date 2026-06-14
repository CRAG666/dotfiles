#!/bin/sh

ROFI=~/.config/rofi/
# refresh the pre-rendered icon theme in the background if apps changed
# (no-op stat check when fresh, so it never delays the menu)
"$ROFI/gen-icon-cache.sh" >/dev/null 2>&1 &
$ROFI/colors/ramdom_color.sh
$ROFI/scripts/$1 $2
