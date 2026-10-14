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
        const wanted = windows.map(window => window.ident).filter(ident => ident && !(ident in shots) && !grabber.queue.includes(ident) && !grabber.pending.includes(ident));
        grabber.queue = [...grabber.queue, ...wanted];
        grabber.next();
    }

    function windowsIn(node, workspace) {
        const here = node.type === "workspace" ? node.name : workspace;
        const children = [...(node.nodes ?? []), ...(node.floating_nodes ?? [])];
        if (!children.length && node.pid > 0)
            return [{ id: node.id, ident: node.foreign_toplevel_identifier ?? "", title: node.name ?? "", appId: node.app_id ?? node.window_properties?.class ?? "", workspace: here, marks: node.marks ?? [], focused: node.focused }];
        return [].concat(...children.map(child => windowsIn(child, here)));
    }

    function items(tokens, limit) {
        return list
            .filter(window => Spot.matches(window.title + " " + window.appId, tokens))
            .slice(0, limit)
            .map(window => ({ key: "window:" + window.id, kind: "window", store: root, window, title: window.title, hint: window.appId, icon: Spot.iconFor(window.appId), thumb: capturing === "all" ? shot(window) : "" }));
    }

    function describe(item) {
        return { image: shot(item.window), icon: item.icon, title: item.title, subtitle: item.window.appId, details: ["Workspace " + item.window.workspace], actions: [["Enter", "Focus window"]] };
    }

    function peek(item) {
        capture([item.window]);
    }

    function activate(item, keys) {
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
