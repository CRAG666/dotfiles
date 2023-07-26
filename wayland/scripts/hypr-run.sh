#!/bin/sh

# Set Vars for Hardware Video Acceleration
DRM_DEVICE="/dev/dri/renderD"
if vainfo --display drm --device "${DRM_DEVICE}"128 >/dev/null 2>&1; then
	export MOZ_WAYLAND_DRM_DEVICE=${DRM_DEVICE}128
	export MOZ_DRM_DEVICE=${DRM_DEVICE}128
else
	export MOZ_WAYLAND_DRM_DEVICE=${DRM_DEVICE}129
	export MOZ_DRM_DEVICE=${DRM_DEVICE}129
fi

exec Hyprland
