import Quickshell
import QtQuick

// Centred date stack: framed weekday · cursive ordinal · month · time.
Column {
    id: root
    property real u: 1                 // responsive unit (= screen height / 1440)
    property bool dark: Theme.dateDark
    property var now: clock.date
    spacing: 10 * u

    // the time reads "hh:mm", so one aligned wake-up per minute is enough
    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    function ordinal(n) {
        const w = ["zeroth", "first", "second", "third", "fourth", "fifth",
            "sixth", "seventh", "eighth", "ninth", "tenth", "eleventh", "twelfth",
            "thirteenth", "fourteenth", "fifteenth", "sixteenth", "seventeenth",
            "eighteenth", "nineteenth", "twentieth", "twenty-first", "twenty-second",
            "twenty-third", "twenty-fourth", "twenty-fifth", "twenty-sixth",
            "twenty-seventh", "twenty-eighth", "twenty-ninth", "thirtieth",
            "thirty-first"];
        const s = w[n] || (n + "th");
        return s.charAt(0).toUpperCase() + s.slice(1);
    }

    // weekday with two small centred brackets (top ⊓, bottom ⊔); the word runs
    // through the middle and extends well beyond the brackets.
    Item {
        id: frame
        anchors.horizontalCenter: parent.horizontalCenter
        implicitWidth: wd.implicitWidth
        implicitHeight: wd.implicitHeight + 2 * (legH + gap)

        property real lw: Math.max(3, Math.round(3 * u))   // integer px → uniform, crisp lines
        property color lc: Theme.line(root.dark)
        property real bw: Math.round(wd.implicitWidth * 0.33)   // bracket width (~2 letters)
        property real legH: Math.round(30 * u)                  // bracket leg length
        property real gap: 6 * u                     // space between bracket and letters

        WText {
            id: wd
            dark: root.dark
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: font.letterSpacing / 2
            text: root.now.toLocaleDateString(Qt.locale("en_US"), "dddd").toUpperCase()
            font.pixelSize: 72 * u
            font.weight: Font.Light
            font.letterSpacing: 26 * u
        }

        // top bracket ⊓ (bar on top, legs pointing down)
        Item {
            width: frame.bw
            height: frame.legH
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            Rectangle { anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; height: frame.lw; color: frame.lc }
            Rectangle { anchors.top: parent.top; anchors.left: parent.left;  width: frame.lw; height: frame.legH; color: frame.lc }
            Rectangle { anchors.top: parent.top; anchors.right: parent.right; width: frame.lw; height: frame.legH; color: frame.lc }
        }

        // bottom bracket ⊔ (bar on bottom, legs pointing up)
        Item {
            width: frame.bw
            height: frame.legH
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: frame.lw; color: frame.lc }
            Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left;  width: frame.lw; height: frame.legH; color: frame.lc }
            Rectangle { anchors.bottom: parent.bottom; anchors.right: parent.right; width: frame.lw; height: frame.legH; color: frame.lc }
        }
    }

    WText {
        anchors.horizontalCenter: parent.horizontalCenter
        dark: root.dark
        text: root.ordinal(root.now.getDate())
        color: Theme.orange(root.dark)
        font.family: Theme.cursive
        font.italic: true
        font.pixelSize: 62 * u
    }

    WText {
        anchors.horizontalCenter: parent.horizontalCenter
        dark: root.dark
        text: root.now.toLocaleDateString(Qt.locale("en_US"), "MMMM").toUpperCase()
        font.weight: Font.Bold
        font.pixelSize: 28 * u
        font.letterSpacing: 5 * u
    }

    // time, flanked by two rules
    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 18 * u

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 84 * u
            height: Math.max(1, 2 * u)
            color: Theme.line(root.dark)
        }
        WText {
            dark: root.dark
            text: root.now.toLocaleTimeString(Qt.locale("en_US"), "hh:mm AP")
            font.pixelSize: 24 * u
            font.weight: Font.Medium
            font.letterSpacing: 2 * u
        }
        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 84 * u
            height: Math.max(1, 2 * u)
            color: Theme.line(root.dark)
        }
    }
}
