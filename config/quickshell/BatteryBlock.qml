import QtQuick

// Battery gauge: circular charge ring with status and time remaining.
Column {
    id: root
    property real u: 1
    property bool dark: Theme.systemDark
    spacing: 18 * u
    visible: SysInfo.batPresent

    CircleStat {
        anchors.horizontalCenter: parent.horizontalCenter
        u: root.u; dark: root.dark
        label: "BAT"
        value: SysInfo.batPct
        centerText: Math.round(SysInfo.batPct) + "%"
        subText: SysInfo.batTime
        ringColor: {
            if (SysInfo.batStatus === "Charging") return Theme.teal(root.dark);
            if (SysInfo.batPct <= 15) return Theme.orange(root.dark);
            return Theme.green(root.dark);
        }
    }

    // status label
    WText {
        anchors.horizontalCenter: parent.horizontalCenter
        dark: root.dark
        text: SysInfo.batStatus.toUpperCase()
        color: Theme.muted(root.dark)
        font.pixelSize: 14 * root.u
        font.letterSpacing: 3 * root.u
    }
}
