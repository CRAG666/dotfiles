pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick
import qs.spotlight
import "spotlight/js/search.js" as Search

// App search for spotlight.qml and launcher.qml: the name matches loosely
// (search.js: initials, typos, accents), the generic name, exec, categories and
// keywords only exactly and below any name match. How well an app matches and
// how often it was launched make one score; ties are alphabetical. Launch counts
// are kept in rofi's drun history format under the spotlight state dir.
Singleton {
    id: root
    property var launches: ({})
    readonly property var indexed: DesktopEntries.applications.values.map(app => ({ app, name: Search.fold(app.name), haystack: Search.fold([app.name, app.genericName, app.execString, ...app.categories, ...app.keywords].join(" ")) }))

    FileView {
        id: history
        path: Spot.stateDir + "/launches"
        blockLoading: true
        blockWrites: true
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
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
        const tokens = Search.tokens(query);
        const ranked = [];
        for (const { app, name, haystack } of indexed) {
            const quality = Search.score(name, tokens) || Search.score(haystack, tokens, false) * 0.4;
            if (quality)
                ranked.push({ app, name, score: quality + Search.boost(launches[app.id + ".desktop"] ?? 0) });
        }
        ranked.sort((a, b) => b.score - a.score || a.name.localeCompare(b.name));
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
            Quickshell.execDetached({ command: ["ghostty", "+new-window", "-e", ...app.command], workingDirectory: app.workingDirectory });
        else
            app.execute();
    }
}
