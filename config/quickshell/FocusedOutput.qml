pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

// The screen holding scroll's focused workspace, read once and then followed
// through workspace events, so popups open where you are working.
Singleton {
    id: root
    property string name: ""
    readonly property var screen: Quickshell.screens.find(screen => screen.name === name) ?? Quickshell.screens[0]

    Process {
        running: true
        command: ["scrollmsg", "-t", "get_workspaces", "-r"]
        stdout: StdioCollector {
            onStreamFinished: root.name = JSON.parse(text).find(workspace => workspace.focused)?.output ?? ""
        }
    }

    Process {
        running: true
        command: ["scrollmsg", "-t", "subscribe", "-m", "-r", '["workspace"]']
        stdout: SplitParser {
            onRead: line => {
                const event = JSON.parse(line);
                if (event.change === "focus" && event.current?.output)
                    root.name = event.current.output;
            }
        }
    }
}
