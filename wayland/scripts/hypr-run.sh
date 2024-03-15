#!/bin/bash

show_help() {
	echo "Uso: $0 [-m MODE] [-h]"
	echo "  -m MODE: Especifica el modo de gráficos (intel, nvidia, hybrid)"
	echo "  -h: Muestra este mensaje de ayuda"
	exit 1
}

validate_mode() {
	if [ "$1" != "intel" ] && [ "$1" != "nvidia" ] && [ "$1" != "hybrid" ]; then
		echo "Modo de gráficos '$1' no válido."
		show_help
	fi
}

MODE=""
while getopts ":m:h" opt; do
	case ${opt} in
	m)
		MODE=$OPTARG
		validate_mode "$MODE"
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

if [ -z "$MODE" ]; then
	echo "Debe especificar un modo de gráficos."
	show_help
fi

DRM_DEVICE="/dev/dri/"
if [ "$MODE" = "hybrid" ]; then
	DEVICE_NAME=$(ls -l /dev/dri/by-path | grep "$(lspci -k | grep -E '(VGA|3D)' | grep -i "intel" | awk '{print $1}')" | awk -F/ '{print $NF}')
	DEVICE_NVIDIA=$(ls -l /dev/dri/by-path | grep "$(lspci -k | grep -E '(VGA|3D)' | grep -i "nvidia" | awk '{print $1}')" | awk -F/ '{print $NF}')
else
	DEVICE_NAME=$(ls -l /dev/dri/by-path | grep "$(lspci -k | grep -E '(VGA|3D)' | grep -i "$MODE" | awk '{print $1}')" | awk -F/ '{print $NF}')
fi

CARD=$(echo "$DEVICE_NAME" | awk 'NR==1')

if [ "$CARD" = "card0" ]; then
	export WLR_DRM_DEVICES="/dev/dri/card0:/dev/dri/card1"
else
	export WLR_DRM_DEVICES="/dev/dri/card1:/dev/dri/card0"
fi

RENDER=$(echo "$DEVICE_NAME" | awk 'NR==2')

case "$MODE" in
"intel")
	sed -i "s/nvidia/intel/" "$HOME/.config/hypr/hyprland.conf"
	sed -i "s/hybrid/intel/" "$HOME/.config/hypr/hyprland.conf"
	;;
"nvidia")
	sed -i "s/intel/nvidia/" "$HOME/.config/hypr/hyprland.conf"
	sed -i "s/hybrid/nvidia/" "$HOME/.config/hypr/hyprland.conf"
	;;
"hybrid")
	sed -i "s/intel/hybrid/" "$HOME/.config/hypr/hyprland.conf"
	sed -i "s/nvidia/hybrid/" "$HOME/.config/hypr/hyprland.conf"
	RENDER=$(echo "$DEVICE_NVIDIA" | awk 'NR==2')
	;;
esac

export MOZ_WAYLAND_DRM_DEVICE="${DRM_DEVICE}${RENDER}"
export MOZ_DRM_DEVICE="${DRM_DEVICE}${RENDER}"

fastfetch -l ~/.config/fastfetch/thinkpad.txt --logo-color-1 white --logo-color-2 red --logo-color-3 '38;2;23;147;209'

Hyprland >/dev/null 2>&1
