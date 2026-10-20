import Quickshell
import QtQuick
import "js/search.js" as Search

// Files and folders under ~. With nothing typed: recent files (the helper's
// recent-files: opened from Spotlight or GTK apps, or saved lately), the home
// folders, then zoxide's frequent folders; typing: recent and frequent matches
// first, then fd over ~ (other file systems, like rclone mounts, are skipped;
// accents are ignored). Documents are also searched
// by their text, through an SQLite index of ~/Documents, ~/Desktop and
// ~/Downloads that the helper brings up to date at most once an hour. The
// preview lists a folder, shows the head of a text file, or a thumbnail of an
// image, a PDF's first page or a video. Spotlight's filters narrow the
// search: "kind:pdf" (image, video, audio, archive, folder or any extension),
// "modified:today|week|month|year" or "modified:3d", "in:~/Documents". The
// newest file in ~/Downloads leads the view. Ctrl+K moves a file. A typed path
// ("~/Doc", "/etc/") browses its folder: → enters a folder, ← goes up. Ctrl+B
// gathers files in a buffer, whose actions lead the view while it holds any.
Scope {
    id: root
    property var host
    property string query: ""   // fd runs on it, debounced; "" clears the hits
    property string contentQuery: ""   // the index is searched for it, debounced
    property var found: []
    property var contentHits: []
    property double indexedAt: 0
    readonly property var frequentPaths: frequent.items.map(entry => entry.path)
    property string peekKey: ""
    property string peekText: ""
    property string peekThumb: ""
    property var peekFacts: []
    property var buffer: []   // paths gathered with Ctrl+B, acted on together
    readonly property var buffered: {
        const index = Object.create(null);
        for (const path of buffer)
            index[path] = true;
        return index;
    }
    property var listing: ({ dir: "", entries: [] })   // the folder a typed path browses
    readonly property string browseDir: isPath(query) ? expand(query.slice(0, query.lastIndexOf("/") + 1)) : ""
    readonly property var imageTypes: ["png", "jpg", "jpeg", "gif", "webp", "bmp", "svg", "avif"]
    readonly property var videoTypes: ["mp4", "mkv", "webm", "mov", "avi"]
    readonly property var audioTypes: ["mp3", "flac", "ogg", "wav", "m4a", "opus"]
    readonly property var archiveTypes: ["zip", "tar", "gz", "xz", "zst", "7z", "rar"]
    readonly property var kinds: ({ image: imageTypes, video: videoTypes, audio: audioTypes, archive: archiveTypes })
    readonly property var textTypes: ["txt", "md", "qml", "js", "ts", "py", "sh", "rs", "go", "c", "h", "cpp", "json", "toml", "yaml", "yml", "ini", "conf", "lua", "nix", "tex", "csv", "log", "rasi", "css", "html", "xml"]


    function load() {
        frequent.load();
        homeDirs.load();
        recent.load();
        latestDownload.load();
        if (Date.now() - indexedAt > 3600000) {
            indexedAt = Date.now();
            Quickshell.execDetached(["flock", "-n", Spot.cacheDir + "/index.lock", "nice", "-n", "19", "sh", "-c", 'out=$(python3 "$@" 2>&1) || notify-send -u critical "Spotlight index" "$out"', "sh", Spot.helper, "index-contents"]);
        }
    }

    function isPath(text) {
        return /^(~\/|\/)/.test(text);
    }

    function expand(path) {
        return path.replace(/^~(?=\/)/, Spot.home);
    }

    // the folder of a typed path, filtered by what follows its last "/" (hidden
    // entries only for a filter starting with "."), folders first; the listing
    // is sorted once as it arrives, so each keystroke only filters it
    function browseSections(raw) {
        const filter = raw.slice(raw.lastIndexOf("/") + 1);
        const tokens = Search.tokens(filter);
        const dir = expand(raw.slice(0, raw.lastIndexOf("/") + 1));
        const entries = listing.dir === dir ? listing.entries : [];
        const shown = entries
            .filter(entry => (filter.startsWith(".") || !entry.name.startsWith(".")) && Spot.matches(entry.name, tokens))
            .map(entry => fileItem(entry.path, entry.isDir, ""));
        return [["Buffer", bufferItems(tokens)], [Spot.tilde(dir), shown]];
    }

    // ← at the end of a browsed path: its parent folder
    function parentPath(text) {
        const dir = expand(text).replace(/\/$/, "");
        return Spot.tilde(dir.slice(0, dir.lastIndexOf("/") + 1) || "/");
    }

    function bufferItems(tokens) {
        if (!buffer.length)
            return [];
        const count = buffer.length === 1 ? "1 file" : `${buffer.length} files`;
        return [["move", `Move ${count} to…`, "folder-move"], ["copy", `Copy ${count} to…`, "edit-copy"], ["open", `Open ${count}`, "document-open"], ["trash", `Move ${count} to Trash`, "user-trash"], ["paths", buffer.length === 1 ? "Copy Path" : "Copy Paths", "edit-paste"], ["clear", "Clear Buffer", "edit-clear"]]
            .filter(([, title]) => Spot.matches(title + " buffer", tokens))
            .map(([action, title, icon]) => ({ key: "buffer:" + action, kind: "buffer", store: root, action, title, hint: count, icon, confirm: action === "trash" }));
    }

    function sections(tokens, everything) {
        return everything ? searchSections(tokens, true) : [["Buffer", bufferItems(tokens)], ...searchSections(tokens, false)];
    }

    function searchSections(tokens, everything) {
        const words = tokens.filter(token => !/^(kind|modified|in):/.test(token));
        if (words.length < tokens.length)
            return [["Files", found.slice(0, everything ? 6 : 60)]];
        const download = Spot.matches("latest download downloads", tokens) ? downloadItems() : [];
        if (!tokens.length)
            return everything ? [] : [["Latest Download", downloadItems()], ["Recent", recentItems([], 9).filter(item => item.path !== latestDownload.items?.path).slice(0, 8)], ["Home", homeDirs.items.map(path => fileItem(path, true, ""))], ["Frequent", frequentItems([], 12)]];
        const shown = Object.create(null);
        const unseen = items => items.filter(item => !(item.path in shown) && (shown[item.path] = true));
        const recentHits = unseen(recentItems(tokens, everything ? 3 : 6));
        const frequentHits = unseen(frequentItems(tokens, everything ? 3 : 6));
        const fileHits = Spot.take(Search.matching(found, "found", file => file.folded, tokens, false), file => !(file.path in shown) && (shown[file.path] = true), everything ? 6 : 60);
        return [["Latest Download", download], ["Recent", recentHits], ["Frequent", frequentHits], ["Files", fileHits]];
    }

    function downloadItems() {
        const latest = latestDownload.items;
        return latest?.path ? [Object.assign(fileItem(latest.path, false, Spot.ago(latest.modified)), { key: "latest-download" })] : [];
    }

    // the words to match, and fd's arguments and folder for the filters among them
    function search(query) {
        const words = [];
        const args = [];
        let folder = Spot.home;
        for (const word of query.split(/\s+/).filter(word => word)) {
            const filter = word.match(/^(kind|modified|in):(\S+)$/i);
            if (!filter) {
                words.push(word);
                continue;
            }
            const value = filter[2].toLowerCase();
            switch (filter[1].toLowerCase()) {
            case "kind":
                if (value === "folder")
                    args.push("--type", "d");
                else
                    for (const type of kinds[value] ?? [value])
                        args.push("--extension", type);
                break;
            case "modified":
                args.push("--changed-within", value === "today" ? Qt.formatDate(new Date(), "yyyy-MM-dd") + " 00:00:00" : ({ week: "7d", month: "30d", year: "365d" })[value] ?? value);
                break;
            default:
                folder = filter[2].replace(/^~/, Spot.home);
            }
        }
        // a folder's time changes with whatever changes inside it, so dates look at files
        if (args.includes("--changed-within") && !args.includes("--type"))
            args.push("--type", "f");
        return { text: words.join(" "), args, folder, filtered: args.length > 0 || folder !== Spot.home };
    }

    function contentItems() {
        return contentHits.map(hit => Object.assign(fileItem(hit.path, false, hit.page ? "p. " + hit.page : ""), { key: "content:" + hit.path, page: hit.page, snippet: hit.snippet }));
    }

    function recentItems(tokens, limit) {
        return Search.matching(recent.items, "recent", entry => entry.folded, tokens, false).slice(0, limit)
            .map(entry => fileItem(entry.path, entry.isDir, Spot.tilde(Spot.dirname(entry.path))));
    }

    // zoxide's most visited directories, best first
    function frequentItems(tokens, limit) {
        return Search.matching(frequent.items, "frequent", entry => entry.folded, tokens, false).slice(0, limit)
            .map(({ path }) => fileItem(path, true, Spot.tilde(Spot.dirname(path))));
    }

    function fileItem(path, isDir, hint) {
        const name = Spot.basename(path);
        return { key: "file:" + path, kind: "file", store: root, path, isDir, title: name, hint: path in buffered ? "● Buffer" : hint, icon: fileIcon(name, isDir) };
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
        if (videoTypes.includes(type))
            return "video-x-generic";
        if (audioTypes.includes(type))
            return "audio-x-generic";
        if (archiveTypes.includes(type))
            return "package-x-generic";
        return "text-x-generic";
    }

    // fd has no accent folding, so every vowel, n and c also match their accented
    // forms, whether precomposed or followed by combining marks (as macOS and
    // Google Drive write names): "cancion" finds "Canción"
    function accentPattern(token) {
        const variants = { a: "aáàâäã", e: "eéèêë", i: "iíìîï", o: "oóòôöõ", u: "uúùûü", n: "nñ", c: "cç" };
        return [...token].map(letter => (variants[letter] ? `[${variants[letter]}]` : letter.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")) + "\\p{M}*").join("");
    }

    function rank(output, query) {
        const tokens = Search.tokens(query);
        const first = tokens[0] ?? "";
        return output.split("\n")
            .filter(line => line)
            .map(line => {
                const isDir = line.endsWith("/");
                const path = isDir ? line.slice(0, -1) : line;
                const name = Search.fold(Spot.basename(path));
                const rank = name.startsWith(first) ? 0 : name.includes(first) ? 1 : 2;
                return Object.assign(fileItem(path, isDir, ""), { folded: Search.fold(path), rank });
            })
            .filter(file => Spot.matchesFolded(file.folded, tokens, false))
            .sort((a, b) => a.rank - b.rank || a.path.length - b.path.length);
    }

    function describe(item) {
        if (item.kind === "buffer")
            return { icon: item.icon, title: item.title, body: buffer.map(path => Spot.tilde(path)).join("\n"), mono: true, metadata: [["Files", buffer.length]], actions: [["Enter", item.title]] };
        const peeked = peekKey === item.key;
        const type = extension(item.title);
        const kind = item.isDir ? "Folder" : type ? type.toUpperCase() + " file" : "File";
        const image = imageTypes.includes(type) ? "file://" + item.path : peeked && peekThumb ? "file://" + peekThumb : "";
        const body = item.snippet ? item.snippet : peeked ? peekText : "";
        return { image, icon: item.icon, metadata: [["Name", item.title], ["Where", Spot.tilde(Spot.dirname(item.path))], ["Kind", kind], ["Page", item.page || ""], ...(peeked ? peekFacts : [])], body, mono: !item.snippet, actions: [["Enter", "Open"], ["Ctrl+Enter", "Show in folder"], ["Ctrl+C", "Copy path"], ["Ctrl+B", buffer.includes(item.path) ? "Remove from buffer" : "Add to buffer"], ["", "Move to…", "move"]] };
    }

    // the size and modification time, the thumbnail (made once into the cache),
    // a PDF's page count or a video's duration, and a folder's first entries or
    // a text's first bytes, from the resident helper (helper/peek.py)
    function peek(item) {
        const type = extension(item.title);
        peekKey = item.key;
        peekText = "";
        peekThumb = "";
        peekFacts = [];
        const kind = type === "pdf" ? "pdf" : videoTypes.includes(type) ? "video" : textTypes.includes(type) ? "text" : "";
        Spot.call(["peek", item.path, kind, Spot.cacheDir + "/thumbs"], (output, error) => {
            // a later selection's, or a file gone since it was listed
            if (error || peekKey !== item.key)
                return;
            const peeked = JSON.parse(output);
            const entries = peeked.content.split("\n").filter(line => line).length;
            const size = item.isDir ? `${entries}${entries === 40 ? "+" : ""} ${entries === 1 ? "item" : "items"}` : Spot.formatSize(peeked.bytes);
            const [extraLabel, extraValue] = peeked.extra;
            peekFacts = [[item.isDir ? "Contents" : "Size", size], ["Modified", Spot.dateTime(peeked.modified * 1000)], [extraLabel, extraLabel === "Duration" && extraValue ? duration(Number(extraValue)) : extraValue]];
            peekThumb = peeked.thumb;
            peekText = peeked.content;
        });
    }

    function duration(seconds) {
        const whole = Math.round(seconds);
        const clock = [Math.floor(whole / 60) % 60, whole % 60].map(part => String(part).padStart(2, "0")).join(":");
        return whole >= 3600 ? Math.floor(whole / 3600) + ":" + clock : clock.replace(/^0/, "");
    }

    function activate(item, keys) {
        if (item.kind === "buffer")
            return runBuffer(item.action);
        Spot.open(keys.ctrl ? Spot.dirname(item.path) : item.path);
        return true;
    }

    function runBuffer(action) {
        const paths = buffer;
        switch (action) {
        case "move":
        case "copy":
            transferForm(paths, action === "copy");
            return false;
        case "open":
            paths.forEach(path => Spot.open(path));
            break;
        case "trash":
            Quickshell.execDetached(["gio", "trash", "--", ...paths]);
            break;
        case "paths":
            Spot.copy(paths.join("\n"));
            break;
        }
        buffer = [];
        return action !== "clear";
    }

    // asks the folder, then moves (or copies) the files there, never over one
    function transferForm(paths, copy) {
        host.openForm({
            title: `${copy ? "Copy" : "Move"} ${paths.length === 1 ? Spot.basename(paths[0]) : paths.length + " files"}`,
            fields: [{ key: "folder", label: "Folder", value: "", options: homeDirs.items.map(path => Spot.tilde(path)) }],
            submit: values => {
                Quickshell.execDetached(["sh", "-c", `verb=$1 dest=$2
shift 2
mkdir -p "$dest" || exit
moved=0
for file; do
    if [ -e "$dest/\${file##*/}" ]; then
        notify-send -u critical Spotlight "\${dest##*/} already has \${file##*/}"
    elif ${copy ? "cp -r" : "mv"} -- "$file" "$dest"/; then
        moved=$((moved + 1))
    fi
done
notify-send -t 3000 -i folder "$verb to \${dest##*/}" "$moved of $# files"`, "sh", copy ? "Copied" : "Moved", values.folder.trim().replace(/^~/, Spot.home), ...paths]);
                buffer = buffer.filter(path => !paths.includes(path));
                recent.reload();
                latestDownload.reload();
                return true;
            }
        });
    }

    function copy(item) {
        Spot.copy(item.path);
    }

    function act(item, action) {
        if (item.kind !== "file")
            return false;
        if (action === "move") {
            transferForm([item.path], false);
        } else if (action === "buffer") {
            const had = buffer.includes(item.path);
            buffer = had ? buffer.filter(path => path !== item.path) : [...buffer, item.path];
            host.notify(`${had ? "Removed from" : "Added to"} the buffer (${buffer.length})`);
        }
        return false;
    }

    Source {
        id: frequent
        maxAge: 60000
        command: ["zoxide", "query", "--list"]
        parse: output => output.split("\n").filter(path => path && path !== Spot.home).map(path => ({ path, folded: Search.fold(path) }))
    }

    Source {
        id: homeDirs
        maxAge: 300000
        command: ["find", Spot.home, "-mindepth", "1", "-maxdepth", "1", "-type", "d", "-not", "-name", ".*"]
        parse: output => output.split("\n").filter(path => path).sort((a, b) => a.localeCompare(b))
    }

    Source {
        id: recent
        maxAge: 60000
        request: ["recent-files"]
        parse: output => JSON.parse(output).map(entry => Object.assign(entry, { folded: Search.fold(entry.path) }))
    }

    // the newest finished download: browsers' partial files are left out
    Source {
        id: latestDownload
        maxAge: 5000
        command: ["sh", "-c", 'find "$1" -maxdepth 1 -type f -not -name "*.part" -not -name "*.crdownload" -not -name ".*" -printf "%T@ %p\\n" | sort -nr | head -n 1', "sh", Spot.home + "/Downloads"]
        parse: output => {
            const line = output.trim();
            return line ? { modified: Number(line.slice(0, line.indexOf(" "))) * 1000, path: line.slice(line.indexOf(" ") + 1) } : null;
        }
    }

    Lookup {
        query: root.query
        // fd answers in 15-45 ms and a newer query stops it
        interval: 50
        command: query => {
            if (root.isPath(query))
                return null;
            const wanted = root.search(query);
            return !wanted.filtered && query.length < 2 ? null : ["fd", "--one-file-system", "--ignore-case", "--absolute-path", "--max-results", "200", ...wanted.args, "--", root.accentPattern(Search.tokens(wanted.text)[0] ?? ""), wanted.folder];
        }
        onDone: output => root.found = root.rank(output, root.search(root.query).text)
    }

    Lookup {
        query: root.browseDir
        interval: 0
        command: dir => dir ? ["find", dir, "-mindepth", "1", "-maxdepth", "1", "-printf", "%Y\t%p\n"] : null
        onDone: output => root.listing = { dir: root.browseDir, entries: output.split("\n").filter(line => line).map(line => ({ isDir: line[0] === "d", path: line.slice(2), name: Spot.basename(line.slice(2)) })).sort((a, b) => b.isDir - a.isDir || a.name.localeCompare(b.name)) }
    }

    Lookup {
        query: root.contentQuery
        interval: 50
        helper: true
        command: query => query.length < 3 ? null : ["contents", query]
        onDone: output => root.contentHits = output.trim() ? JSON.parse(output) : []
    }
}
