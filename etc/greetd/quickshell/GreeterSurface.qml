import QtQuick

// One screen of the greeter: the machine's line-art picture, kept sharp, with
// the DateBlock, the user, a password pill like the lock's and the session
// picker over its empty left side; restart and power off sit bottom right.
Item {
    id: root
    required property var greeter
    readonly property real u: height / 1440
    readonly property color accent: "#e2231a"   // ThinkPad red
    readonly property color ink: Theme.fg(true)
    property bool started: false
    readonly property bool shown: started && !greeter.leaving
    Component.onCompleted: started = true

    focus: true
    Keys.onPressed: event => {
        const ctrl = (event.modifiers & Qt.ControlModifier) !== 0;
        event.accepted = true;
        if (ctrl && event.key === Qt.Key_R)
            greeter.power("reboot");
        else if (ctrl && event.key === Qt.Key_P)
            greeter.power("poweroff");
        else if (greeter.busy)
            return;
        else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
            greeter.login();
        else if (event.key === Qt.Key_Tab)
            greeter.pickSession(1);
        else if (event.key === Qt.Key_Backtab)
            greeter.pickSession(-1);
        else if (event.key === Qt.Key_Down)
            greeter.pickUser(1);
        else if (event.key === Qt.Key_Up)
            greeter.pickUser(-1);
        else if (event.key === Qt.Key_Escape)
            greeter.edit("");
        else if (event.key === Qt.Key_Backspace)
            greeter.edit(ctrl ? "" : greeter.password.slice(0, -1));
        else if (event.text !== "" && !ctrl && event.text.charCodeAt(0) >= 32)
            greeter.edit(greeter.password + event.text);
        else
            event.accepted = false;
    }

    component Smooth: NumberAnimation {
        duration: 450
        easing.type: Easing.OutCubic
    }

    Image {
        anchors.fill: parent
        source: "file://" + root.greeter.background
        sourceSize: Qt.size(width, height)
        fillMode: Image.PreserveAspectCrop
        opacity: root.shown ? 1 : 0
        Behavior on opacity { Smooth {} }
    }

    Item {
        anchors.fill: parent
        opacity: root.shown ? 1 : 0
        transform: Translate { y: root.shown ? 0 : 30 * root.u; Behavior on y { Smooth {} } }
        Behavior on opacity { Smooth {} }

        Column {
            x: parent.width * 0.27 - width / 2
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -70 * root.u
            spacing: 34 * root.u

            DateBlock {
                u: root.u * 1.05
                dark: true
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 16 * root.u

                Rectangle {
                    width: 48 * root.u
                    height: width
                    radius: width / 2
                    color: root.accent

                    Text {
                        anchors.centerIn: parent
                        text: (root.greeter.user?.label ?? "?").charAt(0).toUpperCase()
                        color: "white"
                        font.family: Theme.sans
                        font.pixelSize: 24 * root.u
                        font.weight: Font.DemiBold
                    }
                }
                WText {
                    anchors.verticalCenter: parent.verticalCenter
                    dark: true
                    text: root.greeter.user?.label ?? "No users"
                    font.pixelSize: 28 * root.u
                    font.weight: Font.Medium
                }
            }

            Rectangle {
                id: pill
                readonly property color edge: root.greeter.failed ? Theme.orange(true)
                    : root.greeter.password !== "" ? Qt.alpha(root.ink, 0.9)
                    : Qt.alpha(root.ink, 0.35)

                anchors.horizontalCenter: parent.horizontalCenter
                width: 520 * root.u
                height: 76 * root.u
                radius: height / 2
                color: Qt.rgba(1, 1, 1, 0.06)
                border.width: Math.max(1, 2 * root.u)
                border.color: edge
                Behavior on border.color { ColorAnimation { duration: 200 } }

                transform: Translate { id: shakeX }
                SequentialAnimation {
                    id: shake
                    NumberAnimation { target: shakeX; property: "x"; to: -18 * root.u; duration: 50 }
                    NumberAnimation { target: shakeX; property: "x"; to: 15 * root.u; duration: 70 }
                    NumberAnimation { target: shakeX; property: "x"; to: -10 * root.u; duration: 70 }
                    NumberAnimation { target: shakeX; property: "x"; to: 5 * root.u; duration: 60 }
                    NumberAnimation { target: shakeX; property: "x"; to: 0; duration: 50 }
                }
                Connections {
                    target: root.greeter
                    function onFailedChanged() {
                        if (root.greeter.failed)
                            shake.restart();
                    }
                }

                WText {
                    anchors.left: parent.left
                    anchors.leftMargin: 30 * root.u
                    anchors.verticalCenter: parent.verticalCenter
                    dark: true
                    text: "\uf023"
                    font.family: Theme.mono
                    font.pixelSize: 24 * root.u
                    color: root.greeter.failed ? Theme.orange(true) : root.ink
                }

                WText {
                    anchors.centerIn: parent
                    visible: root.greeter.password === ""
                    dark: true
                    text: root.greeter.failed ? root.greeter.message : "Enter password"
                    color: root.greeter.failed ? Theme.orange(true) : Qt.alpha(root.ink, 0.7)
                    font.pixelSize: 22 * root.u
                    font.weight: root.greeter.failed ? Font.DemiBold : Font.Normal
                    font.letterSpacing: 2 * root.u
                }

                Row {
                    id: dots
                    anchors.centerIn: parent
                    spacing: 12 * root.u

                    SequentialAnimation on opacity {
                        running: root.greeter.busy
                        loops: Animation.Infinite
                        onStopped: dots.opacity = 1
                        NumberAnimation { to: 0.3; duration: 450; easing.type: Easing.InOutSine }
                        NumberAnimation { to: 1; duration: 450; easing.type: Easing.InOutSine }
                    }

                    Repeater {
                        model: Math.min(root.greeter.password.length, 18)
                        Rectangle {
                            width: 14 * root.u
                            height: width
                            radius: width / 2
                            color: root.ink
                            NumberAnimation on scale { from: 0; to: 1; duration: 180; easing.type: Easing.OutBack }
                        }
                    }
                }
            }

            // the session picker: click a side or press Tab / Shift+Tab
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 14 * root.u

                WText {
                    anchors.verticalCenter: parent.verticalCenter
                    dark: true
                    text: "‹"
                    font.pixelSize: 30 * root.u
                    color: Qt.alpha(root.ink, root.greeter.sessions.length > 1 ? 0.8 : 0.2)
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -10 * root.u
                        onClicked: root.greeter.pickSession(-1)
                    }
                }
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: sessionName.implicitWidth + 36 * root.u
                    height: 40 * root.u
                    radius: height / 2
                    color: Qt.alpha(root.accent, 0.85)

                    Text {
                        id: sessionName
                        anchors.centerIn: parent
                        text: root.greeter.session?.name ?? "No sessions"
                        color: "white"
                        font.family: Theme.sans
                        font.pixelSize: 18 * root.u
                        font.weight: Font.DemiBold
                    }
                }
                WText {
                    anchors.verticalCenter: parent.verticalCenter
                    dark: true
                    text: "›"
                    font.pixelSize: 30 * root.u
                    color: Qt.alpha(root.ink, root.greeter.sessions.length > 1 ? 0.8 : 0.2)
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -10 * root.u
                        onClicked: root.greeter.pickSession(1)
                    }
                }
            }

            WText {
                anchors.horizontalCenter: parent.horizontalCenter
                dark: true
                text: "Tab session" + (root.greeter.users.length > 1 ? "  ·  ↑↓ user" : "") + "  ·  Ctrl+R restart  ·  Ctrl+P power off"
                color: Qt.alpha(root.ink, 0.5)
                font.pixelSize: 15 * root.u
                font.letterSpacing: 1 * root.u
            }
        }

        Row {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 48 * root.u
            spacing: 18 * root.u

            Repeater {
                model: [{ action: "reboot", glyph: "\uf021", label: "Restart" }, { action: "poweroff", glyph: "\uf011", label: "Power off" }]

                Rectangle {
                    id: button
                    required property var modelData
                    readonly property bool armed: root.greeter.armed === modelData.action
                    width: buttonLabel.implicitWidth + 64 * root.u
                    height: 48 * root.u
                    radius: height / 2
                    color: armed ? root.accent : Qt.rgba(1, 1, 1, hover.containsMouse ? 0.16 : 0.08)
                    border.width: 1
                    border.color: Qt.alpha(root.ink, 0.25)

                    Row {
                        anchors.centerIn: parent
                        spacing: 10 * root.u

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: button.modelData.glyph
                            color: "white"
                            font.family: Theme.mono
                            font.pixelSize: 18 * root.u
                        }
                        Text {
                            id: buttonLabel
                            anchors.verticalCenter: parent.verticalCenter
                            text: button.armed ? "Press again" : button.modelData.label
                            color: "white"
                            font.family: Theme.sans
                            font.pixelSize: 16 * root.u
                            font.weight: Font.Medium
                        }
                    }
                    MouseArea {
                        id: hover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.greeter.power(button.modelData.action)
                    }
                }
            }
        }
    }
}
