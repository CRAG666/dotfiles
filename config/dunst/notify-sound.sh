#!/bin/bash
summary="$2"

if [ "$summary" = "Volume" ]; then
    exit 0
fi

paplay ~/.config/dunst/normal.wav &
