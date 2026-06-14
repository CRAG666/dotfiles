import QtQuick

// System panel: circular CPU / RAM / TEMP / NET gauges + uptime.
Column {
    id: root
    property real u: 1
    property bool dark: Theme.systemDark
    spacing: 22 * u

    CircleStat {
        anchors.horizontalCenter: parent.horizontalCenter
        u: root.u; dark: root.dark
        label: "CPU"
        value: SysInfo.cpu
        ringColor: Theme.blue(root.dark)
    }
    CircleStat {
        anchors.horizontalCenter: parent.horizontalCenter
        u: root.u; dark: root.dark
        label: "RAM"
        value: SysInfo.ram
        subText: SysInfo.ramshort
        ringColor: Theme.green(root.dark)
    }
    CircleStat {
        anchors.horizontalCenter: parent.horizontalCenter
        u: root.u; dark: root.dark
        label: "TEMP"
        value: SysInfo.temp
        centerText: Math.round(SysInfo.temp) + "°"
        ringColor: Theme.orange(root.dark)
    }
    CircleStat {
        anchors.horizontalCenter: parent.horizontalCenter
        u: root.u; dark: root.dark
        label: "NET"
        value: SysInfo.netpct                       // arc = total throughput activity
        centerText: "↓" + SysInfo.netdown      // ↓ download
        subText: "↑" + SysInfo.netup           // ↑ upload
        mono: true
        ringColor: Theme.pink(root.dark)
    }

    // uptime
    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 8 * u
        WText { anchors.verticalCenter: parent.verticalCenter; dark: root.dark; text: ""; font.family: Theme.mono; font.pixelSize: 16 * root.u; color: Theme.yellow(root.dark) }
        WText { anchors.verticalCenter: parent.verticalCenter; dark: root.dark; text: SysInfo.uptime; font.pixelSize: 14 * root.u }
    }
}
