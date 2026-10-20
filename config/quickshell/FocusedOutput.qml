pragma Singleton
import Quickshell
import Quickshell.I3
import QtQuick

// The screen holding scroll's focused workspace, followed through scroll's IPC
// (sway's, which Quickshell.I3 speaks), so popups open where you are working.
// Null while no output is connected: a nameless screen is Qt's placeholder for
// none, or one that went away.
Singleton {
    readonly property string name: I3.focusedMonitor?.name ?? ""
    readonly property var screen: Quickshell.screens.find(screen => screen.name && screen.name === name) ?? Quickshell.screens.find(screen => screen.name) ?? null
}
