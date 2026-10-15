import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Widgets
import QtQuick
import qs

// One notification in macOS Sequoia's shape, on the popups' glass: the app
// icon, a bold title with its age at the right, the body, and the image it
// carries as a thumbnail. One with actions, or a critical one, is an alert: its
// buttons, Close last, stack on the right of the card. Left or middle
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
    readonly property string appIcon: notification?.appIcon || notification?.desktopEntry || ""
    readonly property string image: notification?.image ?? ""
    readonly property int pad: Math.round(11 * u)
    readonly property double arrived: Date.now()
    property double now: arrived

    width: Math.round(345 * u)
    height: Math.max(text.implicitHeight, icon.height, alert ? actions.implicitHeight : 0) + 2 * pad

    function iconSource(name) {
        if (name.startsWith("/"))
            return "file://" + name;
        return name.includes("://") ? name : Quickshell.iconPath(name, "dialog-information");
    }

    function age() {
        const minutes = Math.round((now - arrived) / 60000);
        if (minutes < 1)
            return "now";
        return minutes < 60 ? minutes + " min" : Math.round(minutes / 60) + " h";
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
        interval: 60000
        repeat: true
        running: true
        onTriggered: card.now = Date.now()
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
            radius: Math.round(16 * card.u)
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
            source: card.iconSource(card.appIcon || card.image)
            asynchronous: true
        }

        Column {
            id: text
            anchors.left: icon.right
            anchors.leftMargin: Math.round(10 * card.u)
            anchors.right: card.alert ? actions.left : thumb.visible ? thumb.left : parent.right
            anchors.rightMargin: card.pad
            anchors.verticalCenter: parent.verticalCenter
            spacing: Math.round(2 * card.u)

            Item {
                width: parent.width
                height: title.implicitHeight

                Text {
                    id: title
                    width: parent.width - age.implicitWidth - Math.round(8 * card.u)
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
                    id: age
                    anchors.right: parent.right
                    anchors.baseline: title.baseline
                    text: card.age()
                    color: Theme.inkSoft
                    font.family: Theme.menuText
                    font.pixelSize: Math.round(11 * card.u)
                    renderType: Text.NativeRendering
                }
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
                linkColor: Theme.accent
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
                    color: Theme.eyes.bg4

                    Rectangle {
                        width: parent.width * Math.max(0, Math.min(100, card.progress ?? 0)) / 100
                        height: parent.height
                        radius: parent.radius
                        color: Theme.eyes.green0
                    }
                }
            }
        }

        ClippingRectangle {
            id: thumb
            anchors.right: parent.right
            anchors.rightMargin: card.pad
            anchors.verticalCenter: parent.verticalCenter
            width: Math.round(40 * card.u)
            height: width
            radius: Math.round(6 * card.u)
            visible: !card.alert && card.appIcon !== "" && card.image !== ""
            color: "transparent"

            Image {
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                sourceSize: Qt.size(width * 2, height * 2)
                source: thumb.visible ? card.iconSource(card.image) : ""
                asynchronous: true
            }
        }

        // the alert's buttons, Close last
        Column {
            id: actions
            anchors.right: parent.right
            anchors.rightMargin: card.pad
            anchors.verticalCenter: parent.verticalCenter
            width: Math.round(84 * card.u)
            spacing: Math.round(6 * card.u)
            visible: card.alert

            Repeater {
                model: [...card.buttons.map(action => ({ text: action.text, action })), { text: "Close", action: null }]

                Rectangle {
                    id: button
                    required property var modelData
                    width: actions.width
                    height: Math.round(26 * card.u)
                    radius: Math.round(7 * card.u)
                    color: Theme.fill

                    Text {
                        anchors.centerIn: parent
                        width: parent.width - Math.round(8 * card.u)
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                        text: button.modelData.text
                        color: Theme.ink
                        font.family: Theme.menuText
                        font.pixelSize: Math.round(12 * card.u)
                        renderType: Text.NativeRendering
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: button.modelData.action ? button.modelData.action.invoke() : card.notification?.dismiss()
                    }
                }
            }
        }

        // the close button, a small disc on the top-left corner
        Rectangle {
            x: -Math.round(7 * card.u)
            y: -Math.round(7 * card.u)
            width: Math.round(20 * card.u)
            height: width
            radius: width / 2
            color: Theme.fill
            border.width: 1
            border.color: Theme.border
            opacity: hover.hovered && !card.alert ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 120 } }

            Text {
                anchors.centerIn: parent
                text: "✕"
                color: Theme.ink
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
