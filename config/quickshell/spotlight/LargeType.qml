import QtQuick
import qs

// Large Type, as Alfred's: a text across the screen, as large as it fits, to
// read from afar or show someone; a click or any key (Shortcuts) dismisses it
Rectangle {
    id: root
    property string text: ""
    signal dismissed

    visible: text !== ""
    color: Qt.rgba(0, 0, 0, 0.55)

    Rectangle {
        anchors.centerIn: parent
        width: shown.contentWidth + Spot.px(80)
        height: shown.contentHeight + Spot.px(60)
        radius: Spot.px(28)
        color: Qt.rgba(0, 0, 0, 0.8)
    }
    Label {
        id: shown
        anchors.centerIn: parent
        width: parent.width * 0.85
        height: parent.height * 0.6
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.Wrap
        fontSizeMode: root.visible ? Text.Fit : Text.FixedSize
        minimumPixelSize: Spot.px(24)
        text: root.text
        color: "white"
        font.family: Theme.menu
        font.pixelSize: Spot.px(220)
        font.weight: Font.DemiBold
    }
    MouseArea {
        anchors.fill: parent
        onClicked: root.dismissed()
    }
}
