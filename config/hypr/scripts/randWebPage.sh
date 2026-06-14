#!/bin/bash
hora_actual=$(date +%H)
if [ "$hora_actual" -ge 7 ] && [ "$hora_actual" -lt 12 ]; then
    count=${1:-60}
    for ((i = 1; i <= count; i++)); do
        $BROWSER "https://searchmysite.net/search/random" &
    done
fi
