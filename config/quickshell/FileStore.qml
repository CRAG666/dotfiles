import Quickshell
import Quickshell.Io
import QtQuick

// Files and folders under ~. With nothing typed: zoxide's frequent folders and
// the home folders; typing: frequent matches first, then fd over ~ (other file
// systems, like rclone mounts, are skipped). The preview lists a folder or
// shows the head of a text file.
Scope {
    id: root
    property string query: ""   // fd runs on it, debounced; "" clears the hits
    property var found: []
    readonly property var frequentPaths: frequent.items
    property string peekKey: ""
    property string peekText: ""
    property string peekMeta: ""
    readonly property var imageTypes: ["png", "jpg", "jpeg", "gif", "webp", "bmp", "svg", "avif"]
    readonly property var textTypes: ["txt", "md", "qml", "js", "ts", "py", "sh", "rs", "go", "c", "h", "cpp", "json", "toml", "yaml", "yml", "ini", "conf", "lua", "nix", "tex", "csv", "log", "rasi", "css", "html", "xml"]

    onQueryChanged: debounce.restart()

    function load() {
        frequent.load();
        homeDirs.load();
    }

    function sections(tokens, everything) {
        if (!tokens.length)
            return everything ? [] : [["Frequent", frequentItems([]).slice(0, 12)], ["Home", homeDirs.items.map(path => folderItem(path, ""))]];
        const frequentHits = frequentItems(tokens).slice(0, everything ? 3 : 6);
        const shown = new Set(frequentHits.map(item => item.path));
        return [["Frequent", frequentHits], ["Files", found.filter(file => !shown.has(file.path) && Spot.matches(file.path, tokens)).slice(0, everything ? 6 : 60)]];
    }

    // zoxide's most visited directories, best first
    function frequentItems(tokens) {
        return frequent.items
            .filter(path => Spot.matches(path, tokens))
            .map(path => folderItem(path, path.slice(0, path.lastIndexOf("/")).replace(Spot.home, "~")));
    }

    function folderItem(path, hint) {
        return { key: "file:" + path, kind: "file", store: root, path, isDir: true, title: path.slice(path.lastIndexOf("/") + 1), hint, icon: "folder" };
    }

    function extension(name) {
        const dot = name.lastIndexOf(".");
        return dot > 0 ? name.slice(dot + 1).toLowerCase() : "";
    }

    function fileIcon(name, isDir) {
        if (isDir)
            return "folder";
        const type = extension(name);
        if (imageTypes.includes(type))
            return "image-x-generic";
        if (type === "pdf")
            return "application-pdf";
        if (["mp4", "mkv", "webm", "mov", "avi"].includes(type))
            return "video-x-generic";
        if (["mp3", "flac", "ogg", "wav", "m4a", "opus"].includes(type))
            return "audio-x-generic";
        if (["zip", "tar", "gz", "xz", "zst", "7z", "rar"].includes(type))
            return "package-x-generic";
        return "text-x-generic";
    }

    function rank(output, query) {
        const tokens = query.toLowerCase().split(/\s+/).filter(token => token);
        const first = tokens[0] ?? "";
        return output.split("\n")
            .filter(line => line && Spot.matches(line, tokens))
            .map(line => {
                const isDir = line.endsWith("/");
                const path = isDir ? line.slice(0, -1) : line;
                const name = path.slice(path.lastIndexOf("/") + 1);
                const lower = name.toLowerCase();
                const rank = lower.startsWith(first) ? 0 : lower.includes(first) ? 1 : 2;
                return { key: "file:" + path, kind: "file", store: root, path, isDir, title: name, icon: fileIcon(name, isDir), rank };
            })
            .sort((a, b) => a.rank - b.rank || a.path.length - b.path.length);
    }

    function describe(item) {
        const peeked = peekKey === item.key;
        return { image: imageTypes.includes(extension(item.title)) ? "file://" + item.path : "", icon: item.icon, title: item.title, subtitle: item.path.replace(Spot.home, "~"), details: [peeked ? peekMeta : ""], body: peeked ? peekText : "", mono: true, actions: [["Enter", "Open"], ["Ctrl+Enter", "Show in folder"], ["Ctrl+C", "Copy path"]] };
    }

    function peek(item) {
        peekKey = item.key;
        peekText = "";
        peekMeta = "";
        peeker.isDir = item.isDir;
        peeker.exec(["sh", "-c", 'stat -c "%s|%Y" -- "$1"; if [ -d "$1" ]; then ls -1Ap -- "$1" | head -n 40; elif [ "$2" = text ]; then head -c 3000 -- "$1"; fi', "sh", item.path, textTypes.includes(extension(item.title)) ? "text" : ""]);
    }

    function activate(item, keys) {
        Quickshell.execDetached(["xdg-open", keys.ctrl ? item.path.slice(0, item.path.lastIndexOf("/")) : item.path]);
        return true;
    }

    function copy(item) {
        Spot.copy(item.path);
    }

    Source {
        id: frequent
        maxAge: 60000
        command: ["zoxide", "query", "--list"]
        parse: output => output.split("\n").filter(path => path && path !== Spot.home)
    }

    Source {
        id: homeDirs
        maxAge: 300000
        command: ["find", Spot.home, "-mindepth", "1", "-maxdepth", "1", "-type", "d", "-not", "-name", ".*"]
        parse: output => output.split("\n").filter(path => path).sort((a, b) => a.localeCompare(b))
    }

    Timer {
        id: debounce
        interval: 150
        onTriggered: {
            if (root.query.length < 2) {
                root.found = [];
                return;
            }
            fd.forQuery = root.query;
            fd.exec(["fd", "--one-file-system", "--fixed-strings", "--ignore-case", "--absolute-path", "--max-results", "200", "--", root.query.split(/\s+/)[0], Spot.home]);
        }
    }

    Process {
        id: fd
        property string forQuery: ""
        stdout: StdioCollector {
            onStreamFinished: {
                if (fd.forQuery === root.query)
                    root.found = root.rank(text, root.query);
            }
        }
    }

    Process {
        id: peeker
        property bool isDir: false
        stdout: StdioCollector {
            onStreamFinished: {
                const newline = text.indexOf("\n");
                const [bytes, modified] = (newline < 0 ? text : text.slice(0, newline)).split("|");
                const content = newline < 0 ? "" : text.slice(newline + 1);
                const entries = content.split("\n").filter(line => line).length;
                const size = peeker.isDir ? `${entries}${entries === 40 ? "+" : ""} ${entries === 1 ? "item" : "items"}` : Spot.formatSize(Number(bytes));
                root.peekMeta = size + "  ·  Modified " + new Date(Number(modified) * 1000).toLocaleString(Qt.locale(), Locale.ShortFormat);
                root.peekText = content;
            }
        }
    }
}
