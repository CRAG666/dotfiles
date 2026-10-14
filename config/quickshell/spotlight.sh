#!/bin/sh
# Toggle Spotlight, opening it in an optional mode (clipboard, windows, commands,
# passwords, bookmarks, notes, quicklinks, marks, run, ...). Spotlight stays
# resident and hidden between uses: a toggle is one IPC call, and the first one
# starts it ("start" only starts it, e.g. at login). "toggle-mark" unmarks the
# focused window when it has a mark and otherwise asks for one.
# Compositor keybindings run with a bare PATH, so pi, jq and eyes-theme are put
# back on it for the resident instance.
config="$HOME/.config/quickshell/spotlight.qml"
mode="${1:-}"

if [ "$mode" = toggle-mark ]; then
    mark=$(scrollmsg -t get_tree | jq -r '[.. | objects | select(.focused? == true)][0].marks[0] // empty')
    [ -n "$mark" ] && exec scrollmsg unmark "$mark" > /dev/null
    mode="mark-add"
fi
if [ "$mode" != start ]; then
    qs ipc -p "$config" call spotlight toggle "$mode" > /dev/null 2>&1 && exit 0
fi

mkdir -p "${XDG_STATE_HOME:-$HOME/.local/state}/spotlight"
export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"
qs -n -d -p "$config" > /dev/null 2>&1
[ "$mode" = start ] && exit 0
for _ in $(seq 50); do
    qs ipc -p "$config" call spotlight toggle "$mode" > /dev/null 2>&1 && exit 0
    sleep 0.05
done
echo "spotlight.sh: Spotlight did not start within 5s" >&2
exit 1
