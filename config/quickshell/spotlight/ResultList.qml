import Quickshell
import QtQuick
import QtQuick.Effects
import qs

// The results under their section headers, each row with its icon, thumbnail,
// glyph or swatch, the query's words in bold and a hint (or a confirmation) on
// the right; the clipboard's type filter sits above them. The list fades out at
// the bottom while more rows follow
Item {
    id: root
    property var host
    property var clipboardStore

    // scrolls row `index` into view, clear of the fade at the bottom, but not
    // while the panel is still opening and the list too short to hold a row
    function reveal(index) {
        if (index === 0) {
            list.positionViewAtBeginning();
            return;
        }
        list.positionViewAtIndex(index, ListView.Contain);
        const row = list.itemAtIndex(index);
        if (row && list.height >= row.height + list.fade)
            list.contentY = Math.max(list.originY, Math.min(Math.max(list.contentY, row.y + row.height + list.fade - list.height), list.originY + list.contentHeight - list.height));
    }

    Row {
        id: clipboardFilters
        // not `visible`, which is false while Spotlight is hidden
        readonly property bool filtering: host.mode === "clipboard" && !host.form
        visible: filtering
        height: filtering ? Spot.px(38) : 0
        spacing: Spot.px(6)
        leftPadding: Spot.px(6)
        topPadding: Spot.px(4)

        Repeater {
            model: clipboardStore.filters

            Rectangle {
                id: pill
                required property string modelData
                readonly property bool active: clipboardStore.filter === modelData
                width: pillText.implicitWidth + Spot.px(22)
                height: Spot.px(26)
                radius: height / 2
                color: active ? host.viewTone : Theme.fill

                Label {
                    id: pillText
                    anchors.centerIn: parent
                    text: pill.modelData[0].toUpperCase() + pill.modelData.slice(1)
                    color: pill.active ? Theme.accentText : Theme.ink
                    font.pixelSize: Spot.px(12)
                    font.weight: Font.DemiBold
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: clipboardStore.filter = pill.modelData
                }
            }
        }

        Label {
            topPadding: Spot.px(6)
            text: "Ctrl+T"
            color: Theme.inkSoft
            font.pixelSize: Spot.px(11)
        }
    }

    ListView {
        id: list
        readonly property int fade: Spot.px(40)
        y: clipboardFilters.height
        width: parent.width
        height: parent.height - clipboardFilters.height
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        // the rows in sight and one more are made: the 320 px Qt makes ahead are
        // some eight more rows on every keystroke (p90 21 → 19 ms). The one more
        // keeps the list's height exact, and so the fade, for a list just longer
        // than the window; scrolling makes the rest
        cacheBuffer: Spot.px(90)
        // a row that leaves hands its delegate to one that arrives (p90 25 → 22 ms)
        reuseItems: true
        // diffed, so the rows a change leaves in place keep their delegates, and
        // a row whose text changed is updated, not remade. Rows compare by
        // `place`, a string, not field by field, as the diff compares each row with
        // the old ones (n·m); and none under the grid: leaving the emoji for the
        // history cost 130 ms
        model: ScriptModel {
            objectProp: "place"
            values: host.results.grid ? [] : host.results
        }
        layer.enabled: !atYEnd
        layer.effect: MultiEffect {
            maskEnabled: true
            maskSource: listFade
            maskSpreadAtMin: 1
        }

        delegate: Column {
            id: row
            required property var modelData
            required property int index
            readonly property bool isCurrent: index === host.current
            readonly property bool opensSection: index === 0 || host.results[index - 1]?.section !== modelData.section
            // across the whole window the hint follows the title, as Raycast's subtitle,
            // and what the result is takes the right
            readonly property bool spread: !host.previewing
            readonly property bool isCalc: modelData.kind === "calc"
            width: ListView.view.width

            // what only some rows show is loaded where it shows: a row would
            // otherwise make seven texts for the three it draws. An inactive
            // Loader keeps the height it had, so it is hidden too: the Column
            // skips it when a moved row no longer opens a section
            Loader {
                active: row.opensSection
                visible: active
                sourceComponent: Label {
                    leftPadding: Spot.px(10)
                    topPadding: row.index ? Spot.px(12) : Spot.px(4)
                    bottomPadding: Spot.px(4)
                    text: row.modelData.section
                    color: Theme.inkSoft
                    font.pixelSize: Spot.px(11)
                    font.weight: Font.Bold
                }
            }

            Rectangle {
                width: parent.width
                height: host.thumbs || row.modelData.thumb ? Spot.px(44) : Spot.px(40)
                visible: !row.isCalc
                radius: Spot.px(8)
                color: row.isCurrent ? Theme.selection : rowMouse.containsMouse ? Theme.hairline : "transparent"

                Item {
                    id: rowIcon
                    x: Spot.px(8)
                    anchors.verticalCenter: parent.verticalCenter
                    width: host.thumbs || row.modelData.thumb ? Spot.px(36) : Spot.px(22)
                    height: row.modelData.thumb ? Spot.px(32) : Spot.px(22)

                    Loader {
                        anchors.fill: parent
                        active: !!row.modelData.swatch
                        sourceComponent: Rectangle {
                            radius: Spot.px(6)
                            color: row.modelData.swatch
                            border.width: 1
                            border.color: Theme.hairline
                        }
                    }
                    Loader {
                        anchors.fill: parent
                        active: !!row.modelData.thumb
                        sourceComponent: Image {
                            fillMode: Image.PreserveAspectCrop
                            sourceSize: Qt.size(Spot.px(96), Spot.px(96))
                            source: row.modelData.thumb
                            cache: false
                            asynchronous: true
                        }
                    }
                    Image {
                        anchors.centerIn: parent
                        width: Spot.px(22)
                        height: Spot.px(22)
                        // not `visible`, which is false while Spotlight is hidden
                        readonly property bool showsIcon: !row.modelData.glyph && !row.modelData.thumb && !row.modelData.swatch
                        visible: showsIcon
                        sourceSize: Qt.size(Spot.px(44), Spot.px(44))
                        source: showsIcon ? Quickshell.iconPath(row.modelData.icon ?? "", "application-x-executable") : ""
                        asynchronous: true
                    }
                    Loader {
                        anchors.centerIn: parent
                        active: !!row.modelData.glyph && !row.modelData.thumb
                        sourceComponent: Label {
                            text: row.modelData.glyph
                            color: row.isCurrent ? Theme.selectionText : host.tone(row.modelData)
                            font.family: "Noto Color Emoji"
                            font.pixelSize: Spot.px(17)
                        }
                    }
                }
                Label {
                    id: rowHint
                    anchors.right: parent.right
                    anchors.rightMargin: Spot.px(10)
                    anchors.verticalCenter: parent.verticalCenter
                    width: Math.min(implicitWidth, parent.width * 0.4)
                    elide: Text.ElideRight
                    text: host.armed === row.modelData.key ? "Press Enter again" : host.armed === row.modelData.key + ":delete" ? "Ctrl+X again to delete" : row.spread ? host.kindLabel(row.modelData) : row.modelData.hint ?? ""
                    color: row.isCurrent ? Qt.alpha(Theme.selectionText, 0.75) : Theme.eyes.ash
                    font.pixelSize: Spot.px(12)
                }
                Label {
                    id: rowTitle
                    anchors.left: rowIcon.right
                    anchors.leftMargin: Spot.px(10)
                    anchors.verticalCenter: parent.verticalCenter
                    // the subtitle's room is measured apart, so no width follows from another's
                    width: rowHint.x - x - Spot.px(8) - (rowSubtitle.text ? Math.min(subtitleMetrics.advanceWidth, Spot.px(240)) + Spot.px(10) : 0)
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    textFormat: host.query ? Text.StyledText : Text.PlainText
                    text: host.query ? host.marked(row.modelData.title.replace(/\s+/g, " ")) : row.modelData.title.replace(/\s+/g, " ")
                    color: row.isCurrent ? Theme.selectionText : Theme.ink
                    font.pixelSize: Spot.px(15)
                }
                Label {
                    id: rowSubtitle
                    anchors.left: rowTitle.left
                    anchors.leftMargin: rowTitle.contentWidth + Spot.px(10)
                    anchors.verticalCenter: parent.verticalCenter
                    width: Math.min(subtitleMetrics.advanceWidth, rowHint.x - x - Spot.px(8))
                    elide: Text.ElideRight
                    text: row.spread ? row.modelData.hint ?? "" : ""
                    color: row.isCurrent ? Qt.alpha(Theme.selectionText, 0.75) : Theme.inkSoft
                    font.pixelSize: Spot.px(15)
                }
                TextMetrics {
                    id: subtitleMetrics
                    font: rowSubtitle.font
                    text: rowSubtitle.text
                }
                MouseArea {
                    id: rowMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: host.pick(row.index)
                    onDoubleClicked: host.activate(row.modelData, { ctrl: false, shift: false })
                }
            }

            // the calculator's answer as Raycast shows it: what was typed → the result
            Loader {
                width: parent.width
                active: row.isCalc
                visible: active
                sourceComponent: Rectangle {
                    height: Spot.px(110)
                    radius: Spot.px(10)
                    color: row.isCurrent ? Theme.selection : Theme.fill

                    Label {
                        x: Spot.px(16)
                        width: parent.width / 2 - Spot.px(40)
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.verticalCenterOffset: -Spot.px(10)
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                        text: row.modelData.expression ?? ""
                        color: row.isCurrent ? Theme.selectionText : Theme.ink
                        font.family: Theme.menu
                        font.pixelSize: Spot.px(24)
                        font.weight: Font.Bold
                    }
                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.verticalCenterOffset: -Spot.px(10)
                        text: "→"
                        color: row.isCurrent ? Theme.selectionText : Theme.inkSoft
                        font.pixelSize: Spot.px(22)
                    }
                    Label {
                        x: parent.width / 2 + Spot.px(24)
                        width: parent.width / 2 - Spot.px(40)
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.verticalCenterOffset: -Spot.px(10)
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                        text: row.modelData.title
                        color: row.isCurrent ? Theme.selectionText : Theme.ink
                        font.family: Theme.menu
                        font.pixelSize: Spot.px(24)
                        font.weight: Font.Bold
                    }
                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: Spot.px(14)
                        width: parent.width - Spot.px(32)
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                        text: row.modelData.detail ?? ""
                        color: row.isCurrent ? Qt.alpha(Theme.selectionText, 0.75) : Theme.inkSoft
                        font.pixelSize: Spot.px(12)
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: host.pick(row.index)
                        onDoubleClicked: host.activate(row.modelData, { ctrl: false, shift: false })
                    }
                }
            }
        }
    }

    Rectangle {
        id: listFade
        width: list.width
        height: list.height
        visible: false
        layer.enabled: true
        gradient: Gradient {
            GradientStop { position: 0; color: "white" }
            GradientStop { position: 1 - list.fade / Math.max(list.height, list.fade); color: "white" }
            GradientStop { position: 1; color: "transparent" }
        }
    }
}
