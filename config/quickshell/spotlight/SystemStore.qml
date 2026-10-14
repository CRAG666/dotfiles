import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

// Quick system toggles: Wi-Fi and Bluetooth (rfkill), the default audio output
// (PipeWire) and the brightness of the laptop and external screens
// (brightness.sh). "brightness 40" sets 40% at once; "Set Brightness" asks.
Scope {
    id: root
    property var host
    readonly property string brightnessScript: Spot.home + "/.config/scroll/brightness.sh"
    readonly property var radios: [
        { type: "wlan", title: "Wi-Fi", words: "wifi wireless network internet", icon: "network-wireless-secure-signal-excellent" },
        { type: "bluetooth", title: "Bluetooth", words: "bt", icon: "bluetooth" }
    ]
    readonly property var sinks: Pipewire.nodes.values.filter(node => node.isSink && !node.isStream && node.audio)

    function load() {
        rfkill.load();
        backlight.load();
    }

    function items(tokens) {
        const radioItems = radios
            .filter(radio => radio.type in rfkill.items && Spot.matches(`toggle turn ${radio.title} ${radio.words}`, tokens))
            .map(radio => {
                const on = rfkill.items[radio.type];
                return { key: "radio:" + radio.type, kind: "radio", store: root, radio, on, title: `Turn ${radio.title} ${on ? "Off" : "On"}`, hint: on ? "On" : "Off", icon: radio.icon };
            });
        const sinkItems = sinks
            .filter(node => Spot.matches(`audio output sound speakers headphones ${node.description}`, tokens))
            .map(node => ({ key: "sink:" + node.name, kind: "sink", store: root, node, title: "Audio Output: " + (node.nickname || node.description), hint: node === Pipewire.defaultAudioSink ? "Current" : "", icon: "audio-speakers" }));
        return [...radioItems, ...sinkItems, ...brightnessItems(tokens)];
    }

    function brightnessItems(tokens) {
        const isLevel = token => /^\d{1,3}%?$/.test(token) && parseInt(token) <= 100;
        const words = tokens.filter(token => !isLevel(token));
        const level = tokens.find(isLevel);
        if (!Spot.matches("set brightness screen display backlight", words))
            return [];
        const now = backlight.items.length ? backlight.items[0] : "";
        if (level === undefined)
            return [{ key: "brightness", kind: "brightness", store: root, title: "Set Brightness", hint: now, icon: "brightnesssettings" }];
        if (!words.length)
            return [];
        return [{ key: "brightness:" + parseInt(level), kind: "brightness", store: root, level: parseInt(level), title: `Set Brightness to ${parseInt(level)}%`, hint: now, icon: "brightnesssettings" }];
    }

    // the laptop panel stays off when ktc-brightness.sh turned it off for the external monitor
    function setBrightness(level) {
        Quickshell.execDetached(["sh", "-c", '[ "$(brightnessctl get)" -eq 0 ] || brightnessctl -q set "$1%"; "$2" init "$1"', "sh", String(level), brightnessScript]);
    }

    function describe(item) {
        switch (item.kind) {
        case "radio":
            return { icon: item.icon, title: item.radio.title, subtitle: item.on ? "On" : "Off", actions: [["Enter", item.title]] };
        case "sink":
            return { icon: item.icon, title: item.node.nickname || item.node.description, subtitle: item.hint ? "Current output" : "Audio Output", metadata: [["Device", item.node.name]], actions: [["Enter", "Use this output"]] };
        default:
            return { icon: item.icon, title: item.title, subtitle: item.hint ? "Now " + item.hint : "Brightness", actions: [["Enter", item.level === undefined ? "Choose a level" : "Set"]] };
        }
    }

    function activate(item, keys) {
        switch (item.kind) {
        case "radio":
            Quickshell.execDetached(["sh", "-c", 'rfkill "$1" "$2" && notify-send -t 2000 -i "$3" "$4"', "sh", item.on ? "block" : "unblock", item.radio.type, item.icon, `${item.radio.title} ${item.on ? "off" : "on"}`]);
            return true;
        case "sink":
            Pipewire.preferredDefaultAudioSink = item.node;
            return true;
        }
        if (item.level !== undefined) {
            setBrightness(item.level);
            return true;
        }
        host.openForm({
            title: "Brightness",
            fields: [{ key: "level", label: "Brightness (0–100)", value: "", options: ["10", "25", "50", "75", "100"] }],
            submit: values => {
                const level = parseInt(values.level);
                if (!(level >= 0 && level <= 100)) {
                    host.notify("Brightness takes a number from 0 to 100");
                    return false;
                }
                setBrightness(level);
                return true;
            }
        });
        return false;
    }

    Source {
        id: rfkill
        maxAge: 1000
        command: ["rfkill", "-J", "-o", "TYPE,SOFT,HARD"]
        parse: output => {
            const state = {};
            for (const device of output.trim() ? JSON.parse(output).rfkilldevices : [])
                state[device.type] = !!state[device.type] || device.soft === "unblocked" && device.hard === "unblocked";
            return state;
        }
    }

    Source {
        id: backlight
        maxAge: 1000
        command: ["brightnessctl", "-m"]
        parse: output => output.trim() ? [output.split(",")[3]] : []
    }
}
