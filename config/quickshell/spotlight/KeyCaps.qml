import QtQuick
import qs

// "Ctrl+Enter" as keycaps: Ctrl ↵
Row {
    id: root
    property string keys: ""
    spacing: Spot.px(3)

    Repeater {
        model: root.keys.split("+").map(key => key === "Enter" ? "↵" : key)

        Rectangle {
            required property string modelData
            width: Math.max(height, capText.implicitWidth + Spot.px(10))
            height: Spot.px(20)
            radius: Spot.px(5)
            color: Theme.hairline

            Label {
                id: capText
                anchors.centerIn: parent
                text: parent.modelData
                color: Theme.inkSoft
                font.pixelSize: Spot.px(11)
            }
        }
    }
}
