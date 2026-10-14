import Quickshell
import Quickshell.Services.Mpris
import QtQuick

// Commands: power, dark mode, wallpaper, caffeine, screenshots and window
// management; the terminal tools (XF86Tools opens them as the "tools" view);
// play / pause / next for the active player; and an entry per view with its
// alias. Commands marked `confirm` need a second Enter.
Scope {
    id: root
    property var host
    readonly property string configDir: Spot.home + "/.config/quickshell"

    readonly property var commands: [
        { title: "Lock Screen", icon: "system-lock-screen", command: [configDir + "/lock.sh"] },
        { title: "Sleep", icon: "system-suspend", command: ["systemctl", "suspend"] },
        { title: "Hibernate", icon: "system-hibernate", command: ["systemctl", "hibernate"], confirm: true },
        { title: "Restart", icon: "system-reboot", command: ["systemctl", "reboot"], confirm: true },
        { title: "Shut Down", icon: "system-shutdown", command: ["systemctl", "poweroff"], confirm: true },
        { title: "Log Out", icon: "system-log-out", command: ["scrollmsg", "exit"], confirm: true },
        { title: "Toggle Dark Mode", icon: "weather-clear-night", command: ["eyes-theme", "toggle"] },
        { title: "Next Wallpaper", icon: "preferences-desktop-wallpaper", command: [Spot.home + "/.config/awww/awwwallpaper.sh", "-n"] },
        { title: "Toggle Caffeine", icon: "caffeine", command: ["sh", "-c", 'if pkill swayidle; then notify-send -t 2000 "Caffeine on"; else swayidle -w & notify-send -t 2000 "Caffeine off"; fi'] },
        { title: "Screenshot Area", icon: "applets-screenshooter", command: ["sh", "-c", 'sleep 0.3; grim -g "$(slurp -d)" - | swappy -f -'] },
        { title: "Screenshot Screen", icon: "applets-screenshooter", command: ["sh", "-c", 'sleep 0.3; grim -o "$(scrollmsg -t get_outputs | jq -r ".[] | select(.focused) | .name")" - | swappy -f -'] },
        { title: "Empty Trash", icon: "user-trash-full", command: ["gio", "trash", "--empty"], confirm: true },
        { title: "Edit Snippets, Quicklinks and AI Commands", icon: "accessories-text-editor", command: ["kitty", "-1", "-e", "sh", "-c", '"${EDITOR:-nvim}" "$1"', "sh", configDir + "/spotlight.json"] },
        { title: "Close Window", icon: "window-close", command: ["scrollmsg", "kill"] },
        { title: "Toggle Fullscreen", icon: "view-fullscreen", command: ["scrollmsg", "fullscreen", "toggle"] },
        { title: "Toggle Floating", icon: "window-new", command: ["scrollmsg", "floating", "toggle"] },
        ...Array.from({ length: 9 }, (_, index) => ({ title: `Move Window to Workspace ${index + 1}`, icon: "go-next", command: ["scrollmsg", "move", "container", "to", "workspace", String(index + 1)] }))
    ]

    readonly property var tools: [
        { title: "Email", program: "aerc", command: ["kitty", "-T", "aerc", "aerc"] },
        { title: "Bluetooth", program: "bluetui", icon: "bluetooth", command: ["kitty", "--class", "dialog", "-T", "bluetui", "bluetui"] },
        { title: "Wi-Fi", program: "impala", icon: "network-wireless", command: ["kitty", "--class", "dialog", "-T", "impala", "impala"] },
        { title: "Files", program: "yazi", icon: "system-file-manager", command: ["kitty", "--class", "dialog", "-T", "yazi", "yazi"] },
        { title: "Calendar", program: "cal", icon: "office-calendar", command: ["kitty", "--class", "dialog", "-T", "calendar", "--hold", "cal", "-3", "-m"] },
        { title: "Music", program: "termusic", command: ["kitty", "-T", "termusic", "termusic"] },
        { title: "Volume Mixer", program: "wiremix", icon: "audio-volume-high", command: ["kitty", "--class", "dialog", "-T", "wiremix", "wiremix"] }
    ]

    readonly property MprisPlayer player: {
        const players = Mpris.players.values;
        return players.find(candidate => candidate.isPlaying) ?? players[0] ?? null;
    }

    function items(tokens) {
        return commands
            .filter(command => Spot.matches(command.title, tokens))
            .map(command => ({ key: "cmd:" + command.title, kind: "command", store: root, title: command.title, icon: command.icon, command: command.command, confirm: command.confirm ?? false }));
    }

    function viewItem(view) {
        return { key: "mode:" + view.mode, kind: "mode", store: root, mode: view.mode, title: view.title, hint: view.alias ?? "", icon: view.icon, glyph: view.glyph };
    }

    function viewItems(tokens) {
        return host.views.filter(view => Spot.matches(`${view.title} ${view.alias ?? ""}`, tokens)).map(viewItem);
    }

    function toolItems(tokens) {
        return tools
            .filter(tool => Spot.matches(`${tool.title} ${tool.program}`, tokens))
            .map(tool => ({ key: "tool:" + tool.title, kind: "command", store: root, title: tool.title, hint: tool.program, icon: tool.icon ?? Spot.iconFor(tool.program), command: tool.command }));
    }

    function mediaItems(tokens) {
        if (!player)
            return [];
        return [[player.isPlaying ? "Pause" : "Play", "toggle"], ["Next Track", "next"], ["Previous Track", "previous"]]
            .filter(([title]) => Spot.matches(title + " media music " + player.identity, tokens))
            .map(([title, action]) => ({ key: "media:" + action, kind: "media", store: root, title, hint: player.identity, icon: "multimedia-player", action }));
    }

    function describe(item) {
        switch (item.kind) {
        case "mode": {
            const view = host.views.find(entry => entry.mode === item.mode);
            return { icon: item.icon, glyph: item.glyph, title: item.title, subtitle: view.placeholder ?? view.title, details: [item.hint ? `Alias: type “${item.hint}” and a space` : ""], actions: [["Enter", "Open view"]] };
        }
        case "media":
            return { image: player?.trackArtUrl ?? "", icon: item.icon, title: player?.trackTitle || item.title, subtitle: player?.trackArtist ?? "", details: [player?.identity ?? ""], actions: [["Enter", item.title]] };
        default:
            return { icon: item.icon, title: item.title, subtitle: "Command", actions: [["Enter", "Run"]] };
        }
    }

    function activate(item, keys) {
        switch (item.kind) {
        case "mode":
            host.openView(item.mode);
            return false;
        case "media":
            if (item.action === "toggle")
                player.togglePlaying();
            else if (item.action === "next")
                player.next();
            else
                player.previous();
            return true;
        default:
            Quickshell.execDetached(item.command);
            return true;
        }
    }
}
