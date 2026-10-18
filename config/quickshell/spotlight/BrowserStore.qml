import Quickshell
import QtQuick

// Zen history of every profile, read by spotlight.py from a copy of
// places.sqlite, and the open tabs of every running profile, listed through
// tabctl's extension. Enter opens a visited page in its profile, or switches
// to a tab and focuses its Zen window.
Scope {
    id: root
    property var host

    function loadHistory() {
        history.load();
    }

    function loadTabs() {
        tabs.reload();
    }

    function domain(url) {
        return url.replace(/^[a-z]+:\/\/(www\.)?/, "").split("/")[0];
    }

    function historyItems(tokens) {
        return history.items
            .filter(visit => Spot.matches(visit.title + " " + visit.url, tokens, false))
            .slice(0, 200)
            .map(visit => ({ key: `visit:${visit.profile}:${visit.url}`, kind: "visit", store: root, page: visit, title: visit.title, hint: domain(visit.url), icon: "web-browser" }));
    }

    function tabSections(tokens) {
        const shown = tabs.items.filter(tab => Spot.matches(tab.title + " " + tab.url, tokens));
        return [...new Set(shown.map(tab => tab.profile))].map(profile => [profile, shown
            .filter(tab => tab.profile === profile)
            .map(tab => ({ key: `tab:${tab.id}`, kind: "tab", store: root, page: tab, title: tab.title, hint: domain(tab.url), icon: "web-browser" }))]);
    }

    function describe(item) {
        const page = item.page;
        const where = item.kind === "visit"
            ? [["Visits", page.visits], ["Last visit", Spot.dateTime(page.last * 1000)]]
            : [["Window", page.window]];
        return { icon: item.icon, title: item.title, subtitle: page.url, metadata: [["Profile", page.profile], ...where], actions: [["Enter", item.kind === "visit" ? "Open in Zen" : "Switch to tab"], ["Ctrl+C", "Copy URL"]] };
    }

    function activate(item, keys) {
        if (item.kind === "visit")
            Quickshell.execDetached([...host.userConfig.browser, "-P", item.page.profile, item.page.url]);
        else
            Quickshell.execDetached(["sh", "-c", 'tabctl activate --focused "$1" && scrollmsg "[pid=$2] focus"', "sh", item.page.id, String(item.page.pid)]);
        return true;
    }

    function copy(item) {
        Spot.copy(item.page.url);
    }

    Source {
        id: history
        maxAge: 60000
        command: ["python3", Spot.helper, "zen-history"]
    }

    Source {
        id: tabs
        command: ["python3", Spot.helper, "zen-tabs"]
    }
}
