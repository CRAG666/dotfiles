import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

// Quick system toggles: Wi-Fi and Bluetooth (rfkill), the default audio output
// and input, muting the microphone (PipeWire, through osd/vol so the mic-mute
// LED follows) and the brightness of the laptop and external screens
// (brightness.sh), and the output volume. "brightness 40" or "volume 40" sets
// 40% at once; "Set Brightness" or "Set Volume" asks.
Scope {
    id: root
    property var host
    readonly property string brightnessScript: Spot.home + "/.config/scroll/brightness.sh"
    readonly property var radios: [
        { type: "wlan", title: "Wi-Fi", words: "wifi wireless network internet", icon: "network-wireless-secure-signal-excellent" },
        { type: "bluetooth", title: "Bluetooth", words: "bt", icon: "bluetooth" }
    ]
    readonly property var sinks: Pipewire.nodes.values.filter(node => node.isSink && !node.isStream && node.audio)
    readonly property var sources: Pipewire.nodes.values.filter(node => !node.isSink && !node.isStream && node.audio)
    readonly property string volScript: Spot.home + "/.config/quickshell/osd/vol"
    readonly property var levels: [
        { name: "Brightness", words: "set brightness screen display backlight", icon: "brightnesssettings", now: () => backlight.items.length ? backlight.items[0] : "", set: level => setBrightness(level) },
        { name: "Volume", words: "set volume sound audio output speakers", icon: "audio-volume-high", now: () => Pipewire.defaultAudioSink?.audio ? Math.round(Pipewire.defaultAudioSink.audio.volume * 100) + "%" : "", set: level => setVolume(level) }
    ]

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
        const sourceItems = sources
            .filter(node => Spot.matches(`audio input microphone mic ${node.description}`, tokens))
            .map(node => ({ key: "source:" + node.name, kind: "source", store: root, node, title: "Audio Input: " + (node.nickname || node.description), hint: node === Pipewire.defaultAudioSource ? "Current" : "", icon: "audio-input-microphone" }));
        const muteItems = [
            { node: Pipewire.defaultAudioSink, name: "Audio Output", words: "mute unmute sound audio output volume speakers", volArg: "mute", icons: ["audio-volume-muted", "audio-volume-high"] },
            { node: Pipewire.defaultAudioSource, name: "Microphone", words: "mute unmute microphone mic", volArg: "mic", icons: ["mic-off", "audio-input-microphone"] }
        ]
            .filter(device => device.node?.audio && Spot.matches(device.words, tokens))
            .map(device => {
                const muted = device.node.audio.muted;
                return { key: "mute:" + device.volArg, kind: "mute", store: root, device, title: `${muted ? "Unmute" : "Mute"} ${device.name}`, hint: muted ? "Muted" : "On", icon: device.icons[muted ? 0 : 1] };
            });
        return radioItems.concat(muteItems, sinkItems, sourceItems, levelItems(tokens));
    }

    function levelItems(tokens) {
        const isLevel = token => /^\d{1,3}%?$/.test(token) && parseInt(token) <= 100;
        const words = tokens.filter(token => !isLevel(token));
        const level = tokens.find(isLevel);
        // a bare number is no setting
        if (level !== undefined && !words.length)
            return [];
        return levels.filter(setting => Spot.matches(setting.words, words)).map(setting => {
            const item = { key: setting.name.toLowerCase(), kind: "level", store: root, setting, title: `Set ${setting.name}`, hint: setting.now(), icon: setting.icon };
            return level === undefined ? item : Object.assign(item, { key: `${item.key}:${parseInt(level)}`, level: parseInt(level), title: `Set ${setting.name} to ${parseInt(level)}%` });
        });
    }

    // unmutes the output too: setting a volume means wanting to hear it
    function setVolume(level) {
        Quickshell.execDetached(["sh", "-c", 'wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ "$1%"', "sh", String(level)]);
    }

    function setBrightness(level) {
        Quickshell.execDetached([brightnessScript, "init", String(level)]);
    }

    function describe(item) {
        switch (item.kind) {
        case "radio":
            return { icon: item.icon, title: item.radio.title, subtitle: item.on ? "On" : "Off", actions: [["Enter", item.title]] };
        case "sink":
            return { icon: item.icon, title: item.node.nickname || item.node.description, subtitle: item.hint ? "Current output" : "Audio Output", metadata: [["Device", item.node.name]], actions: [["Enter", "Use this output"]] };
        case "source":
            return { icon: item.icon, title: item.node.nickname || item.node.description, subtitle: item.hint ? "Current input" : "Audio Input", metadata: [["Device", item.node.name]], actions: [["Enter", "Use this input"]] };
        case "mute":
            return { icon: item.icon, title: item.title, subtitle: `${item.device.name} ${item.hint.toLowerCase()}`, metadata: [["Device", item.device.node.nickname || item.device.node.description]], actions: [["Enter", item.title]] };
        default:
            return { icon: item.icon, title: item.title, subtitle: item.hint ? "Now " + item.hint : item.setting.name, actions: [["Enter", item.level === undefined ? "Choose a level" : "Set"]] };
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
        case "source":
            Pipewire.preferredDefaultAudioSource = item.node;
            // the mic-mute LED shows the new input's state once PipeWire switched
            Quickshell.execDetached(["sh", "-c", 'sleep 0.5; "$1" mic-led', "sh", volScript]);
            return true;
        case "mute":
            Quickshell.execDetached([volScript, item.device.volArg]);
            return true;
        }
        if (item.level !== undefined) {
            item.setting.set(item.level);
            return true;
        }
        host.openForm({
            title: item.setting.name,
            fields: [{ key: "level", label: `${item.setting.name} (0–100)`, value: "", options: ["10", "25", "50", "75", "100"] }],
            submit: values => {
                const level = parseInt(values.level);
                if (!(level >= 0 && level <= 100)) {
                    host.notify(`${item.setting.name} takes a number from 0 to 100`);
                    return false;
                }
                item.setting.set(level);
                return true;
            }
        });
        return false;
    }

    // volume and muted are only kept up to date for tracked nodes
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource]
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
        command: ["brightnessctl", "-m", "-c", "backlight"]
        parse: output => output.trim() ? [output.split(",")[3]] : []
    }
}
