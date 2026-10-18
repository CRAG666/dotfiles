import Quickshell
import Quickshell.Io
import QtQuick

// SSH hosts: ~/.ssh/config (git-only hosts skipped) merged with your Tailscale
// peers, with their online state. Enter connects with ssh in the terminal.
Scope {
    id: root
    property var host
    property var hosts: []

    function load() {
        tailnet.load();
    }

    function parseConfig(text) {
        const found = [];
        let block = [];
        for (const line of text.split("\n")) {
            const [keyword, ...rest] = line.trim().split(/\s+/);
            const value = rest.join(" ");
            switch (keyword.toLowerCase()) {
            case "host":
                block = rest.filter(name => !/[*?!]/.test(name)).map(name => ({ name, hostName: "", user: "" }));
                found.push(...block);
                break;
            case "match":
                block = [];
                break;
            case "hostname":
                block.forEach(host => host.hostName = value);
                break;
            case "user":
                block.forEach(host => host.user = value);
                break;
            }
        }
        return found;
    }

    function items(tokens) {
        const peers = tailnet.items;
        // the first peer with an address or a name, by its index, so joining hosts
        // to peers scans neither list
        const byAddress = Object.create(null);
        const byName = Object.create(null);
        peers.forEach((peer, index) => {
            for (const address of [peer.ip, peer.dns])
                if (!(address in byAddress))
                    byAddress[address] = index;
            if (!(peer.name.toLowerCase() in byName))
                byName[peer.name.toLowerCase()] = index;
        });
        const joined = Object.create(null);
        // git remotes and the AUR take ssh but give no shell
        const merged = hosts.filter(host => host.user !== "git" && (host.hostName || host.name) !== "aur.archlinux.org").map(host => {
            const index = Math.min(byAddress[host.hostName] ?? Infinity, byName[host.name.toLowerCase()] ?? Infinity);
            if (index < peers.length)
                joined[index] = true;
            return {
                name: host.name,
                target: host.name,
                address: (host.user ? host.user + "@" : "") + (host.hostName || host.name),
                peer: peers[index]
            };
        });
        peers.forEach((peer, index) => {
            if (!(index in joined))
                merged.push({ name: peer.name, target: peer.dns, address: peer.dns, peer });
        });
        return merged
            .filter(host => Spot.matches("ssh " + host.name + " " + host.address, tokens))
            .map(host => ({ key: "ssh:" + host.name, kind: "ssh", store: root, host, title: host.name, hint: host.peer ? (host.peer.online ? "online" : "offline") : host.address, icon: "utilities-terminal", value: host.target }));
    }

    function describe(item) {
        return { icon: item.icon, title: item.title, subtitle: item.host.address, metadata: item.host.peer ? [["Tailscale", item.host.peer.online ? "Online" : "Offline"], ["OS", item.host.peer.os]] : [], actions: [["Enter", "Connect with ssh"], ["Ctrl+C", "Copy host"]] };
    }

    function activate(item, keys) {
        Quickshell.execDetached([...host.userConfig.terminal, "env", "TERM=xterm-256color", "ssh", item.value]);
        return true;
    }

    FileView {
        path: Spot.home + "/.ssh/config"
        blockLoading: true
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: root.hosts = root.parseConfig(text())
    }

    Source {
        id: tailnet
        maxAge: 60000
        command: ["tailscale", "status", "--json"]
        parse: output => output.trim() ? Object.values(JSON.parse(output).Peer ?? {}).map(peer => ({ name: peer.HostName, dns: peer.DNSName.replace(/\.$/, ""), ip: peer.TailscaleIPs[0], os: peer.OS, online: peer.Online })) : []
    }
}
