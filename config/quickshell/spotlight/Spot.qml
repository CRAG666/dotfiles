pragma Singleton
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import "js/search.js" as Search

// Paths and small actions shared by spotlight.qml and its stores.
Singleton {
    readonly property string home: Quickshell.env("HOME")
    readonly property string dataDir: (Quickshell.env("XDG_DATA_HOME") || home + "/.local/share") + "/spotlight"
    readonly property string stateDir: (Quickshell.env("XDG_STATE_HOME") || home + "/.local/state") + "/spotlight"
    readonly property string cacheDir: (Quickshell.env("XDG_CACHE_HOME") || home + "/.cache") + "/spotlight"
    // what you configure: spotlight.json and the script commands, apart from the code
    readonly property string configDir: (Quickshell.env("XDG_CONFIG_HOME") || home + "/.config") + "/spotlight"
    readonly property string configFile: configDir + "/spotlight.json"
    // the Python helper, a package: python3 runs its __main__.py
    readonly property string helper: home + "/.config/quickshell/spotlight/helper"
    // Spotlight's window sets it from the size of the screen it opens on
    property real scale: 1
    readonly property var terminals: ["kitty", "foot", "Alacritty", "org.wezfurlong.wezterm", "com.mitchellh.ghostty", "ghostty.dialog"]

    // bound from the start: ToplevelManager learns the windows only once first
    // read, and a first read when pasting found none
    readonly property Toplevel activeWindow: ToplevelManager.activeToplevel

    // the paste shortcut for the focused window (terminals take Ctrl+Shift+V),
    // read once Spotlight is hidden (whenHidden) and the window is active again
    function pasteKeys() {
        return terminals.includes(activeWindow?.appId) ? "wtype -M ctrl -M shift v -m shift -m ctrl" : "wtype -M ctrl v -m ctrl";
    }

    // `tokens` come from Search.tokens; `loose` false keeps to exact matches
    function matches(text, tokens, loose = true) {
        return Search.score(Search.fold(text), tokens, loose) > 0;
    }

    // for text a store folded once with Search.fold when it loaded, instead of on
    // every keystroke
    function matchesFolded(haystack, tokens, loose = true) {
        return Search.score(haystack, tokens, loose) > 0;
    }

    // whole pixels keep text and icons on the pixel grid, so they stay sharp
    function px(value) {
        return Math.round(value * scale);
    }

    function copy(text) {
        Quickshell.execDetached(["wl-copy", "--", text]);
    }

    function open(target) {
        Quickshell.execDetached(["xdg-open", target]);
    }

    // `path` in $EDITOR, at `line` when given, for a terminal prefix to run
    function editor(path, line) {
        return ["sh", "-c", '"${EDITOR:-nvim}" ${2:+"+$2"} "$1"', "sh", path, line === undefined ? "" : String(line)];
    }

    function tilde(path) {
        return path === home || path.startsWith(home + "/") ? "~" + path.slice(home.length) : path;
    }

    function basename(path) {
        return path.slice(path.lastIndexOf("/") + 1);
    }

    // "" for a bare name
    function dirname(path) {
        return path.slice(0, Math.max(0, path.lastIndexOf("/")));
    }

    function dateTime(milliseconds) {
        return new Date(milliseconds).toLocaleString(Qt.locale(), Locale.ShortFormat);
    }

    // type into the window that had focus once Spotlight is gone, then walk the
    // cursor back to {cursor}; the clipboard is left untouched
    function type(text) {
        const marker = "{cursor}";
        const at = text.indexOf(marker);
        const command = ["sh", "-c", 'wtype -- "$1"; shift; [ $# -eq 0 ] || wtype "$@"', "sh", text.split(marker).join("")];
        const lefts = at < 0 ? 0 : [...text.slice(at + marker.length).split(marker).join("")].length;
        for (let step = 0; step < lefts; step++)
            command.push("-k", "Left");
        whenHidden(command);
    }

    // runs `command` once Spotlight is off the screen and the keyboard is back
    // with the window under it, for what types, pastes or captures the screen:
    // two frames after the frame that hid it (Spotlight's window calls hidden()),
    // where a fixed pause waited 300 ms; after those 300 ms anyway if no such
    // frame comes. `command` may be a function that makes it then
    function whenHidden(command) {
        afterHiding.push(command);
        hidingFallback.restart();
    }

    function hidden() {
        if (afterHiding.length)
            hidingSettled.restart();
    }

    function runHidden() {
        const commands = afterHiding;
        afterHiding = [];
        hidingSettled.stop();
        hidingFallback.stop();
        for (let index = 0; index < commands.length; index++)
            Quickshell.execDetached(typeof commands[index] === "function" ? commands[index]() : commands[index]);
    }

    property var afterHiding: []

    Timer {
        id: hidingSettled
        interval: 34
        onTriggered: runHidden()
    }

    Timer {
        id: hidingFallback
        interval: 300
        onTriggered: runHidden()
    }

    // keeps the terminal open after `command` ends
    function hold(command) {
        return ["sh", "-c", '"$@"; printf "\\n[exit %s] Press Enter to close" "$?"; read -r _', "sh", ...command];
    }

    // runs the helper, its failure shown as a notification: a process of its own
    // for what waits on an editor, which a restart of Spotlight must not end
    function helperCommand(args) {
        return ["sh", "-c", 'out=$(python3 "$@" 2>&1) || notify-send -u critical Spotlight "$out"', "sh", helper, ...args];
    }

    function helperDetached(args) {
        Quickshell.execDetached(helperCommand(args));
    }

    // asks the resident helper: `done(output, error)` gets what
    // `python3 helper args…` prints and the reason it failed ("" when it did not).
    // A call is a JSON line on its stdin answered by id, so it costs the work and
    // not Python's start and imports (~100 ms). Calls made while it starts wait
    // for it; a death fails the calls it held, and it starts again
    function call(args, done) {
        const id = ++helperCalls;
        answering[id] = done;
        const line = JSON.stringify({ id, args }) + "\n";
        if (resident.running)
            resident.write(line);
        else
            waiting.push(line);
    }

    // a writer in the resident helper, its failure shown as a notification
    function send(args) {
        call(args, (output, error) => {
            if (error)
                Quickshell.execDetached(["notify-send", "-u", "critical", "Spotlight", error]);
        });
    }

    property int helperCalls: 0
    property var answering: ({})
    property var waiting: []

    Process {
        id: resident
        running: true
        stdinEnabled: true
        command: ["python3", helper, "serve"]
        stdout: SplitParser {
            onRead: line => {
                const reply = JSON.parse(line);
                const done = answering[reply.id];
                delete answering[reply.id];
                done(reply.output ?? "", reply.error ?? "");
            }
        }
        onRunningChanged: {
            if (!running)
                return;
            for (let index = 0; index < waiting.length; index++)
                write(waiting[index]);
            waiting = [];
        }
        onExited: {
            const lost = answering;
            answering = {};
            for (const id in lost)
                lost[id]("", "Spotlight's helper stopped");
            restartHelper.start();
        }
    }

    Timer {
        id: restartHelper
        interval: 1000
        onTriggered: resident.running = true
    }

    // DesktopEntries' apps, taken once its list stops changing: it adds them one
    // at a time as it loads, and each list built from them (entriesByName,
    // Apps.indexed) would be rebuilt once per app, O(n²)
    property var applications: []
    function takeApplications() {
        applications = DesktopEntries.applications.values;
    }
    Component.onCompleted: takeApplications()
    Connections {
        target: DesktopEntries.applications
        function onValuesChanged() {
            Qt.callLater(takeApplications);
        }
    }

    // app id or window class (lowercase) → the app with it, so a lookup scans no
    // list; the least id where two share one, as DesktopEntries' order changes
    // at every start
    readonly property var entriesByName: {
        const index = Object.create(null);
        const apps = applications;
        const claim = (name, app) => {
            if (!(name in index) || app.id < index[name].id)
                index[name] = app;
        };
        for (let at = 0; at < apps.length; at++) {
            claim(apps[at].id.toLowerCase(), apps[at]);
            claim(apps[at].startupClass.toLowerCase(), apps[at]);
        }
        return index;
    }

    // the desktop entry of an app id or window class; reads the (asynchronously
    // loaded) app list, so callers refresh once it arrives
    function desktopEntry(name) {
        return entriesByName[name.toLowerCase()] ?? DesktopEntries.heuristicLookup(name);
    }

    // distinct values in first-seen order: V4's Set looks values up one by one
    function unique(values) {
        const seen = Object.create(null);
        return values.filter(value => !(value in seen) && (seen[value] = true));
    }

    // values.filter(keep).slice(0, limit), stopping at the limit-th kept value
    function take(values, keep, limit) {
        const kept = [];
        for (let index = 0; index < values.length && kept.length < limit; index++)
            if (keep(values[index]))
                kept.push(values[index]);
        return kept;
    }

    // entries.sort(order).slice(0, limit) for a total `order`, without sorting
    // them all: a binary heap built in place in linear time (Floyd), from which
    // the best `limit` are popped, log n each. A list ordered lazily asks for
    // the rows in sight and more as it scrolls, so a keystroke costs O(n + k log n)
    function firstSorted(entries, order, limit) {
        const heap = entries.slice();
        const sift = (from, size) => {
            const entry = heap[from];
            let at = from;
            for (;;) {
                let child = 2 * at + 1;
                if (child >= size)
                    break;
                if (child + 1 < size && order(heap[child + 1], heap[child]) < 0)
                    child++;
                if (order(heap[child], entry) >= 0)
                    break;
                heap[at] = heap[child];
                at = child;
            }
            heap[at] = entry;
        };
        for (let at = (heap.length >> 1) - 1; at >= 0; at--)
            sift(at, heap.length);
        const best = [];
        for (let size = heap.length; size > 0 && best.length < limit; size--) {
            best.push(heap[0]);
            heap[0] = heap[size - 1];
            sift(0, size - 1);
        }
        return best;
    }

    // ScriptModel's diff looks each row it removes, inserts or moves up in the
    // rest of the other list: 15 ms for 200 rows replaced, 230 ms for 800. Rows
    // kept in place, a cut tail and an appended one cost it a pass, so past
    // `diffBudget` lookups (~1 ms) the rows after the first that differs are cut
    // and appended again: the view remakes only those in sight, from its pool
    readonly property int diffBudget: 8000

    // model.values (a ScriptModel's) from `previous` to `next`, rows known by
    // keyOf, in time linear in the rows
    function relist(model, previous, next, keyOf) {
        const at = Object.create(null);
        for (let index = 0; index < previous.length; index++)
            at[keyOf(previous[index])] = index;
        let kept = 0;
        let moved = 0;
        let last = -1;
        for (let index = 0; index < next.length; index++) {
            const old = at[keyOf(next[index])];
            if (old === undefined)
                continue;
            kept++;
            if (old < last)
                moved++;
            last = old;
        }
        const lookups = (previous.length - kept) * next.length + (next.length - kept) * previous.length + moved * Math.max(previous.length, next.length);
        if (lookups > diffBudget) {
            let same = 0;
            while (same < previous.length && same < next.length && keyOf(previous[same]) === keyOf(next[same]))
                same++;
            model.values = next.slice(0, same);
        }
        model.values = next;
        // a row it moves keeps its old object, so a changed hint or thumbnail
        // would stay stale: the same rows again, all in place, take the new ones
        model.values = next;
    }

    function iconFor(name) {
        return desktopEntry(name)?.icon ?? "application-x-executable";
    }

    // "now", "5 min", "3 h" or "2 d" since `time` (ms)
    function ago(time) {
        const minutes = Math.round((Date.now() - time) / 60000);
        if (minutes < 1)
            return "now";
        if (minutes < 60)
            return minutes + " min";
        return minutes < 1440 ? Math.round(minutes / 60) + " h" : Math.round(minutes / 1440) + " d";
    }

    function formatSize(bytes) {
        const units = ["bytes", "KB", "MB", "GB", "TB"];
        let size = bytes;
        let unit = 0;
        while (size >= 1000 && unit < units.length - 1) {
            size /= 1000;
            unit++;
        }
        return (unit ? size.toFixed(1) : size) + " " + units[unit];
    }
}
