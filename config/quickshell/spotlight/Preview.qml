import Quickshell
import QtQuick
import qs

// The selection described by its store: image, swatch, icon or glyph, title,
// subtitle, details and body, scrolling when long, with label → value facts at
// the foot, like Raycast's metadata
Item {
    id: root
    property var host
    readonly property alias info: preview.info

    function scroll(delta) {
        preview.contentY = Math.max(0, Math.min(preview.contentHeight - preview.height, preview.contentY + delta));
    }

    Flickable {
        id: preview
        readonly property var info: host.selection ? host.describe(host.selection) : null
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: facts.visible ? facts.top : parent.bottom
        anchors.margins: Spot.px(24)
        anchors.bottomMargin: facts.visible ? Spot.px(12) : Spot.px(24)
        clip: true
        contentHeight: details.implicitHeight
        boundsBehavior: Flickable.StopAtBounds
        visible: info !== null

        Column {
            id: details
            y: host.mode === "clipboard" ? 0 : Math.max(0, (preview.height - implicitHeight) / 2)
            width: preview.width
            spacing: Spot.px(8)

            Image {
                width: parent.width
                height: Spot.px(200)
                visible: !!preview.info?.image
                fillMode: Image.PreserveAspectFit
                sourceSize: Qt.size(Spot.px(800), Spot.px(600))
                source: preview.info?.image ?? ""
                asynchronous: true
            }
            Rectangle {
                width: parent.width
                height: Spot.px(140)
                visible: !!preview.info?.swatch
                radius: Spot.px(16)
                color: preview.info?.swatch ?? "transparent"
                border.width: 1
                border.color: Theme.hairline
            }
            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                width: Spot.px(104)
                height: Spot.px(104)
                readonly property bool showsIcon: !preview.info?.image && !preview.info?.glyph && !preview.info?.swatch && !!preview.info?.icon
                visible: showsIcon
                sourceSize: Qt.size(Spot.px(208), Spot.px(208))
                source: showsIcon ? Quickshell.iconPath(preview.info?.icon ?? "", "application-x-executable") : ""
                asynchronous: true
            }
            Label {
                width: parent.width
                visible: !!preview.info?.glyph
                topPadding: Spot.px(24)
                horizontalAlignment: Text.AlignHCenter
                fontSizeMode: Text.HorizontalFit
                minimumPixelSize: Spot.px(18)
                text: preview.info?.glyph ?? ""
                color: host.selection?.kind === "emoji" ? Theme.ink : host.tone(host.selection)
                font.family: host.selection?.kind === "emoji" ? "Noto Color Emoji" : Theme.menu
                font.pixelSize: preview.info?.glyph?.length > 2 ? Spot.px(48) : Spot.px(72)
                font.weight: Font.Bold
            }
            Label {
                width: parent.width
                visible: text !== ""
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                text: preview.info?.title ?? ""
                font.family: Theme.menu
                font.pixelSize: Spot.px(20)
                font.weight: Font.Bold
            }
            Label {
                width: parent.width
                visible: text !== ""
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                maximumLineCount: 3
                elide: Text.ElideMiddle
                text: preview.info?.subtitle ?? ""
                color: Theme.inkSoft
            }
            Repeater {
                model: (preview.info?.details ?? []).filter(line => line)

                Label {
                    required property string modelData
                    width: details.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    text: modelData
                    color: Theme.inkSoft
                    font.pixelSize: Spot.px(12)
                }
            }
            Rectangle {
                width: parent.width
                height: body.implicitHeight + Spot.px(24)
                visible: !!preview.info?.body
                radius: Spot.px(10)
                color: Theme.fill

                Label {
                    id: body
                    x: Spot.px(12)
                    y: Spot.px(12)
                    width: parent.width - Spot.px(24)
                    wrapMode: Text.Wrap
                    textFormat: preview.info?.markdown ? Text.MarkdownText : Text.PlainText
                    text: preview.info?.body ?? ""
                    color: preview.info?.mono ? Theme.eyes.green1 : Theme.ink
                    linkColor: Theme.eyes.blue0
                    font.family: preview.info?.mono ? "Iosevka Nerd Font" : Theme.menuText
                    font.pixelSize: preview.info?.mono ? Spot.px(11) : Spot.px(13)
                    onLinkActivated: link => Spot.open(link)
                }
            }
        }
    }

    // label → value rows at the foot of the preview, like Raycast's metadata
    Column {
        id: facts
        readonly property var rows: (preview.info?.metadata ?? []).filter(([label, value]) => value !== undefined && value !== null && value !== "")
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: Spot.px(24)
        anchors.rightMargin: Spot.px(24)
        anchors.bottomMargin: Spot.px(10)
        visible: preview.visible && rows.length > 0

        Repeater {
            model: facts.rows

            Item {
                required property var modelData
                width: facts.width
                height: Spot.px(30)

                Rectangle {
                    width: parent.width
                    height: 1
                    color: Theme.hairline
                }
                Label {
                    id: factLabel
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: parent.modelData[0]
                    color: Theme.inkSoft
                    font.pixelSize: Spot.px(12)
                }
                Label {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    width: Math.min(implicitWidth, parent.width - factLabel.implicitWidth - Spot.px(16))
                    horizontalAlignment: Text.AlignRight
                    elide: Text.ElideMiddle
                    text: String(parent.modelData[1])
                    font.pixelSize: Spot.px(12)
                }
            }
        }
    }
}
