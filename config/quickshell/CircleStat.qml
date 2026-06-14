import QtQuick
import QtQuick.Shapes

// Circular progress ring with the label + value centred inside it.
// Drawn with GPU-accelerated Shape arcs (no Canvas/JS rasterization).
Item {
    id: root
    property real u: 1
    property bool dark: true
    property string label: ""
    property real value: 0                              // 0..100
    property string centerText: Math.round(value) + "%"
    property string subText: ""
    property bool mono: false                            // render centre/sub in the nerd font
    property color ringColor: Theme.blue(dark)
    property real diameter: 150 * u
    property real thickness: 11 * u

    implicitWidth: diameter
    implicitHeight: diameter

    Shape {
        id: ring
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        property real r: Math.min(root.width, root.height) / 2 - root.thickness / 2

        // track
        ShapePath {
            strokeColor: Theme.track(root.dark)
            strokeWidth: root.thickness
            fillColor: "transparent"
            PathAngleArc {
                centerX: root.width / 2
                centerY: root.height / 2
                radiusX: ring.r
                radiusY: ring.r
                startAngle: 0
                sweepAngle: 360
            }
        }

        // progress arc (starts at 12 o'clock, clockwise)
        ShapePath {
            strokeColor: root.ringColor
            strokeWidth: root.thickness
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathAngleArc {
                centerX: root.width / 2
                centerY: root.height / 2
                radiusX: ring.r
                radiusY: ring.r
                startAngle: -90
                sweepAngle: 360 * Math.max(0, Math.min(root.value / 100, 1))
            }
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: 1 * root.u

        WText {
            anchors.horizontalCenter: parent.horizontalCenter
            dark: root.dark
            text: root.label
            color: root.ringColor
            font.pixelSize: 18 * root.u
            font.weight: Font.Bold
            font.letterSpacing: 3 * root.u
        }
        WText {
            anchors.horizontalCenter: parent.horizontalCenter
            dark: root.dark
            text: root.centerText
            font.family: root.mono ? Theme.mono : Theme.sans
            font.pixelSize: (root.mono ? 22 : 28) * root.u
            font.weight: Font.Bold
        }
        WText {
            anchors.horizontalCenter: parent.horizontalCenter
            dark: root.dark
            visible: root.subText !== ""
            text: root.subText
            color: Theme.muted(root.dark)
            font.family: root.mono ? Theme.mono : Theme.sans
            font.pixelSize: (root.mono ? 13 : 16) * root.u
            font.weight: Font.DemiBold
        }
    }
}
