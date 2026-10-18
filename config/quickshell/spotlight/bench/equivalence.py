"""Whether a change kept the results: the matcher of two commits on the same
text-query pairs, and the stores of two sandboxes on the same queries.
"""

import json
from random import Random

from corpus import matcher_queries, texts
from sandbox import sandbox, show, standalone

MATCHER = """import Quickshell
import Quickshell.Io
import QtQuick
import "before.js" as Before
import "after.js" as After

ShellRoot {
    id: root
    FileView { id: input; path: "SCRATCH/input.json"; blockLoading: true }
    FileView { id: answer; path: "ANSWER"; blockWrites: true; printErrors: false }
    Timer { running: true; interval: 10; onTriggered: root.run() }

    // a pass of one matcher over every pair, summed so nothing is optimised away
    function time(Search, folded, tokenized) {
        const started = Date.now();
        let sum = 0;
        for (const tokens of tokenized)
            for (let index = 0; index < folded.length; index++)
                sum += Search.score(folded[index], tokens) + Search.score(folded[index], tokens, false);
        return [Date.now() - started, sum];
    }

    function run() {
        try {
            const { corpus, queries } = JSON.parse(input.text());
            const before = corpus.map(Before.fold), after = corpus.map(After.fold);
            let pairs = 0, differences = 0;
            const examples = [];
            for (const query of queries) {
                const beforeTokens = Before.tokens(query), afterTokens = After.tokens(query);
                for (let index = 0; index < corpus.length; index++)
                    for (const loose of [true, false]) {
                        const was = Before.score(before[index], beforeTokens, loose), is = After.score(after[index], afterTokens, loose);
                        pairs++;
                        if (was !== is && differences++ < 20)
                            examples.push({ query, text: corpus[index], loose, before: was, after: is });
                    }
            }
            // alternated and the best of three each, so neither pays for the other's garbage
            let beforeMs = Infinity, afterMs = Infinity;
            for (let round = 0; round < 3; round++) {
                beforeMs = Math.min(beforeMs, time(Before, before, queries.map(Before.tokens))[0]);
                afterMs = Math.min(afterMs, time(After, after, queries.map(After.tokens))[0]);
            }
            answer.setText(JSON.stringify({ pairs, differences, examples, beforeMs, afterMs }));
        } catch (error) {
            answer.setText(JSON.stringify({ error: String(error) + "\n" + error.stack }));
        }
        Qt.quit();
    }
}
"""

# what each store answers, keyed by name; sorted where the order is not the point
STORES = """
const keys = list => list.map(item => item.key);
const sections = list => list.map(([section, items]) => [section, keys(items)]);
const skip = ["store", "entry", "page", "agent", "space", "tab", "pane", "peer", "host", "window", "event", "app", "process", "device", "repo", "snippet", "pin", "timer", "node", "player"];
const plain = value => JSON.parse(JSON.stringify(value, (key, field) => skip.includes(key) ? undefined : field));
const queries = ["", "a", "f", "fi", "fire", "firefox", "fierfox", "term", "nvim con", "git", "zen", "conf", "ssh", "ag", "doc", "2+2", "x"];
const found = {};
const each = (name, compute) => {
    for (const query of queries) {
        try {
            found[name + " " + JSON.stringify(query)] = plain(compute(tokens(query), query));
        } catch (error) {
            found[name + " " + JSON.stringify(query)] = "ERROR " + error;
        }
    }
};
each("everything", (t, q) => sections(win.everything(t, q)));
each("apps", (t, q) => Apps.search(q).map(app => app.id));
each("windows", t => keys(windows.items(t, 50)));
each("quit", t => keys(windows.quitItems(t)));
each("herdr", t => [herdr.agentItems(t), herdr.workspaceItems(t), herdr.tabItems(t), herdr.paneItems(t)].map(keys));
each("ssh", t => keys(ssh.items(t)));
each("agenda", t => sections(agenda.sections(t)));
each("agendaSearch", t => keys(agenda.searchItems(t)));
each("tabs", t => sections(browser.tabSections(t)));
each("history", t => keys(browser.historyItems(t)));
each("run", (t, q) => keys(run.items(q, true)).sort());
each("emoji", t => keys(snippets.emojiItems(t)).sort());
each("help", t => keys(help.items(t)));
each("colors", t => keys(colors.items(t)));
each("files", t => sections(files.sections(t, false)));
each("filesEverything", t => sections(files.sections(t, true)));
each("clipboard", t => keys(clipboard.items(t)));
each("bookmarks", t => keys(win.ranked(library.bookmarkItems(t), t)));
each("notes", t => keys(win.ranked(library.noteItems(t), t)));
each("commands", t => keys(win.ranked(win.commandItems(t), t)));
each("wallpapers", t => wallpapers.items(t).map(item => [item.key, item.thumb]));
each("passwords", t => keys(passwords.items(t)));
each("repos", t => keys(web.repoItems(t)));
each("quicklinks", (t, q) => keys(web.quicklinkItems(t, q)));
each("snippets", t => keys(snippets.snippetItems(t)));
for (const path of ["~/", "~/Git/dotfiles/", "~/Git/dotfiles/co", "~/Git/dotfiles/.g"])
    found["browse " + path] = sections(files.browseSections(path));
const typed = ["f", "fi", "fir", "fire", "firef", "firefo", "firefox", "firefo", "fire", "fi", "n", "nv", "nvi", "nvim", "nvim ", "nvim c", "nvim co", "nvim c", "d", "do", "doc", "docs", "t", "te", "ter", "term", "termi", "s", "ss", "ssh", "ssh ", "g", "gi", "git", "github", "z", "ze", "zen", "c", "co", "con", "conf", "2", "2+", "2+2", "~/", "~/G", ">", ">l", ">ls", ":", ":s", ":sm", "a", "ag", "age"];
for (const text of typed) {
    win.search.text = text;
    found["typed " + JSON.stringify(text)] = win.results.map(item => item.section + " " + item.key);
}
win.search.text = "";
found["desktop"] = ["firefox", "com.mitchellh.ghostty", "zen", "kitty", "nvim", "unknownapp", "Zathura"].map(name => Spot.desktopEntry(name)?.id ?? null);
found["aliases"] = Object.keys(aliases.entries).map(alias => aliases.aliasOf(aliases.entries[alias].key));
found["pickedEmoji"] = win.pickedEmoji();
done(found);
"""

