import Quickshell
import Quickshell.Io
import QtQuick

// A DOI or a paper URL holding one ("10.1145/…", "dl.acm.org/doi/…") is
// looked up, debounced, through the helper's paper: BibTeX from doi.org, the
// open access PDF from OpenAlex. Enter copies the BibTeX, Ctrl+Enter opens the PDF, Ctrl+C copies
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

    // the DOI in the text, or ""
    function identify(text) {
        const doi = text.replace(/[?#].*$/, "").match(/\b(10\.\d{4,9}\/\S+)/);
        return doi ? decodeURIComponent(doi[1]).replace(/[.,;)\]]+$/, "") : "";
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
        if (!paper)
            return [{ key: "paper-pending", kind: "paperPending", store: root, title: failure?.target === target ? "No paper found for " + target : `Looking up ${target}…`, icon: "application-pdf" }];
        return [{ key: "paper:" + target, kind: "paper", store: root, paper, title: paper.title, hint: byline(paper), icon: "application-pdf" }];
    }

    function describe(item) {
        if (item.kind === "paperPending")
            return { icon: item.icon, title: item.title, subtitle: failure?.target === target ? failure.reason : "Asking doi.org and OpenAlex" };
        const paper = item.paper;
        return {
            icon: item.icon,
            title: paper.title,
            subtitle: paper.authors.join("; "),
            metadata: [["Year", paper.year], ["Venue", paper.venue], ["Key", paper.key], ["DOI", paper.id], ["PDF", paper.pdf ? "Open access" : "None found"]],
            body: paper.bibtex,
            mono: true,
            actions: [["Enter", "Copy BibTeX"], ...(paper.pdf ? [["Ctrl+Enter", "Open PDF"]] : []), ["Ctrl+C", "Copy citation key"], ["", "Open page", "page"], ["", "Copy DOI", "copy-id"], ["", "Add to bookmarks…", "bookmark"]]
        };
    }

    function activate(item, keys) {
        if (item.kind === "paperPending")
            return false;
        if (keys.ctrl && item.paper.pdf)
            Spot.open(item.paper.pdf);
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
            Spot.open(item.paper.page);
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
            const target = root.target;
            Spot.call(["paper", target], (output, error) => {
                if (error)
                    root.failure = { target, reason: error };
                else if (output.trim())
                    root.papers = Object.assign({}, root.papers, { [target]: JSON.parse(output) });
            });
        }
    }
}
