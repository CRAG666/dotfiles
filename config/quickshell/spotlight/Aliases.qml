import Quickshell
import Quickshell.Io
import QtQuick

// Aliases you gave results from the Ctrl+K panel ("ov" → Overleaf). Typing an
// alias alone puts its result first; Spotlight finds it again by searching its
// title and picking the same key, or the same kind and title when the key
// changed (a restarted Herdr renumbers its workspaces).
Scope {
    id: root
    property var entries: ({})   // alias → { key, kind, title }

    function get(alias) {
        // own keys only: "constructor" is not an alias
        return Object.prototype.hasOwnProperty.call(entries, alias.toLowerCase()) ? entries[alias.toLowerCase()] : null;
    }

    function aliasOf(key) {
        return Object.keys(entries).find(alias => entries[alias].key === key) ?? "";
    }

    function set(alias, item) {
        const kept = without(item.key);
        kept[alias.toLowerCase()] = { key: item.key, kind: item.kind, title: item.title };
        save(kept);
    }

    function remove(key) {
        save(without(key));
    }

    // Qt's JavaScript has no Object.fromEntries
    function without(key) {
        const kept = {};
        for (const alias of Object.keys(entries).filter(alias => entries[alias].key !== key))
            kept[alias] = entries[alias];
        return kept;
    }

    function save(kept) {
        entries = kept;
        file.setText(JSON.stringify(kept, null, 2));
    }

    FileView {
        id: file
        path: Spot.stateDir + "/aliases.json"
        blockLoading: true
        printErrors: false
        onLoaded: root.entries = JSON.parse(text())
    }
}
