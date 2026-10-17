#!/usr/bin/env bash
sleep 1
dbus-update-activation-environment --systemd --all
sleep 1
systemctl --user restart xdg-desktop-portal.service
