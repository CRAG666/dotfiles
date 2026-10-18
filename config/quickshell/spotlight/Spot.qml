pragma Singleton
import Quickshell
import QtQuick
import "js/search.js" as Search

// Paths and small actions shared by spotlight.qml and its stores.
Singleton {
    readonly property string home: Quickshell.env("HOME")
    readonly property string dataDir: (Quickshell.env("XDG_DATA_HOME") || home + "/.local/share") + "/spotlight"
    readonly property string stateDir: (Quickshell.env("XDG_STATE_HOME") || home + "/.local/state") + "/spotlight"
    readonly property string cacheDir: (Quickshell.env("XDG_CACHE_HOME") || home + "/.cache") + "/spotlight"
    // what you configure: spotlight.json and the script commands, apart from the code
    readonly property string configDir: (Quickshell.env("XDG_CONFIG_HOME") || home + "/.config") + "/spotlight"
    readonly property string configFile: configDir + "/spotlight.json"
    // the Python helper, a package: python3 runs its __main__.py
    readonly property string helper: home + "/.config/quickshell/spotlight/helper"
    // Spotlight's window sets it from the size of the screen it opens on
    property real scale: 1
    readonly property var terminals: ["kitty", "foot", "Alacritty", "org.wezfurlong.wezterm", "com.mitchellh.ghostty", "ghostty.dialog"]

    // run after Spotlight closes: send the paste shortcut to the focused window
    // (terminals take Ctrl+Shift+V)
    readonly property string pasteKeys: `sleep 0.3
app=$(scrollmsg -t get_tree | jq -r '[.. | select(.focused? == true)][0] | .app_id // .window_properties.class // ""')
case "$app" in
kitty | foot | Alacritty | org.wezfurlong.wezterm | com.mitchellh.ghostty | ghostty.dialog) wtype -M ctrl -M shift v -m shift -m ctrl ;;
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

    // whole pixels keep text and icons on the pixel grid, so they stay sharp
    function px(value) {
        return Math.round(value * scale);
    }

    function copy(text) {
        Quickshell.execDetached(["wl-copy", "--", text]);
    }

    function open(target) {
        Quickshell.execDetached(["xdg-open", target]);
    }

    // `path` in $EDITOR, at `line` when given, for a terminal prefix to run
    function editor(path, line) {
        return ["sh", "-c", '"${EDITOR:-nvim}" ${2:+"+$2"} "$1"', "sh", path, line === undefined ? "" : String(line)];
    }

    function tilde(path) {
        return path === home || path.startsWith(home + "/") ? "~" + path.slice(home.length) : path;
    }

    function basename(path) {
        return path.slice(path.lastIndexOf("/") + 1);
    }

    // "" for a bare name
    function dirname(path) {
        return path.slice(0, Math.max(0, path.lastIndexOf("/")));
    }

    function dateTime(milliseconds) {
        return new Date(milliseconds).toLocaleString(Qt.locale(), Locale.ShortFormat);
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

    // keeps the terminal open after `command` ends
    function hold(command) {
        return ["sh", "-c", '"$@"; printf "\\n[exit %s] Press Enter to close" "$?"; read -r _', "sh", ...command];
    }

    // runs the helper, its failure shown as a notification
    function helperCommand(args) {
        return ["sh", "-c", 'out=$(python3 "$@" 2>&1) || notify-send -u critical Spotlight "$out"', "sh", helper, ...args];
    }

    function helperDetached(args) {
        Quickshell.execDetached(helperCommand(args));
    }

    // reads the (asynchronously loaded) app list, so callers refresh once it arrives
    function iconFor(name) {
        const id = name.toLowerCase();
        const entry = DesktopEntries.applications.values.find(app => app.id.toLowerCase() === id || app.startupClass.toLowerCase() === id);
        return (entry ?? DesktopEntries.heuristicLookup(name))?.icon ?? "application-x-executable";
    }

    // "now", "5 min", "3 h" or "2 d" since `time` (ms)
    function ago(time) {
        const minutes = Math.round((Date.now() - time) / 60000);
        if (minutes < 1)
            return "now";
        if (minutes < 60)
            return minutes + " min";
        return minutes < 1440 ? Math.round(minutes / 60) + " h" : Math.round(minutes / 1440) + " d";
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
