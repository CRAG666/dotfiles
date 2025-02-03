#!/usr/bin/env bash
sleep 1
systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=Hyprland

# sleep 1
# killall -e xdg-desktop-portal-hyprland
# killall xdg-desktop-portal
# killall xdg-desktop-portal-wlr
# killall xdg-desktop-portal-termfilechooser
# killall xdg-desktop-portal-gtk
# /usr/lib/xdg-desktop-portal-hyprland &
# /usr/lib/xdg-desktop-portal-gtk &
# /usr/lib/xdg-desktop-portal-termfilechooser &
#
# sleep 2
# /usr/lib/xdg-desktop-portal &
