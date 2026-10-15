import Quickshell
import Quickshell.Io
import QtQuick
import "search.js" as Search

// Files and folders under ~. With nothing typed: recently used files (GTK's
// recently-used.xbel), the home folders, then zoxide's frequent folders; typing:
// recent and frequent matches first, then fd over ~ (other file systems, like
// rclone mounts, are skipped; accents are ignored). Documents are also searched
// by their text, through an SQLite index of ~/Documents, ~/Desktop and
// ~/Downloads that spotlight.py brings up to date at most once an hour. The
// preview lists a folder, shows the head of a text file, or a thumbnail of an
// image, a PDF's first page or a video.
Scope {
    id: root
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
    readonly property var textTypes: ["txt", "md", "qml", "js", "ts", "py", "sh", "rs", "go", "c", "h", "cpp", "json", "toml", "yaml", "yml", "ini", "conf", "lua", "nix", "tex", "csv", "log", "rasi", "css", "html", "xml"]

    onQueryChanged: debounce.restart()
    onContentQueryChanged: contentDebounce.restart()

    function load() {
        frequent.load();
        homeDirs.load();
        recent.load();
        if (Date.now() - indexedAt > 3600000) {
            indexedAt = Date.now();
            Quickshell.execDetached(["flock", "-n", Spot.cacheDir + "/index.lock", "nice", "-n", "19", "sh", "-c", 'out=$(python3 "$@" 2>&1) || notify-send -u critical "Spotlight index" "$out"', "sh", Spot.helper, "index-contents"]);
        }
    }

    function sections(tokens, everything) {
        if (!tokens.length)
            return everything ? [] : [["Recent", recentItems([], 8)], ["Home", homeDirs.items.map(path => fileItem(path, true, ""))], ["Frequent", frequentItems([], 12)]];
        const shown = new Set();
        const unseen = items => items.filter(item => !shown.has(item.path) && shown.add(item.path));
        const recentHits = unseen(recentItems(tokens, everything ? 3 : 6));
        const frequentHits = unseen(frequentItems(tokens, everything ? 3 : 6));
        const fileHits = unseen(found.filter(file => Spot.matchesFolded(file.folded, tokens, false))).slice(0, everything ? 6 : 60);
        return [["Recent", recentHits], ["Frequent", frequentHits], ["Files", fileHits]];
    }

    function contentItems() {
        return contentHits.map(hit => Object.assign(fileItem(hit.path, false, hit.page ? "p. " + hit.page : ""), { key: "content:" + hit.path, page: hit.page, snippet: hit.snippet }));
    }

    function recentItems(tokens, limit) {
        return recent.items
            .filter(entry => Spot.matchesFolded(entry.folded, tokens, false))
            .slice(0, limit)
            .map(entry => fileItem(entry.path, entry.isDir, entry.path.slice(0, entry.path.lastIndexOf("/")).replace(Spot.home, "~")));
    }

    // zoxide's most visited directories, best first
    function frequentItems(tokens, limit) {
        return frequent.items
            .filter(entry => Spot.matchesFolded(entry.folded, tokens, false))
            .slice(0, limit)
            .map(({ path }) => fileItem(path, true, path.slice(0, path.lastIndexOf("/")).replace(Spot.home, "~")));
    }

    function fileItem(path, isDir, hint) {
        const name = path.slice(path.lastIndexOf("/") + 1);
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
        if (["mp3", "flac", "ogg", "wav", "m4a", "opus"].includes(type))
            return "audio-x-generic";
        if (["zip", "tar", "gz", "xz", "zst", "7z", "rar"].includes(type))
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
                const name = Search.fold(path.slice(path.lastIndexOf("/") + 1));
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
        return { image, icon: item.icon, title: item.title, subtitle: item.path.replace(Spot.home, "~"), metadata: [["Kind", kind], ["Page", item.page || ""], ...(peeked ? peekFacts : [])], body, mono: !item.snippet, actions: [["Enter", "Open"], ["Ctrl+Enter", "Show in folder"], ["Ctrl+C", "Copy path"]] };
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

    Timer {
        id: debounce
        interval: 150
        onTriggered: {
            if (root.query.length < 2) {
                root.found = [];
                return;
            }
            fd.forQuery = root.query;
            fd.exec(["fd", "--one-file-system", "--ignore-case", "--absolute-path", "--max-results", "200", "--", root.accentPattern(Search.tokens(root.query)[0]), Spot.home]);
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

    Timer {
        id: contentDebounce
        interval: 200
        onTriggered: {
            if (root.contentQuery.length < 3) {
                root.contentHits = [];
                return;
            }
            contents.forQuery = root.contentQuery;
            contents.exec(["python3", Spot.helper, "contents", root.contentQuery]);
        }
    }

    Process {
        id: contents
        property string forQuery: ""
        stdout: StdioCollector {
            onStreamFinished: {
                if (contents.forQuery === root.contentQuery)
                    root.contentHits = text.trim() ? JSON.parse(text) : [];
            }
        }
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
                root.peekFacts = [[peeker.isDir ? "Contents" : "Size", size], ["Modified", new Date(Number(modified) * 1000).toLocaleString(Qt.locale(), Locale.ShortFormat)], [extraLabel, extraLabel === "Duration" && extraValue ? root.duration(Number(extraValue)) : extraValue]];
                root.peekThumb = thumb ?? "";
                root.peekText = content;
            }
        }
    }
}
