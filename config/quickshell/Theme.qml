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
    function fg(d)     { return d ? "#e4e0cc" : "#231d18"; }
    function muted(d)  { return d ? "#b6b4ac" : "#3a4838"; }
    function blue(d)   { return d ? "#a2cdf7" : "#073c6e"; }
    function teal(d)   { return d ? "#95ded1" : "#004d44"; }
    function green(d)  { return d ? "#bfe6a1" : "#294f01"; }
    function pink(d)   { return d ? "#efb7db" : "#661b53"; }
    function orange(d) { return d ? "#ffbab1" : "#630005"; }
    function yellow(d) { return d ? "#f1de95" : "#574a00"; }
    function line(d)   { return d ? Qt.rgba(0.89, 0.88, 0.80, 0.65) : Qt.rgba(0.10, 0.13, 0.10, 0.55); }
    function track(d)  { return d ? Qt.rgba(0.89, 0.88, 0.80, 0.25) : Qt.rgba(0.10, 0.13, 0.10, 0.22); }
    function shadow(d) { return d ? "#000000" : "#eef2ea"; }
    function bg(d)     { return d ? "#192019" : "#f7dbb9"; }
    function bgAlt(d)  { return d ? "#2c372c" : "#e6c7a3"; }

    // selection colours, one picked at random per menu like rofi/colors/eyes*.txt
    function accents(d) {
        return d
            ? ["#ffbab1", "#f7bc95", "#f4cb94", "#f1de95", "#bfe6a1", "#96d4a6", "#95ded1", "#96d4e2", "#a2cdf7", "#a8d7f0", "#d5c9fc", "#efb7db", "#adbaa9", "#667366"]
            : ["#630005", "#5e2600", "#5f3700", "#574a00", "#294f01", "#003d1b", "#004d44", "#003e4c", "#073c6e", "#00314e", "#3f206c", "#661b53", "#473b2d", "#b1936e"];
    }

    // nvim's eyes palette (config/nvim/colors/eyes.lua), whole and by name, for
    // the macOS Sequoia popups (Spotlight, notifications, the HUD, the auth sheet)
    readonly property var eyes: eyesDark ? ({
        bg0: "#192019",
        bg1: "#1f271f",
        bg2: "#252f25",
        bg3: "#2c372c",
        bg4: "#3a463a",
        bg5: "#667366",
        fg0: "#e4e0cc",
        fg1: "#d0d4be",
        fg2: "#bbc7b0",
        green0: "#bfe6a1",
        green1: "#96d4a6",
        green2: "#c3c799",
        teal: "#95ded1",
        blue0: "#a2cdf7",
        blue1: "#a8d7f0",
        violet: "#d5c9fc",
        aqua: "#96d4e2",
        orange0: "#f7bc95",
        orange1: "#f4cb94",
        red: "#ffbab1",
        yellow: "#f1de95",
        pink: "#efb7db",
        ash: "#9fb9a1",
        gray0: "#adbaa9",
        gray1: "#b6b4ac",
        gray2: "#a2afa0",
        winterGreen: "#253525",
        winterBlue: "#223243",
        winterRed: "#442928",
        winterYellow: "#3b3520"
    }) : ({
        bg0: "#f7dbb9",
        bg1: "#f2d5b2",
        bg2: "#edcfac",
        bg3: "#e6c7a3",
        bg4: "#dab992",
        bg5: "#b1936e",
        fg0: "#231d18",
        fg1: "#31251a",
        fg2: "#483523",
        green0: "#294f01",
        green1: "#003d1b",
        green2: "#383f17",
        teal: "#004d44",
        blue0: "#073c6e",
        blue1: "#00314e",
        violet: "#3f206c",
        aqua: "#003e4c",
        orange0: "#5e2600",
        orange1: "#5f3700",
        red: "#630005",
        yellow: "#574a00",
        pink: "#661b53",
        ash: "#504531",
        gray0: "#473b2d",
        gray1: "#3b3931",
        gray2: "#392e23",
        winterGreen: "#b2e2af",
        winterBlue: "#b3d7e9",
        winterRed: "#f2c7c2",
        winterYellow: "#e4dcab"
    })

    // their roles, as nvim gives them to its floats: the Pmenu bg3 under a
    // FloatBorder bg5 edge, so they stand off the bg0 terminals; blue0, eyes'
    // Title and url colour, as macOS's accent, which also marks the selection in
    // light mode, as macOS's does (the dark one keeps eyes' bg5)
    readonly property color ink: eyes.fg0
    readonly property color inkSoft: eyesDark ? eyes.fg2 : eyes.gray2
    readonly property color glass: Qt.alpha(eyes.bg3, 0.9)
    readonly property color border: eyes.bg5
    readonly property color hairline: eyes.bg4
    readonly property color fill: eyesDark ? eyes.bg4 : eyes.bg1
    readonly property color selection: eyesDark ? eyes.bg5 : eyes.blue0
    readonly property color selectionText: eyesDark ? eyes.fg0 : eyes.bg0
    readonly property color accent: eyes.blue0
    readonly property color accentText: eyes.bg0
    readonly property color alert: eyes.red

    readonly property string sans: "SFProDisplay Nerd Font Propo"
    readonly property string mono: "SFMono Nerd Font Mono"
    readonly property string cursive: "Inspiration"
    readonly property string menu: "SFProDisplay Nerd Font Propo"
    readonly property string menuText: "SFProText Nerd Font Propo"
}
