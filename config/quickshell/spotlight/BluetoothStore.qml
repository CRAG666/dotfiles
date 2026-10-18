import Quickshell
import Quickshell.Bluetooth
import QtQuick
import qs

// Bluetooth devices (bluez, through Quickshell): connected first, then paired,
// then those in range, which the adapter looks for while the view is open.
// Enter connects or disconnects; a new device is paired, trusted and connected.
// Ctrl+X forgets a paired device. bluez pairs without an agent, so a device
// that asks for a PIN needs the Tools' Bluetooth (bluetui).
Scope {
    id: root
    property var host
    readonly property var adapter: Bluetooth.defaultAdapter
    property var pairing: null   // the device being paired, connected once paired

    function rank(device) {
        return device.connected ? 0 : device.paired ? 1 : 2;
    }

    function status(device) {
        if (device.pairing)
            return "Pairing…";
        if (device.state === BluetoothDeviceState.Connecting)
            return "Connecting…";
        if (device.state === BluetoothDeviceState.Disconnecting)
            return "Disconnecting…";
        if (device.connected)
            return device.batteryAvailable ? `Connected · ${Math.round(device.battery * 100)}%` : "Connected";
        return device.paired ? "Paired" : "Available";
    }

    // unnamed devices in range only show their address
    function items(tokens) {
        return Bluetooth.devices.values
            .filter(device => device.deviceName && Spot.matches(device.name, tokens))
            .sort((a, b) => rank(a) - rank(b))
            .map(device => ({ key: "bluetooth:" + device.address, kind: "bluetoothDevice", store: root, device, title: device.name, hint: status(device), icon: device.icon || "bluetooth" }));
    }

    function describe(item) {
        const device = item.device;
        return { icon: item.icon, title: item.title, metadata: [["Address", device.address], ["Status", status(device)]], actions: [["Enter", device.connected ? "Disconnect" : device.paired ? "Connect" : "Pair and connect"], ...(device.paired ? [["Ctrl+X", "Forget"]] : [])] };
    }

    function activate(item, keys) {
        const device = item.device;
        if (device.connected) {
            device.disconnect();
        } else if (device.paired) {
            device.connect();
        } else {
            pairing = device;
            device.pair();
        }
        return false;
    }

    function act(item, action) {
        if (action !== "delete" || !item.device.paired)
            return false;
        item.device.forget();
        return false;
    }

    function copy(item) {
        Spot.copy(item.device.address);
    }

    // looks for devices only while the view is shown
    Binding {
        target: root.adapter
        property: "discovering"
        value: root.host.shown && root.host.mode === "bluetooth"
        when: !!root.adapter && root.adapter.enabled
        restoreMode: Binding.RestoreNone
    }

    Connections {
        target: root.pairing
        function onPairedChanged() {
            if (!root.pairing.paired)
                return;
            root.pairing.trusted = true;
            root.pairing.connect();
            root.pairing = null;
        }
    }
}
