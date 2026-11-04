import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import QtQuick

// macOS's privacy indicator: while an app records the microphone (a PipeWire
// audio capture stream) or xdg-desktop-portal-wlr shares the screen (its
// "xdpw-stream-" source), a pill at the top centre of the focused screen names
// them with Sonoma's orange and violet dots. The top right is the banners'.
// Cameras opened through V4L2, as browsers do, never reach PipeWire.
Scope {
    id: root
    readonly property var nodes: Pipewire.nodes.values
    readonly property var recorders: nodes.filter(node => node.type === PwNodeType.AudioInStream)
    readonly property bool sharing: nodes.some(node => node.type === PwNodeType.VideoSource && node.name.startsWith("xdpw-stream-"))
    readonly property var uses: recorders.map(node => ({
                tone: Theme.eyes.orange0,
                label: node.properties["application.name"] ?? node.name
            })).concat(sharing ? [{ tone: Theme.eyes.violet, label: "Screen" }] : [])

    // application.name is only read from bound nodes
    PwObjectTracker {
        objects: root.recorders
    }

    FocusedPanel {
        id: win
        readonly property real u: Math.min(screen.width / 1920, screen.height / 1080) * 1.2
        mapped: root.uses.length > 0
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "qs-privacy"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        exclusionMode: ExclusionMode.Ignore
        anchors.top: true
        margins.top: Math.round(6 * u)
        implicitWidth: pill.width
        implicitHeight: pill.height
        mask: Region {}

        Rectangle {
            id: pill
            width: row.implicitWidth + height
            height: Math.round(22 * win.u)
            radius: height / 2
            color: Theme.eyes.bg0

            Row {
                id: row
                anchors.centerIn: parent
                spacing: Math.round(12 * win.u)

                Repeater {
                    model: root.uses

                    Row {
                        id: use
                        required property var modelData
                        spacing: Math.round(5 * win.u)

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: Math.round(8 * win.u)
                            height: width
                            radius: width / 2
                            color: use.modelData.tone
                        }

                        Text {
                            text: use.modelData.label
                            color: Theme.eyes.fg1
                            font.family: Theme.menuText
                            font.pixelSize: Math.round(12 * win.u)
                            renderType: Text.NativeRendering
                        }
                    }
                }
            }
        }
    }
}
