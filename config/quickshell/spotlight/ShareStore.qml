import Quickshell
import Quickshell.Io
import QtQuick

// The chooser of xdg-desktop-portal-wlr: when an app asks to share the screen,
// share-picker hands over the monitors and windows it may share, one per line
// ("Monitor: name description", "Window: title (identifier)"), and waits on a
// fifo for the chosen line, empty when declined (Esc, or Spotlight closing).
// Windows show with WindowStore's snapshots: grim -T takes them by the same
// identifier. Monitors get one from grim -o, taken before the view shows, so
// Spotlight is not in them.
Scope {
    id: root
    property var host
    property var windows
    property string fifo: ""
    property var offered: []
    // monitor name → the url of its snapshot
    property var shots: ({})

    function ask(fifo, lines) {
        root.fifo = fifo;
        offered = lines.split("\n").filter(line => line);
        replier.command = ["sh", "-c", 'exec cat > "$1"', "sh", fifo];
        replier.stdinEnabled = true;
        replier.running = true;
        const monitors = offered.map(line => line.match(/^Monitor: (\S+)/)).filter(found => found).map(found => found[1]);
        if (!monitors.length) {
            host.open("share");
            return;
        }
        grabber.pending = monitors;
        grabber.exec(["sh", "-c", 'dir=$1; shift; mkdir -p "$dir"; for name in "$@"; do grim -t jpeg -o "$name" "$dir/$name.jpg" & done; wait', "sh", grabber.dir, ...monitors]);
    }

    // the line goes to the waiting share-picker through cat's stdin
    function reply(line) {
        if (!fifo)
            return;
        replier.write(line + "\n");
        replier.stdinEnabled = false;
        fifo = "";
    }

    function parse(line) {
        const monitor = line.match(/^Monitor: (\S+) ?(.*)$/);
        if (monitor)
            return { key: "share:" + line, kind: "shareMonitor", store: root, line, title: monitor[1], hint: monitor[2], icon: "video-display", thumb: shots[monitor[1]] ?? "" };
        const match = line.match(/^Window: (.*) \((\S+)\)$/);
        const window = match ? windows.list.find(entry => entry.ident === match[2]) : null;
        return { key: "share:" + line, kind: "shareWindow", store: root, line, title: match ? match[1] : line, hint: window?.appId ?? "", icon: Spot.iconFor(window?.appId ?? ""), window, thumb: window ? windows.shot(window) : "" };
    }

    function sections(tokens) {
        const sources = offered.map(parse).filter(source => Spot.matches(source.title + " " + source.hint, tokens));
        return [["Monitors", sources.filter(source => source.kind === "shareMonitor")], ["Windows", sources.filter(source => source.kind === "shareWindow")]];
    }

    function describe(item) {
        if (item.kind === "shareMonitor")
            return { image: item.thumb, icon: item.icon, title: item.title, subtitle: item.hint, actions: [["Enter", "Share monitor"]] };
        const window = item.window;
        return { image: window ? windows.shot(window) : "", icon: item.icon, title: item.title, metadata: window ? [["App", window.appId], ["Workspace", window.workspace]] : [], actions: [["Enter", "Share window"]] };
    }

    function activate(item) {
        reply(item.line);
        return true;
    }

    Process {
        id: replier
    }

    Process {
        id: grabber
        property var pending: []
        readonly property string dir: Spot.cacheDir + "/outputs"

        // the stamp keeps Image from showing an earlier request's snapshot
        onExited: {
            const stamp = Date.now();
            const taken = {};
            for (let index = 0; index < pending.length; index++)
                taken[pending[index]] = `file://${dir}/${pending[index]}.jpg?${stamp}`;
            root.shots = taken;
            root.host.open("share");
        }
    }
}
