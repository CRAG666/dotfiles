#!/bin/sh

#
# GTK environment
#
# export GDK_BACKEND=wayland
export TDESKTOP_DISABLE_GTK_INTEGRATION=1
export CLUTTER_BACKEND=wayland
export BEMENU_BACKEND=wayland

# Firefox
export MOZ_DISABLE_RDD_SANDBOX=1
export MOZ_ENABLE_WAYLAND=1
# export MOZ_WEBRENDER=1
# export MOZ_WAYLAND_DRM_DEVICE=/dev/dri/renderD128
# export MOZ_DRM_DEVICE=/dev/dri/renderD128

#
# Qt environment
#
export QT_QPA_PLATFORM=wayland-egl
# export QT_QPA_PLATFORM=wayland
export QT_WAYLAND_FORCE_DPI=physical
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export QT_AUTO_SCREEN_SCALE_FACTOR=1

#
# Elementary environment
#
# export ELM_DISPLAY=wl
export ECORE_EVAS_ENGINE=wayland_egl
export ELM_ENGINE=wayland_egl
export ELM_ACCEL=opengl
# export ELM_SCALE=1

#
# SDL environment
#
export SDL_VIDEODRIVER=wayland

#
# Java environment
#
export _JAVA_AWT_WM_NONREPARENTING=1

export NO_AT_BRIDGE=1
export WINIT_UNIX_BACKEND=wayland
# unset WAYLAND_DISPLAY

#
# LibreOffice
#
export SAL_USE_VCLPLUGIN=gtk3
