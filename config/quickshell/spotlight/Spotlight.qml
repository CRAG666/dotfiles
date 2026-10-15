import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Effects
import qs
import "search.js" as Search

// Spotlight/Raycast-style launcher. It stays resident and hidden: spotlight.sh
// toggles it over IPC, optionally straight into a view, so opening it only
// maps a ready window. Every store loads its sources the first time a view or
// a search needs them and keeps them cached between openings (see Source).
// One query searches apps, windows, Herdr, commands, AI commands, SSH hosts,
// snippets, bookmarks, notes, passwords, GitHub repos, files and the text of
// documents, agenda events, script commands, plus math and conversions, DOIs and arXiv ids (BibTeX), URLs and quicklinks, then offers a question to pi or a web search; the
// selection is previewed on the right. Matching is loose (search.js) and results
// are ranked by how well their title matches plus how often they were picked
// (Frecency), which also picks the Top Hit across kinds. Each view is an entry of `views`; each
// kind of result belongs to a store (AppStore, FileStore, ...), which lists,
// describes and activates its own items. Keys are listed in help.js (Ctrl+?).
Scope {
    PanelWindow {
        id: win
        // the surface stays mapped while hidden: showing a fresh one costs ~40 ms
        // before its first frame. Hidden, it sits in the background layer with no
        // keyboard focus and no input region, and draws nothing
        property bool shown: false

        // the sizes below are 1.2× macOS Spotlight's points on a 1920×1080 screen;
        // u brings them to 1.44× and follows the logical size of the screen it opens on
        readonly property real u: Math.min(width / 1920, height / 1080) * 1.2
        readonly property bool dark: Theme.eyesDark
        readonly property color ink: Theme.ink
        readonly property color inkSoft: Theme.inkSoft
        readonly property color glass: Theme.glass
        readonly property color hairline: Theme.hairline
        readonly property color fill: Theme.fill
        readonly property color highlight: Theme.selection
        readonly property color highlightText: Theme.selectionText
        readonly property color accent: Theme.accent
        readonly property color accentText: Theme.accentText

        // `chip`: listed in the bar, reachable with Ctrl+1..7 and Tab; `alias`
        // plus a space opens the view ("hr " → Herdr); `open` loads what it shows;
        // `wide` splits list and preview evenly where the preview adds little;
        // `tone`: its colour in Theme.eyes
        readonly property var views: [
            { mode: "apps", tone: "blue1", chip: "\uf009", title: "Search Apps", icon: "applications-other", sections: (tokens, raw) => [["Applications", apps.items(raw)]] },
            { mode: "files", tone: "aqua", chip: "\uf07b", alias: "fi", title: "Search Files", icon: "folder", open: () => files.load(), sections: tokens => files.sections(tokens, false) },
            { mode: "contents", tone: "aqua", alias: "fc", title: "Search File Contents", placeholder: "Search inside documents", icon: "x-office-document", open: () => files.load(), sections: () => [["Documents", files.contentItems()]] },
            { mode: "clipboard", tone: "pink", chip: "\uf0ea", alias: "cb", title: "Clipboard History", placeholder: "Search Clipboard", icon: "edit-paste", open: () => clipboard.load(), sections: tokens => [["Clipboard", clipboard.items(tokens)]] },
            { mode: "windows", tone: "teal", chip: "\uf2d0", alias: "win", title: "Switch Windows", placeholder: "Search Windows", icon: "preferences-system-windows", open: () => windows.load(), sections: tokens => [["Windows", windows.items(tokens, 80)]] },
            { mode: "emoji", tone: "yellow", alias: "ej", title: "Search Emoji", icon: "face-smile", open: () => snippets.load(), sections: tokens => [["Emoji", snippets.emojiItems(tokens)]] },
            { mode: "passwords", tone: "red", wide: true, chip: "\uf084", alias: "pw", title: "Search Passwords", icon: "dialog-password", open: () => passwords.load(), sections: tokens => [["Passwords", ranked(passwords.items(tokens), tokens)]] },
            { mode: "snippets", tone: "violet", chip: "\uf121", alias: "sn", title: "Search Snippets", icon: "insert-text", sections: tokens => [["Snippets", ranked(snippets.snippetItems(tokens), tokens)]] },
            { mode: "commands", tone: "orange0", chip: "\uf0e7", alias: "cmd", title: "Commands", placeholder: "Search Commands", icon: "system-run", open: () => { herdr.load(); system.load(); scripts.load(); }, sections: tokens => [["Commands", ranked(commandItems(tokens), tokens)]] },
            { mode: "bookmarks", tone: "blue0", alias: "bm", title: "Search Bookmarks", icon: "user-bookmarks", open: () => library.load(), sections: tokens => [["Bookmarks", ranked(library.bookmarkItems(tokens), tokens)], ["Commands", library.commandItems(["bookmark"])]] },
            { mode: "notes", tone: "green1", alias: "nt", title: "Search Notes", icon: "accessories-text-editor", open: () => library.load(), sections: tokens => [["Notes", ranked(library.noteItems(tokens), tokens)], ["Commands", library.commandItems(["note"])]] },
            { mode: "quicklinks", tone: "blue0", alias: "ql", title: "Quicklinks", placeholder: "Search Quicklinks", icon: "web-browser", sections: (tokens, raw) => [["Quicklinks", ranked(web.quicklinkItems(tokens, raw), tokens)]] },
            { mode: "processes", tone: "orange1", wide: true, alias: "ps", title: "Kill Process", placeholder: "Search Processes", icon: "utilities-system-monitor", open: () => processes.refresh(), sections: tokens => [["Processes", processes.items(tokens)]] },
            { mode: "history", tone: "blue0", wide: true, alias: "bh", title: "Search Browser History", icon: "web-browser", open: () => browser.loadHistory(), sections: tokens => [["History", browser.historyItems(tokens)]] },
            { mode: "tabs", tone: "blue0", wide: true, alias: "bt", title: "Search Browser Tabs", icon: "web-browser", open: () => browser.loadTabs(), sections: tokens => [["Tabs", browser.tabItems(tokens)]] },
            { mode: "timers", tone: "yellow", alias: "tm", title: "Timers", placeholder: "Type a duration: 10m tea", icon: "alarm-clock", sections: (tokens, raw) => [["Timers", timers.items(tokens, raw, true)]] },
            { mode: "colors", tone: "pink", alias: "co", title: "Color History", placeholder: "Search Colors", icon: "color-picker", sections: tokens => [["Colors", colors.items(tokens)]] },
            { mode: "notifications", tone: "teal", alias: "nf", title: "Notifications", placeholder: "Search Notifications", icon: "preferences-system-notifications", sections: tokens => [["Notifications", notifications.items(tokens)], ["Commands", notifications.commandItems(tokens)]] },
            { mode: "ai", tone: "green1", alias: "ac", title: "AI Commands", placeholder: "Search AI Commands", icon: "", glyph: "✦", sections: tokens => [["AI Commands", ranked(ai.commandItems(tokens), tokens)]] },
            { mode: "run", tone: "violet", title: "Run Command", placeholder: "Type a command", icon: "system-run", open: () => run.load(), sections: (tokens, raw) => [["Run", run.items(raw, true)]] },
            { mode: "marks", tone: "orange1", alias: "mk", title: "Scroll Marks", placeholder: "Search marks or type a new one", icon: "bookmark-new", open: () => windows.reload(), sections: (tokens, raw) => [["Marks", marks.items(tokens, raw)]] },
            { mode: "herdr", tone: "teal", alias: "hr", title: "Herdr", placeholder: "Search Herdr agents, workspaces, tabs and panes", icon: "utilities-terminal", open: () => { herdr.load(); windows.load(); files.load(); }, sections: tokens => [["Agents", herdr.agentItems(tokens)], ["Workspaces", herdr.workspaceItems(tokens)], ["Tabs", herdr.tabItems(tokens)], ["Panes", herdr.paneItems(tokens)], ["Herdr", herdr.commandItems(tokens)]] },
            { mode: "agenda", tone: "pink", alias: "ag", title: "Agenda", placeholder: "Search events and deadlines", icon: "office-calendar", open: () => agenda.load(), sections: tokens => [...agenda.sections(tokens), ["Commands", agenda.commandItems(tokens)]] },
            { mode: "wallpapers", tone: "aqua", alias: "wp", title: "Wallpapers", placeholder: "Search Wallpapers", icon: "preferences-desktop-wallpaper", open: () => wallpapers.load(), sections: tokens => [["Wallpapers", wallpapers.items(tokens)]] },
            { mode: "tools", tone: "green2", alias: "tl", title: "Tools", placeholder: "Search Tools", icon: "applications-utilities", sections: tokens => [["Tools", ranked(commands.toolItems(tokens), tokens)]] },
            { mode: "help", tone: "aqua", alias: "?", title: "Spotlight Help", placeholder: "Search shortcuts and features", icon: "help-about", sections: tokens => [["Help", help.items(tokens)]] }
        ]
        readonly property var chips: views.filter(view => view.chip)
        // each kind of result in a colour of nvim's palette, as Blink colours its
        // completion kinds; the rest take their view's
        readonly property var kindTones: ({
            app: "blue1", mode: "blue1", file: "aqua", repo: "aqua", wallpaper: "aqua", help: "aqua",
            clip: "pink", color: "pink", calc: "pink", window: "teal", ssh: "teal", notification: "teal",
            emoji: "yellow", timer: "yellow", pomodoro: "yellow", password: "red", process: "orange1", mark: "orange1",
            snippet: "violet", run: "violet", command: "orange0", script: "orange0",
            bookmark: "blue0", quicklink: "blue0", url: "blue0", web: "blue0", visit: "blue0", tab: "blue0",
            note: "green1", paper: "green1", ai: "green1", brightness: "green2", sink: "green2", media: "green2", radio: "green2"
        })
        readonly property color viewTone: currentView ? Theme.eyes[currentView.tone] : accent

        function tone(item) {
            return Theme.eyes[kindTones[item?.kind]] ?? viewTone;
        }

        // the query's words in a title, in bold; the folding keeps lengths, so its
        // offsets hold in the title
        function marked(title) {
            const folded = Search.fold(title);
            const spans = Search.tokens(query).map(token => [folded.indexOf(token), token.length]).filter(([at]) => at >= 0).sort((a, b) => a[0] - b[0]);
            const escape = text => text.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
            let html = "", from = 0;
            for (const [at, length] of spans) {
                if (at < from)
                    continue;
                html += escape(title.slice(from, at)) + `<b>${escape(title.slice(at, at + length))}</b>`;
                from = at + length;
            }
            return html + escape(title.slice(from));
        }
        readonly property var currentView: views.find(view => view.mode === mode) ?? null

        readonly property string clipboardText: clipboardOut.text
        readonly property string selectedText: selectionOut.text
        property var userConfig: ({ snippets: [], quicklinks: [], aiCommands: [] })
        property string mode: ""   // "" searches everything, else the mode of one of `views`
        readonly property string query: search.text.trim()
        readonly property var results: collect()
        property int current: -1
        property string selectedKey: ""
        readonly property var selection: current >= 0 && current < results.length ? results[current] : null
        // one thumbnail makes every row of the list as tall as a thumbnail row,
        // except in the clipboard, where text entries stay compact among images
        readonly property bool thumbs: mode !== "clipboard" && results.some(item => item.thumb)
        property bool keepSelection: false
        property string armed: ""
        property string notice: ""
        property var actionTarget: null   // the item whose Ctrl+K panel is open
        property string savedQuery: ""

        // a form runs its fields one by one through the search field
        property var form: null   // { title, fields: [{ key, label, value, options, optional, strict: only an option }], submit: values => closes, closeOnCancel }
        property int formStep: 0
        property var formValues: ({})
        readonly property var formField: form ? form.fields[formStep] : null

        readonly property string tag: actionTarget ? "Actions" : form ? form.title : currentView && !currentView.chip ? currentView.title.replace(/^Search /, "") : ""
        readonly property string completion: {
            const top = results[0];
            const typed = search.text;
            if (form || !top || top.kind !== "app" || !typed || search.cursorPosition !== typed.length || !top.title.toLowerCase().startsWith(typed.toLowerCase()))
                return "";
            return top.title.slice(typed.length) + " — Application";
        }

        // the search of everything only needs its sources once something is typed,
        // and checks them once per opening: a source landing mid-typing recomputes
        // every result
        property bool sourcesChecked: false
        onQueryChanged: {
            keepSelection = false;
            if (mode || !query)
                return;
            if (!sourcesChecked) {
                sourcesChecked = true;
                windows.load();
                herdr.load();
                library.load();
                passwords.load();
                ssh.load();
                files.load();
                system.load();
                scripts.load();
            }
            if (query.length >= 2)
                web.load();
            if (query.startsWith(":"))
                snippets.load();
        }
        // currentView may not have caught up with mode yet in here
        onModeChanged: {
            keepSelection = false;
            views.find(view => view.mode === mode)?.open?.();
        }
        onResultsChanged: {
            const kept = keepSelection ? results.findIndex(item => item.key === selectedKey) : -1;
            select(kept >= 0 ? kept : 0);
        }
        onSelectedKeyChanged: refreshPeek()

        IpcHandler {
            target: "spotlight"

            // `mode`: a view, "mark-add" (ask for a mark for the focused window) or ""
            function toggle(mode: string): void {
                win.toggle(mode);
            }
        }

        // spotlight.sh writes "toggle <mode>" lines here: a printf from the shell
        // answers a key press much sooner than starting `qs ipc` (~60 ms). cat
        // holds the fifo open read-write, so it never sees an end and writers never
        // block; the fifo is made anew, so a cat left behind by a crash reads nothing.
        // The pid lets spotlight.sh check that a Spotlight is reading
        Process {
            running: true
            command: ["sh", "-c", 'echo "$PPID" > "$1.pid"; rm -f "$1"; mkfifo -m 600 "$1"; exec cat 0<> "$1"', "sh", (Quickshell.env("XDG_RUNTIME_DIR") || "/tmp") + "/spotlight.fifo"]
            stdout: SplitParser {
                onRead: line => win.toggle(line.replace(/^toggle ?/, ""))
            }
            onRunningChanged: if (!running) running = true
        }

        function toggle(mode) {
            if (shown)
                close();
            else
                open(mode);
        }

        // whole pixels keep text and icons on the pixel grid, so they stay sharp
        function px(value) {
            return Math.round(value * u);
        }

        function open(requested) {
            windows.forget();
            if (requested === "mark-add")
                marks.promptAdd();
            else
                mode = views.some(view => view.mode === requested) ? requested : "";
            shown = true;
            agenda.load();
            search.forceActiveFocus();
            fadeIn.restart();
            clipboardNow.running = true;
            selectionNow.running = true;
            Wallpaper.refresh();
        }

        // everything goes back to an empty search, so the next opening starts clean
        function close() {
            shown = false;
            sourcesChecked = false;
            form = null;
            actionTarget = null;
            mode = "";
            search.text = "";
            armed = "";
            notice = "";
            ai.reset();
        }

        function notify(message) {
            notice = message;
            noticeTimer.restart();
        }

        function openView(name) {
            search.text = "";
            mode = name;
        }

        function setQuery(text) {
            search.text = text;
        }

        // the step resets first: setting `form` recomputes the list for formStep
        function openForm(spec) {
            formStep = 0;
            formValues = {};
            form = spec;
            search.text = spec.fields[0].value ?? "";
        }

        // the alias must find its result again, which rules out what only a live
        // query produces (files found by fd, an answer of pi)
        function aliasForm(target) {
            openForm({
                title: "Alias for " + target.title,
                fields: [{ key: "alias", label: "Alias", value: aliases.aliasOf(target.key) }],
                submit: values => {
                    const alias = values.alias.trim().toLowerCase();
                    if (!resolveAlias({ key: target.key, kind: target.kind, title: target.title })) {
                        notify("This kind of result can't keep an alias");
                        return false;
                    }
                    aliases.set(alias, target);
                    notify(`Type “${alias}” to get ${target.title}`);
                    return false;
                }
            });
        }

        function resolveAlias(entry) {
            const found = [].concat(...everything(Search.tokens(entry.title), entry.title, true).map(([section, list]) => list));
            return found.find(item => item.key === entry.key) ?? found.find(item => item.kind === entry.kind && item.title === entry.title) ?? null;
        }

        function formNext(value) {
            const field = form.fields[formStep];
            if (!value && !field.optional) {
                notify(field.label + " is required");
                return;
            }
            const values = Object.assign({}, formValues, { [field.key]: value });
            if (formStep + 1 < form.fields.length) {
                formValues = values;
                formStep++;
                search.text = form.fields[formStep].value ?? "";
                return;
            }
            const spec = form;
            form = null;
            search.text = "";
            if (spec.submit(values))
                close();
        }

        function formItems() {
            const field = form.fields[formStep];
            const typed = query;
            const options = field.options ?? [];
            const tokens = Search.tokens(typed);
            const section = `${form.title} · ${field.label}`;
            const items = [];
            if (typed && !options.includes(typed) && !field.strict)
                items.push({ key: "form:typed", kind: "form", section, title: options.length ? `Use “${typed}”` : typed, value: typed, icon: "document-edit" });
            if (!typed && (!options.length || field.optional))
                items.push({ key: "form:empty", kind: "form", section, title: field.optional ? `Leave the ${field.label.toLowerCase()} empty` : `Type the ${field.label.toLowerCase()}`, value: "", icon: "document-edit" });
            for (const option of options.filter(option => Spot.matches(option, tokens)))
                items.push({ key: "form:" + option, kind: "form", section, title: option, value: option, icon: "folder" });
            return items;
        }

        function actionItems() {
            const tokens = Search.tokens(query);
            const alias = aliases.aliasOf(actionTarget.key);
            const own = [["", alias ? `Change alias “${alias}”…` : "Set alias…", "alias"], ...(alias ? [["", "Remove alias", "unalias"]] : [])];
            return [...(describe(actionTarget).actions ?? []), ...own]
                .filter(([keys, label]) => Spot.matches(label + " " + keys, tokens))
                .map(([keys, label, name]) => ({ key: "action:" + (name ?? keys), kind: "action", section: "Actions · " + actionTarget.title, title: label, hint: keys, shortcut: keys, name, icon: actionTarget.icon, glyph: actionTarget.glyph, swatch: actionTarget.swatch }));
        }

        // "hr " (an alias and a space) opens that view at once; "?" opens the help
        function jumpToAlias(text) {
            if (mode || form || actionTarget)
                return;
            const typed = text === "?" ? "? " : text;
            const match = typed.match(/^(\S+) $/);
            const target = match && views.find(view => view.alias === match[1].toLowerCase());
            if (target)
                openView(target.mode);
        }

        function cycleMode(step) {
            const order = ["", ...chips.map(chip => chip.mode)];
            const at = Math.max(0, order.indexOf(mode));
            mode = order[(at + step + order.length) % order.length];
        }

        function openActions() {
            const item = selection;
            if (!item || item.kind === "form" || item.kind === "action")
                return;
            savedQuery = search.text;
            actionTarget = item;
            search.text = "";
        }

        function closeActions() {
            const key = actionTarget.key;
            actionTarget = null;
            search.text = savedQuery;
            keepSelection = true;
            select(Math.max(0, results.findIndex(item => item.key === key)));
        }

        // runs one of the panel's [keys, label] actions on the item it was opened for;
        // a [keys, label, name] action goes to the store's act() as `name`
        function runShortcut(target, shortcut, name) {
            closeActions();
            if (name === "alias") {
                aliasForm(target);
                return;
            }
            if (name === "unalias") {
                aliases.remove(target.key);
                notify("Alias removed");
                return;
            }
            if (name) {
                act(target, name, true);
                return;
            }
            switch (shortcut) {
            case "Ctrl+C":
                copyItem(target);
                return;
            case "Ctrl+P":
                act(target, "pin", true);
                return;
            case "Ctrl+X":
                act(target, "delete", true);
                return;
            case "Ctrl+E":
                act(target, "edit", true);
                return;
            case "Ctrl+R":
                act(target, "rename", true);
                return;
            }
            armed = target.key;   // picking it from the panel is the confirmation
            activate(target, { ctrl: shortcut === "Ctrl+Enter", shift: shortcut === "Shift+Enter" });
        }

        function scrollPreview(delta) {
            preview.contentY = Math.max(0, Math.min(preview.contentHeight - preview.height, preview.contentY + delta));
        }

        function back() {
            if (actionTarget) {
                closeActions();
            } else if (form?.closeOnCancel) {
                close();
            } else if (form) {
                form = null;
                search.text = "";
            } else if (mode) {
                mode = "";
            } else if (search.text) {
                search.text = "";
            } else {
                close();
            }
        }

        function commandItems(tokens) {
            return [...commands.items(tokens), ...system.items(tokens), ...commands.viewItems(tokens), ...commands.toolItems(tokens), ...library.commandItems(tokens), ...herdr.commandItems(tokens), ...colors.pickItem(tokens), ...notifications.commandItems(tokens), ...commands.mediaItems(tokens), ...apps.actionItems(tokens), ...scripts.items(tokens), ...scripts.commandItems(tokens), ...agenda.commandItems(tokens)];
        }

        // best first: how well the title matches plus how often the item was picked
        // (apps: launched); `lead` items stay ahead. Each item is copied with its
        // score, which picks the Top Hit. An empty query keeps the store's order
        function ranked(items, tokens) {
            if (!tokens.length)
                return items;
            return items
                .map((item, index) => ({ item, index, score: (Search.score(Search.fold(item.title), tokens) || 0.4) + (item.lead ? 1 : 0) + Search.boost(item.uses ?? frecency.weight(item.key)) }))
                .sort((a, b) => b.score - a.score || a.index - b.index)
                .map(({ item, score }) => Object.assign({ score }, item));
        }

        // the search of everything: [section, items] pairs, best kinds first; an
        // alias typed alone puts its result above them (`resolving` finds that
        // result, so aliases are left out)
        function everything(tokens, raw, resolving = false) {
            if (!tokens.length)
                return [["Up Next", agenda.soonItems()]];
            const aliased = resolving ? null : aliases.get(raw) && resolveAlias(aliases.get(raw));
            if (aliased)
                return [["Alias", [aliased]], ...everything(tokens, raw, true).map(([section, list]) => [section, list.filter(item => item.key !== aliased.key)])];
            const view = views.find(entry => entry.alias === raw.toLowerCase());
            const found = {
                apps: ranked(apps.items(raw), tokens),
                commands: ranked(commandItems(tokens).filter(item => item.key !== "mode:" + view?.mode), tokens),
                quicklinks: ranked(web.quicklinkItems(tokens, raw), tokens),
                bookmarks: ranked(library.bookmarkItems(tokens), tokens),
                snippets: ranked(snippets.snippetItems(tokens), tokens),
                notes: ranked(library.noteItems(tokens), tokens),
                ssh: ranked(ssh.items(tokens), tokens)
            };
            // the best of every kind that is opened by name, if its title matches;
            // apps win a tie
            const top = Object.values(found).map(list => list[0]).filter(item => item?.score >= 0.5).reduce((best, item) => !best || item.score > best.score ? item : best, null);
            const rest = list => list.filter(item => item !== top);
            // a DOI like 10.1145/3292500.3330701 is no sum
            const answer = papers.target ? [] : calculator.items(raw);
            return [
                ["Views", view ? [Object.assign(commands.viewItem(view), { key: "alias:" + view.mode })] : []],
                ["Paper", papers.items()],
                ["Calculator", answer],
                ["Website", web.urlItems(raw)],
                ["Quicklinks", rest(found.quicklinks).slice(0, 3)],
                ["SSH", tokens[0] === "ssh" ? rest(found.ssh) : []],
                ["Timers", ["timer", "pomodoro"].includes(tokens[0]) ? timers.items(tokens, raw.replace(/^timer\s*/i, ""), false) : []],
                ["Top Hit", top ? [top] : []],
                ["Applications", rest(found.apps).slice(0, 5)],
                ["Windows", windows.items(tokens, 4)],
                ["Herdr", [...herdr.agentItems(tokens).slice(0, 3), ...herdr.workspaceItems(tokens).slice(0, 2)]],
                ["Agenda", agenda.searchItems(tokens)],
                ["Commands", rest(found.commands).slice(0, 5)],
                ["AI Commands", ranked(ai.commandItems(tokens), tokens).slice(0, 3)],
                ["SSH", tokens[0] === "ssh" ? [] : rest(found.ssh).slice(0, 4)],
                ["Snippets", rest(found.snippets).slice(0, 3)],
                ["Bookmarks", rest(found.bookmarks).slice(0, 4)],
                ["Notes", rest(found.notes).slice(0, 3)],
                ["Passwords", ranked(passwords.items(tokens), tokens).slice(0, 3)],
                ["GitHub", ranked(web.repoItems(tokens), tokens).slice(0, 4)],
                ...files.sections(tokens, true),
                ["Documents", answer.length ? [] : files.contentItems().slice(0, 3)],
                ["AI", ai.askItems(raw)],
                ["Web", web.searchItems(raw)]
            ];
        }

        // ":" searches emoji and ">" runs a command from any view
        function collect() {
            if (actionTarget)
                return actionItems();
            if (form)
                return formItems();
            const raw = query;
            const tokens = Search.tokens(raw.replace(/^[:>]/, ""));
            let sections;
            if (raw.startsWith(":"))
                sections = [["Emoji", snippets.emojiItems(tokens)]];
            else if (!mode && raw.startsWith(">"))
                sections = [["Run", run.items(raw.slice(1).trim(), false)]];
            else
                sections = currentView ? currentView.sections(tokens, raw) : everything(tokens, raw);
            const items = [];
            for (const [section, list] of sections)
                for (const item of list)
                    items.push(Object.assign({ section }, item));
            return items;
        }

        // `actions` are [keys, label] pairs: they feed the footer and the Ctrl+K panel;
        // [keys, label, name] ones (keys may be "") run store.act(item, name)
        function describe(item) {
            if (item.kind === "action")
                return describe(actionTarget);
            if (item.kind === "form")
                return { icon: item.icon, title: form.title, subtitle: `Step ${formStep + 1} of ${form.fields.length}: ${form.fields[formStep].label}`, metadata: Object.entries(formValues), footer: "Enter continues · Esc cancels" };
            const info = item.store.describe(item);
            const alias = aliases.aliasOf(item.key);
            return alias ? Object.assign({}, info, { metadata: [...(info.metadata ?? []), ["Alias", alias]] }) : info;
        }

        function select(index) {
            if (!results.length) {
                current = -1;
                selectedKey = "";
                return;
            }
            current = Math.max(0, Math.min(results.length - 1, index));
            selectedKey = results[current].key;
            armed = "";
            if (current === 0) {
                list.positionViewAtBeginning();
                return;
            }
            list.positionViewAtIndex(current, ListView.Contain);
            // keep the selection clear of the fade at the bottom of the list, but not
            // while the panel is still opening and the list too short to hold a row
            const row = list.itemAtIndex(current);
            if (row && list.height >= row.height + list.fade)
                list.contentY = Math.max(list.originY, Math.min(Math.max(list.contentY, row.y + row.height + list.fade - list.height), list.originY + list.contentHeight - list.height));
        }

        // a selection the user moved survives results arriving late (files)
        function pick(index) {
            keepSelection = true;
            select(index);
        }

        // one row up or down, wrapping around the ends
        function step(delta) {
            if (results.length)
                pick((current + delta + results.length) % results.length);
        }

        function refreshPeek() {
            const item = results[current];
            if (item?.store?.peek)
                item.store.peek(item);
        }

        function activate(item, keys) {
            if (!item)
                return;
            if (item.kind === "action") {
                runShortcut(actionTarget, item.shortcut, item.name);
                return;
            }
            if (item.kind === "form") {
                formNext(item.value);
                return;
            }
            if (item.confirm && armed !== item.key) {
                armed = item.key;
                return;
            }
            armed = "";
            frecency.bump(item.key);
            if (item.store.activate(item, keys))
                close();
        }

        function copyItem(item) {
            if (!item || item.kind === "form" || item.kind === "action")
                return;
            frecency.bump(item.key);
            if (item.store.copy)
                item.store.copy(item);
            else
                Spot.copy(item.value ?? item.title);
            close();
        }

        // Ctrl+P / Ctrl+X / Ctrl+E / Ctrl+R on a store item; deleting asks twice
        // unless it was confirmed by picking it from the Ctrl+K panel
        function act(item, action, confirmed) {
            if (!item?.store?.act)
                return;
            if (action === "delete" && !confirmed && armed !== item.key + ":delete") {
                armed = item.key + ":delete";
                return;
            }
            armed = "";
            if (item.store.act(item, action))
                close();
        }

        Frecency {
            id: frecency
        }
        Aliases {
            id: aliases
        }
        ScriptStore {
            id: scripts
            host: win
        }
        AgendaStore {
            id: agenda
            host: win
        }
        AppStore {
            id: apps
        }
        FileStore {
            id: files
            query: (win.mode === "" || win.mode === "files") && !win.form && !win.actionTarget && !/^[:>]/.test(win.query) ? win.query : ""
            contentQuery: (win.mode === "" || win.mode === "contents") && !win.form && !win.actionTarget && !/^[:>]/.test(win.query) ? win.query : ""
        }
        WindowStore {
            id: windows
            capturing: win.mode === "windows" ? "all" : win.mode === "marks" ? "marked" : ""
        }
        CommandStore {
            id: commands
            host: win
        }
        HelpStore {
            id: help
            host: win
        }
        SnippetStore {
            id: snippets
            host: win
        }
        WebStore {
            id: web
            host: win
        }
        CalculatorStore {
            id: calculator
            query: win.mode === "" && !win.form && !win.actionTarget ? win.query : ""
        }
        PaperStore {
            id: papers
            host: win
            library: library
            query: win.mode === "" && !win.form && !win.actionTarget ? win.query : ""
        }
        AiStore {
            id: ai
            host: win
        }
        SshStore {
            id: ssh
        }
        PasswordStore {
            id: passwords
        }
        RunStore {
            id: run
        }
        ClipboardStore {
            id: clipboard
            host: win
        }
        LibraryStore {
            id: library
            host: win
        }
        BrowserStore {
            id: browser
            host: win
        }
        TimerStore {
            id: timers
            host: win
        }
        ColorStore {
            id: colors
            host: win
        }
        ProcessStore {
            id: processes
            host: win
        }
        MarkStore {
            id: marks
            host: win
            windows: windows
        }
        HerdrStore {
            id: herdr
            host: win
            windows: windows
            files: files
        }
        WallpaperStore {
            id: wallpapers
            host: win
        }
        SystemStore {
            id: system
            host: win
        }
        NotificationStore {
            id: notifications
        }

        FileView {
            path: Spot.home + "/.config/quickshell/spotlight/spotlight.json"
            blockLoading: true
            watchChanges: true
            onFileChanged: reload()
            onLoaded: win.userConfig = JSON.parse(text())
        }

        Process {
            id: clipboardNow
            command: ["wl-paste", "--no-newline", "--type", "text"]
            stdout: StdioCollector {
                id: clipboardOut
            }
        }
        Process {
            id: selectionNow
            command: ["wl-paste", "--primary", "--no-newline", "--type", "text"]
            stdout: StdioCollector {
                id: selectionOut
            }
        }

        Timer {
            id: noticeTimer
            interval: 5000
            onTriggered: win.notice = ""
        }

        screen: FocusedOutput.screen
        color: "transparent"
        WlrLayershell.layer: shown ? WlrLayer.Overlay : WlrLayer.Background
        WlrLayershell.namespace: "qs-spotlight"
        WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
        mask: shown ? null : noInput
        exclusionMode: ExclusionMode.Ignore
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        Region {
            id: noInput
        }

        MouseArea {
            anchors.fill: parent
            visible: win.shown
            onClicked: win.close()
        }

        // "Ctrl+Enter" as keycaps: Ctrl ↵
        component KeyCaps: Row {
            id: keyCaps
            property string keys: ""
            spacing: win.px(3)

            Repeater {
                model: keyCaps.keys.split("+").map(key => key === "Enter" ? "↵" : key)

                Rectangle {
                    required property string modelData
                    width: Math.max(height, capText.implicitWidth + win.px(10))
                    height: win.px(20)
                    radius: win.px(5)
                    color: win.hairline

                    Label {
                        id: capText
                        anchors.centerIn: parent
                        text: parent.modelData
                        color: win.inkSoft
                        font.pixelSize: win.px(11)
                    }
                }
            }
        }

        component Label: Text {
            color: win.ink
            font.family: Theme.menuText
            font.pixelSize: win.px(14)
            textFormat: Text.PlainText
            renderType: Text.NativeRendering
        }

        RectangularShadow {
            anchors.fill: panel
            radius: panel.radius
            blur: win.px(50)
            offset.y: win.px(18)
            color: Qt.rgba(0, 0, 0, win.dark ? 0.55 : 0.3)
            opacity: panel.opacity
            visible: win.shown
        }

        Item {
            id: panel
            readonly property bool expanded: win.results.length > 0 || win.notice !== ""
            readonly property real radius: win.px(14)

            width: win.px(820)
            height: bar.height + (expanded ? win.px(460) + actionBar.height : 0)
            Behavior on height { enabled: win.shown; NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
            visible: win.shown
            x: Math.round((parent.width - width) / 2)
            y: Math.round(parent.height * 0.2)

            NumberAnimation on opacity { id: fadeIn; from: 0; to: 1; duration: 140 }

            MouseArea {
                anchors.fill: parent
            }

            Item {
                anchors.fill: parent
                layer.enabled: true
                layer.effect: MultiEffect {
                    maskEnabled: true
                    maskSource: glassMask
                    maskThresholdMin: 0.5
                    maskSpreadAtMin: 1
                }

                WallBlur {
                    x: -panel.x
                    y: -panel.y
                    width: win.width
                    height: win.height
                }
                Rectangle {
                    anchors.fill: parent
                    color: win.glass
                }
            }
            Item {
                id: glassMask
                anchors.fill: parent
                layer.enabled: true
                visible: false
                Rectangle {
                    anchors.fill: parent
                    radius: panel.radius
                }
            }
            Rectangle {
                anchors.fill: parent
                radius: panel.radius
                color: "transparent"
                border.width: 1
                border.color: Theme.border
            }

            Item {
                id: bar
                width: parent.width
                height: win.px(64)

                Label {
                    id: glassIcon
                    x: win.px(24)
                    anchors.verticalCenter: parent.verticalCenter
                    text: "\uf002"
                    color: win.inkSoft
                    font.family: Theme.menu
                    font.pixelSize: win.px(22)
                }

                Rectangle {
                    id: tagPill
                    anchors.left: glassIcon.right
                    anchors.leftMargin: win.px(12)
                    anchors.verticalCenter: parent.verticalCenter
                    visible: win.tag !== ""
                    width: win.tag !== "" ? tagText.implicitWidth + win.px(20) : 0
                    height: win.px(28)
                    radius: height / 2
                    color: win.actionTarget || win.form ? win.accent : win.viewTone

                    Label {
                        id: tagText
                        anchors.centerIn: parent
                        text: win.tag
                        color: win.accentText
                        font.pixelSize: win.px(13)
                        font.weight: Font.DemiBold
                    }
                }

                TextInput {
                    id: search
                    anchors.left: tagPill.right
                    anchors.leftMargin: win.px(12)
                    anchors.right: chipRow.left
                    anchors.rightMargin: win.px(12)
                    anchors.verticalCenter: parent.verticalCenter
                    focus: true
                    clip: true
                    color: win.ink
                    selectionColor: win.highlight
                    selectedTextColor: win.highlightText
                    font.family: Theme.menu
                    font.pixelSize: win.px(26)
                    renderType: Text.NativeRendering
                    onTextChanged: win.jumpToAlias(text)

                    Keys.onPressed: event => {
                        const ctrl = (event.modifiers & Qt.ControlModifier) !== 0;
                        const shift = (event.modifiers & Qt.ShiftModifier) !== 0;
                        const quiet = search.selectedText === "";
                        const listing = win.form || win.actionTarget;
                        if (ctrl && (event.key === Qt.Key_Question || event.key === Qt.Key_Slash) && !listing) {
                            win.mode = win.mode === "help" ? "" : "help";
                        } else if (ctrl && event.key === Qt.Key_K) {
                            if (win.actionTarget)
                                win.closeActions();
                            else
                                win.openActions();
                        } else if (ctrl && event.key >= Qt.Key_1 && event.key < Qt.Key_1 + win.chips.length) {
                            const picked = win.chips[event.key - Qt.Key_1].mode;
                            win.mode = win.mode === picked ? "" : picked;
                        } else if (ctrl && event.key === Qt.Key_C && quiet) {
                            win.copyItem(win.selection);
                        } else if (ctrl && event.key === Qt.Key_X && quiet) {
                            win.act(win.selection, "delete", false);
                        } else if (ctrl && event.key === Qt.Key_P) {
                            win.act(win.selection, "pin", false);
                        } else if (ctrl && event.key === Qt.Key_E) {
                            win.act(win.selection, "edit", false);
                        } else if (ctrl && event.key === Qt.Key_R) {
                            win.act(win.selection, "rename", false);
                        } else if (ctrl && event.key === Qt.Key_T && win.mode === "clipboard") {
                            clipboard.cycleFilter();
                        } else if (ctrl && (event.key === Qt.Key_Up || event.key === Qt.Key_Down)) {
                            win.scrollPreview(event.key === Qt.Key_Down ? 120 : -120);
                        } else if (ctrl && event.key === Qt.Key_Home) {
                            win.pick(0);
                        } else if (ctrl && event.key === Qt.Key_End) {
                            win.pick(win.results.length - 1);
                        } else if (event.key === Qt.Key_Escape) {
                            win.back();
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            win.activate(win.selection, { ctrl, shift });
                        } else if (event.key === Qt.Key_Tab) {
                            if (listing)
                                win.step(1);
                            else
                                win.cycleMode(1);
                        } else if (event.key === Qt.Key_Backtab) {
                            if (listing)
                                win.step(-1);
                            else
                                win.cycleMode(-1);
                        } else if (event.key === Qt.Key_Right && win.completion) {
                            search.text = win.results[0].title;
                        } else if (event.key === Qt.Key_Down) {
                            win.step(1);
                        } else if (event.key === Qt.Key_Up) {
                            win.step(-1);
                        } else if (event.key === Qt.Key_PageDown) {
                            win.pick(win.current + 8);
                        } else if (event.key === Qt.Key_PageUp) {
                            win.pick(win.current - 8);
                        } else {
                            return;
                        }
                        event.accepted = true;
                    }

                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        width: search.width
                        elide: Text.ElideRight
                        visible: search.text === ""
                        text: win.actionTarget ? `Search actions for ${win.actionTarget.title}` : win.formField ? win.formField.label : win.currentView ? win.currentView.placeholder ?? win.currentView.title : "Search"
                        color: win.inkSoft
                        font: search.font
                    }
                    Label {
                        x: search.contentWidth
                        anchors.verticalCenter: parent.verticalCenter
                        text: win.completion
                        color: win.inkSoft
                        font: search.font
                    }
                }

                Row {
                    id: chipRow
                    anchors.right: parent.right
                    anchors.rightMargin: win.px(18)
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: win.px(4)

                    Repeater {
                        model: win.chips

                        Rectangle {
                            id: chip
                            required property var modelData
                            readonly property bool active: win.mode === modelData.mode
                            width: win.px(30)
                            height: win.px(30)
                            radius: height / 2
                            color: active ? Theme.eyes[modelData.tone] : "transparent"

                            Label {
                                anchors.centerIn: parent
                                text: chip.modelData.chip
                                color: chip.active ? win.accentText : win.inkSoft
                                font.family: Theme.menu
                                font.pixelSize: win.px(14)
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: win.mode = chip.active ? "" : chip.modelData.mode
                            }
                        }
                    }
                }
            }

            Item {
                anchors.top: bar.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                clip: true
                opacity: panel.expanded ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 120 } }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: win.hairline
                }

                Row {
                    id: clipboardFilters
                    // not `visible`, which is false while Spotlight is hidden
                    readonly property bool filtering: win.mode === "clipboard" && !win.form
                    visible: filtering
                    x: win.px(10)
                    y: win.px(8)
                    height: filtering ? win.px(38) : 0
                    spacing: win.px(6)
                    leftPadding: win.px(6)
                    topPadding: win.px(4)

                    Repeater {
                        model: clipboard.filters

                        Rectangle {
                            id: pill
                            required property string modelData
                            readonly property bool active: clipboard.filter === modelData
                            width: pillText.implicitWidth + win.px(22)
                            height: win.px(26)
                            radius: height / 2
                            color: active ? win.viewTone : win.fill

                            Label {
                                id: pillText
                                anchors.centerIn: parent
                                text: pill.modelData[0].toUpperCase() + pill.modelData.slice(1)
                                color: pill.active ? win.accentText : win.ink
                                font.pixelSize: win.px(12)
                                font.weight: Font.DemiBold
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: clipboard.filter = pill.modelData
                            }
                        }
                    }

                    Label {
                        topPadding: win.px(6)
                        text: "Ctrl+T"
                        color: win.inkSoft
                        font.pixelSize: win.px(11)
                    }
                }

                ListView {
                    id: list
                    readonly property int fade: win.px(40)
                    x: win.px(10)
                    y: win.px(8) + clipboardFilters.height
                    width: win.currentView?.wide ? win.px(410) : win.px(330)
                    height: parent.height - win.px(16) - clipboardFilters.height - actionBar.height
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    model: win.results
                    layer.enabled: !atYEnd
                    layer.effect: MultiEffect {
                        maskEnabled: true
                        maskSource: listFade
                        maskSpreadAtMin: 1
                    }

                    delegate: Column {
                        id: row
                        required property var modelData
                        required property int index
                        readonly property bool isCurrent: index === win.current
                        readonly property bool opensSection: index === 0 || win.results[index - 1]?.section !== modelData.section
                        width: ListView.view.width

                        Label {
                            visible: row.opensSection
                            leftPadding: win.px(10)
                            topPadding: row.index ? win.px(12) : win.px(4)
                            bottomPadding: win.px(4)
                            text: row.modelData.section
                            color: win.inkSoft
                            font.pixelSize: win.px(11)
                            font.weight: Font.Bold
                        }

                        Rectangle {
                            width: parent.width
                            height: win.thumbs || row.modelData.thumb ? win.px(44) : win.px(34)
                            radius: win.px(8)
                            color: row.isCurrent ? win.highlight : rowMouse.containsMouse ? win.hairline : "transparent"

                            Item {
                                id: rowIcon
                                x: win.px(8)
                                anchors.verticalCenter: parent.verticalCenter
                                width: win.thumbs || row.modelData.thumb ? win.px(36) : win.px(22)
                                height: row.modelData.thumb ? win.px(32) : win.px(22)

                                Rectangle {
                                    anchors.fill: parent
                                    visible: !!row.modelData.swatch
                                    radius: win.px(6)
                                    color: row.modelData.swatch ?? "transparent"
                                    border.width: 1
                                    border.color: win.hairline
                                }
                                Image {
                                    anchors.fill: parent
                                    visible: !!row.modelData.thumb
                                    fillMode: Image.PreserveAspectCrop
                                    sourceSize: Qt.size(win.px(96), win.px(96))
                                    source: row.modelData.thumb ?? ""
                                    cache: false
                                    asynchronous: true
                                }
                                Image {
                                    anchors.centerIn: parent
                                    width: win.px(22)
                                    height: win.px(22)
                                    // not `visible`, which is false while Spotlight is hidden
                                    readonly property bool showsIcon: !row.modelData.glyph && !row.modelData.thumb && !row.modelData.swatch
                                    visible: showsIcon
                                    sourceSize: Qt.size(win.px(44), win.px(44))
                                    source: showsIcon ? Quickshell.iconPath(row.modelData.icon ?? "", "application-x-executable") : ""
                                    asynchronous: true
                                }
                                Label {
                                    anchors.centerIn: parent
                                    visible: !!row.modelData.glyph && !row.modelData.thumb
                                    text: row.modelData.glyph ?? ""
                                    color: row.isCurrent ? win.highlightText : win.tone(row.modelData)
                                    font.family: "Noto Color Emoji"
                                    font.pixelSize: win.px(17)
                                }
                            }
                            Label {
                                id: rowHint
                                anchors.right: parent.right
                                anchors.rightMargin: win.px(10)
                                anchors.verticalCenter: parent.verticalCenter
                                width: Math.min(implicitWidth, parent.width * 0.4)
                                elide: Text.ElideRight
                                text: win.armed === row.modelData.key ? "Press Enter again" : win.armed === row.modelData.key + ":delete" ? "Ctrl+X again to delete" : row.modelData.hint ?? ""
                                color: row.isCurrent ? Qt.alpha(win.highlightText, 0.75) : Theme.eyes.ash
                                font.pixelSize: win.px(12)
                            }
                            Label {
                                anchors.left: rowIcon.right
                                anchors.leftMargin: win.px(10)
                                anchors.right: rowHint.left
                                anchors.rightMargin: win.px(8)
                                anchors.verticalCenter: parent.verticalCenter
                                elide: Text.ElideRight
                                maximumLineCount: 1
                                textFormat: win.query ? Text.StyledText : Text.PlainText
                                text: win.query ? win.marked(row.modelData.title.replace(/\s+/g, " ")) : row.modelData.title.replace(/\s+/g, " ")
                                color: row.isCurrent ? win.highlightText : win.ink
                            }
                            MouseArea {
                                id: rowMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: win.pick(row.index)
                                onDoubleClicked: win.activate(row.modelData, { ctrl: false, shift: false })
                            }
                        }
                    }
                }

                Rectangle {
                    id: listFade
                    width: list.width
                    height: list.height
                    visible: false
                    layer.enabled: true
                    gradient: Gradient {
                        GradientStop { position: 0; color: "white" }
                        GradientStop { position: 1 - list.fade / Math.max(list.height, list.fade); color: "white" }
                        GradientStop { position: 1; color: "transparent" }
                    }
                }

                Rectangle {
                    id: divider
                    x: list.x + list.width + win.px(10)
                    y: 1
                    width: 1
                    height: parent.height - 1 - actionBar.height
                    color: win.hairline
                }

                Flickable {
                    id: preview
                    readonly property var info: win.selection ? win.describe(win.selection) : null
                    anchors.left: divider.right
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: facts.visible ? facts.top : noticeBar.top
                    anchors.margins: win.px(24)
                    anchors.bottomMargin: facts.visible ? win.px(12) : win.px(24)
                    clip: true
                    contentHeight: details.implicitHeight
                    boundsBehavior: Flickable.StopAtBounds
                    visible: info !== null

                    Column {
                        id: details
                        y: win.mode === "clipboard" ? 0 : Math.max(0, (preview.height - implicitHeight) / 2)
                        width: preview.width
                        spacing: win.px(8)

                        Image {
                            width: parent.width
                            height: win.px(200)
                            visible: !!preview.info?.image
                            fillMode: Image.PreserveAspectFit
                            sourceSize: Qt.size(win.px(800), win.px(600))
                            source: preview.info?.image ?? ""
                            asynchronous: true
                        }
                        Rectangle {
                            width: parent.width
                            height: win.px(140)
                            visible: !!preview.info?.swatch
                            radius: win.px(16)
                            color: preview.info?.swatch ?? "transparent"
                            border.width: 1
                            border.color: win.hairline
                        }
                        Image {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: win.px(104)
                            height: win.px(104)
                            readonly property bool showsIcon: !preview.info?.image && !preview.info?.glyph && !preview.info?.swatch && !!preview.info?.icon
                            visible: showsIcon
                            sourceSize: Qt.size(win.px(208), win.px(208))
                            source: showsIcon ? Quickshell.iconPath(preview.info?.icon ?? "", "application-x-executable") : ""
                            asynchronous: true
                        }
                        Label {
                            width: parent.width
                            visible: !!preview.info?.glyph
                            topPadding: win.px(24)
                            horizontalAlignment: Text.AlignHCenter
                            fontSizeMode: Text.HorizontalFit
                            minimumPixelSize: win.px(18)
                            text: preview.info?.glyph ?? ""
                            color: win.selection?.kind === "emoji" ? win.ink : win.tone(win.selection)
                            font.family: win.selection?.kind === "emoji" ? "Noto Color Emoji" : Theme.menu
                            font.pixelSize: preview.info?.glyph?.length > 2 ? win.px(48) : win.px(72)
                            font.weight: Font.Bold
                        }
                        Label {
                            width: parent.width
                            visible: text !== ""
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.Wrap
                            text: preview.info?.title ?? ""
                            font.family: Theme.menu
                            font.pixelSize: win.px(20)
                            font.weight: Font.Bold
                        }
                        Label {
                            width: parent.width
                            visible: text !== ""
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.Wrap
                            maximumLineCount: 3
                            elide: Text.ElideMiddle
                            text: preview.info?.subtitle ?? ""
                            color: win.inkSoft
                        }
                        Repeater {
                            model: (preview.info?.details ?? []).filter(line => line)

                            Label {
                                required property string modelData
                                width: details.width
                                horizontalAlignment: Text.AlignHCenter
                                wrapMode: Text.Wrap
                                text: modelData
                                color: win.inkSoft
                                font.pixelSize: win.px(12)
                            }
                        }
                        Rectangle {
                            width: parent.width
                            height: body.implicitHeight + win.px(24)
                            visible: !!preview.info?.body
                            radius: win.px(10)
                            color: win.fill

                            Label {
                                id: body
                                x: win.px(12)
                                y: win.px(12)
                                width: parent.width - win.px(24)
                                wrapMode: Text.Wrap
                                textFormat: preview.info?.markdown ? Text.MarkdownText : Text.PlainText
                                text: preview.info?.body ?? ""
                                color: preview.info?.mono ? Theme.eyes.green1 : win.ink
                                linkColor: Theme.eyes.blue0
                                font.family: preview.info?.mono ? "Iosevka Nerd Font" : Theme.menuText
                                font.pixelSize: preview.info?.mono ? win.px(11) : win.px(13)
                                onLinkActivated: link => Quickshell.execDetached(["xdg-open", link])
                            }
                        }
                    }
                }

                // label → value rows at the foot of the preview, like Raycast's metadata
                Column {
                    id: facts
                    readonly property var rows: (preview.info?.metadata ?? []).filter(([label, value]) => value !== undefined && value !== null && value !== "")
                    anchors.left: divider.right
                    anchors.right: parent.right
                    anchors.bottom: noticeBar.top
                    anchors.leftMargin: win.px(24)
                    anchors.rightMargin: win.px(24)
                    anchors.bottomMargin: win.px(10)
                    visible: preview.visible && rows.length > 0

                    Repeater {
                        model: facts.rows

                        Item {
                            required property var modelData
                            width: facts.width
                            height: win.px(30)

                            Rectangle {
                                width: parent.width
                                height: 1
                                color: win.hairline
                            }
                            Label {
                                id: factLabel
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                text: parent.modelData[0]
                                color: win.inkSoft
                                font.pixelSize: win.px(12)
                            }
                            Label {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                width: Math.min(implicitWidth, parent.width - factLabel.implicitWidth - win.px(16))
                                horizontalAlignment: Text.AlignRight
                                elide: Text.ElideMiddle
                                text: String(parent.modelData[1])
                                font.pixelSize: win.px(12)
                            }
                        }
                    }
                }

                Rectangle {
                    id: noticeBar
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: actionBar.top
                    anchors.margins: win.px(10)
                    height: win.notice ? noticeText.implicitHeight + win.px(16) : 0
                    visible: win.notice !== ""
                    radius: win.px(10)
                    color: Theme.eyes.winterBlue

                    Label {
                        id: noticeText
                        anchors.centerIn: parent
                        width: parent.width - win.px(24)
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.Wrap
                        text: win.notice
                        color: Theme.eyes.blue1
                        font.pixelSize: win.px(13)
                        font.weight: Font.DemiBold
                    }
                }

                // the view on the left; the primary action and the Ctrl+K panel on the
                // right, or a confirmation or a store's own status in their place
                Item {
                    id: actionBar
                    readonly property var info: preview.info
                    readonly property var primary: win.actionTarget ? (win.selection ? ["Enter", win.selection.title] : null) : info?.actions?.[0] ?? null
                    readonly property bool confirming: win.armed !== "" && win.armed.startsWith(win.selectedKey)
                    readonly property string status: confirming ? (win.armed.endsWith(":delete") ? "Press Ctrl+X again to delete it" : "Press Enter again to confirm") : info?.footer ?? ""
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: win.px(40)

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: win.hairline
                    }

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: win.px(16)
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: win.px(8)

                        Image {
                            anchors.verticalCenter: parent.verticalCenter
                            width: win.px(16)
                            height: win.px(16)
                            readonly property string viewIcon: win.actionTarget || win.form ? "" : win.currentView?.icon ?? ""
                            visible: viewIcon !== ""
                            sourceSize: Qt.size(win.px(32), win.px(32))
                            source: viewIcon ? Quickshell.iconPath(viewIcon, "application-x-executable") : ""
                            asynchronous: true
                        }
                        Label {
                            anchors.verticalCenter: parent.verticalCenter
                            text: win.actionTarget ? "Actions" : win.form ? win.form.title : win.currentView ? win.currentView.title.replace(/^Search /, "") : win.selection?.section ?? "Search"
                            color: win.currentView ? win.viewTone : win.selection ? win.tone(win.selection) : win.inkSoft
                            font.pixelSize: win.px(12)
                            font.weight: Font.DemiBold
                        }
                    }

                    Row {
                        anchors.right: parent.right
                        anchors.rightMargin: win.px(14)
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: win.px(8)

                        Label {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: actionBar.status !== ""
                            text: actionBar.status
                            color: !actionBar.confirming ? win.inkSoft : win.armed.endsWith(":delete") ? Theme.eyes.red : Theme.eyes.yellow
                            font.pixelSize: win.px(12)
                            font.weight: actionBar.confirming ? Font.DemiBold : Font.Normal
                        }
                        Label {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: actionBar.status === "" && actionBar.primary !== null
                            text: actionBar.primary?.[1] ?? ""
                            font.pixelSize: win.px(12)
                        }
                        KeyCaps {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: actionBar.status === "" && actionBar.primary !== null
                            keys: actionBar.primary?.[0] ?? ""
                        }
                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: actionsButton.visible && actionBar.status === "" && actionBar.primary !== null
                            width: 1
                            height: win.px(16)
                            color: win.hairline
                        }
                        Row {
                            id: actionsButton
                            anchors.verticalCenter: parent.verticalCenter
                            visible: !actionBar.confirming && (!!win.actionTarget || !!actionBar.info?.actions?.length)
                            spacing: win.px(6)

                            Label {
                                anchors.verticalCenter: parent.verticalCenter
                                text: win.actionTarget ? "Close" : "Actions"
                                color: win.inkSoft
                                font.pixelSize: win.px(12)
                            }
                            KeyCaps {
                                anchors.verticalCenter: parent.verticalCenter
                                keys: "Ctrl+K"
                            }
                            TapHandler {
                                onTapped: win.actionTarget ? win.closeActions() : win.openActions()
                            }
                            HoverHandler {
                                cursorShape: Qt.PointingHandCursor
                            }
                        }
                    }
                }
            }
        }
    }
}
