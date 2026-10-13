import QtQuick

// One screen of the lock: the blurred wallpaper, the desktop DateBlock, a
// frosted password pill and the media player. `revealed` drives the blur in on
// lock and back out on unlock.
Item {
    id: root
    property string password: ""
    property string message: ""
    property bool busy: false
    property bool failed: false
    property bool revealed: true
    signal edited(string text)
    signal submitted()

    readonly property real u: height / 1440
    property bool started: false
    readonly property bool shown: started && revealed
    Component.onCompleted: started = true

    focus: true
    Keys.onPressed: event => {
        event.accepted = true;
        if (busy)
            return;
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
            submitted();
        else if (event.key === Qt.Key_Escape)
            edited("");
        else if (event.key === Qt.Key_Backspace)
            edited(event.modifiers & Qt.ControlModifier ? "" : password.slice(0, -1));
        else if (event.text !== "" && !(event.modifiers & Qt.ControlModifier) && event.text.charCodeAt(0) >= 32)
            edited(password + event.text);
        else
            event.accepted = false;
    }

    component Smooth: NumberAnimation {
        duration: 450
        easing.type: Easing.OutCubic
    }

    WallBlur {
        anchors.fill: parent
        blurred: root.shown
    }

    Rectangle {
        anchors.fill: parent
        opacity: root.shown ? 1 : 0
        Behavior on opacity { Smooth {} }
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.30) }
            GradientStop { position: 0.5; color: Qt.rgba(0, 0, 0, 0.05) }
            GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.45) }
        }
    }

    Item {
        anchors.fill: parent
        opacity: root.shown ? 1 : 0
        transform: Translate { y: root.shown ? 0 : 30 * root.u; Behavior on y { Smooth {} } }
        Behavior on opacity { Smooth {} }

        DateBlock {
            u: root.u * 1.15
            dark: true
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.verticalCenter
            anchors.bottomMargin: 30 * root.u
        }

        Rectangle {
            id: pill
            readonly property color accent: root.failed ? Theme.orange(true)
                : root.password !== "" ? Wallpaper.tint
                : Qt.alpha(Wallpaper.tint, 0.45)

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.verticalCenter
            anchors.topMargin: 90 * root.u
            width: 520 * root.u
            height: 76 * root.u
            radius: height / 2
            color: Qt.alpha(Wallpaper.tint, 0.14)
            border.width: Math.max(1, 2 * root.u)
            border.color: accent
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
                target: root
                function onFailedChanged() {
                    if (root.failed)
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
                color: root.failed ? Theme.orange(true) : Wallpaper.tint
            }

            WText {
                anchors.centerIn: parent
                visible: root.password === ""
                dark: true
                text: root.failed ? root.message : "Enter password"
                color: root.failed ? Theme.orange(true) : Qt.alpha(Wallpaper.tint, 0.75)
                font.pixelSize: 22 * root.u
                font.weight: root.failed ? Font.DemiBold : Font.Normal
                font.letterSpacing: 2 * root.u
            }

            Row {
                id: dots
                anchors.centerIn: parent
                spacing: 12 * root.u

                SequentialAnimation on opacity {
                    running: root.busy
                    loops: Animation.Infinite
                    onStopped: dots.opacity = 1
                    NumberAnimation { to: 0.3; duration: 450; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 1; duration: 450; easing.type: Easing.InOutSine }
                }

                Repeater {
                    model: Math.min(root.password.length, 18)
                    Rectangle {
                        width: 14 * root.u
                        height: width
                        radius: width / 2
                        color: Wallpaper.tint
                        NumberAnimation on scale { from: 0; to: 1; duration: 180; easing.type: Easing.OutBack }
                    }
                }
            }
        }

        Row {
            visible: SysInfo.batPresent
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 40 * root.u
            spacing: 10 * root.u

            WText {
                dark: true
                text: SysInfo.batStatus === "Charging" ? "\uf0e7" : "\uf240"
                font.family: Theme.mono
                font.pixelSize: 20 * root.u
            }
            WText {
                dark: true
                text: Math.round(SysInfo.batPct) + "%"
                font.pixelSize: 20 * root.u
                font.weight: Font.DemiBold
            }
        }

        PlayerBlock {
            u: root.u
            dark: true
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 90 * root.u
        }
    }
}
