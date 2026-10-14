import Quickshell
import Quickshell.Io
import QtQuick

// Clipboard history (cliphist) plus pinned entries kept by spotlight.py, with
// image thumbnails decoded once into the cache and a text / image / link
// filter. Enter pastes into the focused window, Shift+Enter pastes as plain
// text, Ctrl+P pins or unpins, Ctrl+X deletes.
Scope {
    id: root
    property var host
    readonly property var filters: ["all", "text", "image", "link"]
    property string filter: "all"
    property int thumbsReady: 0
    property string peekKey: ""
    property string peekText: ""
    readonly property string thumbDir: Spot.cacheDir + "/clip"

    function load() {
        history.load();
        pins.load();
    }

    function cycleFilter() {
        filter = filters[(filters.indexOf(filter) + 1) % filters.length];
    }

    function typeOf(text) {
        if (/^\[\[ binary data .*(png|jpe?g|webp|gif|bmp)/i.test(text))
            return "image";
        return /^https?:\/\/\S+$/.test(text.trim()) ? "link" : "text";
    }

    function items(tokens) {
        const shown = entry => (filter === "all" || entry.type === filter) && Spot.matches(entry.title + " " + (entry.hint ?? ""), tokens);
        const pinned = pins.items.map(pin => {
            const type = pin.image ? "image" : typeOf(pin.text);
            return { key: "pin:" + pin.name, kind: "pin", store: root, section: "Pinned", pin, type, title: pin.image ? "Pinned image" : pin.text.split("\n")[0], hint: "Pinned", icon: pin.image ? "image-x-generic" : "edit-paste", thumb: pin.image ? "file://" + pin.path : "" };
        });
        const recent = history.items.map(entry => {
            const image = entry.type === "image" ? entry.preview.match(/binary data (.+?) (\w+) (\d+x\d+)/) : null;
            return { key: "clip:" + entry.id, kind: "clip", store: root, section: "History", entry, type: entry.type, title: image ? `Image ${image[3]}` : entry.preview, hint: image ? `${image[2]} · ${image[1]}` : entry.type === "link" ? "Link" : "", icon: entry.type === "image" ? "image-x-generic" : entry.type === "link" ? "web-browser" : "edit-paste", thumb: image && thumbsReady ? `file://${thumbDir}/${entry.id}` : "" };
        });
        return [...pinned.filter(shown), ...recent.filter(shown).slice(0, 200)];
    }

    function describe(item) {
        const actions = [["Enter", "Paste"], ...(item.type === "image" ? [] : [["Shift+Enter", "Paste as plain text"]]), ["Ctrl+C", "Copy"], ["Ctrl+P", item.kind === "pin" ? "Unpin" : "Pin"], ["Ctrl+X", "Delete"]];
        if (item.type === "image")
            return { image: item.thumb, title: item.title, subtitle: item.hint, actions };
        const text = item.kind === "pin" ? item.pin.text : peekKey === item.key ? peekText : item.entry.preview;
        return { body: text, details: [item.type === "link" ? "Link" : "Text", item.kind === "pin" ? "Pinned" : ""], actions };
    }

    function peek(item) {
        if (item.kind !== "clip" || item.type === "image")
            return;
        peekKey = item.key;
        peekText = "";
        preview.exec(["sh", "-c", 'cliphist decode "$1" | head -c 4000', "sh", item.entry.id]);
    }

    // `followUp` runs after the content is on the clipboard
    function toClipboard(item, plain, followUp) {
        const target = plain && item.type !== "image" ? " --type text/plain" : "";
        const source = item.kind === "pin" ? `wl-copy${target} < "$1"` : `cliphist decode "$1" | wl-copy${target}`;
        Quickshell.execDetached(["sh", "-c", source + "\n" + followUp, "sh", item.kind === "pin" ? item.pin.path : item.entry.id]);
    }

    function activate(item, keys) {
        toClipboard(item, keys.shift, Spot.pasteKeys);
        return true;
    }

    function copy(item) {
        toClipboard(item, false, "");
    }

    function act(item, action) {
        if (action === "pin")
            job.run(item.kind === "pin" ? ["python3", Spot.helper, "pin-remove", item.pin.name] : ["python3", Spot.helper, "pin-add", item.entry.id], () => pins.reload());
        else if (action === "delete" && item.kind === "pin")
            job.run(["python3", Spot.helper, "pin-remove", item.pin.name], () => pins.reload());
        else if (action === "delete")
            job.run(["sh", "-c", 'printf "%s\\n" "$1" | cliphist delete', "sh", item.entry.line], () => history.reload());
        return false;
    }

    Source {
        id: history
        maxAge: 0
        command: ["cliphist", "list"]
        parse: output => output.split("\n").filter(line => line.includes("\t")).map(line => {
            const tab = line.indexOf("\t");
            const preview = line.slice(tab + 1);
            return { id: line.slice(0, tab), line, preview, type: root.typeOf(preview) };
        })
        onItemsChanged: thumbs.refresh()
    }

    Source {
        id: pins
        command: ["python3", Spot.helper, "pins"]
        parse: output => JSON.parse(output)
    }

    // decodes every image entry not cached yet and drops thumbs of deleted ones
    Process {
        id: thumbs
        function refresh() {
            exec(["sh", "-c", `dir=$1; shift; mkdir -p "$dir"
for file in "$dir"/*; do
    [ -e "$file" ] || continue
    case " $* " in *" \${file##*/} "*) ;; *) rm -f "$file" ;; esac
done
for id in "$@"; do [ -s "$dir/$id" ] || cliphist decode "$id" > "$dir/$id"; done`, "sh", root.thumbDir, ...history.items.filter(entry => entry.type === "image").map(entry => entry.id)]);
        }
        onExited: root.thumbsReady++
    }

    Process {
        id: preview
        stdout: StdioCollector {
            onStreamFinished: root.peekText = text
        }
    }

    Process {
        id: job
        property var afterwards: () => {}
        function run(command, after) {
            afterwards = after;
            exec(command);
        }
        stderr: StdioCollector {
            id: jobErrors
        }
        onExited: exitCode => {
            if (exitCode !== 0)
                root.host.notify(jobErrors.text.trim() || `Failed with code ${exitCode}`);
            afterwards();
        }
    }
}
