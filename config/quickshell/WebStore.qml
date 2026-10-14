import Quickshell
import QtQuick

// Pages for the browser: whatever looks like a URL, quicklinks from
// spotlight.json ("yt lofi" fills YouTube's {query}; a group opens every page),
// your GitHub repositories (gh, listed once the query has two characters) and
// a web search.
Scope {
    id: root
    property var host
    readonly property string webSearch: "https://www.google.com/search?q="

    function load() {
        repos.load();
    }

    function urlItems(text) {
        let url = "";
        if (/^https?:\/\/\S+$/.test(text))
            url = text;
        else if (/^(www\.)?[\w-]+(\.[\w-]+)*\.(com|org|net|io|dev|app|ai|co|mx|edu|gov|me|xyz)(\/\S*)?$/i.test(text))
            url = "https://" + text;
        return url ? [{ key: "url", kind: "url", store: root, title: url, icon: "web-browser", urls: [url] }] : [];
    }

    // a keyword and text fill the link's {query}; a name match opens the link,
    // its home page, or every page of a group
    function quicklinkItems(tokens, raw) {
        const [keyword, ...words] = raw.split(/\s+/);
        const rest = words.join(" ");
        const hits = [];
        for (const link of host.userConfig.quicklinks) {
            const opener = link.open ?? ["xdg-open"];
            const searchable = (link.url ?? "").includes("{query}");
            if (rest && searchable && link.keyword === keyword.toLowerCase())
                hits.unshift({ key: "link:" + link.name, kind: "quicklink", store: root, title: `${link.name}: “${rest}”`, hint: link.keyword, icon: "web-browser", urls: [link.url.replace("{query}", encodeURIComponent(rest))], opener });
            else if (Spot.matches(link.name + " " + link.keyword, tokens))
                hits.push({ key: "link:" + link.name, kind: "quicklink", store: root, title: link.name, hint: link.urls ? `${link.urls.length} links` : link.keyword, icon: "web-browser", urls: link.urls ?? [searchable ? link.home ?? link.url.replace("{query}", "") : link.url], opener });
        }
        return hits;
    }

    function repoItems(tokens) {
        return repos.items
            .filter(repo => Spot.matches(repo.nameWithOwner + " " + (repo.description ?? ""), tokens))
            .map(repo => ({ key: "repo:" + repo.nameWithOwner, kind: "repo", store: root, repo, title: repo.nameWithOwner, hint: repo.isPrivate ? "Private" : "", icon: "github", urls: [repo.url] }));
    }

    function searchItems(text) {
        return [{ key: "web", kind: "web", store: root, title: `Search the web for “${text}”`, icon: "web-browser", value: text, urls: [webSearch + encodeURIComponent(text)] }];
    }

    function describe(item) {
        switch (item.kind) {
        case "quicklink":
            return { icon: item.icon, title: item.title, subtitle: item.urls.length > 1 ? `${item.urls.length} links` : item.urls[0], body: item.urls.length > 1 ? item.urls.join("\n") : "", actions: [["Enter", item.urls.length > 1 ? "Open all" : "Open"], ["Ctrl+C", "Copy URLs"]] };
        case "repo":
            return { icon: item.icon, title: item.title, subtitle: item.repo.description ?? "", details: [`★ ${item.repo.stargazerCount}  ·  ${item.repo.isPrivate ? "Private" : "Public"}`, "Updated " + new Date(item.repo.updatedAt).toLocaleDateString(Qt.locale(), Locale.ShortFormat)], actions: [["Enter", "Open on GitHub"], ["Ctrl+C", "Copy URL"]] };
        case "url":
            return { icon: item.icon, title: item.title, subtitle: "Open in your browser", actions: [["Enter", "Open"], ["Ctrl+C", "Copy URL"]] };
        default:
            return { icon: item.icon, title: item.title, subtitle: "Search with Google", actions: [["Enter", "Search"]] };
        }
    }

    function activate(item, keys) {
        for (const url of item.urls)
            Quickshell.execDetached([...(item.opener ?? ["xdg-open"]), url]);
        return true;
    }

    function copy(item) {
        Spot.copy(item.value ?? item.urls.join("\n"));
    }

    Source {
        id: repos
        maxAge: 600000
        command: ["gh", "repo", "list", "--limit", "300", "--json", "nameWithOwner,description,url,isPrivate,stargazerCount,updatedAt"]
        parse: output => output.trim() ? JSON.parse(output) : []
    }
}
