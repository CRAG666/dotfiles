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

    // a mark as one quoted argument of a scroll command: unquoted, a ";" or ","
    // in it would start a second command ("x;kill" closing the window)
    function quoted(mark) {
        return '"' + mark.replace(/["\\]/g, "\\$&") + '"';
    }

    // con_mark is a regex, so the name is escaped to match literally
    function criteria(mark) {
        const literal = mark.replace(/[.*+?^$(){}|[\]\\"]/g, "\\$&");
        return `[con_mark="^${literal}$"]`;
    }

    // every mark with its window, the focused window's first and then by name,
    // and the marks taken: made once a tree, so a keystroke only filters them
    readonly property var marked: {
        const list = [];
        for (let index = 0; index < windows.list.length; index++) {
            const window = windows.list[index];
            for (let at = 0; at < window.marks.length; at++)
                list.push({ mark: window.marks[at], window });
        }
        return list.sort((a, b) => b.window.focused - a.window.focused || a.mark.localeCompare(b.mark));
    }
    readonly property var taken: {
        const names = Object.create(null);
        for (let index = 0; index < marked.length; index++)
            names[marked[index].mark] = true;
        return names;
    }

    function items(tokens, raw) {
        const focused = windows.list.find(window => window.focused);
        const list = [];
        if (raw && !/\s/.test(raw) && focused && !(raw in taken))
            list.push({ key: "mark:add", kind: "markAdd", store: root, section: "Add", title: `Add mark “${raw}”`, hint: focused.appId, icon: Spot.iconFor(focused.appId), mark: raw, window: focused });
        const matching = marked.filter(entry => Spot.matches(`${entry.mark} ${entry.window.appId} ${entry.window.title}`, tokens));
        for (let index = 0; index < matching.length; index++) {
            const entry = matching[index];
            list.push({ key: "mark:" + entry.mark, kind: "mark", store: root, section: entry.window.focused ? "This window" : "Marks", title: entry.mark, hint: entry.window.appId, icon: Spot.iconFor(entry.window.appId), mark: entry.mark, window: entry.window, thumb: windows.shot(entry.window) });
        }
        if (!tokens.length && focused?.marks.length > 1)
            list.push({ key: "mark:clear", kind: "markClear", store: root, section: "This window", title: "Remove all marks of this window", icon: "edit-clear", window: focused });
        return list;
    }

    // $mod+i on an unmarked window opens Spotlight straight into this form
    function promptAdd() {
        host.openForm({
            title: "Add Mark",
            closeOnCancel: true,
            fields: [{ key: "mark", label: "Mark for the focused window", value: "" }],
            submit: values => {
                Quickshell.execDetached(["scrollmsg", "mark --add " + root.quoted(values.mark.replace(/\s+/g, "-"))]);
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
            Quickshell.execDetached(["scrollmsg", "mark --add " + quoted(item.mark)]);
            return true;
        }
        job.exec(["scrollmsg", item.window.marks.map(mark => "unmark " + quoted(mark)).join("; ")]);
        return false;
    }

    function copy(item) {
        Spot.copy(item.mark);
    }

    function act(item, action) {
        if (item.kind === "mark" && action === "delete")
            job.exec(["scrollmsg", "unmark " + quoted(item.mark)]);
        return false;
    }

    Process {
        id: job
        onExited: root.windows.reload()
    }
}
