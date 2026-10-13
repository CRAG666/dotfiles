pragma Singleton
import Quickshell
import QtQuick

// The current awww wallpaper (wall.set symlink) and a pastel tint lifted from
// its most saturated colour, so the lock and launchers match any wallpaper.
Singleton {
    id: root
    readonly property string source: "file://" + Quickshell.env("HOME") + "/.config/awww/wall.set"

    readonly property color vivid: {
        let best = Qt.hsla(0, 0, 0.8, 1);
        for (const c of palette.colors)
            if (c.hslSaturation > best.hslSaturation)
                best = c;
        return best;
    }
    readonly property color tint: Qt.hsla(Math.max(0, vivid.hslHue), Math.min(vivid.hslSaturation, 0.6), 0.8, 1)
    // same hue at mid lightness: a selection fill that carries white text
    readonly property color accent: Qt.hsla(Math.max(0, vivid.hslHue), Math.min(Math.max(vivid.hslSaturation, 0.45), 0.75), 0.5, 1)

    ColorQuantizer {
        id: palette
        source: root.source
        depth: 3
        rescaleSize: 64
    }
}
