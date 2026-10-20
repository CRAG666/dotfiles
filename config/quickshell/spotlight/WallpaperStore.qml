import Quickshell
import Quickshell.Io
import QtQuick
import qs

// Wallpapers in ~/Pictures/wallpaperCicle, each with a square thumbnail cached
// as <md5 of the path>.sqre and a 960x720 preview, both JPEG (Qt reads no
// WebP here) and made once from one decode. The current one comes first;
// Enter applies one through awwwallpaper.sh.
Scope {
    id: root
    property var host
    readonly property string folder: Spot.home + "/Pictures/wallpaperCicle"
    readonly property string thumbDir: Spot.home + "/.cache/wallpapers/thumbnails"
    readonly property string previewDir: Spot.cacheDir + "/wallpapers"
    readonly property string current: listing.items[0] ?? ""
    readonly property var wallpapers: listing.items.slice(1).sort((a, b) => a.localeCompare(b))
    property int thumbsReady: 0
    // whether this listing's thumbnails and previews were all made
    property bool rendered: false

    function load() {
        listing.reload();
    }

    // path → md5 of it, the thumb's name, hashed once per listing, not per keystroke
    readonly property var thumbNames: {
        const names = Object.create(null);
        for (const path of wallpapers)
            names[path] = Qt.md5(path);
        return names;
    }

    function thumbOf(path) {
        return `file://${thumbDir}/${thumbNames[path] ?? Qt.md5(path)}.sqre`;
    }

    // the original until the previews are made: a 5K image took up to ~1 s to decode
    function previewOf(path) {
        return rendered ? `file://${previewDir}/${thumbNames[path] ?? Qt.md5(path)}.jpg` : "file://" + path;
    }

    // the counter in the query makes rows reload thumbs rendered after the first paint
    function items(tokens) {
        const item = (path, section) => ({ key: "wallpaper:" + path, kind: "wallpaper", store: root, section, path, title: Spot.basename(path), hint: path === current ? "Current" : "", thumb: `${thumbOf(path)}?${thumbsReady}` });
        const matching = wallpapers.filter(path => Spot.matches(path.slice(folder.length), tokens));
        return matching.filter(path => path === current).map(path => item(path, "Current")).concat(matching.filter(path => path !== current).map(path => item(path, "Wallpapers")));
    }

    function describe(item) {
        return { image: previewOf(item.path), title: item.title, subtitle: Spot.tilde(item.path), details: [item.path === current ? "Current wallpaper" : ""], actions: [["Enter", "Set wallpaper"], ["Ctrl+Enter", "Open image"], ["Ctrl+C", "Copy path"]] };
    }

    function activate(item, keys) {
        if (keys.ctrl)
            Spot.open(item.path);
        else
            Quickshell.execDetached(["sh", "-c", '"$1" -s "$2" && notify-send -a Spotlight -i "$3" Wallpaper "${2##*/}"', "sh", Spot.home + "/.config/awww/awwwallpaper.sh", item.path, thumbOf(item.path).slice("file://".length)]);
        return true;
    }

    function copy(item) {
        Spot.copy(item.path);
    }

    // first line: the current wallpaper (wall.set); then every image in the folder
    Source {
        id: listing
        command: ["sh", "-c", 'readlink -f "$HOME/.config/awww/wall.set"; fd --type f -e jpg -e jpeg -e png -e gif -e bmp -e tiff -e svg -e webp . "$1"', "sh", root.folder]
        parse: output => output.split("\n").filter(line => line)
    }

    // here, not in the listing's onItemsChanged, which still sees the last
    // listing's wallpapers; hashed here too, as thumbNames may not have caught up.
    // Niced: the first run makes every preview, about a minute on all cores
    onWallpapersChanged: {
        rendered = false;
        const pairs = [];
        for (let index = 0; index < wallpapers.length; index++)
            pairs.push(wallpapers[index], Qt.md5(wallpapers[index]));
        thumbs.exec(["sh", "-c", `thumbs=$1 previews=$2; shift 2; mkdir -p "$thumbs" "$previews"
while [ $# -gt 0 ]; do
    [ -f "$thumbs/$2.sqre" ] && [ -f "$previews/$2.jpg" ] || printf '%s\\0%s\\0%s\\0' "$1" "$thumbs/$2.sqre" "$previews/$2.jpg"
    shift 2
done | xargs -0 -r -n3 -P "$(nproc)" nice -n 19 sh -c 'magick "$1[0]" \\( +clone -resize "960x720>" -quality 85 -write "jpg:$3" +delete \\) -resize 400x400^ -gravity center -quality 90 -extent 400x400 "jpg:$2" && echo "$2"' _`, "sh", thumbDir, previewDir].concat(pairs));
    }

    // a counter bumped only when thumbnails were made reloads the rows' images
    Process {
        id: thumbs
        stdout: StdioCollector {
            onStreamFinished: if (text)
                root.thumbsReady++
        }
        onExited: root.rendered = true
    }
}
