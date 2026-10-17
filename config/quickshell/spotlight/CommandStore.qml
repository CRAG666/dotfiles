import Quickshell
import Quickshell.Services.Mpris
import QtQuick
import qs

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
        { title: "Edit Snippets, Quicklinks and AI Commands", icon: "accessories-text-editor", command: ["ghostty", "+new-window", "-e", "sh", "-c", '"${EDITOR:-nvim}" "$1"', "sh", configDir + "/spotlight/spotlight.json"] },
        { title: "Close Window", icon: "window-close", command: ["scrollmsg", "kill"] },
        { title: "Toggle Fullscreen", icon: "view-fullscreen", command: ["scrollmsg", "fullscreen", "toggle"] },
        { title: "Toggle Floating", icon: "window-new", command: ["scrollmsg", "floating", "toggle"] },
        ...[["1/3", "0.33333333"], ["1/2", "0.5"], ["2/3", "0.66666667"], ["Full", "1.0"]].map(([name, fraction]) => ({ title: `Window Width ${name}`, icon: "view-dual", command: ["scrollmsg", "set_size", "h", fraction] })),
        { title: "Center Column", icon: "format-justify-center", command: ["scrollmsg", "align", "center"] },
        { title: "Center Window", icon: "format-justify-center", command: ["scrollmsg", "align", "middle"] },
        { title: "Reset Column Alignment", icon: "format-justify-fill", command: ["scrollmsg", "align", "reset"] },
        { title: "Fit Visible Columns", icon: "zoom-fit-best", command: ["scrollmsg", "fit_size", "h", "visible", "proportional"] },
        { title: "Fit All Columns Equally", icon: "zoom-fit-best", command: ["scrollmsg", "fit_size", "h", "all", "equal"] },
        { title: "Pin Column Left", icon: "window-pin", command: ["scrollmsg", "pin", "beginning"] },
        { title: "Pin Column Right", icon: "window-pin", command: ["scrollmsg", "pin", "end"] },
        { title: "Workspace Overview", icon: "view-grid", command: ["scrollmsg", "scale_workspace", "overview"] },
        { title: "All Workspaces Overview", icon: "view-grid", command: ["scrollmsg", "scale_workspaces", "toggle"] },
        { title: "Jump to Window", icon: "go-jump", command: ["scrollmsg", "jump"] },
        { title: "Transpose Layout", icon: "object-rotate-right", command: ["scrollmsg", "layout_transpose"] },
        { title: "Move Window to Scratchpad", icon: "go-down", command: ["scrollmsg", "move", "scratchpad"] },
        { title: "Show Scratchpad", icon: "go-up", command: ["scrollmsg", "scratchpad", "show"] },
        ...["Left", "Right"].map(side => ({ title: `Move Window to ${side} Monitor`, icon: "video-display", command: ["scrollmsg", "move", "container", "to", "output", side.toLowerCase()] })),
        ...["Left", "Right"].map(side => ({ title: `Move Workspace to ${side} Monitor`, icon: "video-display", command: ["scrollmsg", "move", "workspace", "to", "output", side.toLowerCase()] })),
        ...Array.from({ length: 9 }, (_, index) => ({ title: `Move Window to Workspace ${index + 1}`, icon: "go-next", command: ["scrollmsg", "move", "container", "to", "workspace", String(index + 1)] }))
    ]

    readonly property var tools: [
        { title: "Email", program: "aerc", command: ["ghostty", "+new-window", "--title=aerc", "-e", "aerc"] },
        { title: "Bluetooth", program: "bluetui", icon: "bluetooth", command: ["ghostty", "--class=ghostty.dialog", "--title=bluetui", "-e", "bluetui"] },
        { title: "Wi-Fi", program: "impala", icon: "network-wireless", command: ["ghostty", "--class=ghostty.dialog", "--title=impala", "-e", "impala"] },
        { title: "Files", program: "yazi", icon: "system-file-manager", command: ["ghostty", "--class=ghostty.dialog", "--title=yazi", "-e", "yazi"] },
        { title: "Calendar", program: "cal", icon: "office-calendar", command: ["ghostty", "--class=ghostty.dialog", "--title=calendar", "--wait-after-command=true", "-e", "cal", "-3", "-m"] },
        { title: "Music", program: "termusic", command: ["ghostty", "+new-window", "--title=termusic", "-e", "termusic"] },
        { title: "Volume Mixer", program: "wiremix", icon: "audio-volume-high", command: ["ghostty", "--class=ghostty.dialog", "--title=wiremix", "-e", "wiremix"] }
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
            return { icon: item.icon, glyph: item.glyph, title: item.title, subtitle: view.placeholder ?? view.title, metadata: [["Alias", item.hint ? item.hint + "␣" : ""]], actions: [["Enter", "Open view"]] };
        }
        case "media":
            return { image: player?.trackArtUrl ?? "", icon: item.icon, title: player?.trackTitle || item.title, subtitle: player?.trackArtist ?? "", metadata: [["Player", player?.identity ?? ""]], actions: [["Enter", item.title]] };
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
