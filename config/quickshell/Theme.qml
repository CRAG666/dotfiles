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

    readonly property string sans: "Montserrat"
    readonly property string mono: "CaskaydiaCove Nerd Font"
    readonly property string cursive: "Sacramento"
}
