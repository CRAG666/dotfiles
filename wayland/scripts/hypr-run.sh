#!/bin/sh

# source /usr/local/bin/wayland_enablement.sh
# Set Vars for Hardware Video Acceleration
DRM_DEVICE="/dev/dri/renderD"
if vainfo --display drm --device "${DRM_DEVICE}"128 >/dev/null 2>&1; then
	export MOZ_WAYLAND_DRM_DEVICE=${DRM_DEVICE}128
	export MOZ_DRM_DEVICE=${DRM_DEVICE}128
	export WLR_DRM_DEVICES=/dev/dri/card0
else
	export MOZ_WAYLAND_DRM_DEVICE=${DRM_DEVICE}129
	export MOZ_DRM_DEVICE=${DRM_DEVICE}129
	export WLR_DRM_DEVICES=/dev/dri/card1
fi

WLR_DEVICE="/dev/dri/card"
if vainfo --display drm --device "${WLR_DEVICE}"0 >/dev/null 2>&1; then
	export WLR_DRM_DEVICES=${WLR_DEVICE}0
else
	export WLR_DRM_DEVICES=${WLR_DEVICE}1
fi

exec Hyprland
