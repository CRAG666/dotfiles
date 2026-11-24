import Quickshell
import Quickshell.Io
import QtQuick

// Open windows from Scroll's tree, each with a snapshot: grim -T captures a
// toplevel through ext-image-copy-capture (off-screen ones too), all in
// parallel, once per opening. It saves the full size as JPEG and Image scales
// it while decoding: grim's own -s 0.35 took ~420 of the ~470 ms a window
// cost, a full JPEG ~50. `capturing` ("all", "marked" or "") says which
// windows the current view shows with their snapshot. Enter focuses a window.
// An opening shows the last snapshots at once and takes new ones, which all
// show together once every one is decoded (see decoding).
Scope {
    id: root
    property string capturing: ""
    readonly property var list: tree.items
    // foreign toplevel identifier → the snapshot url shown
    property var shots: ({})
    // the newest snapshot of each window, which Spotlight decodes ahead into
    // Qt's image cache at the rows' and the preview's sizes, and those not in yet
    property var latest: ({})
    readonly property var decoding: Object.keys(latest).map(ident => ({ ident, url: latest[ident] }))
    property var undecoded: ({})
    property int undecodedCount: 0
    // the windows asked for in this opening
    property var taken: ({})

    onCapturingChanged: captureShown()

    // a view that shows snapshots asks for them as it opens: a tree still fresh
    // changes nothing that would ask again
    function load() {
        tree.load();
        captureShown();
    }

    function reload() {
        tree.reload();
        captureShown();
    }

    // each opening takes the snapshots again; the last ones show meanwhile
    function forget() {
        taken = {};
    }

    // every snapshot taken is decoded and grim has none left to take: they show
    // together, from the cache, in one frame, and those of windows closed since
    // go. The selected window, asked for first, waits for the others
    function decoded(url) {
        if (url in undecoded) {
            delete undecoded[url];
            undecodedCount--;
        }
        if (undecodedCount || grabber.running || grabber.queue.length)
            return;
        const open = Object.create(null);
        for (let index = 0; index < list.length; index++)
            open[list[index].ident] = true;
        const kept = {};
        for (const ident in latest)
            if (ident in open)
                kept[ident] = latest[ident];
        latest = kept;
        shots = kept;
    }

    function shot(window) {
        return shots[window.ident] ?? "";
    }

    // tree.items, not `list`: the tree's onItemsChanged runs before `list` follows it
    function captureShown() {
        if (capturing === "all")
            capture(tree.items);
        else if (capturing === "marked")
            // the focused window too, which "Add mark" previews
            capture(tree.items.filter(window => window.marks.length || window.focused));
    }

    // once a window an opening; requests made in one go (the selected window's,
    // then the view's) make one grim run, and those made while grim runs wait
    function capture(windows) {
        const wanted = [];
        for (let index = 0; index < windows.length; index++) {
            const ident = windows[index].ident;
            if (ident && !(ident in taken)) {
                taken[ident] = true;
                grabber.sizes[ident] = windows[index].size;
                wanted.push(ident);
            }
        }
        grabber.queue = grabber.queue.concat(wanted);
        Qt.callLater(grabber.next);
    }

    // the windows are pushed onto `found` as the tree is walked, once each;
    // `size` is the window's in pixels of its output, which its snapshot has
    function windowsIn(node, workspace, scale, found = []) {
        const here = node.type === "workspace" ? node.name : workspace;
        const factor = node.type === "output" ? node.scale ?? 1 : scale;
        const children = (node.nodes ?? []).concat(node.floating_nodes ?? []);
        if (!children.length && node.pid > 0) {
            const rect = node.window_rect ?? node.rect;
            found.push({ id: node.id, ident: node.foreign_toplevel_identifier ?? "", title: node.name ?? "", appId: node.app_id ?? node.window_properties?.class ?? "", workspace: here, marks: node.marks ?? [], focused: node.focused, size: Math.round(rect.width * factor) + "x" + Math.round(rect.height * factor) });
        }
        for (let index = 0; index < children.length; index++)
            windowsIn(children[index], here, factor, found);
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
        parse: output => output.trim() ? root.windowsIn(JSON.parse(output), "", 1) : []
        onItemsChanged: root.captureShown()
    }

    Process {
        id: grabber
        property var queue: []
        property var pending: []
        // foreign toplevel identifier → the size in pixels of a window queued
        property var sizes: ({})
        readonly property string dir: Spot.cacheDir + "/windows"
        // a window's popups and subsurfaces that reach past it (Zen's) come
        // in its capture, transparent, which JPEG turns black: a snapshot
        // larger than its window is cut back, losslessly, to where the
        // window's content begins (found on a decode at 1/4 the size)
        readonly property string script: [
            'crop() {',
            '    size=$(magick identify -ping -format %wx%h "$1") && [ "$size" != "$2" ] || return 0',
            '    width=${2%x*} height=${2#*x} full=${size%x*} tall=${size#*x}',
            '    set -- "$1" $(magick -define jpeg:size=$((full / 4))x$((tall / 4)) "$1" -bordercolor black -border 1 -fuzz 4% -format "%@ %w" info: 2>/dev/null | tr "x+" "  ")',
            '    [ -n "$6" ] || return 0',
            '    x=$((($4 - 1) * full / ($6 - 2))) y=$((($5 - 1) * full / ($6 - 2)))',
            '    x=$((x < full - width ? x : full - width)) y=$((y < tall - height ? y : tall - height))',
            '    jpegtran -crop "${width}x${height}+$((x > 0 ? x : 0))+$((y > 0 ? y : 0))" -outfile "$1.part" "$1" && mv "$1.part" "$1"',
            '}',
            'dir=$1; shift; mkdir -p "$dir"',
            'for spec in "$@"; do',
            '    shot="$dir/${spec%%:*}.jpg"',
            '    { grim -t jpeg -T "${spec%%:*}" "$shot" && crop "$shot" "${spec#*:}"; } &',
            'done',
            'wait'
        ].join("\n")

        function next() {
            if (running || !queue.length)
                return;
            pending = queue;
            queue = [];
            exec(["sh", "-c", script, "sh", dir].concat(pending.map(ident => ident + ":" + sizes[ident])));
            sizes = {};
        }

        // the timestamp keeps Image from showing a snapshot of an earlier opening
        onExited: {
            const stamp = Date.now();
            const newest = Object.assign({}, root.latest);
            for (let index = 0; index < pending.length; index++) {
                const url = `file://${dir}/${pending[index]}.jpg?${stamp}`;
                newest[pending[index]] = url;
                root.undecoded[url] = true;
            }
            root.undecodedCount += pending.length;
            pending = [];
            root.latest = newest;
            next();
        }
    }
}
