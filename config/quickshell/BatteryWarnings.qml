import Quickshell
import QtQuick

// macOS's battery alerts, from UPower: a critical notification when the
// battery runs under 30 % unplugged, and a quiet one when charging reaches
// 80 %. Each fires once as its condition starts; the HUD (Osd) shows the
// charger coming and going.
Scope {
    readonly property bool low: SysInfo.batStatus === "Discharging" && SysInfo.batPct < 30
    readonly property bool high: SysInfo.batStatus === "Charging" && SysInfo.batPct >= 80

    onLowChanged: if (low)
        Quickshell.execDetached(["notify-send", "-u", "critical", "-a", "Battery", "-i", "battery-caution", "Low Battery", `${SysInfo.batPct}% left. Plug in the charger.`])
    onHighChanged: if (high)
        Quickshell.execDetached(["notify-send", "-a", "Battery", "-i", "battery-full-charging", `Battery at ${SysInfo.batPct}%`, "You may unplug the charger."])
}
