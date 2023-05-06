#!/bin/sh

# Session
export XDG_SESSION_TYPE=wayland
export XDG_SESSION_DESKTOP=wlroots
export XDG_CURRENT_DESKTOP=wlroots
# export XDG_CURRENT_SESSION=wlroots
# export XDG_CACHE_HOME="/tmp/$USER/.cache"
# export XDG_RUNTIME_DIR=/run/user/$(id -u)

source /usr/local/bin/wayland_enablement.sh

# Set Vars for Hardware Video Acceleration
DRM_DEVICE="/dev/dri/renderD"
if vainfo --display drm --device ${DRM_DEVICE}128 >/dev/null 2>&1; then
  export MOZ_WAYLAND_DRM_DEVICE=${DRM_DEVICE}128
  export MOZ_DRM_DEVICE=${DRM_DEVICE}128
else
  export MOZ_WAYLAND_DRM_DEVICE=${DRM_DEVICE}129
  export MOZ_DRM_DEVICE=${DRM_DEVICE}129
fi

exec start-newm -d
# WLR_DRM_DEVICES=/dev/dri/card0:/dev/dri/card1 start-newm -d
# WLR_DRM_DEVICES="/dev/dri/card0" start-newm -d
# dbus-run-session start-newm -d
