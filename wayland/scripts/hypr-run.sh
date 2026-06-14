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

# Detecta si está enchufado o con batería (solo relevante en GPU híbrida)
detect_power_mode() {
    # Método 1: usando acpi
    if command -v acpi &>/dev/null; then
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

# Devuelve "card render" (dos líneas) para el patrón de proveedor dado, o nada.
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

# ─── Detectar dispositivos ────────────────────────────────────────────────────

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

# ─── Modo automático ──────────────────────────────────────────────────────────

if [ "$AUTO_MODE" = true ]; then
    if [ -n "$DEVICE_NVIDIA" ]; then
        # GPU híbrida Intel+NVIDIA: alternar según alimentación.
        MODE=$(detect_power_mode)
    elif [ -n "$DEVICE_AMD" ]; then
        MODE="amd"
    else
        MODE="intel"
    fi
    echo "Modo detectado automáticamente: $MODE"
fi

# Si no se especificó modo ni auto, mostrar ayuda
if [ -z "$MODE" ]; then
    echo "Debe especificar un modo (-m) o usar detección automática (-a)."
    show_help
fi

# ─── Aplicar configuración ────────────────────────────────────────────────────

HYPR_CONF="$HOME/.config/hypr/hyprland.conf"

# Apuntar hyprland.conf al archivo de GPU correcto, sea cual sea el actual.
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
