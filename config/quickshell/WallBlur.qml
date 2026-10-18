import QtQuick
import QtQuick.Effects

// The wallpaper, blurred, dimmed and zoomed in while `blurred`; animates both
// ways. The zoom hides the transparent fringe the blur leaves at the edges.
// It is decoded off the GUI thread (~100 ms for a 4K JPEG): it fades in once
// ready, and a new wallpaper replaces the old one only when decoded.
Item {
    id: root
    property bool blurred: true
    property bool decoded: false

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
        asynchronous: true
        retainWhileLoading: true
        visible: false
        onStatusChanged: if (status === Image.Ready) root.decoded = true
    }

    MultiEffect {
        anchors.fill: parent
        source: wall
        opacity: root.decoded ? 1 : 0
        Behavior on opacity { Smooth {} }
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
