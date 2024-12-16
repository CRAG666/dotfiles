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

if [ "$MODE" = "hybrid" ]; then
	DEVICE_INTEL=$(ls -l /dev/dri/by-path | grep "$(lspci -k | grep -E '(VGA|3D)' | grep -i "intel" | awk '{print $1}')" | awk -F/ '{print $NF}')
	DEVICE_NAME=$(ls -l /dev/dri/by-path | grep "$(lspci -k | grep -E '(VGA|3D)' | grep -i "nvidia" | awk '{print $1}')" | awk -F/ '{print $NF}')
	CARD_NVIDIA=$(echo "$DEVICE_NAME" | awk 'NR==1')
	CARD_INTEL=$(echo "$DEVICE_INTEL" | awk 'NR==1')
	sed -i -E "s#/dev/dri/(card[0-9]+):/dev/dri/(card[0-9]+)#/dev/dri/${CARD_INTEL}:/dev/dri/${CARD_NVIDIA}#g" "$HOME/.config/hypr/hybrid.conf"
else
	DEVICE_NAME=$(ls -l /dev/dri/by-path | grep "$(lspci -k | grep -E '(VGA|3D)' | grep -i "$MODE" | awk '{print $1}')" | awk -F/ '{print $NF}')
fi

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
	;;
esac

RENDER=$(echo "$DEVICE_NAME" | awk 'NR==2')
sed -i "s/renderD[[:alnum:]]*/$RENDER/" "$HOME/.config/hypr/hybrid.conf"

Hyprland >/dev/null 2>&1
