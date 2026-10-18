import Quickshell.Io
import QtQuick

// Runs `command` and keeps its stdout run through `parse` (JSON by default, []
// for no output) in `items`. Spotlight stays resident, so load() only fetches
// when nothing was loaded yet or the result is older than `maxAge` ms (-1: it
// never expires); meanwhile the old items keep showing. reload() always fetches;
// the same output again leaves `items` alone, so Spotlight does not recompute.
Process {
    id: root
    property var parse: output => output.trim() ? JSON.parse(output) : []
    property var items: []
    property int maxAge: -1
    property double loadedAt: 0
    property string output: ""

    function load() {
        if (!loadedAt || maxAge >= 0 && Date.now() - loadedAt > maxAge)
            reload();
    }

    function reload() {
        if (!running)
            running = true;
    }

    stdout: StdioCollector {
        onStreamFinished: {
            const fresh = !root.loadedAt || text !== root.output;
            root.loadedAt = Date.now();
            if (fresh) {
                root.output = text;
                root.items = root.parse(text);
            }
        }
    }
}
