#!/bin/sh
# Toggle Spotlight, opening it in an optional mode (clipboard, windows, commands,
# passwords, bookmarks, notes, quicklinks, marks, run, ...). "toggle-mark"
# unmarks the focused window when it has a mark and otherwise asks for one.
# Compositor keybindings run with a bare PATH, so pi, jq and eyes-theme are put
# back on it here.
config="$HOME/.config/quickshell/spotlight.qml"
mode="${1:-}"

qs kill -p "$config" > /dev/null 2>&1 && exit 0
if [ "$mode" = toggle-mark ]; then
    mark=$(scrollmsg -t get_tree | jq -r '[.. | objects | select(.focused? == true)][0].marks[0] // empty')
    [ -n "$mark" ] && exec scrollmsg unmark "$mark" > /dev/null
    mode="mark-add"
fi
mkdir -p "${XDG_STATE_HOME:-$HOME/.local/state}/spotlight"
export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"
SPOTLIGHT_MODE="$mode" exec qs -n -p "$config"
