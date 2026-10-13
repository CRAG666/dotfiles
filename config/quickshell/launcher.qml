//@ pragma IconTheme Macjaro
import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Effects

// Fullscreen app launcher (rofi `launcher`): the wallpaper blurs in like the
// lock, with a search pill over an 8×4 grid of apps. Arrows/Tab move, Enter or
// click launches; Esc or a click on empty space closes.
//   qs -n -p ~/.config/quickshell/launcher.qml
ShellRoot {
    PanelWindow {
        id: win
        readonly property real u: height / 1440
        readonly property var apps: Apps.search(search.text)
        onAppsChanged: grid.currentIndex = 0

        property bool shown: false
        Component.onCompleted: shown = true

        // whole pixels keep text and icons on the pixel grid, so they stay sharp
        function px(value) {
            return Math.round(value * u);
        }

        function launch(app) {
            Apps.launch(app);
            Qt.quit();
        }

        color: "transparent"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "qs-launcher"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        exclusionMode: ExclusionMode.Ignore
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        // the halo is a separate layer behind the text, so the glyphs themselves
        // are drawn natively instead of being resampled from a texture
        component Label: Item {
            property alias text: label.text
            property alias color: label.color
            property alias font: label.font
            property alias elide: label.elide
            property alias horizontalAlignment: label.horizontalAlignment
            implicitWidth: label.implicitWidth
            implicitHeight: label.implicitHeight

            MultiEffect {
                anchors.fill: label
                source: label
                shadowEnabled: true
                shadowColor: "black"
                shadowOpacity: 0.6
                shadowBlur: 0.5
                blurMax: 24
            }
            Text {
                id: label
                width: parent.width
                color: Theme.fg(true)
                font.family: Theme.menu
                font.weight: Font.DemiBold
                renderType: Text.NativeRendering
            }
        }

        WallBlur {
            anchors.fill: parent
            blurred: win.shown
        }

        MouseArea {
            anchors.fill: parent
            onClicked: Qt.quit()
        }

        Item {
            anchors.fill: parent
            opacity: win.shown ? 1 : 0
            scale: win.shown ? 1 : 1.04
            Behavior on opacity { NumberAnimation { duration: 350; easing.type: Easing.OutCubic } }
            Behavior on scale { NumberAnimation { duration: 450; easing.type: Easing.OutCubic } }

            Rectangle {
                id: pill
                width: win.px(680)
                height: win.px(72)
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: win.px(110)
                radius: height / 2
                color: Qt.alpha(Wallpaper.tint, 0.14)
                border.width: Math.max(1, win.px(2))
                border.color: search.text !== "" ? Wallpaper.tint : Qt.alpha(Wallpaper.tint, 0.45)
                Behavior on border.color { ColorAnimation { duration: 200 } }

                Label {
                    id: searchIcon
                    anchors.left: parent.left
                    anchors.leftMargin: win.px(30)
                    anchors.verticalCenter: parent.verticalCenter
                    text: "\uf002"
                    color: Wallpaper.tint
                    font.pixelSize: win.px(26)
                }

                Label {
                    anchors.left: search.left
                    anchors.verticalCenter: parent.verticalCenter
                    visible: search.text === ""
                    text: "Search apps"
                    color: Qt.alpha(Theme.fg(true), 0.65)
                    font.pixelSize: win.px(26)
                }

                TextInput {
                    id: search
                    anchors.left: searchIcon.right
                    anchors.leftMargin: win.px(18)
                    anchors.right: parent.right
                    anchors.rightMargin: win.px(30)
                    anchors.verticalCenter: parent.verticalCenter
                    focus: true
                    clip: true
                    color: Theme.fg(true)
                    selectionColor: Qt.alpha(Wallpaper.tint, 0.5)
                    font.family: Theme.menu
                    font.weight: Font.DemiBold
                    font.pixelSize: win.px(26)
                    renderType: Text.NativeRendering
                    onAccepted: if (grid.count) win.launch(win.apps[grid.currentIndex])

                    Keys.onPressed: event => {
                        const page = grid.columns * grid.rows;
                        switch (event.key) {
                        case Qt.Key_Escape:
                            Qt.quit();
                            break;
                        case Qt.Key_Left:
                            grid.moveCurrentIndexLeft();
                            break;
                        case Qt.Key_Right:
                            grid.moveCurrentIndexRight();
                            break;
                        case Qt.Key_Up:
                            grid.moveCurrentIndexUp();
                            break;
                        case Qt.Key_Down:
                            grid.moveCurrentIndexDown();
                            break;
                        case Qt.Key_Tab:
                            if (grid.count)
                                grid.currentIndex = (grid.currentIndex + 1) % grid.count;
                            break;
                        case Qt.Key_Backtab:
                            if (grid.count)
                                grid.currentIndex = (grid.currentIndex - 1 + grid.count) % grid.count;
                            break;
                        case Qt.Key_PageUp:
                            grid.currentIndex = Math.max(0, grid.currentIndex - page);
                            break;
                        case Qt.Key_PageDown:
                            grid.currentIndex = Math.min(grid.count - 1, grid.currentIndex + page);
                            break;
                        default:
                            return;
                        }
                        event.accepted = true;
                    }
                }
            }

            GridView {
                id: grid
                readonly property int columns: 8
                readonly property int rows: 4
                anchors.top: pill.bottom
                anchors.topMargin: win.px(60)
                anchors.horizontalCenter: parent.horizontalCenter
                cellWidth: win.px(220)
                cellHeight: win.px(240)
                width: columns * cellWidth
                height: rows * cellHeight
                clip: true
                keyNavigationWraps: true
                model: win.apps
                highlightMoveDuration: 120
                highlight: Rectangle {
                    radius: win.px(28)
                    color: Qt.alpha(Wallpaper.tint, 0.3)
                    border.width: 1
                    border.color: Qt.alpha(Wallpaper.tint, 0.7)
                }

                delegate: Item {
                    id: tile
                    required property var modelData
                    required property int index
                    width: grid.cellWidth
                    height: grid.cellHeight

                    Column {
                        x: Math.round((parent.width - width) / 2)
                        y: Math.round((parent.height - height) / 2)
                        width: parent.width - win.px(24)
                        spacing: win.px(18)

                        Image {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: win.px(128)
                            height: width
                            sourceSize: Qt.size(256, 256)
                            source: Quickshell.iconPath(tile.modelData.icon, "application-x-executable")
                            asynchronous: true
                        }
                        Label {
                            width: parent.width
                            text: tile.modelData.name
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                            font.pixelSize: win.px(24)
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: grid.currentIndex = tile.index
                        onClicked: win.launch(tile.modelData)
                    }
                }

                Label {
                    anchors.centerIn: parent
                    visible: grid.count === 0
                    text: "No matches"
                    color: Qt.alpha(Theme.fg(true), 0.65)
                    font.pixelSize: win.px(26)
                }
            }
        }
    }
}
