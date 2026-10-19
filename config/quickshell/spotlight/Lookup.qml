import Quickshell.Io
import QtQuick

// Runs `command(query)` once `query` has rested for `interval` ms and hands its
// stdout to `done`, dropping what arrives after the query changed; a null
// command (nothing worth looking up) hands "" at once. With `helper` the
// command is the resident helper's arguments (Spot.call).
Timer {
    id: root
    property string query: ""
    property var command: query => null
    property bool helper: false
    signal done(string output)

    onQueryChanged: restart()
    onTriggered: {
        const argv = command(query);
        if (!argv) {
            done("");
            return;
        }
        if (helper) {
            const asked = query;
            Spot.call(argv, (output, error) => {
                if (error)
                    console.warn(`helper ${argv.join(" ")}: ${error}`);
                if (asked === root.query)
                    root.done(output);
            });
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
