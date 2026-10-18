import Quickshell.Io
import QtQuick

// Runs `command(query)` once `query` has rested for `interval` ms and hands its
// stdout to `done`, dropping what arrives after the query changed; a null
// command (nothing worth looking up) hands "" at once.
Timer {
    id: root
    property string query: ""
    property var command: query => null
    signal done(string output)

    onQueryChanged: restart()
    onTriggered: {
        const argv = command(query);
        if (!argv) {
            done("");
            return;
        }
        process.forQuery = query;
        process.exec(argv);
    }

    property Process process: Process {
        property string forQuery: ""
        stdout: StdioCollector {
            onStreamFinished: {
                if (root.process.forQuery === root.query)
                    root.done(text);
            }
        }
    }
}
