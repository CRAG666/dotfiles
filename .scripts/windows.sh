#!/bin/bash

# Configuración de la VM
WIN_USER="MyWindowsUser"
WIN_PASS="MyWindowsPassword"
WIN_IP="localhost"
HOST_SHARE_PATH="/home/think-crag/Público/Windows"
GUEST_SHARE_NAME="Linux"
COMPOSE_FILE=~/Git/winapps/compose.yaml
CONTAINER_NAME="WinApps"

# Obtener información del monitor enfocado
MONITOR_INFO=$(hyprctl monitors -j | jq '.[] | select(.focused == true)')
WIDTH=$(echo "$MONITOR_INFO" | jq -r '.width')
HEIGHT=$(echo "$MONITOR_INFO" | jq -r '.height')
WIDTH=$((WIDTH - 16))
HEIGHT=$((HEIGHT - 16))

# Verificar estado del contenedor
STATUS=$(podman ps -a --filter "name=$CONTAINER_NAME" --format "{{.Status}}")

if [ -z "$STATUS" ]; then
	podman-compose --file "$COMPOSE_FILE" up -d
	notify-send "Windows 11" "Powering on..." --icon=windows --urgency=normal
	sleep 10
elif [[ "$STATUS" == *"Paused"* ]]; then
	podman-compose --file "$COMPOSE_FILE" unpause
	notify-send "Windows 11" "Unpause..." --icon=windows --urgency=normal
	sleep 5
elif [[ "$STATUS" == *"Exited"* ]] || [[ "$STATUS" == *"Created"* ]]; then
	podman-compose --file "$COMPOSE_FILE" start
	notify-send "Windows 11" "Powering on..." --icon=windows --urgency=normal
	sleep 5
else
	notify-send "Windows 11" "Abriendo..." --icon=windows --urgency=normal
fi

notify-send "Windows 11" "Abriendo..." --icon=windows --urgency=normal

# Iniciar sesión RDP
xfreerdp3 \
	/u:$WIN_USER /p:$WIN_PASS /v:$WIN_IP \
	/t:Windows \
	/drive:$GUEST_SHARE_NAME,$HOST_SHARE_PATH \
	/sound:sys:pulse /microphone:sys:pulse \
	+clipboard \
	-grab-keyboard \
	/size:${WIDTH}x${HEIGHT} \
	/dynamic-resolution \
	-themes -menu-anims -window-drag \
	-fonts
# /bpp:32 \
# /gfx:AVC444:on,progressive:on \
# /compression-level:0 \
# +async-channels \

notify-send "Windows" "Saliendo..." --icon=wine-uninstaller --urgency=low
podman-compose --file "$COMPOSE_FILE" pause
