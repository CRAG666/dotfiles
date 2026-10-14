import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import QtQuick
import qs

// macOS Mojave's volume, microphone and brightness HUD, on Spotlight's glass:
// a rounded square low in the middle of the screen, a large glyph and sixteen
// segments. Volume and the microphone come straight from PipeWire, so any
// change shows it (the keys, a mixer or an app); brightness.sh reports the
// level it sets as "brightness 40" lines on a fifo. The surface stays mapped,
// hidden in the background layer, because a fresh one costs ~40 ms before its
// first frame.
Scope {
    id: root
    property string kind: "volume"   // "volume", "mic" or "brightness"
    property real level: 0           // 0..1
    property bool muted: false
    property bool shown: false
    // PipeWire's first values at startup are no change worth showing
    property bool armed: false

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool sinkMuted: sink?.audio?.muted ?? false
    readonly property bool micMuted: source?.audio?.muted ?? false

    onVolumeChanged: show("volume", volume, sinkMuted)
    onSinkMutedChanged: show("volume", volume, sinkMuted)
    onMicMutedChanged: show("mic", 1, micMuted)

    function show(newKind, newLevel, newMuted) {
        if (!armed)
            return;
        if (!shown)
            Wallpaper.refresh();
        kind = newKind;
        level = Math.max(0, Math.min(1, newLevel));
        muted = newMuted;
        shown = true;
        hideTimer.restart();
    }

    function glyph() {
        if (kind === "brightness")
            return String.fromCodePoint(0xF00E0);
        if (kind === "mic")
            return String.fromCodePoint(muted ? 0xF036D : 0xF036C);
        if (muted || level === 0)
            return String.fromCodePoint(0xF0581);
        return String.fromCodePoint(level <= 0.33 ? 0xF057F : level <= 0.66 ? 0xF0580 : 0xF057E);
    }

    PwObjectTracker {
        objects: [root.sink, root.source].filter(node => node)
    }

    Timer {
        interval: 1500
        running: Pipewire.ready
        onTriggered: root.armed = true
    }

    Timer {
        id: hideTimer
        interval: 1500
        onTriggered: root.shown = false
    }

    Process {
        running: true
        command: ["sh", "-c", 'echo "$PPID" > "$1.pid"; rm -f "$1"; mkfifo -m 600 "$1"; exec cat 0<> "$1"', "sh", (Quickshell.env("XDG_RUNTIME_DIR") || "/tmp") + "/osd.fifo"]
        stdout: SplitParser {
            onRead: line => {
                const [kind, value] = line.split(" ");
                if (kind === "brightness")
                    root.show("brightness", Number(value) / 100, false);
            }
        }
        onRunningChanged: if (!running) running = true
    }

    PanelWindow {
        id: win
        readonly property real u: Math.min(screen.width / 1920, screen.height / 1080) * 1.2
        readonly property int bottomGap: Math.round(screen.height * 0.12)
        screen: FocusedOutput.screen
        color: "transparent"
        // on top only while visible, fade-out included
        WlrLayershell.layer: hud.opacity > 0 ? WlrLayer.Overlay : WlrLayer.Background
        WlrLayershell.namespace: "qs-osd"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        exclusionMode: ExclusionMode.Ignore
        anchors.bottom: true
        margins.bottom: bottomGap
        // room around the square for its shadow
        implicitWidth: Math.round(260 * u)
        implicitHeight: Math.round(260 * u)
        mask: Region {}

        // the blur behind the square (see Glass); the window is centred
        // horizontally and bottomGap above the screen's bottom edge
        WallBlur {
            id: wallBlur
            visible: false
            x: -Math.round((win.screen.width - win.width) / 2)
            y: win.height + win.bottomGap - win.screen.height
            width: win.screen.width
            height: win.screen.height
        }

        Item {
            id: hud
            anchors.centerIn: parent
            width: Math.round(200 * win.u)
            height: width
            opacity: root.shown ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: root.shown ? 90 : 300; easing.type: Easing.OutCubic } }

            Glass {
                anchors.fill: parent
                radius: Math.round(18 * win.u)
                u: win.u
                backdrop: wallBlur
                origin: Qt.point(hud.x, hud.y)
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: root.kind === "mic" ? 0 : -Math.round(12 * win.u)
                text: root.glyph()
                color: Theme.ink
                font.family: Theme.menu
                font.pixelSize: Math.round(92 * win.u)
                renderType: Text.NativeRendering
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Math.round(22 * win.u)
                visible: root.kind !== "mic"
                spacing: Math.round(2 * win.u)

                Repeater {
                    model: 16

                    Rectangle {
                        required property int index
                        width: Math.round(8 * win.u)
                        height: Math.round(8 * win.u)
                        color: !root.muted && index < Math.round(root.level * 16) ? Theme.ink : Theme.hairline
                    }
                }
            }
        }
    }
}
