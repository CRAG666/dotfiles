#!/bin/sh
# Toggle Spotlight, opening it in an optional mode (clipboard, windows, commands,
# passwords, bookmarks, notes, quicklinks, marks, run, ...) or the fullscreen
# app launcher ("launcher", which shares Spotlight's process). Spotlight stays
# resident and hidden between uses: a toggle is one line written to its fifo
# (qs ipc when nothing reads the fifo), and the first one starts it ("start"
# only starts it, e.g. at login). "toggle-mark" unmarks the
# focused window when it has a mark and otherwise asks for one.
# Compositor keybindings run with a bare PATH, so pi, jq and eyes-theme are put
# back on it for the resident instance, and nvim for the terminals it opens.
# It runs as `quickshell`, not `qs`: CachyOS's ananicy rules renice `qs` to 10
# like a background service, and every key press would wait behind real work.
config="$HOME/.config/quickshell/spotlight.qml"
fifo="${XDG_RUNTIME_DIR:-/tmp}/spotlight.fifo"
mode="${1:-}"

if [ "$mode" = toggle-mark ]; then
    mark=$(scrollmsg -t get_tree | jq -r '[.. | objects | select(.focused? == true)][0].marks[0] // empty')
    [ -n "$mark" ] && exec scrollmsg unmark "$mark" > /dev/null
    mode="mark-add"
fi
if [ "$mode" != start ]; then
    # only shell builtins: Spotlight's pid must still be a quickshell process,
    # which keeps the fifo open, so the write cannot block
    if read -r pid 2>/dev/null < "$fifo.pid" && read -r name 2>/dev/null < "/proc/$pid/comm" && [ "$name" = quickshell ] && [ -p "$fifo" ]; then
        printf 'toggle %s\n' "$mode" > "$fifo"
        exit 0
    fi
    qs ipc -p "$config" call spotlight toggle "$mode" > /dev/null 2>&1 && exit 0
fi

mkdir -p "${XDG_STATE_HOME:-$HOME/.local/state}/spotlight"
export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$HOME/.local/share/bob/nvim-bin:$PATH"
quickshell -n -d -p "$config" > /dev/null 2>&1
[ "$mode" = start ] && exit 0
for _ in $(seq 50); do
    qs ipc -p "$config" call spotlight toggle "$mode" > /dev/null 2>&1 && exit 0
    sleep 0.05
done
echo "spotlight.sh: Spotlight did not start within 5s" >&2
exit 1
