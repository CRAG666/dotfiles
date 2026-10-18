import Quickshell
import QtQuick

// Text typed into the focused window: snippets from spotlight.json, with
// {date}, {time}, {weekday}, {clipboard} and {cursor} placeholders, and emoji
// (every named codepoint the colour emoji font can draw, the faces first, then
// in codepoint order, listed on first use).
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

    readonly property var emojiByChar: {
        const found = {};
        for (const entry of emoji.items)
            found[entry.char] = entry;
        return found;
    }

    function emojiItem(entry) {
        return { key: "emoji:" + entry.char, kind: "emoji", store: root, title: entry.name.replace(/\b\w/g, letter => letter.toUpperCase()), glyph: entry.char, value: entry.char };
    }

    // the best 120 matches, the shortest names first
    function emojiItems(tokens) {
        return emoji.items
            .filter(entry => Spot.matchesFolded(entry.name, tokens))
            .sort((a, b) => a.name.length - b.name.length)
            .slice(0, 120)
            .map(emojiItem);
    }

    function allEmoji() {
        return emoji.items.map(emojiItem);
    }

    // the characters `picked` (most picked first) that are emoji
    function emojiOf(characters) {
        return characters.filter(char => char in emojiByChar).map(char => emojiItem(emojiByChar[char]));
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
# skin tones and the regional indicator letters only make sense inside a sequence
parts = set(range(0x1F3FB, 0x1F400)) | set(range(0x1F1E6, 0x1F200))
# the faces (the Emoticons block) lead, as in Raycast
print(json.dumps([{"char": chr(code), "name": unicodedata.name(chr(code)).lower()} for code in sorted(codes - parts, key=lambda code: (not 0x1F600 <= code <= 0x1F64F, code)) if code > 0x7F and unicodedata.name(chr(code), "")]))
`]
    }
}
