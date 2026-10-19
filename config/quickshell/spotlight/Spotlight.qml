import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Effects
import qs
import "js/search.js" as Search

// Spotlight/Raycast-style launcher. It stays resident and hidden: spotlight.sh
// toggles it over IPC, optionally straight into a view, so opening it only
// maps a ready window. Every store loads its sources the first time a view or
// a search needs them and keeps them cached between openings (see Source).
// One query searches apps, windows, Herdr, commands, AI commands, SSH hosts,
// snippets, bookmarks, notes, passwords, GitHub repos, files and the text of
// documents, agenda events, script commands, plus math and conversions, DOIs
// (BibTeX), URLs and quicklinks, then offers a question to pi or a web search;
// the selection is previewed on the right. Matching is loose (search.js) and
// results are ranked by how well their title matches plus how often they were
// picked (Frecency), which also picks the Top Hit across kinds. Each view is an
// entry of `views`; each kind of result belongs to a store (AppStore,
// FileStore, ...), which lists, describes and activates its own items. This
// file holds the state (query, results, selection, forms, the Ctrl+K panel)
// and wires the stores; SearchBar, ResultList, Preview and ActionBar draw it,
// Shortcuts maps the keys (listed in help.js, Ctrl+?).
Scope {
    Launcher {
        id: launcher
    }

    PanelWindow {
        id: win
        // the surface stays mapped while hidden: showing a fresh one costs ~40 ms
        // before its first frame. Hidden, it sits in the background layer with no
        // keyboard focus and no input region, and draws nothing
        property bool shown: false


        // `chip`: its glyph in the bar, which lists the views of spotlight.json's
        // `chips` (Ctrl+1…9 and Tab reach them); its alias in spotlight.json plus a
        // space opens the view ("hr " → Herdr); `open` loads what it shows;
        // `grid` shows them as cells (emoji); `preview: "answers"` only for pi's
        // answers and papers, as the search of everything;
        // `preview: false` lists its results across the whole window, as Raycast
        // does where a preview adds little;
        // `tone`: its colour in Theme.eyes
        readonly property var views: [
            { mode: "apps", tone: "blue1", preview: false, chip: "\uf009", title: "Search Apps", icon: "applications-other", sections: (tokens, raw) => [["Applications", apps.items(raw)]] },
            { mode: "files", tone: "aqua", chip: "\uf07b", title: "Search Files", icon: "folder", open: () => files.load(), sections: tokens => files.sections(tokens, false) },
            { mode: "contents", tone: "aqua", title: "Search File Contents", placeholder: "Search inside documents", icon: "x-office-document", open: () => files.load(), sections: () => [["Documents", files.contentItems()]] },
            { mode: "clipboard", tone: "pink", chip: "\uf0ea", title: "Clipboard History", placeholder: "Search Clipboard", icon: "edit-paste", open: () => clipboard.load(), sections: tokens => [["Clipboard", clipboard.items(tokens)]] },
            { mode: "windows", tone: "teal", chip: "\uf2d0", title: "Switch Windows", placeholder: "Search Windows", icon: "preferences-system-windows", open: () => windows.load(), sections: tokens => [["Windows", windows.items(tokens, 80)]] },
            { mode: "emoji", tone: "yellow", preview: false, grid: true, title: "Search Emoji", icon: "face-smile", open: () => snippets.load(), sections: tokens => tokens.length ? [["Emoji", snippets.emojiItems(tokens)]] : [["Frequently Used", snippets.emojiOf(pickedEmoji())], ["Emoji", snippets.allEmoji()]] },
            { mode: "passwords", tone: "red", preview: false, chip: "\uf084", title: "Search Passwords", icon: "dialog-password", open: () => passwords.load(), sections: tokens => [["Passwords", ranked(passwords.items(tokens), tokens)]] },
            { mode: "snippets", tone: "violet", chip: "\uf121", title: "Search Snippets", icon: "insert-text", sections: tokens => [["Snippets", ranked(snippets.snippetItems(tokens), tokens)]] },
            { mode: "commands", tone: "orange0", preview: false, chip: "\uf0e7", title: "Commands", placeholder: "Search Commands", icon: "system-run", open: () => { herdr.load(); system.load(); scripts.load(); windows.load(); files.load(); }, sections: tokens => [["Commands", ranked(commandItems(tokens), tokens)]] },
            { mode: "bookmarks", tone: "blue0", preview: false, title: "Search Bookmarks", icon: "user-bookmarks", open: () => library.load(), sections: tokens => [["Bookmarks", ranked(library.bookmarkItems(tokens), tokens)], ["Commands", library.commandItems(["bookmark"])]] },
            { mode: "notes", tone: "green1", title: "Search Notes", icon: "accessories-text-editor", open: () => library.load(), sections: tokens => [["Notes", ranked(library.noteItems(tokens), tokens)], ["Commands", library.commandItems(["note"])]] },
            { mode: "quicklinks", tone: "blue0", preview: false, title: "Quicklinks", placeholder: "Search Quicklinks", icon: "web-browser", sections: (tokens, raw) => [["Quicklinks", ranked(web.quicklinkItems(tokens, raw), tokens)]] },
            { mode: "processes", tone: "orange1", preview: false, title: "Kill Process", placeholder: "Search Processes", icon: "utilities-system-monitor", open: () => processes.refresh(), sections: tokens => [["Processes", processes.items(tokens)]] },
            { mode: "history", tone: "blue0", preview: false, title: "Search Browser History", icon: "web-browser", open: () => browser.loadHistory(), sections: tokens => [["History", browser.historyItems(tokens)]] },
            { mode: "tabs", tone: "blue0", preview: false, title: "Search Browser Tabs", icon: "web-browser", open: () => browser.loadTabs(), sections: tokens => browser.tabSections(tokens) },
            { mode: "timers", tone: "yellow", preview: false, title: "Timers", placeholder: "Type a duration: 10m tea", icon: "alarm-clock", sections: (tokens, raw) => [["Timers", timers.items(tokens, raw, true)]] },
            { mode: "colors", tone: "pink", title: "Color History", placeholder: "Search Colors", icon: "color-picker", sections: tokens => [["Colors", colors.items(tokens)]] },
            { mode: "notifications", tone: "teal", title: "Notifications", placeholder: "Search Notifications", icon: "preferences-system-notifications", sections: tokens => [["Notifications", notifications.items(tokens)], ["Commands", notifications.commandItems(tokens)]] },
            { mode: "ai", tone: "green1", title: "AI Commands", placeholder: "Search AI Commands", icon: "", glyph: "✦", sections: tokens => [["AI Commands", ranked(ai.commandItems(tokens), tokens)]] },
            { mode: "run", tone: "violet", preview: false, title: "Run Command", placeholder: "Type a command", icon: "system-run", open: () => run.load(), sections: (tokens, raw) => [["Run", run.items(raw, true)]] },
            { mode: "marks", tone: "orange1", title: "Scroll Marks", placeholder: "Search marks or type a new one", icon: "bookmark-new", open: () => windows.reload(), sections: (tokens, raw) => [["Marks", marks.items(tokens, raw)]] },
            { mode: "herdr", tone: "teal", title: "Herdr", placeholder: "Search Herdr agents, workspaces, tabs and panes", icon: "utilities-terminal", open: () => { herdr.load(); windows.load(); files.load(); }, sections: tokens => [["Agents", herdr.agentItems(tokens)], ["Workspaces", herdr.workspaceItems(tokens)], ["Tabs", herdr.tabItems(tokens)], ["Panes", herdr.paneItems(tokens)], ["Herdr", herdr.commandItems(tokens)]] },
            { mode: "agenda", tone: "pink", title: "Agenda", placeholder: "Search events and deadlines", icon: "office-calendar", open: () => agenda.load(), sections: tokens => [...agenda.sections(tokens), ["Commands", agenda.commandItems(tokens)]] },
            { mode: "wallpapers", tone: "aqua", title: "Wallpapers", placeholder: "Search Wallpapers", icon: "preferences-desktop-wallpaper", open: () => wallpapers.load(), sections: tokens => [["Wallpapers", wallpapers.items(tokens)]] },
            { mode: "tools", tone: "green2", preview: false, title: "Tools", placeholder: "Search Tools", icon: "applications-utilities", sections: tokens => [["Tools", ranked(commands.toolItems(tokens), tokens)]] },
            { mode: "wifi", tone: "teal", preview: false, title: "Wi-Fi", placeholder: "Search Wi-Fi networks", icon: "network-wireless", open: () => { wifi.load(); system.load(); }, sections: tokens => [["Networks", wifi.items(tokens)], ["Wi-Fi", [...wifi.commandItems(tokens), ...system.items([...tokens, "wifi"])]]] },
            { mode: "bluetooth", tone: "blue1", preview: false, title: "Bluetooth", placeholder: "Search Bluetooth devices", icon: "bluetooth", open: () => system.load(), sections: tokens => [["Devices", bluetooth.items(tokens)], ["Bluetooth", system.items([...tokens, "bluetooth"])]] },
            { mode: "selection", tone: "violet", preview: "answers", title: "Universal Actions", placeholder: "Search actions for the selection", icon: "edit-select-all", sections: tokens => universal.sections(tokens) },
            { mode: "help", tone: "aqua", title: "Spotlight Help", placeholder: "Search shortcuts and features", icon: "help-about", sections: tokens => [["Help", help.items(tokens)]] }
        ].map(view => Object.assign({}, view, { alias: userConfig.aliases[view.mode] }))
        readonly property var chips: userConfig.chips.map(mode => views.find(view => view.mode === mode)).filter(view => view)
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
        readonly property color viewTone: currentView ? Theme.eyes[currentView.tone] : Theme.accent

        function tone(item) {
            return Theme.eyes[kindTones[item?.kind]] ?? viewTone;
        }

        // what a result is, on the right of a row that spans the window
        readonly property var kindLabels: ({
            app: "Application", mode: "View", file: "File", repo: "Repository", wallpaper: "Wallpaper", help: "Help",
            clip: "Clipboard", pin: "Clipboard", color: "Color", window: "Window", ssh: "SSH Host", notification: "Notification",
            emoji: "Emoji", timer: "Timer", pomodoro: "Timer", password: "Password", process: "Process", mark: "Mark",
            snippet: "Snippet", run: "Shell", bookmark: "Bookmark", quicklink: "Quicklink", url: "Website", web: "Web Search",
            visit: "History", tab: "Tab", note: "Note", paper: "Paper", ai: "AI", aiCommand: "AI Command",
            herdrAgent: "Agent", herdrWorkspace: "Workspace", herdrTab: "Herdr Tab", herdrPane: "Pane", agendaEvent: "Event",
            wifi: "Network", bluetoothDevice: "Device", selection: "Action"
        })

        function kindLabel(item) {
            return kindLabels[item.kind] ?? (item.kind === "form" || item.kind === "action" ? "" : "Command");
        }

        // the query's words in a title, in bold; the folding keeps lengths, so its
        // offsets hold in the title
        function marked(title) {
            const folded = Search.fold(title);
            const spans = queryTokens.map(token => [folded.indexOf(token), token.length]).filter(([at]) => at >= 0).sort((a, b) => a[0] - b[0]);
            const escape = text => text.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
            let html = "", from = 0;
            for (let index = 0; index < spans.length; index++) {
                const [at, length] = spans[index];
                if (at < from)
                    continue;
                html += escape(title.slice(from, at)) + `<b>${escape(title.slice(at, at + length))}</b>`;
                from = at + length;
            }
            return html + escape(title.slice(from));
        }
        readonly property var currentView: views.find(view => view.mode === mode) ?? null
        // the search of everything keeps the whole width but for an answer to read
        // the results say whether they fill the grid: the list and the grid read it
        // from them, so neither sees the other's results for a moment when the view
        // changes (bindings run in no set order: the list once took the 1404 emoji)
        readonly property bool gridView: results.grid === true
        readonly property bool previewing: currentView && currentView.preview !== "answers" ? currentView.preview !== false : ["ai", "aiCommand", "paper", "paperPending"].includes(selection?.kind)

        readonly property string clipboardText: clipboardOut.text
        readonly property string selectedText: selectionOut.text
        property var userConfig: ({ aliases: {}, ai: { model: "", thinking: "" }, chips: [], fallbacks: [], webSearch: "", pomodoro: { focus: 25, break: 5, rounds: 4 }, terminal: [], floatingTerminal: [], browser: [], tools: [], snippets: [], quicklinks: [], aiCommands: [] })
        property string mode: ""   // "" searches everything, else the mode of one of `views`
        property alias search: bar.field
        readonly property string query: search.text.trim()
        // once a keystroke, for every row that marks them in its title
        readonly property var queryTokens: Search.tokens(query)
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
        property string lastQuery: ""   // ↑ brings it back when nothing is listed to move through
        property string largeText: ""   // shown across the screen (LargeType) instead of the panel

        // a form runs its fields one by one through the search field
        property var form: null   // { title, fields: [{ key, label, value, options, optional, strict: only an option, secret: typed hidden }], submit: values => closes, closeOnCancel }
        property int formStep: 0
        property var formValues: ({})
        readonly property var formField: form ? form.fields[formStep] : null

        readonly property string tag: actionTarget ? "Actions" : form ? form.title : currentView && !chips.includes(currentView) ? currentView.title.replace(/^Search /, "") : ""
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
            if (query.startsWith(":"))
                snippets.load();
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

        // "launcher" toggles the fullscreen launcher, which shares this process
        function toggle(mode) {
            if (mode === "launcher")
                launcher.toggle();
            else if (shown)
                close();
            else
                open(mode);
        }

        function open(requested) {
            windows.forget();
            if (requested === "mark-add")
                marks.promptAdd();
            else
                mode = views.some(view => view.mode === requested) ? requested : "";
            // the compositor closes the surface when its output goes away (a monitor
            // unplugged during suspend) and Quickshell never maps it again by itself
            visible = true;
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
            if (query && !form && !actionTarget)
                lastQuery = search.text;
            shown = false;
            sourcesChecked = false;
            form = null;
            actionTarget = null;
            mode = "";
            search.text = "";
            armed = "";
            notice = "";
            largeText = "";
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
                items.push({ key: "form:typed", kind: "form", section, title: field.secret ? "•".repeat(typed.length) : options.length ? `Use “${typed}”` : typed, value: typed, icon: "document-edit" });
            if (!typed && (!options.length || field.optional))
                items.push({ key: "form:empty", kind: "form", section, title: field.optional ? `Leave the ${field.label.toLowerCase()} empty` : `Type the ${field.label.toLowerCase()}`, value: "", icon: "document-edit" });
            for (const option of options.filter(option => Spot.matches(option, tokens)))
                items.push({ key: "form:" + option, kind: "form", section, title: option, value: option, icon: "folder" });
            return items;
        }

        function actionItems() {
            const tokens = Search.tokens(query);
            const alias = aliases.aliasOf(actionTarget.key);
            const own = [["Ctrl+L", "Large Type"], ["", alias ? `Change alias “${alias}”…` : "Set alias…", "alias"], ...(alias ? [["", "Remove alias", "unalias"]] : [])];
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
            case "Ctrl+B":
                act(target, "buffer", true);
                return;
            case "Ctrl+L":
                showLarge(target);
                return;
            }
            armed = target.key;   // picking it from the panel is the confirmation
            activate(target, { ctrl: shortcut === "Ctrl+Enter", shift: shortcut === "Shift+Enter" });
        }

        // → on a folder browses into it, ← at the end of a browsed path goes up
        function isFolder(item) {
            return item?.kind === "file" && item.isDir && (!mode || mode === "files");
        }

        function browse(path) {
            search.text = Spot.tilde(path) + "/";
        }

        function atBrowsedFolder() {
            return files.isPath(search.text) && search.text.endsWith("/") && search.cursorPosition === search.text.length;
        }

        function browseUp() {
            search.text = files.parentPath(search.text);
        }

        // Ctrl+L: the result's value (a calculation, an emoji, a path…) or what was typed
        function showLarge(item) {
            const usable = item && item.kind !== "form" && item.kind !== "action";
            largeText = usable ? (typeof item.value === "string" && item.value ? item.value : item.title) : query;
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
            // concat, as V4 spreads an array element by element through its iterator
            return commands.items(tokens).concat(system.items(tokens), commands.viewItems(tokens), commands.toolItems(tokens), library.commandItems(tokens), herdr.commandItems(tokens), colors.pickItem(tokens), notifications.commandItems(tokens), commands.mediaItems(tokens), apps.actionItems(tokens), scripts.items(tokens), scripts.commandItems(tokens), agenda.commandItems(tokens), windows.quitItems(tokens));
        }

        // the 16 emoji picked most
        function pickedEmoji() {
            return Object.keys(frecency.picks).filter(key => key.startsWith("emoji:")).map(key => [key, frecency.weight(key)]).sort((a, b) => b[1] - a[1]).slice(0, 16).map(([key]) => key.slice(6));
        }

        // best first: how well the title matches plus how often the item was picked
        // (apps: launched); `lead` items stay ahead. An empty query keeps the store's
        // order. The items are not copied with their scores, which change at every
        // keystroke and would make the list remake their rows: the list's `best`
        // holds its first's, which picks the Top Hit. `limit`: only the best that
        // many are ordered (top-k selection)
        function ranked(items, tokens, limit = Infinity) {
            if (!tokens.length)
                return items;
            const scored = items.map((item, index) => ({ item, index, score: (Search.score(Search.fold(item.title), tokens) || 0.4) + (item.lead ? 1 : 0) + Search.boost(item.uses ?? frecency.weight(item.key)) }));
            const order = (a, b) => b.score - a.score || a.index - b.index;
            const best = limit < scored.length ? Spot.firstSorted(scored, order, limit) : scored.sort(order);
            const sorted = best.map(({ item }) => item);
            sorted.best = best.length ? best[0].score : 0;
            return sorted;
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
            // one more than each section shows, as the Top Hit may leave its list
            const found = {
                apps: ranked(apps.items(raw), tokens, 6),
                commands: ranked(commandItems(tokens).filter(item => item.key !== "mode:" + view?.mode), tokens, 6),
                quicklinks: ranked(web.quicklinkItems(tokens, raw), tokens, 4),
                bookmarks: ranked(library.bookmarkItems(tokens), tokens, 5),
                snippets: ranked(snippets.snippetItems(tokens), tokens, 4),
                notes: ranked(library.noteItems(tokens), tokens, 4),
                ssh: ranked(ssh.items(tokens), tokens, tokens[0] === "ssh" ? Infinity : 5)
            };
            // the best of every kind that is opened by name, if its title matches;
            // apps win a tie
            const topList = Object.values(found).filter(list => list.best >= 0.5).reduce((best, list) => !best || list.best > best.best ? list : best, null);
            const top = topList ? topList[0] : null;
            const rest = list => list.filter(item => item !== top);
            // a DOI like 10.1145/3292500.3330701 is no sum
            const answer = papers.target ? [] : calculator.items(raw);
            return [
                ["Views", view ? [Object.assign(commands.viewItem(view), { key: "alias:" + view.mode })] : []],
                ["Paper", papers.items()],
                ["Calculator", answer],
                ["Website", web.urlItems(raw)],
                // a keyword and text ("yt lofi") lead; a quicklink found by name is ranked
                // like everything else, below the Top Hit
                ["Quicklinks", rest(found.quicklinks).filter(item => item.lead).slice(0, 3)],
                ["SSH", tokens[0] === "ssh" ? rest(found.ssh) : []],
                ["Timers", ["timer", "pomodoro"].includes(tokens[0]) ? timers.items(tokens, raw.replace(/^timer\s*/i, ""), false) : []],
                ["Top Hit", top ? [top] : []],
                ["Quicklinks", rest(found.quicklinks).filter(item => !item.lead).slice(0, 3)],
                ["Applications", rest(found.apps).slice(0, 5)],
                ["Windows", windows.items(tokens, 4)],
                ["Herdr", [...herdr.agentItems(tokens).slice(0, 3), ...herdr.workspaceItems(tokens).slice(0, 2)]],
                ["Agenda", agenda.searchItems(tokens)],
                ["Commands", rest(found.commands).slice(0, 5)],
                ["AI Commands", ranked(ai.commandItems(tokens), tokens, 3)],
                ["SSH", tokens[0] === "ssh" ? [] : rest(found.ssh).slice(0, 4)],
                ["Snippets", rest(found.snippets).slice(0, 3)],
                ["Bookmarks", rest(found.bookmarks).slice(0, 4)],
                ["Notes", rest(found.notes).slice(0, 3)],
                ["Passwords", ranked(passwords.items(tokens), tokens, 3)],
                ["GitHub", ranked(web.repoItems(tokens), tokens, 4)],
                ...files.sections(tokens, true),
                ["Documents", answer.length ? [] : files.contentItems().slice(0, 3)],
                // spotlight.json's `fallbacks`: "pi", "web" or a quicklink's keyword
                ...userConfig.fallbacks.map(name => name === "pi" ? ["AI", ai.askItems(raw)] : ["Web", name === "web" ? web.searchItems(raw) : web.fallbackItems(name, raw)])
            ];
        }

        // ":" searches emoji and ">" runs a command from any view; a path browses
        // its folder in the search of everything and the files
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
            else if ((!mode || mode === "files") && files.isPath(raw))
                sections = files.browseSections(raw);
            else
                sections = currentView ? currentView.sections(tokens, raw) : everything(tokens, raw);
            // indexed: V4's for…of goes through an iterator for every item. `place`
            // (section and key, unique where a key is not: a folder in Home and
            // Frequent) is what the list knows a row by
            const items = [];
            for (let at = 0; at < sections.length; at++) {
                const [section, list] = sections[at];
                for (let index = 0; index < list.length; index++) {
                    const item = Object.assign({ section }, list[index]);
                    item.place = item.section + "\n" + item.key;
                    items.push(item);
                }
            }
            items.grid = !!currentView?.grid;
            return items;
        }

        // `actions` are [keys, label] pairs: they feed the footer and the Ctrl+K panel;
        // [keys, label, name] ones (keys may be "") run store.act(item, name)
        function describe(item) {
            // the panel closes before the results drop its actions
            if (item.kind === "action")
                return actionTarget ? describe(actionTarget) : { icon: item.icon, title: item.title };
            if (item.kind === "form")
                return { icon: item.icon, title: form.title, subtitle: `Step ${formStep + 1} of ${form.fields.length}: ${form.fields[formStep].label}`, metadata: Object.entries(formValues).map(([key, value]) => [key, form.fields.find(field => field.key === key)?.secret ? "••••••" : value]), footer: "Enter continues · Esc cancels" };
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
            if (results[current].key !== selectedKey)
                armed = "";
            selectedKey = results[current].key;
            (gridView ? resultGrid : resultList).reveal(current);
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
            if (action === "delete" && !(describe(item).actions ?? []).some(([keys]) => keys === "Ctrl+X"))
                return;
            if (action === "delete" && !confirmed && armed !== item.key + ":delete") {
                armed = item.key + ":delete";
                return;
            }
            armed = "";
            if (item.store.act(item, action))
                close();
        }

        Shortcuts {
            id: shortcuts
            host: win
            preview: previewPane
            grid: resultGrid
            clipboardStore: clipboard
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
            host: win
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
            host: win
        }
        PasswordStore {
            id: passwords
        }
        RunStore {
            id: run
            host: win
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
        WifiStore {
            id: wifi
            host: win
        }
        SelectionStore {
            id: universal
            host: win
            files: files
            web: web
            ai: ai
            calculator: calculator
            library: library
        }
        BluetoothStore {
            id: bluetooth
            host: win
        }
        NotificationStore {
            id: notifications
        }

        FileView {
            path: Spot.configFile
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

        // 1.2× macOS Spotlight's points on a 1920×1080 screen, following the logical
        // size of the screen it opens on
        Binding {
            target: Spot
            property: "scale"
            value: Math.min(win.width / 1920, win.height / 1080) * 1.2
            when: win.width > 0 && win.height > 0
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

        LargeType {
            anchors.fill: parent
            z: 1
            text: win.shown ? win.largeText : ""
            onDismissed: win.largeText = ""
        }

        RectangularShadow {
            anchors.fill: panel
            radius: panel.radius
            blur: Spot.px(50)
            offset.y: Spot.px(18)
            color: Qt.rgba(0, 0, 0, Theme.eyesDark ? 0.55 : 0.3)
            opacity: panel.opacity
            visible: win.shown && !win.largeText
        }

        Item {
            id: panel
            readonly property bool expanded: win.results.length > 0 || win.notice !== ""
            readonly property real radius: Spot.px(14)

            width: Spot.px(820)
            height: bar.height + (expanded ? Spot.px(415) + actionBar.height : 0)
            Behavior on height { enabled: win.shown; NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
            visible: win.shown && !win.largeText
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
                    color: Theme.glass
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

            SearchBar {
                id: bar
                width: parent.width
                host: win
                keyMap: shortcuts
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
                    color: Theme.hairline
                }

                ResultList {
                    id: resultList
                    x: Spot.px(10)
                    y: Spot.px(8)
                    width: win.previewing ? Spot.px(330) : parent.width - Spot.px(20)
                    height: parent.height - Spot.px(16) - actionBar.height
                    visible: !win.gridView
                    host: win
                    clipboardStore: clipboard
                }

                ResultGrid {
                    id: resultGrid
                    x: Spot.px(16)
                    y: Spot.px(8)
                    width: parent.width - Spot.px(32)
                    height: parent.height - Spot.px(16) - actionBar.height
                    visible: win.gridView
                    host: win
                }

                Rectangle {
                    id: divider
                    x: resultList.x + resultList.width + Spot.px(10)
                    y: 1
                    width: 1
                    height: parent.height - 1 - actionBar.height
                    visible: win.previewing
                    color: Theme.hairline
                }

                Preview {
                    id: previewPane
                    anchors.left: divider.right
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: noticeBar.top
                    visible: win.previewing
                    host: win
                }

                Rectangle {
                    id: noticeBar
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: actionBar.top
                    anchors.margins: Spot.px(10)
                    height: win.notice ? noticeText.implicitHeight + Spot.px(16) : 0
                    visible: win.notice !== ""
                    radius: Spot.px(10)
                    color: Theme.eyes.winterBlue

                    Label {
                        id: noticeText
                        anchors.centerIn: parent
                        width: parent.width - Spot.px(24)
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.Wrap
                        text: win.notice
                        color: Theme.eyes.blue1
                        font.pixelSize: Spot.px(13)
                        font.weight: Font.DemiBold
                    }
                }

                ActionBar {
                    id: actionBar
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    host: win
                    info: previewPane.info
                }
            }
        }
    }
}
