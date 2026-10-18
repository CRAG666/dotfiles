import Quickshell
import Quickshell.Io
import QtQuick

// How often and how recently each result was picked, by item key, so that what
// a search keeps choosing rises in it (apps keep their launch counts in Apps).
// A pick counts half after `halfLife`; only the 500 heaviest keys are kept.
Scope {
    id: root
    readonly property double halfLife: 30 * 24 * 3600 * 1000
    property var picks: ({})   // key → [count, last pick in ms]

    function weight(key) {
        const pick = picks[key];
        return pick ? pick[0] * Math.pow(0.5, (Date.now() - pick[1]) / halfLife) : 0;
    }

    // at most one key over 500 after a pick, so dropping the lightest is one pass
    function bump(key) {
        picks[key] = [(picks[key]?.[0] ?? 0) + 1, Date.now()];
        const kept = Object.assign({}, picks);
        const names = Object.keys(kept);
        if (names.length > 500) {
            let lightest = names[0];
            let least = weight(lightest);
            for (const name of names) {
                const current = weight(name);
                if (current < least) {
                    lightest = name;
                    least = current;
                }
            }
            delete kept[lightest];
        }
        picks = kept;
        file.setText(JSON.stringify(kept));
    }

    FileView {
        id: file
        path: Spot.stateDir + "/picks.json"
        blockLoading: true
        printErrors: false
        onLoaded: root.picks = JSON.parse(text())
    }
}
