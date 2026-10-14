import Quickshell
import Quickshell.Io
import QtQuick

// The notification history kept by the shell's server (notifications/), newest
// first. Enter opens the notification's link or copies its text, Ctrl+X forgets
// it; clearing and Do Not Disturb are sent back to the server over IPC, and the
// history file it rewrites refreshes the list.
Scope {
    id: root
    readonly property string shell: Spot.home + "/.config/quickshell/shell.qml"
    property var saved: ({ dnd: false, items: [] })

    function call(args) {
        Quickshell.execDetached(["qs", "ipc", "-p", shell, "call", "notifications", ...args]);
    }

    function link(entry) {
        return entry.body.match(/https?:\/\/\S+/)?.[0] ?? "";
    }

    function ago(time) {
        const minutes = Math.round((Date.now() - time) / 60000);
        if (minutes < 1)
            return "now";
        if (minutes < 60)
            return minutes + " min";
        return minutes < 1440 ? Math.round(minutes / 60) + " h" : Math.round(minutes / 1440) + " d";
    }

    function items(tokens) {
        return saved.items
            .filter(entry => Spot.matches(`${entry.app} ${entry.summary} ${entry.body}`, tokens))
            .map(entry => ({ key: "notification:" + entry.id, kind: "notification", store: root, entry, title: entry.summary || entry.app, hint: ago(entry.time), icon: entry.icon || "dialog-information" }));
    }

    function commandItems(tokens) {
        return [
            { action: "dnd", title: `Turn Do Not Disturb ${saved.dnd ? "Off" : "On"}`, hint: saved.dnd ? "On" : "Off", icon: "notification-disabled" },
            { action: "clear", title: "Clear Notifications", icon: "edit-clear-all", confirm: true }
        ]
            .filter(command => Spot.matches(command.title + " notifications dnd", tokens))
            .map(command => Object.assign({ key: "notifications:" + command.action, kind: "notificationCommand", store: root }, command));
    }

    function describe(item) {
        if (item.kind === "notificationCommand")
            return { icon: item.icon, title: item.title, subtitle: "Notifications", actions: [["Enter", item.action === "dnd" ? item.title : "Clear"]] };
        const entry = item.entry;
        return { icon: item.icon, title: entry.summary || entry.app, subtitle: entry.app, body: entry.body, metadata: [["App", entry.app], ["Received", new Date(entry.time).toLocaleString(Qt.locale(), Locale.ShortFormat)], ["Urgency", entry.critical ? "Critical" : "Normal"]], actions: [["Enter", link(entry) ? "Open link" : "Copy"], ["Ctrl+C", "Copy"], ["Ctrl+X", "Forget"]] };
    }

    function activate(item, keys) {
        if (item.kind === "notificationCommand") {
            call([item.action === "dnd" ? "toggleDnd" : "clear"]);
            return true;
        }
        const url = link(item.entry);
        if (url)
            Quickshell.execDetached(["xdg-open", url]);
        else
            copy(item);
        return true;
    }

    function copy(item) {
        Spot.copy(item.entry ? [item.entry.summary, item.entry.body].filter(text => text).join("\n") : item.title);
    }

    function act(item, action) {
        if (action === "delete" && item.kind === "notification")
            call(["remove", item.entry.id]);
        return false;
    }

    FileView {
        path: (Quickshell.env("XDG_STATE_HOME") || Spot.home + "/.local/state") + "/notifications/history.json"
        blockLoading: true
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: root.saved = JSON.parse(text())
    }
}
