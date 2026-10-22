import Quickshell
import QtQuick
import "js/search.js" as Search

// The open tasks of your neorg workspaces, read by the helper's tasks in the
// order of Morg's task list: by status, then soonest due. Enter opens the
// task's line in Neovim.
Scope {
    id: root
    property var host
    property string today: Qt.formatDate(new Date(), "yyyy-MM-dd")
    // each open status in the helper's order, drawn as neorg's concealer and
    // Morg draw it: its icon in the colour (`tone`, of Theme.eyes) of eyes'
    // @neorg.todo_items, or on it (`badge`)
    readonly property var statuses: ({
        "!": { label: "Urgent", icon: "⚠", tone: "red", badge: true },
        "-": { label: "Pending", icon: "\u{f0954}", tone: "orange0" },
        " ": { label: "Undone", icon: " ", tone: "gray1" },
        "?": { label: "Needs Input", icon: "\uf420", tone: "orange0" },
        "=": { label: "On Hold", icon: "\uf04c", tone: "teal", badge: true },
        "+": { label: "Recurring", icon: "↺", tone: "violet" }
    })

    function load() {
        today = Qt.formatDate(new Date(), "yyyy-MM-dd");
        source.load();
    }

    function day(iso) {
        return Qt.formatDate(new Date(iso + "T00:00:00"), "d MMM");
    }

    function due(task) {
        return task.due ? (task.due < today ? "Overdue since " : "Due ") + day(task.due) : "";
    }

    // one item per task and day, so a keystroke or a reopening hands the list the same rows
    readonly property var made: {
        source.items;
        today;
        return Object.create(null);
    }

    function item(task) {
        const key = `task:${task.file}:${task.line}`;
        const status = statuses[task.status];
        return made[key] ?? (made[key] = { key, kind: "task", store: root, task, title: task.title, hint: due(task) || task.workspace, glyph: `(${status.icon})`, mono: true, tone: status.tone, badge: !!status.badge });
    }

    function matching(tokens) {
        return Search.matching(source.items, "tasks", task => task.text, tokens);
    }

    function sections(tokens) {
        const found = matching(tokens);
        return Object.keys(statuses).map(status => [statuses[status].label, found.filter(task => task.status === status).map(item)]);
    }

    // the best three but those among the agenda's `events`
    function searchItems(tokens, events) {
        const shown = Object.create(null);
        for (let index = 0; index < events.length; index++)
            shown[`${events[index].event.file}:${events[index].event.line}`] = true;
        return Spot.take(matching(tokens), task => !shown[`${task.file}:${task.line}`], 3).map(item);
    }

    function describe(item) {
        const task = item.task;
        return {
            glyph: item.glyph,
            title: task.title,
            subtitle: `${statuses[task.status].label} · ${task.workspace}`,
            metadata: [["Due", task.due && day(task.due)], ["Starts", task.start && day(task.start)], ["Priority", task.priority], ["Note", `${Spot.tilde(task.file)}:${task.line}`]],
            actions: [["Enter", "Open in Neovim"], ["Ctrl+C", "Copy title"]]
        };
    }

    function activate(item) {
        Quickshell.execDetached([...host.userConfig.terminal, ...Spot.editor(item.task.file, item.task.line)]);
        return true;
    }

    function copy(item) {
        Spot.copy(item.title);
    }

    Source {
        id: source
        maxAge: 60000
        request: ["tasks"]
        // the text a task is found by, folded once as it loads
        parse: output => output.trim() ? JSON.parse(output).map(task => Object.assign(task, { text: Search.fold(`${task.title} ${root.statuses[task.status].label} ${task.workspace} task`) })) : []
    }
}
