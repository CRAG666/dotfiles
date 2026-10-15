import Quickshell
import Quickshell.Io
import QtQuick

// A DOI, an arXiv id or a paper URL holding either ("10.1145/…",
// "arXiv:1706.03762", "dl.acm.org/doi/…") is looked up, debounced, through
// spotlight.py paper: BibTeX from doi.org or arXiv, the open access PDF from
// OpenAlex. Enter copies the BibTeX, Ctrl+Enter opens the PDF, Ctrl+C copies
// the citation key; Ctrl+K opens the page or adds it to the bookmarks.
Scope {
    id: root
    property var host
    property var library
    property string query: ""
    readonly property string target: identify(query)
    property var papers: ({})   // target → paper, kept while Spotlight runs
    property var failure: null   // { target, reason } of the last failed lookup

    onTargetChanged: {
        if (target && !(target in papers))
            debounce.restart();
    }

    // "doi:<doi>" or "arxiv:<id>"; a bare new-style arXiv id needs a real
    // YYMM so decimals typed for the calculator stay out
    function identify(text) {
        const arxiv = text.match(/^(?:arxiv:\s*|(?:https?:\/\/)?(?:www\.)?arxiv\.org\/(?:abs|pdf|html)\/)?(\d{2}(?:0[1-9]|1[0-2])\.\d{4,5}|[a-z-]+(?:\.[A-Z]{2})?\/\d{7})(?:v\d+)?(?:\.pdf)?\/?$/i);
        if (arxiv)
            return "arxiv:" + arxiv[1];
        const doi = text.replace(/[?#].*$/, "").match(/\b(10\.\d{4,9}\/\S+)/);
        return doi ? "doi:" + decodeURIComponent(doi[1]).replace(/[.,;)\]]+$/, "") : "";
    }

    function byline(paper) {
        const surnames = paper.authors.filter(author => author).map(author => author.includes(",") ? author.split(",")[0] : author.split(" ").pop());
        const authors = surnames.length > 2 ? surnames[0] + " et al." : surnames.join(" & ");
        return [authors, paper.year].filter(part => part).join(", ");
    }

    function items() {
        if (!target)
            return [];
        const paper = papers[target];
        const label = target.replace(/^(doi|arxiv):/, "");
        if (!paper)
            return [{ key: "paper-pending", kind: "paperPending", store: root, title: failure?.target === target ? "No paper found for " + label : `Looking up ${label}…`, icon: "application-pdf" }];
        return [{ key: "paper:" + target, kind: "paper", store: root, paper, title: paper.title, hint: byline(paper), icon: "application-pdf" }];
    }

    function describe(item) {
        if (item.kind === "paperPending")
            return { icon: item.icon, title: item.title, subtitle: failure?.target === target ? failure.reason : "Asking doi.org, arXiv and OpenAlex" };
        const paper = item.paper;
        return {
            icon: item.icon,
            title: paper.title,
            subtitle: paper.authors.join("; "),
            metadata: [["Year", paper.year], ["Venue", paper.venue], ["Key", paper.key], [paper.scheme === "arxiv" ? "arXiv" : "DOI", paper.id], ["PDF", paper.pdf ? "Open access" : "None found"]],
            body: paper.bibtex,
            mono: true,
            actions: [["Enter", "Copy BibTeX"], ...(paper.pdf ? [["Ctrl+Enter", "Open PDF"]] : []), ["Ctrl+C", "Copy citation key"], ["", "Open page", "page"], ["", paper.scheme === "arxiv" ? "Copy arXiv id" : "Copy DOI", "copy-id"], ["", "Add to bookmarks…", "bookmark"]]
        };
    }

    function activate(item, keys) {
        if (item.kind === "paperPending")
            return false;
        if (keys.ctrl && item.paper.pdf)
            Quickshell.execDetached(["xdg-open", item.paper.pdf]);
        else
            Spot.copy(item.paper.bibtex);
        return true;
    }

    function copy(item) {
        Spot.copy(item.paper?.key ?? item.title);
    }

    function act(item, action) {
        if (item.kind === "paperPending")
            return false;
        switch (action) {
        case "page":
            Quickshell.execDetached(["xdg-open", item.paper.page]);
            return true;
        case "copy-id":
            Spot.copy(item.paper.id);
            return true;
        case "bookmark":
            library.bookmarkForm("Add Bookmark", { body: item.paper.page, title: item.paper.title, category: "" });
            return false;
        }
        return false;
    }

    Timer {
        id: debounce
        interval: 300
        onTriggered: {
            lookup.forTarget = root.target;
            lookup.exec(["python3", Spot.helper, "paper", root.target]);
        }
    }

    Process {
        id: lookup
        property string forTarget: ""
        stdout: StdioCollector {
            onStreamFinished: {
                if (text.trim())
                    root.papers = Object.assign({}, root.papers, { [lookup.forTarget]: JSON.parse(text) });
            }
        }
        stderr: StdioCollector {
            id: lookupErrors
        }
        onExited: exitCode => {
            if (exitCode !== 0)
                root.failure = { target: forTarget, reason: lookupErrors.text.trim() };
        }
    }
}
