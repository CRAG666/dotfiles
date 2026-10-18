import Quickshell
import Quickshell.Io
import QtQuick

// Open windows from Scroll's tree, each with a snapshot: grim -T captures a
// toplevel through ext-image-copy-capture (off-screen ones too), all in
// parallel, once per opening. `capturing` ("all", "marked" or "") says which
// windows the current view shows with their snapshot. Enter focuses a window.
Scope {
    id: root
    property string capturing: ""
    readonly property var list: tree.items
    property var shots: ({})   // foreign toplevel identifier → snapshot url

    onCapturingChanged: captureShown()

    function load() {
        tree.load();
    }

    function reload() {
        tree.reload();
    }

    // snapshots are only good for one opening
    function forget() {
        shots = {};
    }

    function shot(window) {
        return shots[window.ident] ?? "";
    }

    function captureShown() {
        if (capturing === "all")
            capture(list);
        else if (capturing === "marked")
            capture(list.filter(window => window.marks.length));
    }

    // requests made while grim runs wait their turn
    function capture(windows) {
        const waiting = Object.create(null);
        for (const ident of [...grabber.queue, ...grabber.pending])
            waiting[ident] = true;
        const wanted = windows.map(window => window.ident).filter(ident => ident && !(ident in shots) && !(ident in waiting));
        grabber.queue = [...grabber.queue, ...wanted];
        grabber.next();
    }

    // the windows are pushed onto `found` as the tree is walked, once each
    function windowsIn(node, workspace, found = []) {
        const here = node.type === "workspace" ? node.name : workspace;
        const children = [...(node.nodes ?? []), ...(node.floating_nodes ?? [])];
        if (!children.length && node.pid > 0)
            found.push({ id: node.id, ident: node.foreign_toplevel_identifier ?? "", title: node.name ?? "", appId: node.app_id ?? node.window_properties?.class ?? "", workspace: here, marks: node.marks ?? [], focused: node.focused });
        for (const child of children)
            windowsIn(child, here, found);
        return found;
    }

    function items(tokens, limit) {
        return Spot.take(list, window => Spot.matches(window.title + " " + window.appId, tokens), limit)
            .map(window => ({ key: "window:" + window.id, kind: "window", store: root, window, title: window.title, hint: window.appId, icon: Spot.iconFor(window.appId), thumb: capturing === "all" ? shot(window) : "" }));
    }

    // "Quit <app>" closes every window of a running app, "Quit All Apps" every
    // window (asking twice): scroll's kill asks each politely, as closing does
    function quitItems(tokens) {
        const counts = Object.create(null);
        for (const window of list)
            if (window.appId)
                counts[window.appId] = (counts[window.appId] ?? 0) + 1;
        const apps = Object.keys(counts).map(id => {
            const count = counts[id];
            return { key: "quit:" + id, kind: "quit", store: root, appId: id, title: "Quit " + (Spot.desktopEntry(id)?.name ?? id), hint: count === 1 ? "1 window" : `${count} windows`, icon: Spot.iconFor(id) };
        });
        const all = { key: "quit:all", kind: "quit", store: root, title: "Quit All Apps", hint: `${list.length} windows`, icon: "application-exit", confirm: true };
        return [...apps, all].filter(item => Spot.matches(item.title + " close", tokens));
    }

    function describe(item) {
        if (item.kind === "quit")
            return { icon: item.icon, title: item.title, subtitle: item.hint, actions: [["Enter", "Quit"]] };
        return { image: shot(item.window), icon: item.icon, title: item.title, metadata: [["App", item.window.appId], ["Workspace", item.window.workspace]], actions: [["Enter", "Focus window"]] };
    }

    function peek(item) {
        if (item.kind === "window")
            capture([item.window]);
    }

    function activate(item, keys) {
        // the windows are looked up when it runs, so ones opened since the list loaded close too
        if (item.kind === "quit") {
            Quickshell.execDetached(["sh", "-c", `scrollmsg -t get_tree | jq -r --arg app "$1" '.. | objects | select(.pid? > 0 and ((.nodes // []) | length) == 0 and ($app == "" or (.app_id // .window_properties.class) == $app)) | .id' | while read -r id; do scrollmsg "[con_id=$id] kill" > /dev/null; done`, "sh", item.appId ?? ""]);
            return true;
        }
        Quickshell.execDetached(["scrollmsg", `[con_id=${item.window.id}] focus`]);
        return true;
    }

    Source {
        id: tree
        maxAge: 1500
        command: ["scrollmsg", "-t", "get_tree"]
        parse: output => output.trim() ? root.windowsIn(JSON.parse(output), "") : []
        onItemsChanged: root.captureShown()
    }

    Process {
        id: grabber
        property var queue: []
        property var pending: []
        readonly property string dir: Spot.cacheDir + "/windows"

        function next() {
            if (running || !queue.length)
                return;
            pending = queue;
            queue = [];
            exec(["sh", "-c", 'dir=$1; shift; mkdir -p "$dir"; for id in "$@"; do grim -T "$id" -s 0.35 "$dir/$id.png" & done; wait', "sh", dir, ...pending]);
        }

        // the timestamp keeps Image from showing a snapshot of an earlier opening
        onExited: {
            const taken = Object.assign({}, root.shots);
            for (const ident of pending)
                taken[ident] = `file://${dir}/${ident}.png?${Date.now()}`;
            pending = [];
            root.shots = taken;
            next();
        }
    }
}
