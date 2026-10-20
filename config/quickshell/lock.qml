import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pam
import QtQuick

// Session lock, run as its own process (via lock.sh) so a widget reload/crash
// never drops it. It stays resident between locks, as starting it took ~300 ms
// of the ~370 before the screen was secure; lock.sh locks it through a fifo. The
// password is shared by every screen's surface; PAM uses /etc/pam.d/login. On
// success the blur dissolves back to the wallpaper, then unlocks.
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
            session.locked = false;
        }
    }

    // does nothing while locked
    function lock() {
        if (session.locked)
            return;
        password = "";
        message = "";
        failed = false;
        unlocking = false;
        session.locked = true;
    }

    // lock.sh writes "lock" lines here, as spotlight.sh does to Spotlight's: a
    // printf costs nothing next to starting a `quickshell ipc` client (~150 ms),
    // which it only uses right after starting this instance
    Process {
        running: true
        command: ["sh", "-c", 'echo "$PPID" > "$1.pid"; rm -f "$1"; mkfifo -m 600 "$1"; exec setpriv --pdeathsig TERM cat 0<> "$1"', "sh", Quickshell.env("XDG_RUNTIME_DIR") + "/qs-lock.fifo"]
        stdout: SplitParser {
            onRead: line => {
                if (line === "lock")
                    root.lock();
            }
        }
        onRunningChanged: if (!running) running = true
    }

    IpcHandler {
        target: "lock"

        function lock(): void {
            root.lock();
        }
    }

    WlSessionLock {
        id: session
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
