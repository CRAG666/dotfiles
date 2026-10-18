import Quickshell
import QtQuick
import "js/help.js" as Help

// The help view (Ctrl+?): every shortcut and feature from help.js, plus the
// abbreviations of the views and of spotlight.json's quicklinks and snippets,
// read from where they are defined so they never go stale. Title and key
// matches beat description-only ones, and sections holding one come first.
// Enter opens the topic's view or types its example into the search field.
Scope {
    id: root
    property var host
    readonly property var topics: [
        ...Help.topics,
        ...host.views.filter(view => view.alias).map(view => ({ section: "Aliases", keys: view.alias + "␣", title: view.title, text: `Type “${view.alias}” and a space to open ${view.title}.`, mode: view.mode })),
        ...host.userConfig.quicklinks.filter(link => link.keyword).map(link => ({ section: "Quicklinks", keys: link.keyword, title: link.name, text: quicklinkText(link), insert: link.keyword + " " })),
        ...host.userConfig.snippets.filter(snippet => snippet.keyword).map(snippet => ({ section: "Snippets", keys: snippet.keyword, title: snippet.name, text: snippet.text, insert: snippet.keyword }))
    ]

    function quicklinkText(link) {
        if (link.urls)
            return `Opens ${link.urls.length} pages:\n${link.urls.join("\n")}`;
        if ((link.url ?? "").includes("{query}"))
            return `“${link.keyword} text” searches ${link.name}; the name alone opens ${link.home ?? "it"}.`;
        return "Opens " + link.url;
    }

    function items(tokens) {
        const hits = topics
            .map((topic, index) => ({ topic, index, rank: Spot.matches(`${topic.keys} ${topic.title}`, tokens) ? 0 : 1 }))
            .filter(hit => hit.rank === 0 || Spot.matches(`${hit.topic.section} ${hit.topic.keys} ${hit.topic.title} ${hit.topic.text ?? ""}`, tokens, false));
        const sectionRank = {};
        for (const hit of hits)
            sectionRank[hit.topic.section] = Math.min(sectionRank[hit.topic.section] ?? 1, hit.rank);
        const sectionOrder = Spot.unique(topics.map(topic => topic.section));
        const position = Object.create(null);
        sectionOrder.forEach((section, index) => position[section] = index);
        const sectionKey = section => sectionRank[section] * sectionOrder.length + position[section];
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
