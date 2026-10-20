import Quickshell
import QtQuick
import "js/help.js" as Help
import "js/search.js" as Search

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

    // each topic as an item once, with the texts it is found by folded
    readonly property var entries: topics.map((topic, index) => ({ index, section: topic.section, named: Search.fold(`${topic.keys} ${topic.title}`), described: Search.fold(`${topic.section} ${topic.keys} ${topic.title} ${topic.text ?? ""}`), item: { key: `help:${topic.section}:${topic.keys}`, kind: "help", store: root, section: topic.section, topic, title: topic.title, hint: topic.keys, icon: "help-about" } }))
    readonly property var sectionOrder: Spot.unique(topics.map(topic => topic.section))

    function items(tokens) {
        const hits = [];
        for (let index = 0; index < entries.length; index++) {
            const entry = entries[index];
            const rank = Spot.matchesFolded(entry.named, tokens) ? 0 : Spot.matchesFolded(entry.described, tokens, false) ? 1 : -1;
            if (rank >= 0)
                hits.push({ entry, rank });
        }
        const sectionRank = Object.create(null);
        for (let index = 0; index < hits.length; index++) {
            const section = hits[index].entry.section;
            sectionRank[section] = Math.min(sectionRank[section] ?? 1, hits[index].rank);
        }
        const position = Object.create(null);
        for (let index = 0; index < sectionOrder.length; index++)
            position[sectionOrder[index]] = index;
        const sectionKey = section => sectionRank[section] * sectionOrder.length + position[section];
        return hits
            .sort((a, b) => sectionKey(a.entry.section) - sectionKey(b.entry.section) || a.rank - b.rank || a.entry.index - b.entry.index)
            .map(hit => hit.entry.item);
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
