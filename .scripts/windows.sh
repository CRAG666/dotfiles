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
    echo "El contenedor no existe, iniciando..."
    podman-compose --file "$COMPOSE_FILE" start
elif [[ "$STATUS" == *"Paused"* ]]; then
    echo "El contenedor está pausado, reanudando..."
    podman-compose --file "$COMPOSE_FILE" unpause
elif [[ "$STATUS" == *"Exited"* ]]; then
    echo "El contenedor está detenido, iniciando..."
    podman-compose --file "$COMPOSE_FILE" start
else
    echo "El contenedor ya está corriendo."
fi

notify-send "Windows 11" "Intentando conectar vía RDP..." --icon=gnome-remote-desktop --urgency=normal

while true; do
    echo "Intentando conectar a $CONTAINER_NAME vía RDP..."

    if timeout 5 bash -c "echo > /dev/tcp/$WIN_IP/3389" 2>/dev/null; then
        echo "Puerto RDP disponible. Iniciando sesión..."

        notify-send "Windows 11" "Abriendo..." --icon=windows --urgency=normal

        # Iniciar sesión RDP
        xfreerdp3 \
            /u:$WIN_USER /p:$WIN_PASS /v:$WIN_IP \
            /t:Windows \
            /drive:$GUEST_SHARE_NAME,$HOST_SHARE_PATH \
            /sound:sys:alsa /microphone:sys:alsa \
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

        echo "Sesión RDP finalizada."
        break
    else
        echo "Conexión no disponible, reintentando en 3 segundos..."
        sleep 3
    fi
done

echo "Script finalizado."
notify-send "Windows" "Saliendo..." --icon=wine-uninstaller --urgency=low
podman-compose --file "$COMPOSE_FILE" pause
