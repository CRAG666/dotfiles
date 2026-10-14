import Quickshell
import Quickshell.Io
import QtQuick

// Scroll marks (auto_marks.lua sets some per app): Enter jumps to the marked
// window, typing a name that isn't a mark yet offers to add it to the focused
// window, Ctrl+X removes one (press twice).
Scope {
    id: root
    property var host
    property var windows

    // con_mark is a regex, so the name is escaped to match literally
    function criteria(mark) {
        const literal = mark.replace(/[.*+?^$(){}|[\]\\"]/g, "\\$&");
        return `[con_mark="^${literal}$"]`;
    }

    function items(tokens, raw) {
        const focused = windows.list.find(window => window.focused);
        const marked = [].concat(...windows.list.map(window => window.marks.map(mark => ({ mark, window }))));
        const list = [];
        if (raw && !/\s/.test(raw) && focused && !marked.some(entry => entry.mark === raw))
            list.push({ key: "mark:add", kind: "markAdd", store: root, section: "Add", title: `Add mark “${raw}”`, hint: focused.appId, icon: Spot.iconFor(focused.appId), mark: raw, window: focused });
        const matching = marked.filter(entry => Spot.matches(`${entry.mark} ${entry.window.appId} ${entry.window.title}`, tokens));
        for (const entry of matching.sort((a, b) => b.window.focused - a.window.focused || a.mark.localeCompare(b.mark)))
            list.push({ key: "mark:" + entry.mark, kind: "mark", store: root, section: entry.window.focused ? "This window" : "Marks", title: entry.mark, hint: entry.window.appId, icon: Spot.iconFor(entry.window.appId), mark: entry.mark, window: entry.window, thumb: windows.shot(entry.window) });
        if (!tokens.length && focused?.marks.length > 1)
            list.push({ key: "mark:clear", kind: "markClear", store: root, section: "This window", title: "Remove all marks of this window", icon: "edit-clear", window: focused });
        return list;
    }

    // $mod+m on an unmarked window opens Spotlight straight into this form
    function promptAdd() {
        host.openForm({
            title: "Add Mark",
            closeOnCancel: true,
            fields: [{ key: "mark", label: "Mark for the focused window", value: "" }],
            submit: values => {
                Quickshell.execDetached(["scrollmsg", "mark --add " + values.mark.replace(/\s+/g, "-")]);
                return true;
            }
        });
    }

    function describe(item) {
        const window = item.window;
        if (item.kind === "markAdd")
            return { image: windows.shot(window), icon: item.icon, title: item.title, subtitle: "On " + window.title, actions: [["Enter", "Add mark"]] };
        if (item.kind === "markClear")
            return { icon: item.icon, title: item.title, subtitle: window.marks.join("  "), actions: [["Enter", "Remove all"]] };
        return { image: windows.shot(window), icon: item.icon, title: item.mark, subtitle: window.title, metadata: [["App", window.appId], ["Workspace", window.workspace]], actions: [["Enter", "Focus window"], ["Ctrl+X", "Remove mark"], ["Ctrl+C", "Copy mark"]] };
    }

    function activate(item, keys) {
        if (item.kind === "mark") {
            Quickshell.execDetached(["scrollmsg", criteria(item.mark) + " focus"]);
            return true;
        }
        if (item.kind === "markAdd") {
            Quickshell.execDetached(["scrollmsg", "mark --add " + item.mark]);
            return true;
        }
        job.exec(["sh", "-c", 'for mark in "$@"; do scrollmsg unmark "$mark"; done', "sh", ...item.window.marks]);
        return false;
    }

    function copy(item) {
        Spot.copy(item.mark);
    }

    function act(item, action) {
        if (item.kind === "mark" && action === "delete")
            job.exec(["scrollmsg", "unmark", item.mark]);
        return false;
    }

    Process {
        id: job
        onExited: root.windows.reload()
    }
}
