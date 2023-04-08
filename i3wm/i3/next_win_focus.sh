#!/bin/bash
win_focus=`ps -e | grep $(xdotool getwindowpid $(xdotool getwindowfocus)) | grep -v grep | awk '{print $4}'`

if [[ $win_focus = "alacritty" ]]
then
  xdotool key Ctrl+a+l
else
  i3 focus right
fi
