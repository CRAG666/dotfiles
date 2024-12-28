#!/usr/bin/env bash

dir="$HOME/.config/rofi/menu"
theme='style-2'

## Run
rofi \
    -show $1 \
    -theme ${dir}/${theme}.rasi
