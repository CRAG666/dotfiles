#!/usr/bin/env bash
sleep 1
systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=Hyprland

sleep 1
killall -e xdg-desktop-portal-hyprland
killall xdg-desktop-portal
/usr/lib/xdg-desktop-portal-hyprland &

sleep 2
/usr/lib/xdg-desktop-portal &
