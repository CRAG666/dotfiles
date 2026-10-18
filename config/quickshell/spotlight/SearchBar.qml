import QtQuick
import qs

// The bar: the search field, the tag of the open view, form or action panel
// with the field's placeholder and the grey completion of an app's name, and
// the chips of the views in the bar
Item {
    id: root
    property var host
    property var keyMap   // a Shortcuts
    property alias field: search
    height: Spot.px(64)

    Label {
        id: glassIcon
        x: Spot.px(24)
        anchors.verticalCenter: parent.verticalCenter
        text: "\uf002"
        color: Theme.inkSoft
        font.family: Theme.menu
        font.pixelSize: Spot.px(22)
    }

    Rectangle {
        id: tagPill
        anchors.left: glassIcon.right
        anchors.leftMargin: Spot.px(12)
        anchors.verticalCenter: parent.verticalCenter
        visible: host.tag !== ""
        width: host.tag !== "" ? tagText.implicitWidth + Spot.px(20) : 0
        height: Spot.px(28)
        radius: height / 2
        color: host.actionTarget || host.form ? Theme.accent : host.viewTone

        Label {
            id: tagText
            anchors.centerIn: parent
            text: host.tag
            color: Theme.accentText
            font.pixelSize: Spot.px(13)
            font.weight: Font.DemiBold
        }
    }

    TextInput {
        id: search
        anchors.left: tagPill.right
        anchors.leftMargin: Spot.px(12)
        anchors.right: chipRow.left
        anchors.rightMargin: Spot.px(12)
        anchors.verticalCenter: parent.verticalCenter
        focus: true
        clip: true
        color: Theme.ink
        selectionColor: Theme.selection
        selectedTextColor: Theme.selectionText
        font.family: Theme.menu
        font.pixelSize: Spot.px(26)
        renderType: Text.NativeRendering
        onTextChanged: host.jumpToAlias(text)
        Keys.onPressed: event => root.keyMap.handle(event)


        Label {
            anchors.verticalCenter: parent.verticalCenter
            width: search.width
            elide: Text.ElideRight
            visible: search.text === ""
            text: host.actionTarget ? `Search actions for ${host.actionTarget.title}` : host.formField ? host.formField.label : host.currentView ? host.currentView.placeholder ?? host.currentView.title : "Search"
            color: Theme.inkSoft
            font: search.font
        }
        Label {
            x: search.contentWidth
            anchors.verticalCenter: parent.verticalCenter
            text: host.completion
            color: Theme.inkSoft
            font: search.font
        }
    }

    Row {
        id: chipRow
        anchors.right: parent.right
        anchors.rightMargin: Spot.px(18)
        anchors.verticalCenter: parent.verticalCenter
        spacing: Spot.px(4)

        Repeater {
            model: host.chips

            Rectangle {
                id: chip
                required property var modelData
                readonly property bool active: host.mode === modelData.mode
                width: Spot.px(30)
                height: Spot.px(30)
                radius: height / 2
                color: active ? Theme.eyes[modelData.tone] : "transparent"

                Label {
                    anchors.centerIn: parent
                    text: chip.modelData.chip ?? chip.modelData.alias ?? chip.modelData.title
                    color: chip.active ? Theme.accentText : Theme.inkSoft
                    font.family: Theme.menu
                    font.pixelSize: Spot.px(14)
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: host.mode = chip.active ? "" : chip.modelData.mode
                }
            }
        }
    }
}
