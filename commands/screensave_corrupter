#!/usr/bin/env bash
tmpbg="/tmp/screen.png"
scrot "$tmpbg"; corrupter -mag 1 -boffset 2 "$tmpbg" "$tmpbg"
i3lock -i "$tmpbg"; rm "$tmpbg"
