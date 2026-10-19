import Quickshell
import Quickshell.Io
import QtQuick
import "js/search.js" as Search

// Bookmarks and notes, the git-crypt'd sqlite databases in
// ~/.local/share/spotlight, read and written through the helper. Bookmarks
// open on Enter, notes are copied; Ctrl+E edits (notes open in nvim), Ctrl+R
// renames a note, Ctrl+X deletes. Forms run inside Spotlight's search field.
Scope {
    id: root
    property var host

    function load() {
        bookmarks.load();
        notes.load();
    }

    function categories(source) {
        return Spot.unique(source.items.map(entry => entry.category)).sort((a, b) => a.localeCompare(b));
    }

    // made once a load, not for every match at every keystroke
    readonly property var bookmarkList: bookmarks.items.map(entry => ({ key: "bookmark:" + entry.id, kind: "bookmark", store: root, entry, title: entry.title, hint: entry.category, icon: "web-browser" }))
    readonly property var noteList: notes.items.map(entry => ({ key: "note:" + entry.id, kind: "note", store: root, entry, title: entry.title, hint: entry.category, icon: "accessories-text-editor" }))

    function bookmarkItems(tokens) {
        return matching(bookmarkList, tokens);
    }

    function noteItems(tokens) {
        return matching(noteList, tokens);
    }

    // the items whose title and category match loosely or whose URL or note
    // text match exactly, in their order; each half keeps its answers (Search.matching).
    // Both halves follow the items' order, so one walk merges them
    function matching(items, tokens) {
        const named = Search.matching(items, "name", item => item.entry.name, tokens);
        const written = Search.matching(items, "haystack", item => item.entry.haystack, tokens, false);
        if (!written.length || !named.length)
            return named.length ? named : written;
        const merged = [];
        let fromNamed = 0, fromWritten = 0;
        for (let index = 0; index < items.length && (fromNamed < named.length || fromWritten < written.length); index++) {
            const item = items[index];
            const isNamed = named[fromNamed] === item, isWritten = written[fromWritten] === item;
            if (isNamed)
                fromNamed++;
            if (isWritten)
                fromWritten++;
            if (isNamed || isWritten)
                merged.push(item);
        }
        return merged;
    }

    function commandItems(tokens) {
        return [
            { action: "add-bookmark", title: "Add Bookmark", icon: "bookmark-new" },
            { action: "create-note", title: "Create Note", icon: "document-new" },
            { action: "rename-bookmarks", title: "Rename Bookmark Category", icon: "folder" },
            { action: "rename-notes", title: "Rename Note Category", icon: "folder" }
        ]
            .filter(command => Spot.matches(command.title, tokens))
            .map(command => Object.assign({ key: "library:" + command.action, kind: "libraryCommand", store: root }, command));
    }

    function describe(item) {
        if (item.kind === "bookmark")
            return { icon: item.icon, title: item.title, subtitle: item.entry.body, metadata: [["Category", item.entry.category]], actions: [["Enter", "Open"], ["Ctrl+C", "Copy URL"], ["Ctrl+E", "Edit"], ["Ctrl+X", "Delete"]] };
        if (item.kind === "note")
            return { document: true, title: item.title, body: item.entry.body, markdown: true, metadata: [["Category", item.entry.category], ["Words", item.entry.body.split(/\s+/).filter(word => word).length]], actions: [["Enter", "Copy"], ["Ctrl+E", "Edit text"], ["Ctrl+R", "Rename"], ["Ctrl+X", "Delete"]] };
        return { icon: item.icon, title: item.title, subtitle: item.action.includes("note") ? "Notes" : "Bookmarks", actions: [["Enter", "Run"]] };
    }

    // asks title and category, then opens the note, starting with `body`, in nvim
    function noteForm(body) {
        host.openForm({
            title: "Create Note",
            fields: [
                { key: "title", label: "Title", value: "" },
                { key: "category", label: "Category", value: "", options: categories(notes) }
            ],
            submit: values => {
                Spot.helperDetached(["note-add", values.title, values.category, body]);
                return true;
            }
        });
    }

    // `entry` without an id only prefills a new bookmark
    function bookmarkForm(title, entry) {
        host.openForm({
            title,
            fields: [
                { key: "url", label: "URL", value: entry?.body ?? (/^https?:\/\//.test(host.clipboardText) ? host.clipboardText : "") },
                { key: "title", label: "Title", value: entry?.title ?? "" },
                { key: "category", label: "Category", value: entry?.category ?? "", options: categories(bookmarks) }
            ],
            submit: values => {
                run(["bookmark-save", entry?.id ? String(entry.id) : "", values.url, values.title, values.category]);
                return false;
            }
        });
    }

    function renameCategoryForm(database, source) {
        host.openForm({
            title: "Rename Category",
            fields: [
                { key: "old", label: "Category", value: "", options: categories(source) },
                { key: "new", label: "New name", value: "" }
            ],
            submit: values => {
                run(["category-rename", database, values.old, values.new]);
                return false;
            }
        });
    }

    function activate(item, keys) {
        switch (item.kind) {
        case "bookmark":
            Spot.open(item.entry.body);
            return true;
        case "note":
            Spot.copy(item.entry.body);
            return true;
        }
        switch (item.action) {
        case "add-bookmark":
            bookmarkForm("Add Bookmark", null);
            break;
        case "create-note":
            noteForm("");
            break;
        case "rename-bookmarks":
            renameCategoryForm("bookmarks", bookmarks);
            break;
        case "rename-notes":
            renameCategoryForm("notes", notes);
            break;
        }
        return false;
    }

    function copy(item) {
        Spot.copy(item.entry ? item.entry.body : item.title);
    }

    function act(item, action) {
        if (item.kind === "bookmark" && (action === "edit" || action === "rename")) {
            bookmarkForm("Edit Bookmark", item.entry);
        } else if (item.kind === "note" && action === "edit") {
            Spot.helperDetached(["note-edit", String(item.entry.id)]);
            return true;
        } else if (item.kind === "note" && action === "rename") {
            host.openForm({
                title: "Rename Note",
                fields: [
                    { key: "title", label: "Title", value: item.entry.title },
                    { key: "category", label: "Category", value: item.entry.category, options: categories(notes) }
                ],
                submit: values => {
                    run(["note-rename", String(item.entry.id), values.title, values.category]);
                    return false;
                }
            });
        } else if (action === "delete") {
            run(["delete", item.kind === "bookmark" ? "bookmarks" : "notes", String(item.entry.id)]);
        }
        return false;
    }

    function indexed(output) {
        return JSON.parse(output).map(entry => Object.assign(entry, { name: Search.fold(`${entry.title} ${entry.category}`), haystack: Search.fold(`${entry.title} ${entry.category} ${entry.body}`) }));
    }

    function run(args) {
        Spot.call(args, (output, error) => {
            if (error)
                root.host.notify(error);
            bookmarks.reload();
            notes.reload();
        });
    }

    Source {
        id: bookmarks
        maxAge: 30000
        request: ["list", "bookmarks"]
        parse: output => root.indexed(output)
    }

    Source {
        id: notes
        maxAge: 30000
        request: ["list", "notes"]
        parse: output => root.indexed(output)
    }
}
