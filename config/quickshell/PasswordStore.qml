import Quickshell
import QtQuick

// pass entries, listed by name and decrypted only when used: Enter copies the
// password for 30 s, Ctrl+Enter types it into the focused window.
Scope {
    id: root

    // the password only ever lives in shell variables and pipes, never in argv
    readonly property string passCopy: `
pw=$(pass show -- "$1") || { notify-send -u critical "pass" "Could not decrypt $1"; exit 1; }
pw=$(printf '%s\\n' "$pw" | head -n1)
printf %s "$pw" | wl-copy --sensitive
notify-send -i passwordsafe "Password copied for 30 seconds"
sleep 30
[ "$(wl-paste -n 2>/dev/null)" = "$pw" ] && wl-copy --clear && notify-send -i passwordsafe "Password cleared from the clipboard"`
    readonly property string passType: `
pw=$(pass show -- "$1") || { notify-send -u critical "pass" "Could not decrypt $1"; exit 1; }
sleep 0.3
printf '%s\\n' "$pw" | head -n1 | tr -d '\\n' | wtype -`

    function load() {
        entries.load();
    }

    function items(tokens) {
        return entries.items
            .filter(entry => Spot.matches(entry, tokens))
            .map(entry => ({ key: "pass:" + entry, kind: "password", store: root, title: entry.slice(entry.lastIndexOf("/") + 1), hint: entry.includes("/") ? entry.slice(0, entry.lastIndexOf("/")) : "", icon: "dialog-password", value: entry }));
    }

    function describe(item) {
        return { icon: item.icon, title: item.title, subtitle: item.value, details: ["Stored in pass, decrypted only when used"], actions: [["Enter", "Copy password for 30 s"], ["Ctrl+Enter", "Type password"]] };
    }

    function activate(item, keys) {
        Quickshell.execDetached(["sh", "-c", keys.ctrl ? passType : passCopy, "sh", item.value]);
        return true;
    }

    function copy(item) {
        Quickshell.execDetached(["sh", "-c", passCopy, "sh", item.value]);
    }

    Source {
        id: entries
        maxAge: 300000
        command: ["sh", "-c", 'cd "${PASSWORD_STORE_DIR:-$HOME/.password-store}" && find . -name "*.gpg" -printf "%P\\n"']
        parse: output => output.split("\n").filter(line => line).map(line => line.slice(0, -4)).sort()
    }
}
