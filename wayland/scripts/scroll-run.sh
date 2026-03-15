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

detect_power_mode() {
    if command -v acpi &> /dev/null; then
        if acpi -a | grep -q "on-line"; then
            echo "nvidia"
        else
            echo "intel"
        fi
        return
    fi
    for adapter in /sys/class/power_supply/A*/online; do
        if [ -f "$adapter" ] && [ "$(cat "$adapter")" = "1" ]; then
            echo "nvidia"
            return
        fi
    done
    echo "intel"
}

set_default_env() {
    export XDG_CURRENT_DESKTOP=scroll
    export XDG_SESSION_TYPE=wayland
    export XDG_SESSION_DESKTOP=scroll
    export ELECTRON_OZONE_PLATFORM_HINT=wayland
    export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
    export QT_SCALE_FACTOR_ROUNDING_POLICY=RoundPreferFloor
    export GDK_BACKEND=wayland
    export TERMCMD="kitty -T yazi"
    export EDITOR=nvim
    export BROWSER=zen-browser
    export QT_QPA_PLATFORM=wayland
    export QT_QPA_PLATFORMTHEME=xdgdesktopportal
    export QT_AUTO_SCREEN_SCALE_FACTOR=1
    export MOZ_ENABLE_WAYLAND=1
    export GDK_SCALE=1
    export GDK_DEBUG=portals
    export GTK_USE_PORTAL=1
    export DISABLE_QT5_COMPAT=0
    export ANKI_WAYLAND=1
    export SDL_VIDEODRIVER=wayland
    export ECORE_EVAS_ENGINE=wayland_egl
    export ELM_ENGINE=wayland_egl
    export AVALONIA_GLOBAL_SCALE_FACTOR=1
    export XDG_SCREENSHOTS_DIR=~/Screenshots
    export CLUTTER_BACKEND=wayland
    export XCURSOR_THEME=catppuccin-mocha-red-cursors
    export XCURSOR_SIZE=30
    export GTK_THEME=catppuccin-mocha-red-standard
    export GPG_TTY=$(tty)
}

set_intel_env() {
    export LIBVA_DRIVER_NAME=iHD
    export VDPAU_DRIVER=va_gl
    export MOZ_WAYLAND_DRM_DEVICE=/dev/dri/${RENDER_INTEL}
    export MOZ_DRM_DEVICE=/dev/dri/${RENDER_INTEL}
}

set_nvidia_env() {
    export LIBVA_DRIVER_NAME=nvidia
    export VDPAU_DRIVER=nvidia
    export GBM_BACKEND=nvidia-drm
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export NVD_BACKEND=direct
    # export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json
    # export VK_DRIVER_FILES=/usr/share/vulkan/icd.d/nvidia_icd.json
    export MOZ_WAYLAND_DRM_DEVICE=/dev/dri/${RENDER_NVIDIA}
    export MOZ_DRM_DEVICE=/dev/dri/${RENDER_NVIDIA}
    export MOZ_WEBRENDER=1
    export WLR_NO_HARDWARE_CURSORS=1
    export MOZ_DISABLE_RDD_SANDBOX=1
    export CUDA_DISABLE_PERF_BOOST=1
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

if [ "$AUTO_MODE" = true ]; then
    MODE=$(detect_power_mode)
    echo "Modo detectado automáticamente: $MODE"
fi

if [ -z "$MODE" ]; then
    echo "Debe especificar un modo (-m) o usar detección automática (-a)."
    show_help
fi

# ─── Detectar dispositivos ────────────────────────────────────────────────────

DEVICE_INTEL=$(ls -l /dev/dri/by-path | grep "$(lspci -k | grep -E '(VGA|3D)' | grep -i "intel" | awk '{print $1}')" | awk -F/ '{print $NF}')
DEVICE_NVIDIA=$(ls -l /dev/dri/by-path | grep "$(lspci -k | grep -E '(VGA|3D)' | grep -i "nvidia" | awk '{print $1}')" | awk -F/ '{print $NF}')

CARD_INTEL=$(echo "$DEVICE_INTEL" | awk 'NR==1')
RENDER_INTEL=$(echo "$DEVICE_INTEL" | awk 'NR==2')
CARD_NVIDIA=$(echo "$DEVICE_NVIDIA" | awk 'NR==1')
RENDER_NVIDIA=$(echo "$DEVICE_NVIDIA" | awk 'NR==2')

echo "Intel : $CARD_INTEL (render: $RENDER_INTEL)"
echo "NVIDIA: $CARD_NVIDIA (render: $RENDER_NVIDIA)"

case "$MODE" in
"intel")
    echo "Configurando para Intel (ahorro de energía)..."
    set_default_env
    set_intel_env
    exec scroll
    ;;
"nvidia")
    echo "Configurando para NVIDIA (máximo rendimiento)..."
    set_default_env
    set_nvidia_env
    exec prime-run scroll
    ;;
esac
