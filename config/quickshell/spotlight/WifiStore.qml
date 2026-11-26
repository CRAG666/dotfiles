import Quickshell
import QtQuick
import qs

// Wi-Fi networks in range, through iwd (the helper's wifi): the connected one
// first, then the strongest. Opening the view scans; Enter connects (asking
// the password of a new secured network, or again of a saved one that fails)
// or disconnects, Ctrl+X forgets a saved network. A hidden network connects by
// its name.
Scope {
    id: root
    property var host

    // what is known now, then again once the scan is over (wifi-scan waits for it)
    function load() {
        networks.reload();
        Spot.call(["wifi-scan"], (output, error) => {
            if (error)
                Quickshell.execDetached(["notify-send", "-u", "critical", "-i", "network-wireless", "Wi-Fi", error]);
            networks.reload();
        });
    }

    function items(tokens) {
        return networks.items
            .filter(network => Spot.matches(network.name, tokens))
            .map(network => ({ key: "wifi:" + network.name, kind: "wifi", store: root, network, title: network.name.trim(), hint: network.connected ? "Connected" : `${network.known ? "Saved" : network.security} · ${network.signal}%`, icon: "network-wireless" }));
    }

    function commandItems(tokens) {
        return [
            ...(Spot.matches("scan wifi networks refresh", tokens) ? [{ key: "wifi-scan", kind: "wifiScan", store: root, title: "Scan for Networks", icon: "view-refresh" }] : []),
            ...(Spot.matches("connect hidden wifi network ssid", tokens) ? [{ key: "wifi-hidden", kind: "wifiHidden", store: root, title: "Connect to a Hidden Network", icon: "network-wireless" }] : [])
        ];
    }

    function describe(item) {
        if (item.kind === "wifiScan")
            return { icon: item.icon, title: item.title, actions: [["Enter", "Scan"]] };
        if (item.kind === "wifiHidden")
            return { icon: item.icon, title: item.title, actions: [["Enter", "Connect"]] };
        const network = item.network;
        return { icon: item.icon, title: item.title, metadata: [["Security", network.security], ["Signal", network.signal + "%"], ["Saved", network.known ? "Yes" : "No"], ...network.details], actions: [["Enter", network.connected ? "Disconnect" : "Connect"], ...(network.known ? [["Ctrl+X", "Forget"]] : [])] };
    }

    // the helper's command, then a notification of how it went, or `retry`
    // with the error; the list loads again once iwctl is done, not before
    function run(args, done, retry) {
        Spot.call(args, (output, error) => {
            networks.reload();
            if (error && retry)
                retry(error);
            else
                Quickshell.execDetached(error ? ["notify-send", "-u", "critical", "-i", "network-wireless", "Wi-Fi", error] : ["notify-send", "-t", "3000", "-i", "network-wireless", "Wi-Fi", done]);
        });
    }

    function askPassword(name) {
        host.openForm({
            title: "Connect to " + name.trim(),
            fields: [{ key: "password", label: "Password", value: "", secret: true }],
            submit: values => {
                run(["wifi-connect", name, values.password], "Connected to " + name.trim());
                return true;
            }
        });
    }

    // a saved WPA network that fails (its password changed) opens Spotlight
    // again on its password, which iwd keeps once it works
    function retryPassword(name, error) {
        host.open("wifi");
        host.notify(error);
        askPassword(name);
    }

    function activate(item, keys) {
        if (item.kind === "wifiScan") {
            load();
            return false;
        }
        if (item.kind === "wifiHidden") {
            host.openForm({
                title: item.title,
                fields: [{ key: "name", label: "Network name", value: "" }, { key: "password", label: "Password", value: "", secret: true, optional: true }],
                submit: values => {
                    run(["wifi-connect-hidden", values.name, values.password], "Connected to " + values.name.trim());
                    return true;
                }
            });
            return false;
        }
        const network = item.network;
        const name = network.name;
        if (network.connected) {
            run(["wifi-disconnect"], "Disconnected from " + name.trim());
            return true;
        }
        if (network.known || network.security === "Open") {
            run(["wifi-connect", name], "Connected to " + name.trim(), network.known && network.security === "WPA" ? error => retryPassword(name, error) : null);
            return true;
        }
        askPassword(name);
        return false;
    }

    function act(item, action) {
        if (item.kind !== "wifi" || action !== "delete" || !item.network.known)
            return false;
        run(["wifi-forget", item.network.name], "Forgot " + item.network.name.trim());
        return false;
    }

    function copy(item) {
        Spot.copy(item.title);
    }

    Source {
        id: networks
        request: ["wifi"]
        // the connected one first, once a scan; the rest stay strongest first
        parse: output => output.trim() ? JSON.parse(output).sort((a, b) => b.connected - a.connected) : []
    }
}
