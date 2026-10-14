import Quickshell
import Quickshell.Services.Notifications
import QtQuick
import qs

// One notification in macOS Mojave's shape, on Spotlight's glass: the app icon,
// a bold title and the body. One with actions, or a critical one, is an alert:
// its buttons, Close last, stack in a column on the right edge. Left or middle
// click elsewhere runs the default action, else opens the first link of the
// body, and closes it; right click closes every banner; the ✕ that appears on
// hover closes this one. The timeout pauses while the pointer is over it.
// `notification` turns null for the moment between its closing and the
// delegate's removal, hence the `?.`.
Item {
    id: card
    required property var notification
    required property real u
    required property Item backdrop
    signal closeAll

    readonly property bool critical: notification?.urgency === NotificationUrgency.Critical
    // expireTimeout arrives in milliseconds, though Quickshell's docs say seconds
    readonly property int timeout: notification?.expireTimeout > 0 ? notification.expireTimeout : critical ? 0 : 5000
    readonly property var progress: notification?.hints.value
    readonly property var buttons: (notification?.actions ?? []).filter(action => action.identifier !== "default")
    readonly property bool alert: critical || buttons.length > 0
    readonly property int pad: Math.round(11 * u)

    width: Math.round(345 * u)
    height: Math.max(text.implicitHeight + 2 * pad, icon.height + 2 * pad, alert ? (buttons.length + 1) * Math.round(30 * u) : 0)

    function iconSource(name) {
        if (name.startsWith("/"))
            return "file://" + name;
        return name.includes("://") ? name : Quickshell.iconPath(name, "dialog-information");
    }

    function activate() {
        const action = notification.actions.find(action => action.identifier === "default");
        const link = notification.body.match(/https?:\/\/[^\s<>"']+/)?.[0];
        if (action) {
            action.invoke();
            return;
        }
        if (link)
            Quickshell.execDetached(["xdg-open", link]);
        notification.dismiss();
    }

    Timer {
        interval: card.timeout
        running: card.timeout > 0 && !hover.hovered
        onTriggered: card.notification?.expire()
    }

    Item {
        id: sheet
        width: parent.width
        height: parent.height

        // slides in from the right, as on macOS
        x: Math.round(40 * card.u)
        opacity: 0
        Component.onCompleted: {
            x = 0;
            opacity = 1;
        }
        Behavior on x { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }
        Behavior on opacity { NumberAnimation { duration: 180 } }

        Glass {
            anchors.fill: parent
            radius: Math.round(12 * card.u)
            u: card.u
            backdrop: card.backdrop
            // follows the slide-in, the stack moving and the cards shifting
            origin: (sheet.x, card.y, card.ListView.view.y, sheet.mapToItem(null, 0, 0))
        }

        // under the buttons, which take their own clicks
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
            onClicked: mouse => mouse.button === Qt.RightButton ? card.closeAll() : card.activate()
        }

        Image {
            id: icon
            x: card.pad
            anchors.verticalCenter: parent.verticalCenter
            width: Math.round(40 * card.u)
            height: width
            sourceSize: Qt.size(width * 2, height * 2)
            fillMode: Image.PreserveAspectFit
            source: card.iconSource(card.notification?.image || card.notification?.appIcon || card.notification?.desktopEntry || "")
            asynchronous: true
        }

        Column {
            id: text
            anchors.left: icon.right
            anchors.leftMargin: Math.round(10 * card.u)
            anchors.right: card.alert ? actions.left : parent.right
            anchors.rightMargin: card.pad
            anchors.verticalCenter: parent.verticalCenter
            spacing: Math.round(2 * card.u)

            Text {
                width: parent.width
                wrapMode: Text.Wrap
                maximumLineCount: 2
                elide: Text.ElideRight
                textFormat: Text.PlainText
                text: card.notification?.summary || card.notification?.appName || ""
                color: Theme.ink
                font.family: Theme.menuText
                font.pixelSize: Math.round(13 * card.u)
                font.weight: Font.Bold
                renderType: Text.NativeRendering
            }
            Text {
                width: parent.width
                visible: text !== ""
                wrapMode: Text.Wrap
                maximumLineCount: 3
                elide: Text.ElideRight
                textFormat: Text.StyledText
                text: (card.notification?.body ?? "").replace(/\n/g, "<br>")
                color: Theme.ink
                linkColor: Wallpaper.accent
                font.family: Theme.menuText
                font.pixelSize: Math.round(13 * card.u)
                renderType: Text.NativeRendering
                onLinkActivated: link => Quickshell.execDetached(["xdg-open", link])
            }
            Item {
                width: parent.width
                height: Math.round(10 * card.u)
                visible: card.progress !== undefined

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: Math.round(5 * card.u)
                    radius: height / 2
                    color: Theme.hairline

                    Rectangle {
                        width: parent.width * Math.max(0, Math.min(100, card.progress ?? 0)) / 100
                        height: parent.height
                        radius: parent.radius
                        color: Wallpaper.accent
                    }
                }
            }
        }

        // the alert's buttons, Close last, split by hairlines
        Rectangle {
            anchors.right: actions.left
            width: 1
            height: parent.height
            visible: card.alert
            color: Theme.hairline
        }
        Column {
            id: actions
            anchors.right: parent.right
            width: Math.round(84 * card.u)
            height: parent.height
            visible: card.alert

            Repeater {
                model: [...card.buttons.map(action => ({ text: action.text, action })), { text: "Close", action: null }]

                Item {
                    id: button
                    required property var modelData
                    required property int index
                    width: actions.width
                    height: actions.height / (card.buttons.length + 1)

                    Rectangle {
                        width: parent.width
                        height: 1
                        visible: button.index > 0
                        color: Theme.hairline
                    }
                    Text {
                        anchors.centerIn: parent
                        width: parent.width - Math.round(8 * card.u)
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                        text: button.modelData.text
                        color: Theme.ink
                        font.family: Theme.menuText
                        font.pixelSize: Math.round(13 * card.u)
                        renderType: Text.NativeRendering
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: button.modelData.action ? button.modelData.action.invoke() : card.notification?.dismiss()
                    }
                }
            }
        }

        // Mojave's close button, a small disc on the top-left corner
        Rectangle {
            x: -Math.round(7 * card.u)
            y: -Math.round(7 * card.u)
            width: Math.round(20 * card.u)
            height: width
            radius: width / 2
            color: Wallpaper.glass
            border.width: 1
            border.color: Theme.hairline
            opacity: hover.hovered && !card.alert ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 120 } }

            Text {
                anchors.centerIn: parent
                text: "✕"
                color: Theme.inkSoft
                font.family: Theme.menuText
                font.pixelSize: Math.round(9 * card.u)
                font.weight: Font.Bold
                renderType: Text.NativeRendering
            }
            MouseArea {
                anchors.fill: parent
                enabled: hover.hovered && !card.alert
                onClicked: card.notification?.dismiss()
            }
        }

        HoverHandler {
            id: hover
        }
    }
}
