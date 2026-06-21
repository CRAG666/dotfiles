#!/bin/bash

show_help() {
    echo "Usage: $0 [-m MODE] [-a] [-h]"
    echo "  -m MODE: Specify the graphics mode (intel, nvidia, nvidia-only, amd)"
    echo "           nvidia-only: NVIDIA only, assumes external monitor (no eDP)"
    echo "           amd: integrated AMD GPU (e.g. ThinkPad L14 Ryzen)"
    echo "  -a: Automatic mode (detects available GPU and whether plugged in)"
    echo "  -h: Show this help message"
    exit 1
}

validate_mode() {
    case "$1" in
    intel | nvidia | nvidia-only | amd) ;;
    *)
        echo "Invalid graphics mode '$1'. Use: intel, nvidia, nvidia-only or amd"
        show_help
        ;;
    esac
}

detect_power_mode() {
    if command -v acpi &>/dev/null; then
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

detect_device() {
    local pci
    pci=$(lspci -k | grep -E '(VGA|3D)' | grep -iE "$1" | awk '{print $1}')
    [ -z "$pci" ] && return
    ls -l /dev/dri/by-path | grep "$pci" | awk -F/ '{print $NF}'
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
    export GTK_IM_MODULE=simple
    export DISABLE_QT5_COMPAT=0
    export ANKI_WAYLAND=1
    export SDL_VIDEODRIVER=wayland
    export ECORE_EVAS_ENGINE=wayland_egl
    export ELM_ENGINE=wayland_egl
    export AVALONIA_GLOBAL_SCALE_FACTOR=1
    export XDG_SCREENSHOTS_DIR=~/Screenshots
    export CLUTTER_BACKEND=wayland
    export XCURSOR_THEME=Adwaita
    export XCURSOR_SIZE=30
    export MOZ_CURSOR_SIZE=30
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
    export MOZ_DISABLE_RDD_SANDBOX=1
    export CUDA_DISABLE_PERF_BOOST=1
    export WLR_DRM_DEVICES=/dev/dri/${CARD_INTEL}:/dev/dri/${CARD_NVIDIA}
}

set_amd_env() {
    export LIBVA_DRIVER_NAME=radeonsi
    export VDPAU_DRIVER=radeonsi
    export MOZ_WAYLAND_DRM_DEVICE=/dev/dri/${RENDER_AMD}
    export MOZ_DRM_DEVICE=/dev/dri/${RENDER_AMD}
    export MOZ_WEBRENDER=1
    export WLR_DRM_DEVICES=/dev/dri/${CARD_AMD}
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
        echo "Invalid option: -$OPTARG" >&2
        show_help
        ;;
    :)
        echo "Option -$OPTARG requires an argument." >&2
        show_help
        ;;
    esac
done

shift $((OPTIND - 1))

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

if [ "$AUTO_MODE" = true ]; then
    if [ -n "$DEVICE_NVIDIA" ]; then
        # Intel+NVIDIA hybrid: choose based on power source.
        MODE=$(detect_power_mode)
    elif [ -n "$DEVICE_AMD" ]; then
        MODE="amd"
    else
        MODE="intel"
    fi
    echo "Automatically detected mode: $MODE"
fi

if [ -z "$MODE" ]; then
    echo "You must specify a mode (-m) or use automatic detection (-a)."
    show_help
fi

case "$MODE" in
"intel")
    echo "Configuring for Intel (power saving)..."
    set_default_env
    set_intel_env
    exec scroll
    ;;
"nvidia")
    echo "Configuring for NVIDIA (maximum performance)..."
    set_default_env
    set_nvidia_env
    exec scroll
    ;;
"nvidia-only")
    echo "Configuring for NVIDIA exclusive (external monitor only)..."
    set_default_env
    set_nvidia_env
    export WLR_DRM_DEVICES=/dev/dri/${CARD_NVIDIA}
    if command -v brightnessctl &>/dev/null; then
        brightnessctl --device=intel_backlight set 0 &>/dev/null
    fi
    exec scroll
    ;;
"amd")
    echo "Configuring for AMD (integrated GPU)..."
    set_default_env
    set_amd_env
    exec scroll
    ;;
esac
