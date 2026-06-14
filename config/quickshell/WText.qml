import QtQuick
import QtQuick.Effects

// Text with a soft halo so it stays legible over ANY wallpaper. `dark` selects
// the zone's palette: light text + dark halo on dark areas, and vice versa.
Text {
    id: t
    property bool dark: true
    color: Theme.fg(dark)
    font.family: Theme.sans
    renderType: Text.NativeRendering

    layer.enabled: true
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: Theme.shadow(t.dark)
        shadowOpacity: 0.9
        shadowBlur: 0.85
        blurMax: 24
        shadowVerticalOffset: 0
        shadowHorizontalOffset: 0
    }
}
