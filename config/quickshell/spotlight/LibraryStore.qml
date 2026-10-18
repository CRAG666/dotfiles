import Quickshell
import Quickshell.Io
import QtQuick
import "js/search.js" as Search

// Bookmarks and notes, the git-crypt'd sqlite databases in
// ~/.local/share/spotlight, read and written through spotlight.py. Bookmarks
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
        return [...new Set(source.items.map(entry => entry.category))].sort((a, b) => a.localeCompare(b));
    }

    function bookmarkItems(tokens) {
        return bookmarks.items
            .filter(entry => matching(entry, tokens))
            .map(entry => ({ key: "bookmark:" + entry.id, kind: "bookmark", store: root, entry, title: entry.title, hint: entry.category, icon: "web-browser" }));
    }

    function noteItems(tokens) {
        return notes.items
            .filter(entry => matching(entry, tokens))
            .map(entry => ({ key: "note:" + entry.id, kind: "note", store: root, entry, title: entry.title, hint: entry.category, icon: "accessories-text-editor" }));
    }

    // the title and category match loosely, the URL or note text only exactly
    function matching(entry, tokens) {
        return Spot.matchesFolded(entry.name, tokens) || Spot.matchesFolded(entry.haystack, tokens, false);
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
            return { icon: item.icon, title: item.title, subtitle: item.entry.category, body: item.entry.body, markdown: true, actions: [["Enter", "Copy"], ["Ctrl+E", "Edit text"], ["Ctrl+R", "Rename"], ["Ctrl+X", "Delete"]] };
        return { icon: item.icon, title: item.title, subtitle: item.action.includes("note") ? "Notes" : "Bookmarks", actions: [["Enter", "Run"]] };
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
            host.openForm({
                title: "Create Note",
                fields: [
                    { key: "title", label: "Title", value: "" },
                    { key: "category", label: "Category", value: "", options: categories(notes) }
                ],
                submit: values => {
                    Spot.helperDetached(["note-add", values.title, values.category]);
                    return true;
                }
            });
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
        job.exec(["python3", Spot.helper, ...args]);
    }

    Source {
        id: bookmarks
        maxAge: 30000
        command: ["python3", Spot.helper, "list", "bookmarks"]
        parse: output => root.indexed(output)
    }

    Source {
        id: notes
        maxAge: 30000
        command: ["python3", Spot.helper, "list", "notes"]
        parse: output => root.indexed(output)
    }

    Process {
        id: job
        stderr: StdioCollector {
            id: jobErrors
        }
        onExited: exitCode => {
            if (exitCode !== 0)
                root.host.notify(jobErrors.text.trim() || `Failed with code ${exitCode}`);
            bookmarks.reload();
            notes.reload();
        }
    }
}
