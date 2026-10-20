import QtQuick

// Desktop text in the zone's palette: `dark` selects light text for dark areas,
// and vice versa. Its halo comes from the block it sits in (see Halo).
Text {
    property bool dark: true
    color: Theme.fg(dark)
    font.family: Theme.sans
    renderType: Text.NativeRendering
}
