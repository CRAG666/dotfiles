import Quickshell
import QtQuick
import qs

// Wi-Fi networks in range, through iwd (the helper's wifi): the connected one
// first, then the strongest. Opening the view scans; Enter connects (asking
// the password of a new secured network) or disconnects, Ctrl+X forgets a
// saved network.
Scope {
    id: root
    property var host

    function load() {
        Spot.helperDetached(["wifi-scan"]);
        networks.reload();
        rescanned.restart();
    }

    function items(tokens) {
        return networks.items
            .filter(network => Spot.matches(network.name, tokens))
            .sort((a, b) => b.connected - a.connected)
            .map(network => ({ key: "wifi:" + network.name, kind: "wifi", store: root, network, title: network.name.trim(), hint: network.connected ? "Connected" : `${network.known ? "Saved" : network.security} · ${network.signal}%`, icon: "network-wireless" }));
    }

    function commandItems(tokens) {
        return Spot.matches("scan wifi networks refresh", tokens) ? [{ key: "wifi-scan", kind: "wifiScan", store: root, title: "Scan for Networks", icon: "view-refresh" }] : [];
    }

    function describe(item) {
        if (item.kind === "wifiScan")
            return { icon: item.icon, title: item.title, actions: [["Enter", "Scan"]] };
        const network = item.network;
        return { icon: item.icon, title: item.title, metadata: [["Security", network.security], ["Signal", network.signal + "%"], ["Saved", network.known ? "Yes" : "No"]], actions: [["Enter", network.connected ? "Disconnect" : "Connect"], ...(network.known ? [["Ctrl+X", "Forget"]] : [])] };
    }

    // the helper's command, then a notification of how it went
    function run(args, done) {
        Quickshell.execDetached(["sh", "-c", 'done=$1; shift; if out=$(python3 "$@" 2>&1); then notify-send -t 3000 -i network-wireless Wi-Fi "$done"; else notify-send -u critical -i network-wireless Wi-Fi "$out"; fi', "sh", done, Spot.helper, ...args]);
    }

    function activate(item, keys) {
        if (item.kind === "wifiScan") {
            load();
            return false;
        }
        const network = item.network;
        const name = network.name;
        if (network.connected) {
            run(["wifi-disconnect"], "Disconnected from " + name.trim());
            return true;
        }
        if (network.known || network.security === "Open") {
            run(["wifi-connect", name], "Connected to " + name.trim());
            return true;
        }
        host.openForm({
            title: "Connect to " + name.trim(),
            fields: [{ key: "password", label: "Password", value: "", secret: true }],
            submit: values => {
                run(["wifi-connect", name, values.password], "Connected to " + name.trim());
                return true;
            }
        });
        return false;
    }

    function act(item, action) {
        if (item.kind !== "wifi" || action !== "delete" || !item.network.known)
            return false;
        run(["wifi-forget", item.network.name], "Forgot " + item.network.name.trim());
        networks.reload();
        return false;
    }

    function copy(item) {
        Spot.copy(item.title);
    }

    Source {
        id: networks
        command: ["python3", Spot.helper, "wifi"]
    }

    // a scan takes a few seconds; list again once it is done
    Timer {
        id: rescanned
        interval: 4000
        onTriggered: networks.reload()
    }
}
