import Quickshell
import Quickshell.Io
import QtQuick
import qs

// Wallpapers in ~/Pictures/wallpaperCicle with the square thumbnails awww's
// scripts cache as <md5 of the path>.sqre (missing ones are rendered here).
// The current one comes first; Enter applies one through awwwallpaper.sh.
Scope {
    id: root
    property var host
    readonly property string folder: Spot.home + "/Pictures/wallpaperCicle"
    readonly property string thumbDir: Spot.home + "/.cache/wallpapers/thumbnails"
    readonly property string current: listing.items[0] ?? ""
    readonly property var wallpapers: listing.items.slice(1).sort((a, b) => a.localeCompare(b))
    property int thumbsReady: 0

    function load() {
        listing.reload();
    }

    function thumbOf(path) {
        return `file://${thumbDir}/${Qt.md5(path)}.sqre`;
    }

    // the counter in the query makes rows reload thumbs rendered after the first paint
    function items(tokens) {
        const item = (path, section) => ({ key: "wallpaper:" + path, kind: "wallpaper", store: root, section, path, title: path.slice(path.lastIndexOf("/") + 1), hint: path === current ? "Current" : "", thumb: `${thumbOf(path)}?${thumbsReady}` });
        const matching = wallpapers.filter(path => Spot.matches(path.slice(folder.length), tokens));
        return [...matching.filter(path => path === current).map(path => item(path, "Current")), ...matching.filter(path => path !== current).map(path => item(path, "Wallpapers"))];
    }

    function describe(item) {
        return { image: "file://" + item.path, title: item.title, subtitle: item.path.replace(Spot.home, "~"), details: [item.path === current ? "Current wallpaper" : ""], actions: [["Enter", "Set wallpaper"], ["Ctrl+Enter", "Open image"], ["Ctrl+C", "Copy path"]] };
    }

    function activate(item, keys) {
        if (keys.ctrl)
            Quickshell.execDetached(["xdg-open", item.path]);
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
        onItemsChanged: thumbs.exec(["sh", "-c", `dir=$1; shift; mkdir -p "$dir"
for path in "$@"; do
    thumb="$dir/$(printf %s "$path" | md5sum | cut -d" " -f1).sqre"
    [ -f "$thumb" ] || printf '%s\\0%s\\0' "$path" "$thumb"
done | xargs -0 -r -n2 -P "$(nproc)" sh -c 'magick "$1[0]" -resize 400x400^ -gravity center -quality 90 -extent 400x400 "$2"' _`, "sh", root.thumbDir, ...root.wallpapers])
    }

    Process {
        id: thumbs
        onExited: root.thumbsReady++
    }
}
