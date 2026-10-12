#!/bin/bash

show_help() {
    echo "Uso: $0 [-m MODE] [-a] [-h]"
    echo "  -m MODE: Especifica el modo de gráficos (intel, nvidia, amd)"
    echo "  -a: Modo automático (detecta GPU disponible y si está enchufado)"
    echo "  -h: Muestra este mensaje de ayuda"
    exit 1
}

validate_mode() {
    case "$1" in
    intel | nvidia | amd) ;;
    *)
        echo "Modo de gráficos '$1' no válido. Usa: intel, nvidia o amd"
        show_help
        ;;
    esac
}

# Detect whether on AC power or battery (only relevant on hybrid GPUs)
detect_power_mode() {
    # Method 1: using acpi
    if command -v acpi &>/dev/null; then
        if acpi -a | grep -q "on-line"; then
            echo "nvidia"
        else
            echo "intel"
        fi
        return
    fi

    # Method 2: check /sys/class/power_supply
    for adapter in /sys/class/power_supply/A*/online; do
        if [ -f "$adapter" ] && [ "$(cat "$adapter")" = "1" ]; then
            echo "nvidia"
            return
        fi
    done

    # Default: battery (Intel)
    echo "intel"
}

# Prints "card render" (two lines) for the given vendor pattern, or nothing.
detect_device() {
    local pci
    pci=$(lspci -k | grep -E '(VGA|3D)' | grep -iE "$1" | awk '{print $1}')
    [ -z "$pci" ] && return
    ls -l /dev/dri/by-path | grep "$pci" | awk -F/ '{print $NF}'
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

# ─── Detect devices ───────────────────────────────────────────────────────────

DEVICE_INTEL=$(detect_device 'intel')
DEVICE_NVIDIA=$(detect_device 'nvidia')
DEVICE_AMD=$(detect_device 'amd|ati')

CARD_INTEL=$(echo "$DEVICE_INTEL" | awk 'NR==1')
RENDER_INTEL=$(echo "$DEVICE_INTEL" | awk 'NR==2')
CARD_NVIDIA=$(echo "$DEVICE_NVIDIA" | awk 'NR==1')
RENDER_NVIDIA=$(echo "$DEVICE_NVIDIA" | awk 'NR==2')
CARD_AMD=$(echo "$DEVICE_AMD" | awk 'NR==1')
RENDER_AMD=$(echo "$DEVICE_AMD" | awk 'NR==2')

[ -n "$DEVICE_INTEL" ] && echo "Intel : $CARD_INTEL (render: $RENDER_INTEL)"
[ -n "$DEVICE_NVIDIA" ] && echo "NVIDIA: $CARD_NVIDIA (render: $RENDER_NVIDIA)"
[ -n "$DEVICE_AMD" ] && echo "AMD   : $CARD_AMD (render: $RENDER_AMD)"

# ─── Automatic mode ───────────────────────────────────────────────────────────

if [ "$AUTO_MODE" = true ]; then
    if [ -n "$DEVICE_NVIDIA" ]; then
        # Hybrid Intel+NVIDIA GPU: switch based on power source.
        MODE=$(detect_power_mode)
    elif [ -n "$DEVICE_AMD" ]; then
        MODE="amd"
    else
        MODE="intel"
    fi
    echo "Modo detectado automáticamente: $MODE"
fi

# If neither a mode nor auto was given, show help
if [ -z "$MODE" ]; then
    echo "Debe especificar un modo (-m) o usar detección automática (-a)."
    show_help
fi

# ─── Apply configuration ──────────────────────────────────────────────────────

HYPR_CONF="$HOME/.config/hypr/hyprland.conf"

# Point hyprland.conf at the right GPU file, whatever the current one is.
sed -i -E "s#^source = \./(intel|nvidia|amd)\.conf#source = ./${MODE}.conf#" "$HYPR_CONF"

case "$MODE" in
"intel")
    echo "Configurando para Intel (ahorro de energía)..."
    sed -i -E "s#/dev/dri/renderD[0-9]+#/dev/dri/${RENDER_INTEL}#g" "$HOME/.config/hypr/intel.conf"
    start-hyprland >/dev/null 2>&1
    ;;
"nvidia")
    echo "Configurando para NVIDIA (máximo rendimiento)..."
    sed -i -E "s#/dev/dri/renderD[0-9]+#/dev/dri/${RENDER_NVIDIA}#g" "$HOME/.config/hypr/nvidia.conf"
    start-hyprland >/dev/null 2>&1
    ;;
"amd")
    echo "Configurando para AMD (GPU integrada)..."
    sed -i -E "s#/dev/dri/renderD[0-9]+#/dev/dri/${RENDER_AMD}#g" "$HOME/.config/hypr/amd.conf"
    start-hyprland >/dev/null 2>&1
    ;;
esac
