#!/bin/bash
win_name=`ps -e | grep $(xdotool getwindowpid $(xdotool getwindowfocus)) | grep -v grep | awk '{print $4}'`

if [[ $win_name = "alacritty" ]]
then
  tmux kill-session -t $(tmux display-message -p "#S")
else
  i3 kill
fi
