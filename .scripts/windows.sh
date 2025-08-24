#!/bin/bash

# Configuración de la VM
VM_NAME="win11pc"
WIN_USER="usuario"
WIN_PASS="1234"
WIN_IP="192.168.122.234"
HOST_SHARE_PATH="/home/think-crag/Público/Windows"
GUEST_SHARE_NAME="Linux"

# Obtener información del monitor enfocado
MONITOR_INFO=$(hyprctl monitors -j | jq '.[] | select(.focused == true)')
WIDTH=$(echo "$MONITOR_INFO" | jq -r '.width')
HEIGHT=$(echo "$MONITOR_INFO" | jq -r '.height')
WIDTH=$((WIDTH - 16))
HEIGHT=$((HEIGHT - 16))

echo "Monitor enfocado detectado: ${WIDTH}x${HEIGHT}"
notify-send "VM Manager" "Monitor detectado: ${WIDTH}x${HEIGHT}" --icon=computer

# Verificar estado de la VM
VM_STATE=$(virsh --connect qemu:///system domstate "$VM_NAME")

if [[ "$VM_STATE" != "ejecutando" ]]; then
    echo "La máquina $VM_NAME está apagada. Iniciando..."
    notify-send "VM Manager" "Iniciando máquina virtual $VM_NAME..." --icon=wine-winecfg --urgency=normal

    virsh --connect qemu:///system start "$VM_NAME"

    echo "Esperando a que la VM inicie..."
    notify-send "VM Manager" "Esperando a que la VM inicie..." --icon=wine-help --urgency=low
    sleep 10
else
    echo "La máquina $VM_NAME ya está encendida."
    notify-send "VM Manager" "La máquina $VM_NAME ya está ejecutándose" --icon=q4wine --urgency=low
fi

# Intentar conexión RDP
notify-send "VM Manager" "Intentando conectar vía RDP..." --icon=gnome-remote-desktop --urgency=normal

while true; do
    echo "Intentando conectar a $VM_NAME vía RDP..."

    if timeout 5 bash -c "echo > /dev/tcp/$WIN_IP/3389" 2>/dev/null; then
        echo "Puerto RDP disponible. Iniciando sesión..."

        notify-send "VM Manager" "Abriendo Windows 10" --icon=q4wine --urgency=normal

        # Iniciar sesión RDP
        xfreerdp3 \
            /u:$WIN_USER /p:$WIN_PASS /v:$WIN_IP \
            /t:Windows \
            /size:${WIDTH}x${HEIGHT} \
            /drive:$GUEST_SHARE_NAME,$HOST_SHARE_PATH \
            /sound:sys:alsa /microphone:sys:alsa \
            +clipboard \
            -grab-keyboard
            # /gfx:AVC444:on,progressive:on
            # /bpp:32
            # /compression-level:0 \
            # +async-channels \
            # +wallpaper -themes -menu-anims -window-drag \
            # -fonts
            # /scale-desktop:100
            # /shell:explorer.exe

        echo "Sesión RDP finalizada."
        break
    else
        echo "Conexión no disponible, reintentando en 3 segundos..."
        sleep 3
    fi
done

echo "Script finalizado."
notify-send "VM Manager" "Saliendo de Windows 10" --icon=wine-uninstaller --urgency=low
