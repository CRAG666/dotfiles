import QtQuick
import QtQuick.Effects

// The wallpaper, blurred, dimmed and zoomed in while `blurred`; animates both
// ways. The zoom hides the transparent fringe the blur leaves at the edges.
Item {
    id: root
    property bool blurred: true

    component Smooth: NumberAnimation {
        duration: 450
        easing.type: Easing.OutCubic
    }

    Image {
        id: wall
        anchors.fill: parent
        source: Wallpaper.source
        sourceSize: Qt.size(width, height)
        fillMode: Image.PreserveAspectCrop
        cache: false
        visible: false
    }

    MultiEffect {
        anchors.fill: parent
        source: wall
        autoPaddingEnabled: false
        blurEnabled: true
        blurMax: 64
        blur: root.blurred ? 1 : 0
        brightness: root.blurred ? -0.2 : 0
        saturation: root.blurred ? 0.2 : 0
        scale: root.blurred ? 1.12 : 1
        Behavior on blur { Smooth {} }
        Behavior on brightness { Smooth {} }
        Behavior on saturation { Smooth {} }
        Behavior on scale { Smooth { duration: 700 } }
    }
}
