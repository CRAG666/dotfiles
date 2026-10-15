pragma Singleton
import Quickshell
import QtQuick
import "search.js" as Search

// Paths and small actions shared by spotlight.qml and its stores.
Singleton {
    readonly property string home: Quickshell.env("HOME")
    readonly property string dataDir: (Quickshell.env("XDG_DATA_HOME") || home + "/.local/share") + "/spotlight"
    readonly property string stateDir: (Quickshell.env("XDG_STATE_HOME") || home + "/.local/state") + "/spotlight"
    readonly property string cacheDir: (Quickshell.env("XDG_CACHE_HOME") || home + "/.cache") + "/spotlight"
    readonly property string helper: home + "/.config/quickshell/spotlight/spotlight.py"
    readonly property var terminals: ["kitty", "foot", "Alacritty", "org.wezfurlong.wezterm", "com.mitchellh.ghostty"]

    // run after Spotlight closes: send the paste shortcut to the focused window
    // (terminals take Ctrl+Shift+V)
    readonly property string pasteKeys: `sleep 0.3
app=$(scrollmsg -t get_tree | jq -r '[.. | select(.focused? == true)][0] | .app_id // .window_properties.class // ""')
case "$app" in
kitty | foot | Alacritty | org.wezfurlong.wezterm | com.mitchellh.ghostty) wtype -M ctrl -M shift v -m shift -m ctrl ;;
*) wtype -M ctrl v -m ctrl ;;
esac`

    // `tokens` come from Search.tokens; `loose` false keeps to exact matches
    function matches(text, tokens, loose = true) {
        return Search.score(Search.fold(text), tokens, loose) > 0;
    }

    // for text a store folded once with Search.fold when it loaded, instead of on
    // every keystroke
    function matchesFolded(haystack, tokens, loose = true) {
        return Search.score(haystack, tokens, loose) > 0;
    }

    function copy(text) {
        Quickshell.execDetached(["wl-copy", "--", text]);
    }

    // type into the window that had focus once Spotlight is gone, then walk the
    // cursor back to {cursor}; the clipboard is left untouched
    function type(text) {
        const marker = "{cursor}";
        const at = text.indexOf(marker);
        const command = ["sh", "-c", 'sleep 0.25; wtype -- "$1"; shift; [ $# -eq 0 ] || wtype "$@"', "sh", text.split(marker).join("")];
        const lefts = at < 0 ? 0 : [...text.slice(at + marker.length).split(marker).join("")].length;
        for (let step = 0; step < lefts; step++)
            command.push("-k", "Left");
        Quickshell.execDetached(command);
    }

    // runs spotlight.py detached and surfaces a failure as a notification
    function helperDetached(args) {
        Quickshell.execDetached(["sh", "-c", 'out=$(python3 "$@" 2>&1) || notify-send -u critical Spotlight "$out"', "sh", helper, ...args]);
    }

    // reads the (asynchronously loaded) app list, so callers refresh once it arrives
    function iconFor(name) {
        const id = name.toLowerCase();
        const entry = DesktopEntries.applications.values.find(app => app.id.toLowerCase() === id || app.startupClass.toLowerCase() === id);
        return (entry ?? DesktopEntries.heuristicLookup(name))?.icon ?? "application-x-executable";
    }

    function formatSize(bytes) {
        const units = ["bytes", "KB", "MB", "GB", "TB"];
        let size = bytes;
        let unit = 0;
        while (size >= 1000 && unit < units.length - 1) {
            size /= 1000;
            unit++;
        }
        return (unit ? size.toFixed(1) : size) + " " + units[unit];
    }
}
