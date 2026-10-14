pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

// eyes palette + fonts. Each widget zone (date / player / system) gets its own
// light/dark variant, chosen from the wallpaper brightness behind it. The awww
// wallpaper scripts write `date=`/`player=`/`system=` (light|dark) into
// theme.state, which FileView watches live. Colours are functions of a `dark`
// bool so each widget can resolve its own palette.
Singleton {
    id: root

    property bool dateDark: true
    property bool playerDark: true
    property bool systemDark: true

    FileView {
        id: stateFile
        path: Quickshell.env("HOME") + "/.config/quickshell/theme.state"
        watchChanges: true
        blockLoading: true
        onFileChanged: reload()
        onLoaded: root.parseState(text())
        onLoadFailed: {
            root.dateDark = true;
            root.playerDark = true;
            root.systemDark = true;
        }
    }

    // global light/dark mode chosen by eyes-theme (drives the rofi-style menus)
    property bool eyesDark: false

    FileView {
        path: Quickshell.env("HOME") + "/.config/eyes/mode"
        watchChanges: true
        blockLoading: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: root.eyesDark = text().trim() === "dark"
    }

    function parseState(t) {
        function zone(key) {
            const m = t.match(new RegExp(key + "\\s*=\\s*(\\w+)"));
            return m ? (m[1].toLowerCase() !== "light") : true;
        }
        root.dateDark = zone("date");
        root.playerDark = zone("player");
        root.systemDark = zone("system");
    }

    // palette: each colour is a function of `d` (dark?) → eyes-dark : eyes-light
    function fg(d)     { return d ? "#d0dcc8" : "#1a1a1a"; }
    function muted(d)  { return d ? "#7a8a78" : "#3a4838"; }
    function blue(d)   { return d ? "#6a94a8" : "#1e4868"; }
    function teal(d)   { return d ? "#5ab8a8" : "#145850"; }
    function green(d)  { return d ? "#7aab72" : "#2a5c22"; }
    function pink(d)   { return d ? "#b890b0" : "#5a2858"; }
    function orange(d) { return d ? "#c87868" : "#7a1e18"; }
    function yellow(d) { return d ? "#d4b85a" : "#5a4808"; }
    function line(d)   { return d ? Qt.rgba(0.82, 0.86, 0.78, 0.65) : Qt.rgba(0.10, 0.13, 0.10, 0.55); }
    function track(d)  { return d ? Qt.rgba(0.82, 0.86, 0.78, 0.25) : Qt.rgba(0.10, 0.13, 0.10, 0.22); }
    function shadow(d) { return d ? "#000000" : "#eef2ea"; }
    function bg(d)     { return d ? "#1a211a" : "#add4a0"; }
    function bgAlt(d)  { return d ? "#2d382d" : "#96be8c"; }

    // selection colours, one picked at random per menu like rofi/colors/eyes*.txt
    function accents(d) {
        return d
            ? ["#c87868", "#b89a6a", "#c8a870", "#d4b85a", "#7aab72", "#88b878", "#5ab8a8", "#6ab8b0", "#6a94a8", "#82aab8", "#9090b8", "#b890b0", "#8a9a88", "#536053"]
            : ["#7a1e18", "#6a3c10", "#7a4a18", "#5a4808", "#2a5c22", "#1e4a18", "#145850", "#1a5858", "#1e4868", "#143c52", "#3a2860", "#5a2858", "#486040", "#6a9060"];
    }

    // the macOS-like popups (Spotlight, notifications, the HUD) follow eyesDark
    readonly property color ink: eyesDark ? "#f5f5f7" : "#1d1d1f"
    readonly property color inkSoft: eyesDark ? Qt.rgba(1, 1, 1, 0.55) : Qt.rgba(0, 0, 0, 0.5)
    readonly property color hairline: eyesDark ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.1)
    // over the blurred wallpaper (Spotlight); `surface` stands without the blur
    readonly property color glass: eyesDark ? Qt.alpha(Qt.tint(Qt.rgba(0.11, 0.11, 0.12, 1), Qt.alpha(Wallpaper.tint, 0.08)), 0.9) : Qt.alpha(Qt.tint(Qt.rgba(0.96, 0.96, 0.97, 1), Qt.alpha(Wallpaper.tint, 0.18)), 0.68)
    readonly property color surface: Qt.alpha(glass, 0.94)
    // a full-strength accent shouts on the dark glass, so it is calmed there
    readonly property color accent: eyesDark ? Qt.hsla(Wallpaper.accent.hslHue, Math.min(Wallpaper.accent.hslSaturation, 0.55), 0.42, 1) : Wallpaper.accent

    readonly property string sans: "SFProDisplay Nerd Font Propo"
    readonly property string mono: "SFMono Nerd Font Mono"
    readonly property string cursive: "Inspiration"
    readonly property string menu: "SFProDisplay Nerd Font Propo"
    readonly property string menuText: "SFProText Nerd Font Propo"
}
