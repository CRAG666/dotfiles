import Quickshell
import QtQuick

// Zen history and open tabs of every profile, read by spotlight.py from a copy
// of places.sqlite and from the session file. Enter opens the page in its
// profile (a tab can't be switched to from outside Zen, so it opens again).
Scope {
    id: root
    property var host

    function loadHistory() {
        history.load();
    }

    function loadTabs() {
        tabs.load();
    }

    function domain(url) {
        return url.replace(/^[a-z]+:\/\/(www\.)?/, "").split("/")[0];
    }

    function historyItems(tokens) {
        return history.items
            .filter(visit => Spot.matches(visit.title + " " + visit.url, tokens))
            .slice(0, 200)
            .map(visit => ({ key: `visit:${visit.profile}:${visit.url}`, kind: "visit", store: root, page: visit, title: visit.title, hint: domain(visit.url), icon: "web-browser" }));
    }

    function tabItems(tokens) {
        return tabs.items
            .filter(tab => Spot.matches(tab.title + " " + tab.url, tokens))
            .map((tab, index) => ({ key: `tab:${index}:${tab.url}`, kind: "tab", store: root, page: tab, title: tab.title, hint: tab.pinned ? "Pinned" : domain(tab.url), icon: "web-browser" }));
    }

    function describe(item) {
        const page = item.page;
        const where = item.kind === "visit"
            ? `Visited ${page.visits} ${page.visits === 1 ? "time" : "times"} · last ${new Date(page.last * 1000).toLocaleString(Qt.locale(), Locale.ShortFormat)}`
            : `Window ${page.window}${page.pinned ? " · pinned" : ""}`;
        return { icon: item.icon, title: item.title, subtitle: page.url, details: [page.profile, where], actions: [["Enter", "Open in Zen"], ["Ctrl+C", "Copy URL"]] };
    }

    function activate(item, keys) {
        Quickshell.execDetached(["zen-browser", "-P", item.page.profile, item.page.url]);
        return true;
    }

    function copy(item) {
        Spot.copy(item.page.url);
    }

    Source {
        id: history
        command: ["python3", Spot.helper, "zen-history"]
        parse: output => JSON.parse(output)
    }

    Source {
        id: tabs
        command: ["python3", Spot.helper, "zen-tabs"]
        parse: output => JSON.parse(output)
    }
}
