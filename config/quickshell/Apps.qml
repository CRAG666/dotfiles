pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick
import qs.spotlight
import "spotlight/js/search.js" as Search

// App search for Spotlight and the Launcher: the name matches loosely
// (search.js: initials, typos, accents), the generic name, exec, categories and
// keywords only exactly and below any name match. How well an app matches and
// how often it was launched make one score; ties are alphabetical. Launch counts
// are kept in rofi's drun history format under the spotlight state dir.
Singleton {
    id: root
    // a binding on the file's text, which blocks until loaded: right from the
    // first read, whoever creates this singleton and whenever, and redone as
    // the file changes
    readonly property var launches: {
        const counts = {};
        for (const line of history.text().split("\n")) {
            const match = line.match(/^(\d+) (.+)$/);
            if (match)
                counts[match[2]] = Number(match[1]);
        }
        return counts;
    }
    // alphabetical, the id breaking ties: DesktopEntries lists the apps in another
    // order at every start. `order` is that rank, so a search breaks ties without
    // comparing names on every keystroke
    readonly property var indexed: {
        const entries = Spot.applications.map(app => ({ app, name: Search.fold(app.name), haystack: Search.fold([app.name, app.genericName, app.execString, ...app.categories, ...app.keywords].join(" ")) }));
        entries.sort((a, b) => a.name.localeCompare(b.name) || (a.app.id < b.app.id ? -1 : a.app.id > b.app.id ? 1 : 0));
        entries.forEach((entry, order) => entry.order = order);
        return entries;
    }

    FileView {
        id: history
        path: Spot.stateDir + "/launches"
        blockLoading: true
        blockWrites: true
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
    }

    // the apps `query` finds, as { app, order, score }, in no order
    function matching(query) {
        const tokens = Search.tokens(query);
        const found = [];
        for (let index = 0; index < indexed.length; index++) {
            const entry = indexed[index];
            const quality = Search.score(entry.name, tokens) || Search.score(entry.haystack, tokens, false) * 0.4;
            if (quality)
                found.push({ app: entry.app, order: entry.order, score: quality + Search.boost(launches[entry.app.id + ".desktop"] ?? 0) });
        }
        return found;
    }

    // the best `limit` apps `query` finds, best first, and whether there are more
    function search(query, limit = Infinity) {
        const found = matching(query);
        const best = Spot.firstSorted(found, (a, b) => b.score - a.score || a.order - b.order, limit);
        const apps = best.map(entry => entry.app);
        apps.more = best.length < found.length;
        return apps;
    }

    function launch(app) {
        const counts = Object.assign({}, launches);
        counts[app.id + ".desktop"] = (counts[app.id + ".desktop"] ?? 0) + 1;
        history.setText(Object.entries(counts).map(([id, count]) => count + " " + id + "\n").join(""));

        if (app.runInTerminal)
            Quickshell.execDetached({ command: ["ghostty", "+new-window", "-e", ...app.command], workingDirectory: app.workingDirectory });
        else
            app.execute();
    }
}
