import Quickshell
import QtQuick
import "help.js" as Help

// The help view (Ctrl+?): every shortcut and feature from help.js. Title and
// key matches beat description-only ones, and sections holding one come first.
// Enter opens the topic's view or types its example into the search field.
Scope {
    id: root
    property var host

    function items(tokens) {
        const hits = Help.topics
            .map((topic, index) => ({ topic, index, rank: Spot.matches(`${topic.keys} ${topic.title}`, tokens) ? 0 : 1 }))
            .filter(hit => Spot.matches(`${hit.topic.section} ${hit.topic.keys} ${hit.topic.title} ${hit.topic.text ?? ""}`, tokens));
        const sectionRank = {};
        for (const hit of hits)
            sectionRank[hit.topic.section] = Math.min(sectionRank[hit.topic.section] ?? 1, hit.rank);
        const sectionOrder = [...new Set(Help.topics.map(topic => topic.section))];
        const sectionKey = section => sectionRank[section] * sectionOrder.length + sectionOrder.indexOf(section);
        return hits
            .sort((a, b) => sectionKey(a.topic.section) - sectionKey(b.topic.section) || a.rank - b.rank || a.index - b.index)
            .map(({ topic }) => ({ key: `help:${topic.section}:${topic.keys}`, kind: "help", store: root, section: topic.section, topic, title: topic.title, hint: topic.keys, icon: "help-about" }));
    }

    function describe(item) {
        const topic = item.topic;
        const actions = topic.mode ? [["Enter", "Open view"]] : topic.insert ? [["Enter", "Try it"]] : [];
        return { icon: item.icon, title: topic.title, subtitle: topic.keys, body: topic.text ?? "", actions, footer: actions.length ? "" : topic.section };
    }

    function activate(item, keys) {
        if (item.topic.mode) {
            host.openView(item.topic.mode);
        } else if (item.topic.insert) {
            host.openView("");
            host.setQuery(item.topic.insert);
        }
        return false;
    }
}
