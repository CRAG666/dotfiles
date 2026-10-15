pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

// The screen holding scroll's focused workspace, read once and then followed
// through workspace events, so popups open where you are working.
Singleton {
    id: root
    readonly property var screen: Quickshell.screens.find(screen => screen.name === focused.name) ?? Quickshell.screens[0]

    // kept across hot reloads: starting again from "" sends every popup window
    // to the first screen and back mid-reload, and Quickshell crashes in setScreen
    PersistentProperties {
        id: focused
        reloadableId: "focusedOutput"
        property string name: ""
    }

    Process {
        running: true
        command: ["scrollmsg", "-t", "get_workspaces", "-r"]
        stdout: StdioCollector {
            onStreamFinished: focused.name = JSON.parse(text).find(workspace => workspace.focused)?.output ?? ""
        }
    }

    Process {
        running: true
        command: ["scrollmsg", "-t", "subscribe", "-m", "-r", '["workspace"]']
        stdout: SplitParser {
            onRead: line => {
                const event = JSON.parse(line);
                if (event.change === "focus" && event.current?.output)
                    focused.name = event.current.output;
            }
        }
    }
}
