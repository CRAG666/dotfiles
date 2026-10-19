import Quickshell.Io
import QtQuick

// Runs `command` and keeps its stdout run through `parse` (JSON by default, []
// for no output) in `items`; `request` asks the resident helper instead
// (Spot.call). Spotlight stays resident, so load() only fetches when nothing
// was loaded yet or the result is older than `maxAge` ms (-1: it never
// expires); meanwhile the old items keep showing. reload() always fetches;
// the same output again leaves `items` alone, so Spotlight does not recompute.
Process {
    id: root
    property var parse: output => output.trim() ? JSON.parse(output) : []
    property var items: []
    property int maxAge: -1
    property double loadedAt: 0
    property string output: ""
    property var request: null
    property bool asking: false

    function load() {
        if (!loadedAt || maxAge >= 0 && Date.now() - loadedAt > maxAge)
            reload();
    }

    function reload() {
        if (!request) {
            if (!running)
                running = true;
            return;
        }
        if (asking)
            return;
        asking = true;
        Spot.call(request, (output, error) => {
            asking = false;
            if (error)
                console.warn(`helper ${request.join(" ")}: ${error}`);
            take(output);
        });
    }

    function take(text) {
        const fresh = !loadedAt || text !== output;
        loadedAt = Date.now();
        if (fresh) {
            output = text;
            items = parse(text);
        }
    }

    stdout: StdioCollector {
        onStreamFinished: root.take(text)
    }
}
