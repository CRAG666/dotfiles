import QtQuick
import QtQuick.Effects

// Sequoia's material for the popups (not Tahoe's Liquid Glass): the blurred
// wallpaper frosted with Theme.glass, a hairline edge and a soft shadow. The
// blur is computed once per window: `backdrop` is that window's hidden
// WallBlur, laid over the whole screen, and each sheet only copies the part
// behind it, found from `origin`, its position in the window.
Item {
    id: glass
    required property Item backdrop
    required property point origin
    property real radius: 0
    property real u: 1

    RectangularShadow {
        anchors.fill: parent
        radius: glass.radius
        blur: Math.round(30 * glass.u)
        offset.y: Math.round(10 * glass.u)
        color: Qt.rgba(0, 0, 0, Theme.eyesDark ? 0.55 : 0.3)
    }

    Item {
        anchors.fill: parent
        layer.enabled: true
        layer.effect: MultiEffect {
            maskEnabled: true
            maskSource: shape
            maskThresholdMin: 0.5
            maskSpreadAtMin: 1
        }

        ShaderEffectSource {
            anchors.fill: parent
            sourceItem: glass.backdrop
            sourceRect: Qt.rect(glass.origin.x - glass.backdrop.x, glass.origin.y - glass.backdrop.y, glass.width, glass.height)
        }
        Rectangle {
            anchors.fill: parent
            color: Theme.glass
        }
    }
    Item {
        id: shape
        anchors.fill: parent
        layer.enabled: true
        visible: false

        Rectangle {
            anchors.fill: parent
            radius: glass.radius
        }
    }
    Rectangle {
        anchors.fill: parent
        radius: glass.radius
        color: "transparent"
        border.width: 1
        border.color: Theme.border
    }
}
