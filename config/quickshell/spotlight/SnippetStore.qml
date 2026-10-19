import Quickshell
import QtQuick
import "js/search.js" as Search

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

    // one item an emoji, made once a load, not for every match at every keystroke
    readonly property var emojiList: emoji.items.map(emojiItem)
    readonly property var emojiByChar: {
        const found = {};
        for (let index = 0; index < emojiList.length; index++)
            found[emojiList[index].glyph] = emojiList[index];
        return found;
    }

    function emojiItem(entry) {
        return { key: "emoji:" + entry.char, kind: "emoji", store: root, title: entry.name.replace(/\b\w/g, letter => letter.toUpperCase()), glyph: entry.char, value: entry.char };
    }

    // the best 120 matches, the shortest names first: a counting sort by name
    // length, linear and stable, so equal lengths keep the faces-first order
    function emojiItems(tokens) {
        const found = Search.matching(emoji.items, "emoji", entry => entry.name, tokens);
        const byLength = [];
        for (let index = 0; index < found.length; index++) {
            const entry = found[index];
            if (!byLength[entry.name.length])
                byLength[entry.name.length] = [];
            byLength[entry.name.length].push(entry);
        }
        const best = [];
        for (let length = 0; length < byLength.length && best.length < 120; length++) {
            const bucket = byLength[length] ?? [];
            for (let index = 0; index < bucket.length && best.length < 120; index++)
                best.push(emojiByChar[bucket[index].char]);
        }
        return best;
    }

    function allEmoji() {
        return emojiList;
    }

    // the characters `picked` (most picked first) that are emoji
    function emojiOf(characters) {
        return characters.filter(char => char in emojiByChar).map(char => emojiByChar[char]);
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
# skin tones, the regional indicator letters, and the joiner, tags and keycap
# (format characters and enclosing marks, drawn as nothing) only make sense
# inside a sequence
parts = set(range(0x1F3FB, 0x1F400)) | set(range(0x1F1E6, 0x1F200))
# the faces (the Emoticons block) lead, as in Raycast
print(json.dumps([{"char": chr(code), "name": unicodedata.name(chr(code)).lower()} for code in sorted(codes - parts, key=lambda code: (not 0x1F600 <= code <= 0x1F64F, code)) if code > 0x7F and unicodedata.name(chr(code), "") and unicodedata.category(chr(code)) not in ("Cf", "Me")]))
`]
    }
}
