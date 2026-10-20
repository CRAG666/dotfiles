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
    // unblurring while hidden snaps: animating it would only draw unseen frames
    readonly property bool animated: visible || blurred

    component Smooth: NumberAnimation {
        duration: 450
        easing.type: Easing.OutCubic
    }

    Image {
        id: wall
        anchors.fill: parent
        // a 0×0 sourceSize decodes the whole wallpaper, so it waits for a size;
        // the cache shares one decode among the windows of a process
        source: width > 0 && height > 0 ? Wallpaper.source : ""
        sourceSize: Qt.size(width, height)
        fillMode: Image.PreserveAspectCrop
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
        Behavior on blur { enabled: root.animated; Smooth {} }
        Behavior on brightness { enabled: root.animated; Smooth {} }
        Behavior on saturation { enabled: root.animated; Smooth {} }
        Behavior on scale { enabled: root.animated; Smooth { duration: 700 } }
    }
}
