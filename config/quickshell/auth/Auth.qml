import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Polkit
import QtQuick
import qs

// macOS Sequoia's authentication sheet on the popups' glass, centred on the
// focused screen, for the session's polkit agent (in place of mate-polkit) and
// for gpg through ./pinentry. A wrong password shakes the sheet; polkit then
// asks again within the same request, gpg with a fresh ask() carrying its error.
Scope {
    id: root
    readonly property AuthFlow flow: agent.flow
    // the pending pinentry GETPIN: { fifo, title, desc, prompt, error }
    property var pin: null
    property bool wrong: false

    // what the sheet shows, whichever of the two is asking
    readonly property string icon: pin ? "gnome-keyring" : flow?.iconName ?? ""
    readonly property string title: pin ? pin.title || "Passphrase Required" : flow?.message ?? ""
    readonly property string message: pin ? pin.desc : "Enter your password to allow this."
    readonly property string placeholder: wrong && !pin ? "Wrong password" : (pin ? pin.prompt : flow?.inputPrompt ?? "").replace(/:\s*$/, "")
    readonly property string error: pin ? pin.error : flow?.supplementaryMessage ?? ""
    readonly property bool errorIsAlert: pin !== null || (flow?.supplementaryIsError ?? false)
    readonly property bool ready: pin !== null || (flow?.isResponseRequired ?? false)
    readonly property bool echo: !pin && (flow?.responseVisible ?? false)

    function open(failed: bool) {
        Wallpaper.refresh();
        field.text = "";
        wrong = false;
        if (failed)
            fail();
    }

    function fail() {
        wrong = true;
        shake.restart();
    }

    function submit() {
        if (pin)
            reply("+" + field.text);
        else if (ready)
            flow.submit(field.text);
        field.text = "";
    }

    function cancel() {
        if (pin)
            reply("-");
        else
            flow?.cancelAuthenticationRequest();
    }

    // the passphrase goes to the waiting pinentry through cat's stdin, never argv
    function reply(line) {
        replier.write(line + "\n");
        replier.stdinEnabled = false;
        pin = null;
    }

    Process {
        id: replier
    }

    IpcHandler {
        target: "pinentry"

        function ask(fifo: string, title: string, desc: string, prompt: string, error: string): void {
            root.pin = { fifo, title, desc, prompt, error };
            replier.command = ["sh", "-c", 'exec cat > "$1"', "sh", fifo];
            replier.stdinEnabled = true;
            replier.running = true;
            root.open(error !== "");
        }

        // the pinentry is gone (gpg-agent cancelled it): drop its request
        function close(fifo: string): void {
            if (root.pin?.fifo !== fifo)
                return;
            replier.running = false;
            root.pin = null;
        }
    }

    PolkitAgent {
        id: agent
        onAuthenticationRequestStarted: root.open(false)
    }

    Connections {
        target: root.flow
        function onAuthenticationFailed() {
            root.fail();
        }
    }

    PanelWindow {
        id: win
        readonly property real u: Math.min(screen.width / 1920, screen.height / 1080) * 1.2
        visible: agent.isActive || root.pin !== null
        onVisibleChanged: if (visible) fadeIn.restart()
        screen: FocusedOutput.screen
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "qs-polkit"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        exclusionMode: ExclusionMode.Ignore
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        component Label: Text {
            color: Theme.ink
            font.family: Theme.menuText
            font.pixelSize: Math.round(13 * win.u)
            textFormat: Text.PlainText
            renderType: Text.NativeRendering
        }

        component Button: Rectangle {
            id: button
            property alias text: label.text
            property bool primary: false
            signal clicked()
            width: (parent.width - parent.spacing) / 2
            height: Math.round(28 * win.u)
            radius: Math.round(6 * win.u)
            color: primary ? Theme.accent : Theme.fill

            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                visible: mouse.pressed
                color: Qt.rgba(0, 0, 0, 0.15)
            }
            Label {
                id: label
                anchors.centerIn: parent
                color: button.primary ? Theme.accentText : Theme.ink
            }
            MouseArea {
                id: mouse
                anchors.fill: parent
                onClicked: button.clicked()
            }
        }

        WallBlur {
            id: wallBlur
            anchors.fill: parent
            visible: false
        }

        // a Sequoia alert: narrow, centred, the buttons sharing the full width
        Item {
            id: sheet
            readonly property int pad: Math.round(20 * win.u)
            anchors.centerIn: parent
            width: Math.round(260 * win.u)
            height: content.implicitHeight + 2 * pad

            NumberAnimation on opacity { id: fadeIn; from: 0; to: 1; duration: 140 }

            // macOS shakes the whole sheet; moving its anchor keeps the glass in step
            SequentialAnimation {
                id: shake
                NumberAnimation { target: sheet; property: "anchors.horizontalCenterOffset"; to: -14 * win.u; duration: 50 }
                NumberAnimation { target: sheet; property: "anchors.horizontalCenterOffset"; to: 11 * win.u; duration: 70 }
                NumberAnimation { target: sheet; property: "anchors.horizontalCenterOffset"; to: -7 * win.u; duration: 70 }
                NumberAnimation { target: sheet; property: "anchors.horizontalCenterOffset"; to: 0; duration: 50 }
            }

            Glass {
                anchors.fill: parent
                radius: Math.round(14 * win.u)
                u: win.u
                backdrop: wallBlur
                origin: Qt.point(sheet.x, sheet.y)
            }

            Column {
                id: content
                x: sheet.pad
                y: sheet.pad
                width: sheet.width - 2 * sheet.pad
                spacing: Math.round(10 * win.u)

                Image {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Math.round(64 * win.u)
                    height: width
                    sourceSize: Qt.size(width, height)
                    source: Quickshell.iconPath(root.icon, "lock")
                }
                Label {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    text: root.title
                    font.weight: Font.Bold
                }
                Label {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    visible: text !== ""
                    text: root.message
                    font.pixelSize: Math.round(11 * win.u)
                }

                Rectangle {
                    width: parent.width
                    height: Math.round(28 * win.u)
                    radius: Math.round(6 * win.u)
                    color: Theme.fill
                    opacity: field.enabled ? 1 : 0.5

                    Rectangle {
                        readonly property int ring: Math.round(3 * win.u)
                        anchors.fill: parent
                        anchors.margins: -ring
                        radius: parent.radius + ring
                        color: "transparent"
                        border.width: ring
                        border.color: Qt.alpha(root.wrong ? Theme.alert : Theme.accent, 0.6)
                    }
                    Label {
                        anchors.fill: field
                        verticalAlignment: Text.AlignVCenter
                        visible: field.text === ""
                        text: root.placeholder
                        color: root.wrong ? Theme.alert : Theme.inkSoft
                    }
                    TextInput {
                        id: field
                        anchors.fill: parent
                        anchors.leftMargin: Math.round(8 * win.u)
                        anchors.rightMargin: Math.round(8 * win.u)
                        verticalAlignment: TextInput.AlignVCenter
                        focus: win.visible
                        enabled: root.ready
                        echoMode: root.echo ? TextInput.Normal : TextInput.Password
                        clip: true
                        color: Theme.ink
                        selectionColor: Theme.selection
                        selectedTextColor: Theme.selectionText
                        font.family: Theme.menuText
                        font.pixelSize: Math.round(13 * win.u)
                        renderType: Text.NativeRendering
                        onTextEdited: root.wrong = false
                        onAccepted: root.submit()
                        Keys.onEscapePressed: root.cancel()
                    }
                }

                Label {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    visible: text !== ""
                    text: root.error
                    color: root.errorIsAlert ? Theme.alert : Theme.inkSoft
                    font.pixelSize: Math.round(11 * win.u)
                }

                Row {
                    width: parent.width
                    spacing: Math.round(8 * win.u)

                    Button {
                        text: "Cancel"
                        onClicked: root.cancel()
                    }
                    Button {
                        text: "OK"
                        primary: true
                        onClicked: root.submit()
                    }
                }
            }
        }
    }
}
