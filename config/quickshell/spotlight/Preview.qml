import Quickshell
import QtQuick
import qs

// The selection described by its store, from the top as Raycast's detail:
// image, swatch, icon or glyph, title, subtitle, details and body, scrolling
// when long, with the label → value facts at the foot under "Metadata". A
// `document` (a note) reads as a page: its title on the left, its text unboxed
Item {
    id: root
    property var host
    readonly property var info: host.selection ? host.describe(host.selection) : null

    function scroll(delta) {
        preview.contentY = Math.max(0, Math.min(preview.contentHeight - preview.height, preview.contentY + delta));
    }

    Flickable {
        id: preview
        // the action bar reads the selection's description; the pane lays it
        // out only while it shows
        readonly property var info: host.previewing ? root.info : null
        x: Spot.px(18)
        y: Spot.px(18)
        width: parent.width - Spot.px(36)
        // as tall as what it shows, so the facts follow it; a long body scrolls
        // above facts kept at the foot
        height: Math.min(contentHeight, parent.height - y - Spot.px(18) - (facts.visible ? facts.implicitHeight + Spot.px(12) : 0))
        clip: true
        contentHeight: details.implicitHeight
        boundsBehavior: Flickable.StopAtBounds
        visible: info !== null

        Column {
            id: details
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
                // 96 macOS points, as the window's other sizes 1.2× them
                width: Spot.px(115)
                height: Spot.px(115)
                readonly property bool showsIcon: !preview.info?.image && !preview.info?.glyph && !preview.info?.swatch && !preview.info?.document && !!preview.info?.icon
                visible: showsIcon
                sourceSize: Qt.size(Spot.px(230), Spot.px(230))
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
                horizontalAlignment: preview.info?.document ? Text.AlignLeft : Text.AlignHCenter
                wrapMode: Text.Wrap
                text: preview.info?.title ?? ""
                font.family: Theme.menu
                font.pixelSize: preview.info?.document ? Spot.px(24) : Spot.px(20)
                font.weight: Font.Bold
            }
            Label {
                width: parent.width
                visible: text !== ""
                horizontalAlignment: preview.info?.document ? Text.AlignLeft : Text.AlignHCenter
                wrapMode: Text.Wrap
                maximumLineCount: 3
                elide: Text.ElideMiddle
                text: preview.info?.subtitle ?? ""
                color: Theme.inkSoft
            }
            Repeater {
                id: detailLines
                readonly property var lines: (preview.info?.details ?? []).filter(line => line)
                // a count, so another selection's lines update the labels in place
                model: lines.length

                Label {
                    required property int index
                    width: details.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    text: detailLines.lines[index] ?? ""
                    color: Theme.inkSoft
                    font.pixelSize: Spot.px(12)
                }
            }
            Rectangle {
                readonly property real inset: preview.info?.document ? 0 : Spot.px(12)
                width: parent.width
                height: body.implicitHeight + 2 * inset
                visible: !!preview.info?.body
                radius: Spot.px(10)
                color: preview.info?.document ? "transparent" : Theme.fill

                Label {
                    id: body
                    x: parent.inset
                    y: parent.inset
                    width: parent.width - 2 * parent.inset
                    wrapMode: Text.Wrap
                    textFormat: preview.info?.markdown ? Text.MarkdownText : Text.PlainText
                    text: preview.info?.body ?? ""
                    color: preview.info?.mono ? Theme.eyes.green1 : Theme.ink
                    linkColor: Theme.eyes.blue0
                    font.family: preview.info?.mono ? "Iosevka Nerd Font" : Theme.menuText
                    font.pixelSize: preview.info?.mono ? Spot.px(11) : preview.info?.document ? Spot.px(14) : Spot.px(13)
                    onLinkActivated: link => Spot.open(link)
                }
            }
        }
    }

    // label → value rows at the foot of the preview, like Raycast's metadata
    Column {
        id: facts
        readonly property var rows: (preview.info?.metadata ?? []).filter(([label, value]) => value !== undefined && value !== null && value !== "")
        x: Spot.px(18)
        y: preview.y + preview.height + Spot.px(12)
        width: parent.width - Spot.px(36)
        visible: preview.visible && rows.length > 0

        Label {
            bottomPadding: Spot.px(6)
            text: "Metadata"
            color: Theme.inkSoft
            font.pixelSize: Spot.px(12)
            font.weight: Font.DemiBold
        }
        Repeater {
            model: facts.rows.length

            Item {
                required property int index
                readonly property var fact: facts.rows[index] ?? ["", ""]
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
                    text: parent.fact[0]
                    color: Theme.inkSoft
                    font.pixelSize: Spot.px(12)
                }
                Label {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    width: Math.min(implicitWidth, parent.width - factLabel.implicitWidth - Spot.px(16))
                    horizontalAlignment: Text.AlignRight
                    elide: Text.ElideMiddle
                    text: String(parent.fact[1])
                    font.pixelSize: Spot.px(12)
                }
            }
        }
    }
}
