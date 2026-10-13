import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pam
import QtQuick

// Session lock, run as its own process (via lock.sh) so a widget reload/crash
// never drops it. The password is shared by every screen's surface; PAM uses
// /etc/pam.d/login. On success the blur dissolves back to the wallpaper, then unlocks.
ShellRoot {
    id: root
    property string password: ""
    property string message: ""
    property bool failed: false
    property bool unlocking: false
    readonly property string secureFlag: Quickshell.env("XDG_RUNTIME_DIR") + "/qs-lock.secure"

    function submit() {
        if (password === "" || pam.active || unlocking)
            return;
        failed = false;
        pam.start();
    }

    PamContext {
        id: pam
        onPamMessage: if (responseRequired) respond(root.password)
        onCompleted: result => {
            if (result === PamResult.Success) {
                root.unlocking = true;
                unlockDelay.start();
                return;
            }
            root.message = pam.messageIsError ? pam.message
                : result === PamResult.MaxTries ? "Too many attempts"
                : "Wrong password";
            root.password = "";
            root.failed = true;
        }
    }

    Timer {
        id: unlockDelay
        interval: 450
        onTriggered: {
            Quickshell.execDetached(["rm", "-f", root.secureFlag]);
            lock.locked = false;
            Qt.quit();
        }
    }

    WlSessionLock {
        id: lock
        locked: true
        onSecureChanged: if (secure) Quickshell.execDetached(["touch", root.secureFlag])

        WlSessionLockSurface {
            color: "black"

            LockSurface {
                anchors.fill: parent
                password: root.password
                busy: pam.active
                failed: root.failed
                message: root.message
                revealed: !root.unlocking
                onEdited: text => {
                    root.password = text;
                    root.failed = false;
                }
                onSubmitted: root.submit()
            }
        }
    }
}
