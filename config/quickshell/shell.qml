import Quickshell
import Quickshell.Wayland
import QtQuick

// One fullscreen, transparent, click-through surface per monitor, pinned to
// the bottom layer (above the wallpaper, behind every window — conky-like).
// Widgets are
// anchored inside and scale with `u = screen height / 1440`, so the layout
// adapts to any resolution.
ShellRoot {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData
            color: "transparent"

            WlrLayershell.layer: WlrLayer.Bottom
            WlrLayershell.namespace: "qs-desktop-widgets"
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            exclusionMode: ExclusionMode.Ignore

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            // empty input region → fully click-through
            mask: Region {}

            Item {
                anchors.fill: parent
                property real u: height / 1440

                DateBlock {
                    u: parent.u
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 64 * parent.u
                }

                PlayerBlock {
                    u: parent.u
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 150 * parent.u
                }

                SystemBlock {
                    u: parent.u
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 48 * parent.u
                }
            }
        }
    }
}
