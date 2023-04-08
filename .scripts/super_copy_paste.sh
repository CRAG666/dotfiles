#!/bin/bash
[[ $1 != 'v' ]] || cliphist list | head -1 | cliphist decode | wl-copy
if [[ $2 = 'term' ]]; then
  wtype -M ctrl -M shift $1 -m shift -m ctrl
else
  wtype -M ctrl $1 -m ctrl
fi
