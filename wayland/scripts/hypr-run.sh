#!/bin/bash

show_help() {
    echo "Uso: $0 [-m MODE] [-a] [-h]"
    echo "  -m MODE: Especifica el modo de gráficos (intel, nvidia)"
    echo "  -a: Modo automático (detecta si está enchufado)"
    echo "  -h: Muestra este mensaje de ayuda"
    exit 1
}

validate_mode() {
    if [ "$1" != "intel" ] && [ "$1" != "nvidia" ]; then
        echo "Modo de gráficos '$1' no válido. Usa: intel o nvidia"
        show_help
    fi
}

# Detecta si está enchufado o con batería
detect_power_mode() {
    # Método 1: usando acpi
    if command -v acpi &> /dev/null; then
        if acpi -a | grep -q "on-line"; then
            echo "nvidia"
        else
            echo "intel"
        fi
        return
    fi

    # Método 2: checar /sys/class/power_supply
    for adapter in /sys/class/power_supply/A*/online; do
        if [ -f "$adapter" ] && [ "$(cat "$adapter")" = "1" ]; then
            echo "nvidia"
            return
        fi
    done

    # Por defecto: batería (Intel)
    echo "intel"
}

MODE=""
AUTO_MODE=false

while getopts ":m:ah" opt; do
    case ${opt} in
    m)
        MODE=$OPTARG
        validate_mode "$MODE"
        ;;
    a)
        AUTO_MODE=true
        ;;
    h)
        show_help
        ;;
    \?)
        echo "Opción inválida: -$OPTARG" >&2
        show_help
        ;;
    :)
        echo "La opción -$OPTARG requiere un argumento." >&2
        show_help
        ;;
    esac
done

shift $((OPTIND - 1))

# Si modo automático está activado, detectar
if [ "$AUTO_MODE" = true ]; then
    MODE=$(detect_power_mode)
    echo "Modo detectado automáticamente: $MODE"
fi

# Si no se especificó modo ni auto, mostrar ayuda
if [ -z "$MODE" ]; then
    echo "Debe especificar un modo (-m) o usar detección automática (-a)."
    show_help
fi

# Obtener dispositivos
DEVICE_INTEL=$(ls -l /dev/dri/by-path | grep "$(lspci -k | grep -E '(VGA|3D)' | grep -i "intel" | awk '{print $1}')" | awk -F/ '{print $NF}' | awk 'NR==1')
DEVICE_NVIDIA=$(ls -l /dev/dri/by-path | grep "$(lspci -k | grep -E '(VGA|3D)' | grep -i "nvidia" | awk '{print $1}')" | awk -F/ '{print $NF}')

CARD_INTEL=$(echo "$DEVICE_INTEL")
CARD_NVIDIA=$(echo "$DEVICE_NVIDIA" | awk 'NR==1')
RENDER_NVIDIA=$(echo "$DEVICE_NVIDIA" | awk 'NR==2')
RENDER_INTEL=$(ls -l /dev/dri/by-path | grep "$(lspci -k | grep -E '(VGA|3D)' | grep -i "intel" | awk '{print $1}')" | awk -F/ '{print $NF}' | awk 'NR==2')

echo "Intel: $CARD_INTEL (render: $RENDER_INTEL)"
echo "NVIDIA: $CARD_NVIDIA (render: $RENDER_NVIDIA)"

# Actualizar configuración según el modo
case "$MODE" in
"intel")
    echo "Configurando para Intel (ahorro de energía)..."

    sed -i "s/nvidia/intel/" "$HOME/.config/hypr/hyprland.conf"

    # sed -i -E "s#/dev/dri/card[0-9]+#/dev/dri/${CARD_INTEL}#g" "$HOME/.config/hypr/intel.conf"
    sed -i -E "s#/dev/dri/renderD[0-9]+#/dev/dri/${RENDER_INTEL}#g" "$HOME/.config/hypr/intel.conf"
    start-hyprland >/dev/null 2>&1
    ;;

"nvidia")
    echo "Configurando para NVIDIA (máximo rendimiento)..."

    sed -i "s/intel/nvidia/" "$HOME/.config/hypr/hyprland.conf"
    # sed -i -E "s#/dev/dri/(card[0-9]+):/dev/dri/(card[0-9]+)#/dev/dri/${CARD_NVIDIA}:/dev/dri/${CARD_INTEL}#g" "$HOME/.config/hypr/nvidia.conf"
    # sed -i -E "s#/dev/dri/card[0-9]+#/dev/dri/${CARD_INTEL}#g" "$HOME/.config/hypr/nvidia.conf"
    sed -i -E "s#/dev/dri/renderD[0-9]+#/dev/dri/${RENDER_NVIDIA}#g" "$HOME/.config/hypr/nvidia.conf"
    start-hyprland >/dev/null 2>&1
    ;;
esac
