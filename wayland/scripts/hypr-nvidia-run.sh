#!/bin/sh
export LIBVA_DRIVER_NAME=nvidia
export XDG_SESSION_TYPE=wayland
export GBM_BACKEND=nvidia-drm
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export WLR_NO_HARDWARE_CURSORS=1
export MOZ_ENABLE_WAYLAND=1 # (REQUIRED: Firefox will break otherwise.)
export MOZ_WAYLAND_DRM_DEVICE=/dev/dri/renderD128
export MOZ_DRM_DEVICE=/dev/dri/renderD128
export WLR_DRM_DEVICES=/dev/dri/card0

exec Hyprland
