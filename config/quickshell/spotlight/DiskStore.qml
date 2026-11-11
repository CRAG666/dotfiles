import Quickshell
import QtQuick
import qs

// The volumes of external drives (udisks2, through the helper's disks): USB
// sticks, external disks and cards, the mounted ones first. Enter mounts a
// volume or opens a mounted one; a locked LUKS volume asks its passphrase.
// Ctrl+Enter unmounts a volume, or locks an unlocked LUKS volume that is not
// mounted. Ctrl+X ejects the drive: unmounts and locks every volume on it and
// powers it off, so it can be unplugged. The list follows plugging and
// unplugging while the view is open.
Scope {
    id: root
    property var host

    function load() {
        volumes.reload();
    }

    function rank(volume) {
        return volume.mountpoint ? 0 : volume.locked ? 2 : 1;
    }

    function status(volume) {
        return volume.mountpoint ? "Mounted at " + volume.mountpoint : volume.locked ? "Locked" : "Not mounted";
    }

    function filesystem(volume) {
        return `${Spot.formatSize(volume.size)} ${volume.type === "crypto_LUKS" ? "LUKS" : volume.type}`;
    }

    function icon(volume) {
        if (volume.media.startsWith("flash"))
            return "media-flash";
        if (volume.media.startsWith("optical"))
            return "media-optical";
        return volume.media === "disk" ? "drive-harddisk" : "drive-removable-media";
    }

    function items(tokens) {
        return volumes.items
            .filter(volume => Spot.matches(`${volume.label} ${volume.drive} ${volume.device}`, tokens))
            .sort((a, b) => rank(a) - rank(b))
            .map(volume => ({ key: "disk:" + volume.device, kind: "disk", store: root, volume, title: volume.label || volume.drive || Spot.basename(volume.device), hint: `${status(volume)} · ${filesystem(volume)}`, icon: icon(volume) }));
    }

    function describe(item) {
        const volume = item.volume;
        const own = volume.mountpoint ? [["Enter", "Open"], ["Ctrl+Enter", "Unmount"]] : volume.locked ? [["Enter", "Unlock and mount"]] : [["Enter", "Mount"], ...(volume.backing ? [["Ctrl+Enter", "Lock"]] : [])];
        return { icon: item.icon, title: item.title, metadata: [["Device", volume.device], ["Drive", volume.drive], ["Status", status(volume)], ["Filesystem", filesystem(volume)]], actions: [...own, ["Ctrl+X", "Eject drive"]] };
    }

    // the helper's command, then a notification of how it went (`done` words it
    // from the helper's answer); the list loads again once udisks is done
    function run(args, done) {
        Spot.call(args, (output, error) => {
            Quickshell.execDetached(error ? ["notify-send", "-u", "critical", "-i", "drive-removable-media", "Disks", error] : ["notify-send", "-t", "3000", "-i", "drive-removable-media", "Disks", done(output)]);
            volumes.reload();
        });
    }

    function activate(item, keys) {
        const volume = item.volume;
        if (keys.ctrl) {
            if (volume.mountpoint)
                run(["disk-unmount", volume.path], () => "Unmounted " + item.title);
            else if (volume.backing)
                run(["disk-lock", volume.backing], () => "Locked " + item.title);
            return false;
        }
        if (volume.mountpoint) {
            Spot.open(volume.mountpoint);
            return true;
        }
        if (volume.locked) {
            host.openForm({
                title: "Unlock " + item.title,
                fields: [{ key: "passphrase", label: "Passphrase", value: "", secret: true }],
                submit: values => {
                    run(["disk-unlock", volume.path, values.passphrase], output => "Mounted at " + JSON.parse(output));
                    return false;
                }
            });
            return false;
        }
        run(["disk-mount", volume.path], output => "Mounted at " + JSON.parse(output));
        return false;
    }

    function act(item, action) {
        if (action !== "delete")
            return false;
        run(["disk-eject", item.volume.path], () => item.title + " can be unplugged");
        return false;
    }

    function copy(item) {
        Spot.copy(item.volume.mountpoint || item.volume.device);
    }

    Source {
        id: volumes
        request: ["disks"]
    }

    Timer {
        running: root.host.shown && root.host.mode === "disks"
        interval: 2000
        repeat: true
        onTriggered: volumes.reload()
    }
}
