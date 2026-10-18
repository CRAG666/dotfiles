import Quickshell
import QtQuick
import qs

// The view on the left; the primary action and the Ctrl+K panel on the right,
// or a confirmation or a store's own status in their place
Item {
    id: actionBar
    property var host
    property var info   // the selection described, as the preview shows it
    readonly property var primary: host.actionTarget ? (host.selection ? ["Enter", host.selection.title] : null) : info?.actions?.[0] ?? null
    readonly property bool confirming: host.armed !== "" && host.armed.startsWith(host.selectedKey)
    readonly property string status: confirming ? (host.armed.endsWith(":delete") ? "Press Ctrl+X again to delete it" : "Press Enter again to confirm") : info?.footer ?? ""
    height: Spot.px(40)

    Rectangle {
        width: parent.width
        height: 1
        color: Theme.hairline
    }

    Row {
        anchors.left: parent.left
        anchors.leftMargin: Spot.px(16)
        anchors.verticalCenter: parent.verticalCenter
        spacing: Spot.px(8)

        Image {
            anchors.verticalCenter: parent.verticalCenter
            width: Spot.px(16)
            height: Spot.px(16)
            readonly property string viewIcon: host.actionTarget || host.form ? "" : host.currentView?.icon ?? ""
            visible: viewIcon !== ""
            sourceSize: Qt.size(Spot.px(32), Spot.px(32))
            source: viewIcon ? Quickshell.iconPath(viewIcon, "application-x-executable") : ""
            asynchronous: true
        }
        Label {
            anchors.verticalCenter: parent.verticalCenter
            text: host.actionTarget ? "Actions" : host.form ? host.form.title : host.currentView ? host.currentView.title.replace(/^Search /, "") + (host.gridView && host.selection ? " · " + host.selection.title : "") : host.selection?.section ?? "Search"
            color: host.currentView ? host.viewTone : host.selection ? host.tone(host.selection) : Theme.inkSoft
            font.pixelSize: Spot.px(12)
            font.weight: Font.DemiBold
        }
    }

    Row {
        anchors.right: parent.right
        anchors.rightMargin: Spot.px(14)
        anchors.verticalCenter: parent.verticalCenter
        spacing: Spot.px(8)

        Label {
            anchors.verticalCenter: parent.verticalCenter
            visible: actionBar.status !== ""
            text: actionBar.status
            color: !actionBar.confirming ? Theme.inkSoft : host.armed.endsWith(":delete") ? Theme.eyes.red : Theme.eyes.yellow
            font.pixelSize: Spot.px(12)
            font.weight: actionBar.confirming ? Font.DemiBold : Font.Normal
        }
        Label {
            anchors.verticalCenter: parent.verticalCenter
            visible: actionBar.status === "" && actionBar.primary !== null
            text: actionBar.primary?.[1] ?? ""
            font.pixelSize: Spot.px(12)
        }
        KeyCaps {
            anchors.verticalCenter: parent.verticalCenter
            visible: actionBar.status === "" && actionBar.primary !== null
            keys: actionBar.primary?.[0] ?? ""
        }
        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            visible: actionsButton.visible && actionBar.status === "" && actionBar.primary !== null
            width: 1
            height: Spot.px(16)
            color: Theme.hairline
        }
        Row {
            id: actionsButton
            anchors.verticalCenter: parent.verticalCenter
            visible: !actionBar.confirming && (!!host.actionTarget || !!actionBar.info?.actions?.length)
            spacing: Spot.px(6)

            Label {
                anchors.verticalCenter: parent.verticalCenter
                text: host.actionTarget ? "Close" : "Actions"
                color: Theme.inkSoft
                font.pixelSize: Spot.px(12)
            }
            KeyCaps {
                anchors.verticalCenter: parent.verticalCenter
                keys: "Ctrl+K"
            }
            TapHandler {
                onTapped: host.actionTarget ? host.closeActions() : host.openActions()
            }
            HoverHandler {
                cursorShape: Qt.PointingHandCursor
            }
        }
    }
}
