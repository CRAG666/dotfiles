import Quickshell
import QtQuick
import qs

// Universal Actions, as Alfred's ($mod+u): what is selected in any window, or
// else what was last copied, with the actions that fit it. A URL opens or
// becomes a bookmark, a path is the file itself (Enter, Ctrl+Enter, Ctrl+B), a
// DOI is looked up, a sum is worked out; any text goes to pi, the AI commands
// (on a selection), a web or quicklink search, a note, the search of
// everything, Large Type or the clipboard. Typing filters the actions.
Scope {
    id: root
    property var host
    property var files
    property var web
    property var ai
    property var calculator
    property var library

    readonly property bool selected: host.selectedText.trim() !== ""
    readonly property string subject: (selected ? host.selectedText : host.clipboardText).trim()
    readonly property string type: /^https?:\/\/\S+$/.test(subject) ? "URL" : files.isPath(subject) ? "Path" : /\b10\.\d{4,9}\/\S+/.test(subject) ? "DOI" : calculator.calculate(subject) !== null ? "Sum" : "Text"

    function own(action, title, icon) {
        return { key: "selection:" + action, kind: "selection", store: root, action, title, icon };
    }

    function typed() {
        switch (type) {
        case "URL":
            return [...web.urlItems(subject), own("bookmark", "Save as Bookmark", "user-bookmarks")];
        case "Path":
            return [files.fileItem(files.expand(subject).replace(/\/$/, ""), subject.endsWith("/"), "")];
        case "DOI":
            return [own("paper", "Look up Paper", "application-pdf")];
        case "Sum":
            return calculator.items(subject);
        }
        return [];
    }

    // made once a subject, so a keystroke only filters them and the list keeps its rows
    readonly property var actions: subject ? typed().concat(ai.askItems(subject), selected ? ai.commandItems([]) : [], web.searchItems(subject), web.queryItems(subject), [own("note", "Save as Note", "accessories-text-editor"), own("spotlight", "Search Spotlight", "system-search"), own("large", "Large Type", "zoom-in"), own("copy", "Copy", "edit-copy")]) : []

    function sections(tokens) {
        if (!subject)
            return [["Selection", [own("none", "Select some text in any window, then press $mod+u", "edit-select-all")]]];
        const actions = root.actions.filter(item => Spot.matches(item.title, tokens));
        const shown = subject.replace(/\s+/g, " ");
        return [[`${selected ? "Selected" : "Copied"} ${type.toLowerCase()} · ${shown.length > 48 ? shown.slice(0, 48) + "…" : shown}`, actions]];
    }

    function describe(item) {
        return { icon: item.icon, title: item.title, subtitle: subject, actions: item.action === "none" ? [] : [["Enter", item.title]] };
    }

    function activate(item, keys) {
        switch (item.action) {
        case "copy":
            Spot.copy(subject);
            return true;
        case "large":
            host.largeText = subject;
            return false;
        case "spotlight":
        case "paper":
            host.openView("");
            host.setQuery(subject);
            return false;
        case "bookmark":
            library.bookmarkForm("Add Bookmark", { body: subject, title: "", category: "" });
            return false;
        case "note":
            library.noteForm(subject);
            return false;
        }
        return false;
    }
}