# counts that stop changing once every source has loaded
LOADED = """[windows.list.length, Apps.indexed.length, library.bookmarkItems([]).length, library.noteItems([]).length,
browser.historyItems([]).length, browser.tabSections([]).length, run.items("a", true).length, snippets.allEmoji().length,
wallpapers.items([]).length, JSON.stringify(files.sections([], false).map(([s, l]) => l.length)), ssh.items([]).length,
passwords.items([]).length, web.repoItems([]).length, agenda.sections([]).length, clipboard.items([]).length,
herdr.workspaceItems([]).length, system.items([]).length]"""


def matcher(rev: str, texts_count: int, queries_count: int) -> bool:
    rng = Random(7)
    corpus = texts(texts_count, rng)
    queries = matcher_queries(corpus, queries_count, rng)
    result = standalone(
        MATCHER,
        {
            "before.js": show(rev, "spotlight/js/search.js"),
            "after.js": show(None, "spotlight/js/search.js"),
            "input.json": json.dumps({"corpus": corpus, "queries": queries}),
        },
    )
    print(
        f"matcher {rev} → working tree: {result['pairs']} scores over {len(corpus)} texts × {len(queries)} queries"
    )
    print(
        f"  {result['differences']} differ; {result['beforeMs']} ms before, {result['afterMs']} ms after"
    )
    for example in result["examples"]:
        print("  ", example)
    return result["differences"] == 0


def store_answers(rev: str | None) -> dict:
    with sandbox(rev) as instance:
        instance.probe(f"loadAll();\nsettle(() => {LOADED}, () => done(true));")
        return instance.probe(STORES)


def stores(rev: str) -> bool:
    before, after = store_answers(rev), store_answers(None)
    differing = [name for name in before if before[name] != after.get(name)]
    print(
        f"stores {rev} → working tree: {len(before)} answers, {len(differing)} differ"
    )
    for name in differing:
        print(
            f"  {name}\n    before: {json.dumps(before[name])[:300]}\n    after:  {json.dumps(after.get(name))[:300]}"
        )
    return not differing


NARROWING = """import Quickshell
import Quickshell.Io
import QtQuick
import "search.js" as Search

ShellRoot {
    id: root
    FileView { id: input; path: "SCRATCH/input.json"; blockLoading: true }
    FileView { id: answer; path: "ANSWER"; blockWrites: true; printErrors: false }
    Timer { running: true; interval: 10; onTriggered: root.run() }

    function run() {
        try {
            const { corpus, typed } = JSON.parse(input.text());
            const items = corpus.map(text => ({ text: Search.fold(text) }));
            const textOf = item => item.text;
            let steps = 0, differences = 0, cachedMs = 0, plainMs = 0;
            const examples = [];
            for (const states of typed)
                for (const state of states)
                    for (const loose of [false, true]) {
                        const tokens = Search.tokens(state);
                        let started = Date.now();
                        const cached = Search.matching(items, "bench", textOf, tokens, loose);
                        cachedMs += Date.now() - started;
                        started = Date.now();
                        const plain = items.filter(item => Search.score(item.text, tokens, loose) > 0);
                        plainMs += Date.now() - started;
                        steps++;
                        if (cached.length !== plain.length || cached.some((item, index) => item !== plain[index])) {
                            if (differences++ < 10)
                                examples.push({ state, loose, cached: cached.length, plain: plain.length });
                        }
                    }
            answer.setText(JSON.stringify({ steps, differences, examples, cachedMs, plainMs }));
        } catch (error) {
            answer.setText(JSON.stringify({ error: String(error) + "\\n" + error.stack }));
        }
        Qt.quit();
    }
}
"""


def narrowing(texts_count: int, queries_count: int) -> bool:
    """Search.matching, with its query cache, against filtering every item
    afresh, after each keystroke of typed queries (backspaces and repeated
    queries included)."""
    from keystrokes import sequences

    rng = Random(3)
    corpus = texts(texts_count, rng)
    typed = sequences(rng, queries_count)
    typed += [states + states[::-1] + states for states in typed[: queries_count // 4]]
    result = standalone(
        NARROWING,
        {
            "search.js": show(None, "spotlight/js/search.js"),
            "input.json": json.dumps({"corpus": corpus, "typed": typed}),
        },
    )
    print(
        f"narrowing: {result['steps']} keystroke answers over {len(corpus)} texts, {result['differences']} differ"
    )
    print(
        f"  {result['cachedMs']} ms with the query cache, {result['plainMs']} ms filtering afresh"
    )
    for example in result["examples"]:
        print("  ", example)
    return result["differences"] == 0
