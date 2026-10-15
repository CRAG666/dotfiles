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

    function bump(key) {
        picks[key] = [(picks[key]?.[0] ?? 0) + 1, Date.now()];
        const kept = {};
        for (const name of Object.keys(picks).sort((a, b) => weight(b) - weight(a)).slice(0, 500))
            kept[name] = picks[name];
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
