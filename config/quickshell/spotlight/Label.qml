import QtQuick
import qs

// Spotlight's text: the menu font at 14 points, plain unless a label says otherwise
Text {
    color: Theme.ink
    font.family: Theme.menuText
    font.pixelSize: Spot.px(14)
    textFormat: Text.PlainText
    renderType: Text.NativeRendering
}
