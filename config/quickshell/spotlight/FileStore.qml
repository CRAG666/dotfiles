import Quickshell
import Quickshell.Io
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
// newest file in ~/Downloads leads the view. Ctrl+K moves a file.
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

    function sections(tokens, everything) {
        const words = tokens.filter(token => !/^(kind|modified|in):/.test(token));
        if (words.length < tokens.length)
            return [["Files", found.slice(0, everything ? 6 : 60)]];
        const download = Spot.matches("latest download downloads", tokens) ? downloadItems() : [];
        if (!tokens.length)
            return everything ? [] : [["Latest Download", downloadItems()], ["Recent", recentItems([], 9).filter(item => item.path !== latestDownload.items?.path).slice(0, 8)], ["Home", homeDirs.items.map(path => fileItem(path, true, ""))], ["Frequent", frequentItems([], 12)]];
        const shown = new Set();
        const unseen = items => items.filter(item => !shown.has(item.path) && shown.add(item.path));
        const recentHits = unseen(recentItems(tokens, everything ? 3 : 6));
        const frequentHits = unseen(frequentItems(tokens, everything ? 3 : 6));
        const fileHits = unseen(found.filter(file => Spot.matchesFolded(file.folded, tokens, false))).slice(0, everything ? 6 : 60);
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
        return recent.items
            .filter(entry => Spot.matchesFolded(entry.folded, tokens, false))
            .slice(0, limit)
            .map(entry => fileItem(entry.path, entry.isDir, Spot.tilde(Spot.dirname(entry.path))));
    }

    // zoxide's most visited directories, best first
    function frequentItems(tokens, limit) {
        return frequent.items
            .filter(entry => Spot.matchesFolded(entry.folded, tokens, false))
            .slice(0, limit)
            .map(({ path }) => fileItem(path, true, Spot.tilde(Spot.dirname(path))));
    }

    function fileItem(path, isDir, hint) {
        const name = Spot.basename(path);
        return { key: "file:" + path, kind: "file", store: root, path, isDir, title: name, hint, icon: fileIcon(name, isDir) };
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
        const peeked = peekKey === item.key;
        const type = extension(item.title);
        const kind = item.isDir ? "Folder" : type ? type.toUpperCase() + " file" : "File";
        const image = imageTypes.includes(type) ? "file://" + item.path : peeked && peekThumb ? "file://" + peekThumb : "";
        const body = item.snippet ? item.snippet : peeked ? peekText : "";
        return { image, icon: item.icon, title: item.title, subtitle: Spot.tilde(item.path), metadata: [["Kind", kind], ["Page", item.page || ""], ...(peeked ? peekFacts : [])], body, mono: !item.snippet, actions: [["Enter", "Open"], ["Ctrl+Enter", "Show in folder"], ["Ctrl+C", "Copy path"], ["", "Move to…", "move"]] };
    }

    // the header lines hold the size and modification time, the thumbnail (made
    // once into the cache) and a PDF's page count or a video's duration
    function peek(item) {
        const type = extension(item.title);
        peekKey = item.key;
        peekText = "";
        peekThumb = "";
        peekFacts = [];
        peeker.isDir = item.isDir;
        peeker.exec(["sh", "-c", `stat -c "%s|%Y" -- "$1"
thumb=""
if [ "$2" = pdf ] || [ "$2" = video ]; then
    thumb="$3/$(printf %s "$1" | md5sum | cut -c1-32).png"
    if [ ! "$thumb" -nt "$1" ]; then
        mkdir -p "$3"
        if [ "$2" = pdf ]; then
            pdftoppm -png -singlefile -f 1 -scale-to 800 "$1" "\${thumb%.png}"
        else
            ffmpegthumbnailer -i "$1" -o "$thumb" -s 800
        fi > /dev/null 2>&1 || thumb=""
    fi
fi
echo "$thumb"
case "$2" in
pdf) echo "Pages|$(pdfinfo "$1" 2> /dev/null | sed -n "s/^Pages: *//p")" ;;
video) echo "Duration|$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$1")" ;;
*) echo ;;
esac
if [ -d "$1" ]; then ls -1Ap -- "$1" | head -n 40; elif [ "$2" = text ]; then head -c 3000 -- "$1"; fi`, "sh", item.path, type === "pdf" ? "pdf" : videoTypes.includes(type) ? "video" : textTypes.includes(type) ? "text" : "", Spot.cacheDir + "/thumbs"]);
    }

    function duration(seconds) {
        const whole = Math.round(seconds);
        const clock = [Math.floor(whole / 60) % 60, whole % 60].map(part => String(part).padStart(2, "0")).join(":");
        return whole >= 3600 ? Math.floor(whole / 3600) + ":" + clock : clock.replace(/^0/, "");
    }

    function activate(item, keys) {
        Spot.open(keys.ctrl ? Spot.dirname(item.path) : item.path);
        return true;
    }

    function copy(item) {
        Spot.copy(item.path);
    }

    function act(item, action) {
        if (action !== "move")
            return false;
        host.openForm({
            title: "Move " + item.title,
            fields: [{ key: "folder", label: "Folder", value: "", options: homeDirs.items.map(path => Spot.tilde(path)) }],
            submit: values => {
                const folder = values.folder.trim().replace(/^~/, Spot.home);
                Quickshell.execDetached(["sh", "-c", 'if [ -e "$2/${1##*/}" ]; then notify-send -u critical Spotlight "${2##*/} already has ${1##*/}"; else mkdir -p "$2" && mv -- "$1" "$2"/ && notify-send -t 3000 -i folder "Moved to ${2##*/}" "${1##*/}"; fi', "sh", item.path, folder]);
                recent.reload();
                latestDownload.reload();
                return true;
            }
        });
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
        command: ["python3", Spot.helper, "recent-files"]
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
        interval: 150
        command: query => {
            const wanted = root.search(query);
            return !wanted.filtered && query.length < 2 ? null : ["fd", "--one-file-system", "--ignore-case", "--absolute-path", "--max-results", "200", ...wanted.args, "--", root.accentPattern(Search.tokens(wanted.text)[0] ?? ""), wanted.folder];
        }
        onDone: output => root.found = root.rank(output, root.search(root.query).text)
    }

    Lookup {
        query: root.contentQuery
        interval: 200
        command: query => query.length < 3 ? null : ["python3", Spot.helper, "contents", query]
        onDone: output => root.contentHits = output.trim() ? JSON.parse(output) : []
    }

    Process {
        id: peeker
        property bool isDir: false
        stdout: StdioCollector {
            onStreamFinished: {
                const [stamp, thumb, extra, ...rest] = text.split("\n");
                const [bytes, modified] = stamp.split("|");
                const content = rest.join("\n");
                const entries = content.split("\n").filter(line => line).length;
                const size = peeker.isDir ? `${entries}${entries === 40 ? "+" : ""} ${entries === 1 ? "item" : "items"}` : Spot.formatSize(Number(bytes));
                const [extraLabel, extraValue] = (extra ?? "").split("|");
                root.peekFacts = [[peeker.isDir ? "Contents" : "Size", size], ["Modified", Spot.dateTime(Number(modified) * 1000)], [extraLabel, extraLabel === "Duration" && extraValue ? root.duration(Number(extraValue)) : extraValue]];
                root.peekThumb = thumb ?? "";
                root.peekText = content;
            }
        }
    }
}
