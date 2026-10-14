import Quickshell
import Quickshell.Io
import QtQuick

// Color picker: "Pick Color" closes Spotlight, lets you click any pixel
// (slurp + grim), copies its hex and remembers it; picked colors are listed
// with a swatch. Enter copies the hex, Ctrl+X forgets a color.
Scope {
    id: root
    property var host
    property var colors: []

    function pickItem(tokens) {
        return Spot.matches("pick color picker eyedropper", tokens) ? [{ key: "color:pick", kind: "pickColor", store: root, title: "Pick Color", icon: "color-picker" }] : [];
    }

    function items(tokens) {
        return [...pickItem(tokens), ...colors.filter(hex => Spot.matches(hex, tokens)).map(hex => ({ key: "color:" + hex, kind: "color", store: root, title: hex, hint: rgb(hex), swatch: hex }))];
    }

    function rgb(hex) {
        const color = Qt.color(hex);
        return `rgb(${Math.round(color.r * 255)}, ${Math.round(color.g * 255)}, ${Math.round(color.b * 255)})`;
    }

    function describe(item) {
        if (item.kind === "pickColor")
            return { icon: item.icon, title: item.title, subtitle: "Click any pixel on screen; its hex lands on the clipboard", actions: [["Enter", "Pick color"]] };
        const color = Qt.color(item.title);
        return { swatch: item.title, title: item.title, metadata: [["Hex", item.title], ["RGB", rgb(item.title)], ["HSL", `hsl(${Math.round(Math.max(0, color.hslHue) * 360)}, ${Math.round(color.hslSaturation * 100)}%, ${Math.round(color.hslLightness * 100)}%)`]], actions: [["Enter", "Copy hex"], ["Ctrl+X", "Forget"]] };
    }

    function activate(item, keys) {
        if (item.kind === "color") {
            Spot.copy(item.title);
            return true;
        }
        Quickshell.execDetached(["sh", "-c", `sleep 0.3
color=$(grim -g "$(slurp -p)" -t ppm - | magick - -depth 8 -format '#%[hex:p{0,0}]' info:) || exit 0
printf %s "$color" | wl-copy
printf '%s\\n' "$color" >> "$1"
notify-send -i color-picker "Color picked" "$color"`, "sh", file.path]);
        return true;
    }

    function copy(item) {
        Spot.copy(item.title);
    }

    function act(item, action) {
        if (item.kind === "color" && action === "delete")
            file.setText(colors.filter(hex => hex !== item.title).reverse().map(hex => hex + "\n").join(""));
        return false;
    }

    FileView {
        id: file
        path: Spot.stateDir + "/colors"
        blockLoading: true
        blockWrites: true
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: root.colors = [...new Set(text().split("\n").filter(line => line).reverse())]
        onSaved: reload()
    }
}
