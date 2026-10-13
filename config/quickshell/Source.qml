import Quickshell.Io
import QtQuick

// Runs `command` and keeps its stdout run through `parse` in `items`: once on
// the first load(), and again on every reload(). spotlight.qml and its stores
// feed most of their results this way.
Process {
    id: root
    property var parse: output => []
    property var items: []

    function load() {
        if (!running && !items.length)
            running = true;
    }

    function reload() {
        if (!running)
            running = true;
    }

    stdout: StdioCollector {
        onStreamFinished: root.items = root.parse(text)
    }
}
