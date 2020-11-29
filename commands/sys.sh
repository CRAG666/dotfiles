#!/usr/bin/env bash

# Realtime system info
#
# Use: watch -ct -n0 sys.sh
#
# TODO:
# 1. Netspeed
# 2. Open ports ?


# color definitions
RESET=$'\e[0m'
BOLD_GREEN_FG=$'\e[1;32m'
BOLD_WHITE_FG=$'\e[1m'

## RAM Usage
ram=$(free -h | awk '/^Mem:/ {print $3 "/" $2}')

## Show CPU temperature
temperature=$(sensors | awk '/^Core*/ {print $1$2, $3}')

## Most Memory Intensive processes
mem_intensive=$(ps axch -o cmd:15,%mem --sort=-%mem | head)

## Most CPU Intensive processes
cpu_intensive=$(ps axch -o cmd:15,%cpu --sort=-%cpu | head)

## Network usage stats
net_device=$(route | awk '/default/ {print $8}')
TRANSMITTED=$(ifconfig "$net_device" | awk '/TX packets/ {print $6$7}')
RECEIVED=$(ifconfig "$net_device" | awk '/RX packets/ {print $6$7}')

pc_uptime=$(uptime -p | awk '{for (i=2; i<NF; i++) printf $i " "; if (NF >= 1) print $NF; }')

printf "%70s\n\n" "${BOLD_WHITE_FG}System Monitor${RESET}"
printf "%s\n\n" "${BOLD_GREEN_FG}Network Usage since${RESET} $pc_uptime"
printf "%s\n" " TRANSMITTED : $TRANSMITTED"
printf "%s\n" " RECEIVED    : $RECEIVED"

printf "\n%s\n" "${BOLD_GREEN_FG}RAM :${RESET} $ram"

printf "\n%s\n\n" "${BOLD_GREEN_FG}CPU Temperature 🌡 : ${RESET}"
printf "%s\n" "$temperature"

printf "\n%s\n\n" "${BOLD_GREEN_FG}Most Memory Intensive Processes${RESET}"
printf "%s" "$mem_intensive"

printf "\n\n%s\n\n" "${BOLD_GREEN_FG}Most CPU Intensive Processes${RESET}"
printf "%s\n\n" "$cpu_intensive"

