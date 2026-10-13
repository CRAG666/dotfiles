pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

// App search for spotlight.qml and launcher.qml, matching like rofi's drun: every
// whitespace token must appear (case-insensitive) in the name, generic name,
// exec, categories or keywords. Most-launched apps come first, then name-prefix
// matches, then name matches; ties are alphabetical. Launch counts are kept in
// rofi's drun history format under the spotlight state dir.
Singleton {
    id: root
    property var launches: ({})

    FileView {
        id: history
        path: Spot.stateDir + "/launches"
        blockLoading: true
        blockWrites: true
        printErrors: false
        onLoaded: {
            const counts = {};
            for (const line of text().split("\n")) {
                const match = line.match(/^(\d+) (.+)$/);
                if (match)
                    counts[match[2]] = Number(match[1]);
            }
            root.launches = counts;
        }
    }

    function search(query) {
        const tokens = query.toLowerCase().split(/\s+/).filter(token => token);
        const first = tokens[0] ?? "";
        const ranked = [];
        for (const app of DesktopEntries.applications.values) {
            const name = app.name.toLowerCase();
            const haystack = [name, app.genericName, app.execString, ...app.categories, ...app.keywords].join(" ").toLowerCase();
            if (!tokens.every(token => haystack.includes(token)))
                continue;
            const uses = launches[app.id + ".desktop"] ?? 0;
            const rank = name.startsWith(first) ? 0 : name.includes(first) ? 1 : 2;
            ranked.push({ app, uses, rank, name });
        }
        ranked.sort((a, b) => b.uses - a.uses || a.rank - b.rank || a.name.localeCompare(b.name));
        return ranked.map(entry => entry.app);
    }

    function launch(app) {
        const counts = Object.assign({}, launches);
        counts[app.id + ".desktop"] = (counts[app.id + ".desktop"] ?? 0) + 1;
        history.setText(Object.entries(counts)
            .sort((a, b) => b[1] - a[1])
            .map(([id, count]) => count + " " + id + "\n")
            .join(""));

        if (app.runInTerminal)
            Quickshell.execDetached({ command: ["kitty", "-1", "-e", ...app.command], workingDirectory: app.workingDirectory });
        else
            app.execute();
    }
}
