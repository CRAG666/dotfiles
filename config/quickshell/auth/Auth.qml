import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Polkit
import QtQuick
import qs

// macOS's authentication sheet on Spotlight's glass, centred on the focused
// screen, for the session's polkit agent (in place of mate-polkit) and for gpg
// through ./pinentry. A wrong password shakes the field; polkit then asks again
// within the same request, gpg with a fresh ask() carrying its error.
Scope {
    id: root
    readonly property AuthFlow flow: agent.flow
    // the pending pinentry GETPIN: { fifo, title, desc, prompt, error }
    property var pin: null
    property bool wrong: false

    function submit() {
        if (pin)
            reply("+" + field.text);
        else if (flow?.isResponseRequired)
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
            Wallpaper.refresh();
            root.pin = { fifo, title, desc, prompt, error };
            replier.command = ["sh", "-c", 'exec cat > "$1"', "sh", fifo];
            replier.stdinEnabled = true;
            replier.running = true;
            root.wrong = error !== "";
            if (root.wrong)
                shake.restart();
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
        onAuthenticationRequestStarted: {
            Wallpaper.refresh();
            root.wrong = false;
        }
    }

    Connections {
        target: root.flow
        function onAuthenticationFailed() {
            root.wrong = true;
            shake.restart();
        }
    }

    PanelWindow {
        id: win
        readonly property real u: Math.min(screen.width / 1920, screen.height / 1080) * 1.2
        visible: agent.isActive || root.pin !== null
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
            width: Math.round(110 * win.u)
            height: Math.round(30 * win.u)
            radius: Math.round(7 * win.u)
            color: primary ? Wallpaper.accent : Theme.hairline

            Label {
                id: label
                anchors.centerIn: parent
                color: button.primary ? "white" : Theme.ink
            }
            MouseArea {
                anchors.fill: parent
                onClicked: button.clicked()
            }
        }

        WallBlur {
            id: wallBlur
            anchors.fill: parent
            visible: false
        }

        Item {
            id: sheet
            readonly property int pad: Math.round(22 * win.u)
            anchors.centerIn: parent
            width: Math.round(420 * win.u)
            height: content.implicitHeight + 2 * pad

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
                spacing: Math.round(12 * win.u)

                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "\uf023"
                    font.family: Theme.mono
                    font.pixelSize: Math.round(40 * win.u)
                }
                Label {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    text: root.pin ? root.pin.title || "Passphrase Required" : "Authentication Required"
                    font.pixelSize: Math.round(15 * win.u)
                    font.weight: Font.Bold
                }
                Label {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    text: root.pin?.desc ?? root.flow?.message ?? ""
                    color: Theme.inkSoft
                }

                Rectangle {
                    width: parent.width
                    height: Math.round(34 * win.u)
                    radius: Math.round(7 * win.u)
                    color: Theme.hairline
                    border.width: Math.max(1, Math.round(1.5 * win.u))
                    border.color: root.wrong ? Theme.orange(Theme.eyesDark) : Wallpaper.accent
                    opacity: field.enabled ? 1 : 0.5
                    transform: Translate { id: shakeX }

                    SequentialAnimation {
                        id: shake
                        NumberAnimation { target: shakeX; property: "x"; to: -14 * win.u; duration: 50 }
                        NumberAnimation { target: shakeX; property: "x"; to: 11 * win.u; duration: 70 }
                        NumberAnimation { target: shakeX; property: "x"; to: -7 * win.u; duration: 70 }
                        NumberAnimation { target: shakeX; property: "x"; to: 0; duration: 50 }
                    }

                    Label {
                        anchors.fill: field
                        verticalAlignment: Text.AlignVCenter
                        visible: field.text === ""
                        text: root.wrong && !root.pin ? "Wrong password" : (root.pin?.prompt ?? root.flow?.inputPrompt ?? "").replace(/:\s*$/, "")
                        color: root.wrong ? Theme.orange(Theme.eyesDark) : Theme.inkSoft
                    }
                    TextInput {
                        id: field
                        anchors.fill: parent
                        anchors.leftMargin: Math.round(10 * win.u)
                        anchors.rightMargin: Math.round(10 * win.u)
                        verticalAlignment: TextInput.AlignVCenter
                        focus: win.visible
                        enabled: root.pin !== null || (root.flow?.isResponseRequired ?? false)
                        echoMode: !root.pin && root.flow?.responseVisible ? TextInput.Normal : TextInput.Password
                        clip: true
                        color: Theme.ink
                        selectionColor: Wallpaper.accent
                        selectedTextColor: "white"
                        font.family: Theme.menuText
                        font.pixelSize: Math.round(14 * win.u)
                        renderType: Text.NativeRendering
                        onTextEdited: root.wrong = false
                        onAccepted: root.submit()
                        Keys.onEscapePressed: root.cancel()
                    }
                }

                Label {
                    width: parent.width
                    wrapMode: Text.Wrap
                    visible: text !== ""
                    text: root.pin?.error ?? root.flow?.supplementaryMessage ?? ""
                    color: root.pin || root.flow?.supplementaryIsError ? Theme.orange(Theme.eyesDark) : Theme.inkSoft
                }

                Row {
                    anchors.right: parent.right
                    spacing: Math.round(10 * win.u)

                    Button {
                        text: "Cancel"
                        onClicked: root.cancel()
                    }
                    Button {
                        text: "Authenticate"
                        primary: true
                        onClicked: root.submit()
                    }
                }
            }
        }
    }
}
