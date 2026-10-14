import Quickshell
import Quickshell.Io
import Quickshell.Services.Greetd
import Quickshell.Wayland
import QtQuick

// greetd greeter, run as the greeter user by /etc/greetd/scroll in place of
// ReGreet. `just wayland` installs it in /etc/greetd/quickshell together with
// Theme, WText and DateBlock from config/quickshell, so it looks like the lock
// screen. Users come from /etc/passwd, sessions from /usr/share/wayland-sessions;
// the last user and each user's last session are kept in /var/lib/qs-greeter.
// Keys: type the password and Enter; Tab / Shift+Tab pick the session, Up / Down
// the user; Ctrl+R restarts and Ctrl+P powers off (press twice).
ShellRoot {
    id: root
    readonly property string stateFile: "/var/lib/qs-greeter/state.json"
    readonly property string background: "/etc/greetd/laptop.png"

    property var users: []
    property var sessions: []
    property var memory: ({ user: "", sessions: {} })   // last user and session per user
    property int userIndex: 0
    property int sessionIndex: 0
    readonly property var user: users[userIndex] ?? null
    readonly property var session: sessions[sessionIndex] ?? null

    property string password: ""
    property string message: ""
    property bool failed: false
    property bool busy: false
    property bool leaving: false
    property string armed: ""   // "reboot" / "poweroff" waiting for the second press

    onUserChanged: rememberedSession()
    onSessionsChanged: rememberedSession()

    function pickUser(step) {
        if (users.length > 1)
            userIndex = (userIndex + step + users.length) % users.length;
    }

    function pickSession(step) {
        if (sessions.length)
            sessionIndex = (sessionIndex + step + sessions.length) % sessions.length;
    }

    function rememberedSession() {
        const name = user ? memory.sessions[user.name] : undefined;
        const index = sessions.findIndex(entry => entry.name === name);
        if (index >= 0)
            sessionIndex = index;
    }

    function edit(text) {
        password = text;
        failed = false;
        armed = "";
    }

    function fail(text) {
        message = text;
        password = "";
        failed = true;
        busy = false;
    }

    function login() {
        if (busy || leaving || !user || !session || password === "")
            return;
        if (!Greetd.available) {
            fail("greetd is not running");
            return;
        }
        busy = true;
        failed = false;
        Greetd.createSession(user.name);
    }

    function power(action) {
        if (armed !== action) {
            armed = action;
            return;
        }
        Quickshell.execDetached(["systemctl", action]);
    }

    Connections {
        target: Greetd

        function onAuthMessage(text, error, responseRequired, echoResponse) {
            if (responseRequired)
                Greetd.respond(root.password);
            else if (error)
                root.message = text;
        }

        function onAuthFailure(text) {
            root.fail(text || "Wrong password");
        }

        function onError(text) {
            Greetd.cancelSession();
            root.fail(text);
        }

        function onReadyToLaunch() {
            const lastSessions = Object.assign({}, root.memory.sessions, { [root.user.name]: root.session.name });
            memoryFile.setText(JSON.stringify({ user: root.user.name, sessions: lastSessions }));
            root.leaving = true;
            launchDelay.start();
        }
    }

    // the fade out finishes before greetd swaps the greeter for the session
    Timer {
        id: launchDelay
        interval: 450
        onTriggered: Greetd.launch(root.session.command, ["XDG_SESSION_TYPE=wayland", "XDG_SESSION_DESKTOP=" + root.session.id, "XDG_CURRENT_DESKTOP=" + root.session.desktops], true)
    }

    FileView {
        path: "/etc/passwd"
        blockLoading: true
        onLoaded: {
            root.users = text().split("\n")
                .map(line => line.split(":"))
                .filter(fields => Number(fields[2]) >= 1000 && Number(fields[2]) < 60000 && !/(nologin|false)$/.test(fields[6] ?? ""))
                .map(fields => ({ name: fields[0], label: fields[4].split(",")[0] || fields[0] }));
            root.userIndex = Math.max(0, root.users.findIndex(entry => entry.name === root.memory.user));
        }
    }

    FileView {
        id: memoryFile
        path: root.stateFile
        blockLoading: true
        blockWrites: true
        printErrors: false
        onLoaded: {
            root.memory = JSON.parse(text());
            root.userIndex = Math.max(0, root.users.findIndex(entry => entry.name === root.memory.user));
            root.rememberedSession();
        }
    }

    // Name, Exec (field codes dropped) and DesktopNames of every visible session
    Process {
        running: true
        command: ["sh", "-c", 'for file in /usr/share/wayland-sessions/*.desktop; do printf "\\036%s\\n" "${file##*/}"; cat "$file"; done']
        stdout: StdioCollector {
            onStreamFinished: {
                const found = [];
                for (const chunk of text.split("\x1e").filter(part => part)) {
                    const lines = chunk.split("\n");
                    const field = key => (lines.find(line => line.startsWith(key + "=")) ?? "").slice(key.length + 1).trim();
                    if (field("NoDisplay") === "true" || field("Hidden") === "true" || !field("Exec"))
                        continue;
                    const id = lines[0].replace(/\.desktop$/, "");
                    found.push({ id, name: field("Name") || id, command: field("Exec").split(/\s+/).filter(word => !/^%[a-zA-Z]$/.test(word)), desktops: field("DesktopNames").replace(/;$/, "").split(";").join(":") || id });
                }
                root.sessions = found.sort((a, b) => a.name.localeCompare(b.name));
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData
            color: "black"
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            GreeterSurface {
                anchors.fill: parent
                greeter: root
            }
        }
    }
}
