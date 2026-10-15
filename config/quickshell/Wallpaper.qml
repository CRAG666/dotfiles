pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

// The current awww wallpaper (wall.set symlink) and a pastel tint lifted from
// its most saturated colour, so the lock and launchers match any wallpaper.
// The url never changes when wall.set is repointed, so a resident window calls
// refresh() as it opens: the revision bumps, and the image reloads, only when
// the link now points elsewhere.
Singleton {
    id: root
    readonly property string link: Quickshell.env("HOME") + "/.config/awww/wall.set"
    property int revision: 0
    readonly property string source: "file://" + link + (revision ? "?" + revision : "")

    function refresh() {
        target.running = true;
    }

    Process {
        id: target
        property string path: ""
        running: true
        command: ["readlink", "-f", root.link]
        stdout: StdioCollector {
            onStreamFinished: {
                const path = text.trim();
                if (target.path && path !== target.path)
                    root.revision++;
                target.path = path;
            }
        }
    }

    readonly property color vivid: {
        let best = Qt.hsla(0, 0, 0.8, 1);
        for (const c of palette.colors)
            if (c.hslSaturation > best.hslSaturation)
                best = c;
        return best;
    }
    readonly property color tint: Qt.hsla(Math.max(0, vivid.hslHue), Math.min(vivid.hslSaturation, 0.6), 0.8, 1)

    ColorQuantizer {
        id: palette
        source: root.source
        depth: 3
        rescaleSize: 64
    }
}
