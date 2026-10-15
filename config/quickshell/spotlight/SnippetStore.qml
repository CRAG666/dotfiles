import Quickshell
import QtQuick

// Text typed into the focused window: snippets from spotlight.json, with
// {date}, {time}, {weekday}, {clipboard} and {cursor} placeholders, and emoji
// (every named codepoint the colour emoji font can draw, listed on first use).
Scope {
    id: root
    property var host

    function load() {
        emoji.load();
    }

    function expand(text) {
        const now = new Date();
        return text
            .replace(/\{date\}/g, Qt.formatDate(now, "yyyy-MM-dd"))
            .replace(/\{time\}/g, Qt.formatTime(now, "HH:mm"))
            .replace(/\{weekday\}/g, now.toLocaleDateString(Qt.locale(), "dddd"))
            .replace(/\{clipboard\}/g, () => host.clipboardText);
    }

    function snippetItems(tokens) {
        return host.userConfig.snippets
            .filter(snippet => Spot.matches(snippet.name + " " + snippet.keyword + " " + snippet.text, tokens))
            .map(snippet => ({ key: "snippet:" + snippet.name, kind: "snippet", store: root, snippet, title: snippet.name, hint: snippet.keyword, icon: "edit-paste", value: expand(snippet.text) }));
    }

    function emojiItems(tokens) {
        const hits = [];
        for (const entry of emoji.items) {
            if (hits.length === 120)
                break;
            if (Spot.matchesFolded(entry.name, tokens))
                hits.push(entry);
        }
        return hits.map(entry => ({ key: "emoji:" + entry.char, kind: "emoji", store: root, title: entry.name, glyph: entry.char, value: entry.char }));
    }

    function describe(item) {
        if (item.kind === "emoji")
            return { glyph: item.glyph, title: item.title, actions: [["Enter", "Paste"], ["Ctrl+C", "Copy"]] };
        return { icon: item.icon, title: item.title, subtitle: "Snippet · " + item.snippet.keyword, body: item.value, actions: [["Enter", "Paste"], ["Ctrl+C", "Copy"]] };
    }

    function activate(item, keys) {
        Spot.type(item.value);
        return true;
    }

    function copy(item) {
        Spot.copy(item.value.split("{cursor}").join(""));
    }

    Source {
        id: emoji
        command: ["python3", "-I", "-c", `
import json, subprocess, unicodedata
charset = subprocess.run(["fc-list", ":family=Noto Color Emoji", "charset"], capture_output=True, text=True, check=True).stdout
codes = set()
for span in charset.partition("=")[2].split():
    start, _, end = span.partition("-")
    codes.update(range(int(start, 16), int(end or start, 16) + 1))
print(json.dumps([{"char": chr(code), "name": unicodedata.name(chr(code)).lower()} for code in sorted(codes) if code > 0x7F and unicodedata.name(chr(code), "")]))
`]
        parse: output => output.trim() ? JSON.parse(output).sort((a, b) => a.name.length - b.name.length) : []
    }
}
