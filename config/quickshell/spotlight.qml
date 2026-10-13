//@ pragma IconTheme Macjaro
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Wayland
import QtQuick
import QtQuick.Effects
import "help.js" as Help

// Spotlight/Raycast-style launcher, opened by spotlight.sh (optionally straight
// into a mode). One query searches apps (most launched first), open windows,
// commands, AI commands on the selected text, SSH hosts, snippets, quicklinks,
// bookmarks, notes, pass entries, GitHub repos, files under ~, inline math and
// URLs, then offers a quick question to pi or a web search; the selection is
// previewed on the right. Ctrl+1..8 narrow to apps / files / commands /
// clipboard / windows / snippets / emoji / passwords; commands open the other
// views (bookmarks, notes, quicklinks, processes, browser history and tabs,
// timers, colors, AI commands, run). ":" searches emoji, ">" runs a command,
// "timer 10m tea" starts a timer. Windows are previewed with grim -T (native
// ext-image-copy-capture of each toplevel, also off-screen ones).
// Keys: Tab / Shift+Tab switch views, Up/Down/PageUp/PageDown/Ctrl+Home/Ctrl+End
// move, Enter runs (Shift+Enter: plain-text paste, Ctrl+Enter: alternate
// action), Ctrl+K lists every action of the selection, Ctrl+C copies, Ctrl+P
// pins, Ctrl+X deletes (press twice), Ctrl+E edits, Ctrl+R renames, Ctrl+T
// cycles the clipboard filter, Ctrl+Up/Down scroll the preview, Right accepts
// the top hit's completion, Esc steps back, Ctrl+? lists all of this (help.js). Stores (ClipboardStore, ...) own
// their results: items carry `store`, which describes and activates them.
ShellRoot {
    PanelWindow {
        id: win

        readonly property string configDir: Spot.home + "/.config/quickshell"
        readonly property string webSearch: "https://www.google.com/search?q="
        readonly property string quickPrompt: "Quick-answer assistant inside a desktop launcher: be brief, use plain Markdown and answer in the user's language."
        readonly property string transformPrompt: "You transform text inside a desktop launcher. Follow the instruction exactly and return only the result, with no preamble."

        readonly property bool dark: Theme.eyesDark
        readonly property color ink: dark ? "#f5f5f7" : "#1d1d1f"
        readonly property color inkSoft: dark ? Qt.rgba(1, 1, 1, 0.55) : Qt.rgba(0, 0, 0, 0.5)
        readonly property color glass: dark ? Qt.rgba(0.11, 0.11, 0.12, 0.68) : Qt.rgba(0.96, 0.96, 0.97, 0.68)
        readonly property color hairline: dark ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.1)

        readonly property var chips: [
            { mode: "apps", glyph: "\uf009" },
            { mode: "files", glyph: "\uf07b" },
            { mode: "commands", glyph: "\uf0e7" },
            { mode: "clipboard", glyph: "\uf0ea" },
            { mode: "windows", glyph: "\uf2d0" },
            { mode: "snippets", glyph: "\uf121" },
            { mode: "emoji", glyph: "\uf118" },
            { mode: "passwords", glyph: "\uf084" }
        ]
        readonly property var placeholders: ({
            "": "Spotlight Search  ·  Ctrl+? for help",
            marks: "Search marks or type a new one",
            herdr: "Search Herdr agents and workspaces",
            help: "Search shortcuts and features",
            apps: "Search Apps",
            files: "Search Files",
            commands: "Search Commands",
            clipboard: "Search Clipboard",
            windows: "Search Windows",
            snippets: "Search Snippets",
            emoji: "Search Emoji",
            passwords: "Search Passwords",
            bookmarks: "Search Bookmarks",
            notes: "Search Notes",
            quicklinks: "Search Quicklinks",
            processes: "Search Processes",
            history: "Search Browser History",
            tabs: "Search Browser Tabs",
            timers: "Type a duration: 10m tea",
            colors: "Search Colors",
            ai: "Search AI Commands",
            run: "Type a command"
        })
        // `alias` plus a space jumps straight to the view ("hr " → Herdr)
        readonly property var modeCommands: [
            { mode: "files", alias: "fi", title: "Search Files", icon: "folder" },
            { mode: "commands", alias: "cmd", title: "Commands", icon: "system-run" },
            { mode: "clipboard", alias: "cb", title: "Clipboard History", icon: "edit-paste" },
            { mode: "windows", alias: "win", title: "Switch Windows", icon: "preferences-system-windows" },
            { mode: "snippets", alias: "sn", title: "Search Snippets", icon: "insert-text" },
            { mode: "emoji", title: "Search Emoji", icon: "face-smile" },
            { mode: "passwords", alias: "pw", title: "Search Passwords", icon: "dialog-password" },
            { mode: "bookmarks", alias: "bm", title: "Search Bookmarks", icon: "user-bookmarks" },
            { mode: "notes", alias: "nt", title: "Search Notes", icon: "accessories-text-editor" },
            { mode: "quicklinks", alias: "ql", title: "Quicklinks", icon: "web-browser" },
            { mode: "processes", alias: "ps", title: "Kill Process", icon: "utilities-system-monitor" },
            { mode: "history", alias: "bh", title: "Search Browser History", icon: "web-browser" },
            { mode: "tabs", alias: "bt", title: "Search Browser Tabs", icon: "web-browser" },
            { mode: "timers", alias: "tm", title: "Timers", icon: "alarm-clock" },
            { mode: "colors", alias: "co", title: "Color History", icon: "color-picker" },
            { mode: "ai", alias: "ac", title: "AI Commands", icon: "", glyph: "✦" },
            { mode: "run", title: "Run Command", icon: "system-run" },
            { mode: "marks", alias: "mk", title: "Scroll Marks", icon: "bookmark-new" },
            { mode: "herdr", alias: "hr", title: "Herdr", icon: "utilities-terminal" },
            { mode: "help", alias: "?", title: "Spotlight Help", icon: "help-about" }
        ]

        readonly property var commands: [
            { title: "Lock Screen", icon: "system-lock-screen", command: [configDir + "/lock.sh"] },
            { title: "Sleep", icon: "system-suspend", command: ["systemctl", "suspend"] },
            { title: "Hibernate", icon: "system-hibernate", command: ["systemctl", "hibernate"], confirm: true },
            { title: "Restart", icon: "system-reboot", command: ["systemctl", "reboot"], confirm: true },
            { title: "Shut Down", icon: "system-shutdown", command: ["systemctl", "poweroff"], confirm: true },
            { title: "Log Out", icon: "system-log-out", command: ["scrollmsg", "exit"], confirm: true },
            { title: "Toggle Dark Mode", icon: "weather-clear-night", command: ["eyes-theme", "toggle"] },
            { title: "Next Wallpaper", icon: "preferences-desktop-wallpaper", command: [Spot.home + "/.config/awww/awwwallpaper.sh", "-n"] },
            { title: "Toggle Caffeine", icon: "caffeine", command: ["sh", "-c", 'if pkill swayidle; then notify-send -t 2000 "Caffeine on"; else swayidle -w & notify-send -t 2000 "Caffeine off"; fi'] },
            { title: "Screenshot Area", icon: "applets-screenshooter", command: ["sh", "-c", 'sleep 0.3; grim -g "$(slurp -d)" - | swappy -f -'] },
            { title: "Screenshot Screen", icon: "applets-screenshooter", command: ["sh", "-c", 'sleep 0.3; grim -o "$(scrollmsg -t get_outputs | jq -r ".[] | select(.focused) | .name")" - | swappy -f -'] },
            { title: "Empty Trash", icon: "user-trash-full", command: ["gio", "trash", "--empty"], confirm: true },
            { title: "Edit Snippets, Quicklinks and AI Commands", icon: "accessories-text-editor", command: ["kitty", "-1", "-e", "sh", "-c", '"${EDITOR:-nvim}" "$1"', "sh", configDir + "/spotlight.json"] },
            { title: "Close Window", icon: "window-close", command: ["scrollmsg", "kill"] },
            { title: "Toggle Fullscreen", icon: "view-fullscreen", command: ["scrollmsg", "fullscreen", "toggle"] },
            { title: "Toggle Floating", icon: "window-new", command: ["scrollmsg", "floating", "toggle"] },
            ...Array.from({ length: 9 }, (_, index) => ({ title: `Move Window to Workspace ${index + 1}`, icon: "go-next", command: ["scrollmsg", "move", "container", "to", "workspace", String(index + 1)] }))
        ]

        // the password only ever lives in shell variables and pipes, never in argv
        readonly property string passCopy: `
pw=$(pass show -- "$1") || { notify-send -u critical "pass" "Could not decrypt $1"; exit 1; }
pw=$(printf '%s\\n' "$pw" | head -n1)
printf %s "$pw" | wl-copy --sensitive
notify-send -i passwordsafe "Password copied for 30 seconds"
sleep 30
[ "$(wl-paste -n 2>/dev/null)" = "$pw" ] && wl-copy --clear && notify-send -i passwordsafe "Password cleared from the clipboard"`
        readonly property string passType: `
pw=$(pass show -- "$1") || { notify-send -u critical "pass" "Could not decrypt $1"; exit 1; }
sleep 0.3
printf '%s\\n' "$pw" | head -n1 | tr -d '\\n' | wtype -`

        readonly property var imageTypes: ["png", "jpg", "jpeg", "gif", "webp", "bmp", "svg", "avif"]
        readonly property var textTypes: ["txt", "md", "qml", "js", "ts", "py", "sh", "rs", "go", "c", "h", "cpp", "json", "toml", "yaml", "yml", "ini", "conf", "lua", "nix", "tex", "csv", "log", "rasi", "css", "html", "xml"]

        readonly property MprisPlayer player: {
            const players = Mpris.players.values;
            return players.find(candidate => candidate.isPlaying) ?? players[0] ?? null;
        }

        readonly property string clipboardText: clipboardOut.text
        readonly property var openWindows: windowList.items
        readonly property string selectedText: selectionOut.text
        property var userConfig: ({ snippets: [], quicklinks: [], aiCommands: [] })
        property var sshHosts: []
        property string mode: ""   // "" searches everything, else a key of `placeholders`
        readonly property string query: search.text.trim()
        property var files: []
        readonly property var results: collect()
        property int current: -1
        property string selectedKey: ""
        readonly property var selection: current >= 0 && current < results.length ? results[current] : null
        property bool keepSelection: false
        property string armed: ""
        property string notice: ""
        property var actionTarget: null   // the item whose Ctrl+K panel is open
        property string savedQuery: ""
        property var windowShots: ({})   // foreign toplevel identifier → captured image url

        // a form runs its fields one by one through the search field
        property var form: null   // { title, fields: [{ key, label, value, options }], submit: values => closes, closeOnCancel }
        property int formStep: 0
        property var formValues: ({})
        readonly property var formField: form ? form.fields[formStep] : null

        property string peekText: ""
        property string peekMeta: ""

        readonly property string tag: actionTarget ? "Actions" : form ? form.title : mode && !chips.some(chip => chip.mode === mode) ? modeCommands.find(command => command.mode === mode).title.replace(/^Search /, "") : ""
        readonly property string completion: {
            const top = results[0];
            const typed = search.text;
            if (form || !top || top.kind !== "app" || !typed || search.cursorPosition !== typed.length || !top.title.toLowerCase().startsWith(typed.toLowerCase()))
                return "";
            return top.title.slice(typed.length) + " — Application";
        }

        Component.onCompleted: {
            windowList.load();
            library.load();
            passwords.load();
            tailnet.load();
            frequent.load();
            homeDirs.load();
            herdr.load();
            clipboardNow.running = true;
            selectionNow.running = true;
            const requested = Quickshell.env("SPOTLIGHT_MODE") ?? "";
            if (requested === "mark-add")
                marks.promptAdd();
            else if (requested in placeholders)
                mode = requested;
        }
        onQueryChanged: {
            keepSelection = false;
            fileSearch.restart();
            if (query.length >= 2)
                repos.load();
            if (query.startsWith(":"))
                emoji.load();
        }
        onModeChanged: {
            keepSelection = false;
            fileSearch.restart();
            switch (mode) {
            case "clipboard":
                clipboard.load();
                break;
            case "emoji":
                emoji.load();
                break;
            case "processes":
                processes.refresh();
                break;
            case "history":
                browser.loadHistory();
                break;
            case "tabs":
                browser.loadTabs();
                break;
            case "run":
                executables.load();
                break;
            case "windows":
                captureWindows(windowList.items);
                break;
            case "marks":
                captureWindows(windowList.items.filter(window => window.marks.length));
                break;
            case "herdr":
                herdr.load();
                break;
            }
        }
        onResultsChanged: {
            const kept = keepSelection ? results.findIndex(item => item.key === selectedKey) : -1;
            select(kept >= 0 ? kept : 0);
        }
        onSelectedKeyChanged: refreshPeek()

        function notify(message) {
            notice = message;
            noticeTimer.restart();
        }

        function openForm(spec) {
            form = spec;
            formStep = 0;
            formValues = {};
            search.text = spec.fields[0].value ?? "";
        }

        function formNext(value) {
            const field = form.fields[formStep];
            if (!value) {
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
                Qt.quit();
        }

        function formItems() {
            const field = form.fields[formStep];
            const typed = query;
            const options = field.options ?? [];
            const tokens = typed.toLowerCase().split(/\s+/).filter(token => token);
            const section = `${form.title} · ${field.label}`;
            const items = [];
            if (typed && !options.includes(typed))
                items.push({ key: "form:typed", kind: "form", section, title: options.length ? `Use “${typed}”` : typed, value: typed, icon: "document-edit" });
            if (!typed && !options.length)
                items.push({ key: "form:empty", kind: "form", section, title: `Type the ${field.label.toLowerCase()}`, value: "", icon: "document-edit" });
            for (const option of options.filter(option => Spot.matches(option, tokens)))
                items.push({ key: "form:" + option, kind: "form", section, title: option, value: option, icon: "folder" });
            return items;
        }

        // "hr " (an alias and a space) opens that view at once; "?" opens the help
        function jumpToAlias(text) {
            if (mode || form || actionTarget)
                return;
            const typed = text === "?" ? "? " : text;
            const match = typed.match(/^(\S+) $/);
            const target = match && modeCommands.find(command => command.alias === match[1].toLowerCase());
            if (!target)
                return;
            search.text = "";
            mode = target.mode;
        }

        function modeItem(entry) {
            return { key: "mode:" + entry.mode, kind: "mode", mode: entry.mode, title: entry.title, hint: entry.alias ?? "", icon: entry.icon, glyph: entry.glyph };
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

        // runs one of the panel's [keys, label] actions on the item it was opened for
        function runShortcut(target, shortcut) {
            closeActions();
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

        // grim -T captures toplevels in parallel; requests made meanwhile wait their turn
        function captureWindows(windows) {
            const wanted = windows.map(window => window.ident).filter(ident => ident && !(ident in windowShots) && !windowCapture.queue.includes(ident) && !windowCapture.pending.includes(ident));
            windowCapture.queue = [...windowCapture.queue, ...wanted];
            windowCapture.next();
        }

        function frequentPaths() {
            return frequent.items;
        }

        function reloadWindows() {
            windowList.reload();
        }

        function windowShot(window) {
            return windowShots[window.ident] ?? "";
        }

        function back() {
            if (actionTarget) {
                closeActions();
            } else if (form?.closeOnCancel) {
                Qt.quit();
            } else if (form) {
                form = null;
                search.text = "";
            } else if (mode) {
                mode = "";
            } else if (search.text) {
                search.text = "";
            } else {
                Qt.quit();
            }
        }

        function rows(output) {
            return output.trim() ? JSON.parse(output) : [];
        }

        function collect() {
            if (actionTarget) {
                const tokens = query.toLowerCase().split(/\s+/).filter(token => token);
                return (describe(actionTarget).actions ?? [])
                    .filter(([keys, label]) => Spot.matches(label + " " + keys, tokens))
                    .map(([keys, label]) => ({ key: "action:" + keys, kind: "action", section: "Actions · " + actionTarget.title, title: label, hint: keys, shortcut: keys, icon: actionTarget.icon, glyph: actionTarget.glyph, swatch: actionTarget.swatch }));
            }
            if (form)
                return formItems();
            const raw = query;
            const commandLine = mode === "run" ? raw : raw.startsWith(">") ? raw.slice(1).trim() : "";
            const tokens = raw.replace(/^[:>]/, "").toLowerCase().split(/\s+/).filter(token => token);
            const everything = mode === "";
            const items = [];
            const add = (section, list) => {
                for (const item of list)
                    items.push(Object.assign({ section }, item));
            };

            if (mode === "emoji" || raw.startsWith(":")) {
                add("Emoji", emoji.items.filter(entry => Spot.matches(entry.name, tokens)).sort((a, b) => a.name.length - b.name.length).slice(0, 120).map(entry => ({ key: "emoji:" + entry.char, kind: "emoji", title: entry.name, glyph: entry.char, value: entry.char })));
                return items;
            }
            switch (mode) {
            case "clipboard":
                add("Clipboard", clipboard.items(tokens));
                return items;
            case "passwords":
                add("Passwords", passwordItems(tokens));
                return items;
            case "bookmarks":
                add("Bookmarks", library.bookmarkItems(tokens));
                add("Commands", library.commandItems(["bookmark"]));
                return items;
            case "notes":
                add("Notes", library.noteItems(tokens));
                add("Commands", library.commandItems(["note"]));
                return items;
            case "quicklinks":
                add("Quicklinks", quicklinks(tokens, raw));
                return items;
            case "processes":
                add("Processes", processes.items(tokens));
                return items;
            case "history":
                add("History", browser.historyItems(tokens));
                return items;
            case "tabs":
                add("Tabs", browser.tabItems(tokens));
                return items;
            case "timers":
                add("Timers", timers.items(tokens, raw, true));
                return items;
            case "colors":
                add("Colors", colors.items(tokens));
                return items;
            case "ai":
                add("AI Commands", aiCommandItems(tokens));
                return items;
            case "run":
                add("Run", runItems(commandLine, true));
                return items;
            case "help":
                add("Help", helpItems(tokens));
                return items;
            case "marks":
                add("Marks", marks.items(tokens, raw, windowList.items));
                return items;
            case "herdr":
                add("Agents", herdr.agentItems(tokens));
                add("Workspaces", herdr.workspaceItems(tokens));
                add("Herdr", herdr.commandItems(tokens));
                return items;
            }
            if (everything && commandLine) {
                add("Run", runItems(commandLine, false));
                return items;
            }
            if (mode === "files" && !tokens.length) {
                add("Frequent", frequentDirs([]).slice(0, 12));
                add("Home", homeDirs.items.map(path => folderItem(path, "")));
                return items;
            }
            if (everything && !tokens.length)
                return items;

            const view = everything ? modeCommands.find(command => command.alias === raw.toLowerCase()) : null;
            if (everything) {
                if (view)
                    add("Views", [Object.assign(modeItem(view), { key: "alias:" + view.mode })]);
                const value = calculate(raw);
                if (value !== null)
                    add("Calculator", [{ key: "calc", kind: "calc", title: value, icon: "accessories-calculator", value, expression: raw }]);
                const url = asUrl(raw);
                if (url)
                    add("Website", [{ key: "url", kind: "url", title: url, icon: "web-browser", value: url }]);
                add("Quicklinks", quicklinks(tokens, raw).slice(0, 3));
                if (tokens[0] === "ssh")
                    add("SSH", sshItems(tokens));
                if (["timer", "pomodoro"].includes(tokens[0]))
                    add("Timers", timers.items(tokens, raw.replace(/^timer\s*/i, ""), false));
            }
            if (everything || mode === "apps") {
                const apps = Apps.search(raw).map(app => ({ key: "app:" + app.id, kind: "app", app, title: app.name, icon: app.icon }));
                if (everything) {
                    add("Top Hit", apps.slice(0, 1));
                    add("Applications", apps.slice(1, 6));
                } else {
                    add("Applications", apps);
                }
            }
            if (everything || mode === "windows")
                add("Windows", windowList.items.filter(window => Spot.matches(window.title + " " + window.appId, tokens)).slice(0, everything ? 4 : 80).map(window => ({ key: "window:" + window.id, kind: "window", window, title: window.title, hint: window.appId, icon: Spot.iconFor(window.appId), thumb: mode === "windows" ? windowShot(window) : "" })));
            if (everything)
                add("Herdr", [...herdr.agentItems(tokens).slice(0, 3), ...herdr.workspaceItems(tokens).slice(0, 2)]);
            if (everything || mode === "commands")
                add("Commands", commandItems(tokens).filter(item => item.key !== "mode:" + view?.mode).slice(0, everything ? 5 : 200));
            if (everything) {
                add("AI Commands", aiCommandItems(tokens).slice(0, 3));
                if (tokens[0] !== "ssh")
                    add("SSH", sshItems(tokens).slice(0, 4));
            }
            if (everything || mode === "snippets")
                add("Snippets", userConfig.snippets.filter(snippet => Spot.matches(snippet.name + " " + snippet.keyword + " " + snippet.text, tokens)).slice(0, everything ? 3 : 100).map(snippet => ({ key: "snippet:" + snippet.name, kind: "snippet", snippet, title: snippet.name, hint: snippet.keyword, icon: "edit-paste", value: expand(snippet.text) })));
            if (everything) {
                add("Bookmarks", library.bookmarkItems(tokens).slice(0, 4));
                add("Notes", library.noteItems(tokens).slice(0, 3));
                add("Passwords", passwordItems(tokens).slice(0, 3));
                add("GitHub", repos.items.filter(repo => Spot.matches(repo.nameWithOwner + " " + (repo.description ?? ""), tokens)).slice(0, 4).map(repo => ({ key: "repo:" + repo.nameWithOwner, kind: "repo", repo, title: repo.nameWithOwner, hint: repo.isPrivate ? "Private" : "", icon: "github", value: repo.url })));
            }
            if (everything || mode === "files") {
                const frequentHits = frequentDirs(tokens).slice(0, everything ? 3 : 6);
                const shown = new Set(frequentHits.map(item => item.path));
                add("Frequent", frequentHits);
                add("Files", files.filter(file => !shown.has(file.path) && Spot.matches(file.path, tokens)).slice(0, everything ? 6 : 60));
            }
            if (everything) {
                add("AI", [{ key: "ask:" + raw, kind: "ai", title: `Ask pi “${raw}”`, glyph: "✦", value: raw }]);
                add("Web", [{ key: "web", kind: "web", title: `Search the web for “${raw}”`, icon: "web-browser", value: raw }]);
            }
            return items;
        }

        // title/keys matches beat description-only ones, and sections holding one come first
        function helpItems(tokens) {
            const hits = Help.topics
                .map((topic, index) => ({ topic, index, rank: Spot.matches(`${topic.keys} ${topic.title}`, tokens) ? 0 : 1 }))
                .filter(hit => Spot.matches(`${hit.topic.section} ${hit.topic.keys} ${hit.topic.title} ${hit.topic.text ?? ""}`, tokens));
            const sectionRank = {};
            for (const hit of hits)
                sectionRank[hit.topic.section] = Math.min(sectionRank[hit.topic.section] ?? 1, hit.rank);
            const sectionOrder = [...new Set(Help.topics.map(topic => topic.section))];
            const sectionKey = section => sectionRank[section] * sectionOrder.length + sectionOrder.indexOf(section);
            return hits
                .sort((a, b) => sectionKey(a.topic.section) - sectionKey(b.topic.section) || a.rank - b.rank || a.index - b.index)
                .map(({ topic }) => ({ key: `help:${topic.section}:${topic.keys}`, kind: "help", section: topic.section, topic, title: topic.title, hint: topic.keys, icon: "help-about" }));
        }

        function commandItems(tokens) {
            const list = commands
                .filter(command => Spot.matches(command.title, tokens))
                .map(command => ({ key: "cmd:" + command.title, kind: "command", title: command.title, icon: command.icon, command: command.command, confirm: command.confirm ?? false }));
            for (const entry of modeCommands.filter(entry => Spot.matches(`${entry.title} ${entry.alias ?? ""}`, tokens)))
                list.push(modeItem(entry));
            list.push(...library.commandItems(tokens), ...herdr.commandItems(tokens), ...colors.pickItem(tokens));
            if (player)
                for (const [title, action] of [[player.isPlaying ? "Pause" : "Play", "toggle"], ["Next Track", "next"], ["Previous Track", "previous"]])
                    if (Spot.matches(title + " media music " + player.identity, tokens))
                        list.push({ key: "media:" + action, kind: "media", title, hint: player.identity, icon: "multimedia-player", action });
            for (const app of DesktopEntries.applications.values)
                for (const action of app.actions)
                    if (Spot.matches(action.name + " " + app.name, tokens))
                        list.push({ key: "act:" + app.id + ":" + action.id, kind: "appAction", action, app, title: action.name, hint: app.name, icon: action.icon || app.icon });
            return list;
        }

        function aiCommandItems(tokens) {
            return (userConfig.aiCommands ?? [])
                .filter(command => Spot.matches(command.name, tokens))
                .map(command => ({ key: "aicmd:" + command.name, kind: "aiCommand", command, title: command.name, hint: selectedText ? "on selection" : "nothing selected", glyph: "✦" }));
        }

        function runItems(commandLine, withExecutables) {
            if (!commandLine)
                return [];
            const [program, ...rest] = commandLine.split(/\s+/);
            const list = [{ key: "run:" + commandLine, kind: "run", title: `Run “${commandLine}”`, icon: "system-run", value: commandLine }];
            if (withExecutables)
                for (const name of executables.items.filter(name => name.startsWith(program) && name !== program).slice(0, 40))
                    list.push({ key: "run:" + name, kind: "run", title: name, hint: rest.join(" "), icon: Spot.iconFor(name), value: [name, ...rest].join(" ") });
            return list;
        }

        // ~/.ssh/config hosts (git-only ones skipped) merged with Tailscale peers
        function sshItems(tokens) {
            const peers = tailnet.items;
            const hosts = sshHosts.filter(host => host.user !== "git").map(host => ({
                name: host.name,
                target: host.name,
                address: (host.user ? host.user + "@" : "") + (host.hostName || host.name),
                peer: peers.find(peer => peer.ip === host.hostName || peer.dns === host.hostName || peer.name.toLowerCase() === host.name.toLowerCase())
            }));
            for (const peer of peers)
                if (!hosts.some(host => host.peer === peer))
                    hosts.push({ name: peer.name, target: peer.dns, address: peer.dns, peer });
            return hosts
                .filter(host => Spot.matches("ssh " + host.name + " " + host.address, tokens))
                .map(host => ({ key: "ssh:" + host.name, kind: "ssh", host, title: host.name, hint: host.peer ? (host.peer.online ? "online" : "offline") : host.address, icon: "utilities-terminal", value: host.target }));
        }

        function parseSshConfig(text) {
            const hosts = [];
            let block = [];
            for (const line of text.split("\n")) {
                const [keyword, ...rest] = line.trim().split(/\s+/);
                const value = rest.join(" ");
                switch (keyword.toLowerCase()) {
                case "host":
                    block = rest.filter(name => !/[*?!]/.test(name)).map(name => ({ name, hostName: "", user: "" }));
                    hosts.push(...block);
                    break;
                case "match":
                    block = [];
                    break;
                case "hostname":
                    block.forEach(host => host.hostName = value);
                    break;
                case "user":
                    block.forEach(host => host.user = value);
                    break;
                }
            }
            return hosts;
        }

        function passwordItems(tokens) {
            return passwords.items
                .filter(entry => Spot.matches(entry, tokens))
                .map(entry => ({ key: "pass:" + entry, kind: "password", title: entry.slice(entry.lastIndexOf("/") + 1), hint: entry.includes("/") ? entry.slice(0, entry.lastIndexOf("/")) : "", icon: "dialog-password", value: entry }));
        }

        // "yt lofi" fills YouTube's {query}; a name match opens the link, its
        // home page, or every page of a group
        function quicklinks(tokens, raw) {
            const [keyword, ...words] = raw.split(/\s+/);
            const rest = words.join(" ");
            const hits = [];
            for (const link of userConfig.quicklinks) {
                const opener = link.open ?? ["xdg-open"];
                const searchable = (link.url ?? "").includes("{query}");
                if (rest && searchable && link.keyword === keyword.toLowerCase())
                    hits.unshift({ key: "link:" + link.name, kind: "quicklink", title: `${link.name}: “${rest}”`, hint: link.keyword, icon: "web-browser", urls: [link.url.replace("{query}", encodeURIComponent(rest))], opener });
                else if (Spot.matches(link.name + " " + link.keyword, tokens))
                    hits.push({ key: "link:" + link.name, kind: "quicklink", title: link.name, hint: link.urls ? `${link.urls.length} links` : link.keyword, icon: "web-browser", urls: link.urls ?? [searchable ? link.home ?? link.url.replace("{query}", "") : link.url], opener });
            }
            return hits;
        }

        function expand(text) {
            const now = new Date();
            return text
                .replace(/\{date\}/g, Qt.formatDate(now, "yyyy-MM-dd"))
                .replace(/\{time\}/g, Qt.formatTime(now, "HH:mm"))
                .replace(/\{weekday\}/g, now.toLocaleDateString(Qt.locale(), "dddd"))
                .replace(/\{clipboard\}/g, () => clipboardText);
        }

        function windowsIn(node, workspace) {
            const here = node.type === "workspace" ? node.name : workspace;
            const children = [...(node.nodes ?? []), ...(node.floating_nodes ?? [])];
            if (!children.length && node.pid > 0)
                return [{ id: node.id, ident: node.foreign_toplevel_identifier ?? "", title: node.name ?? "", appId: node.app_id ?? node.window_properties?.class ?? "", workspace: here, marks: node.marks ?? [], focused: node.focused }];
            return [].concat(...children.map(child => windowsIn(child, here)));
        }

        // arithmetic only: the input is whitelisted to numbers, operators and
        // the Math names below before it is evaluated
        function calculate(text) {
            const names = { sqrt: "Math.sqrt", sin: "Math.sin", cos: "Math.cos", tan: "Math.tan", log: "Math.log10", ln: "Math.log", abs: "Math.abs", round: "Math.round", floor: "Math.floor", ceil: "Math.ceil", pi: "Math.PI", e: "Math.E" };
            const expression = text.replace(/^=/, "").trim();
            const words = expression.match(/[a-z]+/gi) ?? [];
            if (!/\d/.test(expression) || !/^[\d\sa-z.+\-*/%^()]+$/i.test(expression) || !/[+\-*/%^(]/.test(expression))
                return null;
            if (words.some(word => !(word.toLowerCase() in names)))
                return null;
            const source = expression.replace(/[a-z]+/gi, word => names[word.toLowerCase()]).replace(/\^/g, "**");
            let value;
            try {
                value = Function(`"use strict"; return (${source});`)();
            } catch (error) {
                if (error instanceof SyntaxError)
                    return null;
                throw error;
            }
            return typeof value === "number" && isFinite(value) ? String(Number(value.toPrecision(12))) : null;
        }

        function asUrl(text) {
            if (/\s/.test(text))
                return "";
            if (/^https?:\/\/\S+$/.test(text))
                return text;
            if (/^(www\.)?[\w-]+(\.[\w-]+)*\.(com|org|net|io|dev|app|ai|co|mx|edu|gov|me|xyz)(\/\S*)?$/i.test(text))
                return "https://" + text;
            return "";
        }

        function fileIcon(name, isDir) {
            if (isDir)
                return "folder";
            const type = extension(name);
            if (imageTypes.includes(type))
                return "image-x-generic";
            if (type === "pdf")
                return "application-pdf";
            if (["mp4", "mkv", "webm", "mov", "avi"].includes(type))
                return "video-x-generic";
            if (["mp3", "flac", "ogg", "wav", "m4a", "opus"].includes(type))
                return "audio-x-generic";
            if (["zip", "tar", "gz", "xz", "zst", "7z", "rar"].includes(type))
                return "package-x-generic";
            return "text-x-generic";
        }

        function extension(name) {
            const dot = name.lastIndexOf(".");
            return dot > 0 ? name.slice(dot + 1).toLowerCase() : "";
        }

        function folderItem(path, hint) {
            return { key: "file:" + path, kind: "file", path, isDir: true, title: path.slice(path.lastIndexOf("/") + 1), hint, icon: "folder" };
        }

        // zoxide's most visited directories, best first
        function frequentDirs(tokens) {
            return frequent.items
                .filter(path => Spot.matches(path, tokens))
                .map(path => folderItem(path, path.slice(0, path.lastIndexOf("/")).replace(Spot.home, "~")));
        }

        function rankFiles(output, query) {
            const tokens = query.toLowerCase().split(/\s+/).filter(token => token);
            const first = tokens[0] ?? "";
            return output.split("\n")
                .filter(line => line && Spot.matches(line, tokens))
                .map(line => {
                    const isDir = line.endsWith("/");
                    const path = isDir ? line.slice(0, -1) : line;
                    const name = path.slice(path.lastIndexOf("/") + 1);
                    const lower = name.toLowerCase();
                    const rank = lower.startsWith(first) ? 0 : lower.includes(first) ? 1 : 2;
                    return { key: "file:" + path, kind: "file", path, isDir, title: name, icon: fileIcon(name, isDir), rank };
                })
                .sort((a, b) => a.rank - b.rank || a.path.length - b.path.length);
        }

        // `actions` are [keys, label] pairs: they feed the footer and the Ctrl+K panel
        function describe(item) {
            if (item.kind === "action")
                return describe(actionTarget);
            if (item.store)
                return item.store.describe(item);
            switch (item.kind) {
            case "app": {
                const uses = Apps.launches[item.app.id + ".desktop"] ?? 0;
                return { icon: item.icon, title: item.title, subtitle: item.app.genericName, details: [item.app.comment, uses ? `Opened ${uses} ${uses === 1 ? "time" : "times"}` : "Never opened from the launcher"], actions: [["Enter", "Open"]] };
            }
            case "appAction":
                return { icon: item.icon, title: item.title, subtitle: "Action of " + item.app.name, actions: [["Enter", "Run action"]] };
            case "command":
                return { icon: item.icon, title: item.title, subtitle: "Command", actions: [["Enter", "Run"]] };
            case "mode":
                return { icon: item.icon, glyph: item.glyph, title: item.title, subtitle: placeholders[item.mode], details: [item.hint ? `Alias: type “${item.hint}” and a space` : ""], actions: [["Enter", "Open view"]] };
            case "media":
                return { image: player?.trackArtUrl ?? "", icon: item.icon, title: player?.trackTitle || item.title, subtitle: player?.trackArtist ?? "", details: [player?.identity ?? ""], actions: [["Enter", item.title]] };
            case "window":
                return { image: windowShot(item.window), icon: item.icon, title: item.title, subtitle: item.window.appId, details: ["Workspace " + item.window.workspace], actions: [["Enter", "Focus window"]] };
            case "file": {
                const isImage = imageTypes.includes(extension(item.title));
                return { image: isImage ? "file://" + item.path : "", icon: item.icon, title: item.title, subtitle: item.path.replace(Spot.home, "~"), details: [peekMeta], body: peekText, mono: true, actions: [["Enter", "Open"], ["Ctrl+Enter", "Show in folder"], ["Ctrl+C", "Copy path"]] };
            }
            case "calc":
                return { glyph: item.value, title: item.expression + " =", actions: [["Enter", "Copy result"]] };
            case "snippet":
                return { icon: item.icon, title: item.title, subtitle: "Snippet · " + item.snippet.keyword, body: item.value, actions: [["Enter", "Paste"], ["Ctrl+C", "Copy"]] };
            case "ssh":
                return { icon: item.icon, title: item.title, subtitle: item.host.address, details: [item.host.peer ? `Tailscale · ${item.host.peer.online ? "online" : "offline"} · ${item.host.peer.os}` : ""], actions: [["Enter", "Connect with kitten ssh"], ["Ctrl+C", "Copy host"]] };
            case "emoji":
                return { glyph: item.glyph, title: item.title, actions: [["Enter", "Paste"], ["Ctrl+C", "Copy"]] };
            case "quicklink":
                return { icon: item.icon, title: item.title, subtitle: item.urls.length > 1 ? `${item.urls.length} links` : item.urls[0], body: item.urls.length > 1 ? item.urls.join("\n") : "", actions: [["Enter", item.urls.length > 1 ? "Open all" : "Open"], ["Ctrl+C", "Copy URLs"]] };
            case "repo":
                return { icon: item.icon, title: item.title, subtitle: item.repo.description ?? "", details: [`★ ${item.repo.stargazerCount}  ·  ${item.repo.isPrivate ? "Private" : "Public"}`, "Updated " + new Date(item.repo.updatedAt).toLocaleDateString(Qt.locale(), Locale.ShortFormat)], actions: [["Enter", "Open on GitHub"], ["Ctrl+C", "Copy URL"]] };
            case "password":
                return { icon: item.icon, title: item.title, subtitle: item.value, details: ["Stored in pass, decrypted only when used"], actions: [["Enter", "Copy password for 30 s"], ["Ctrl+Enter", "Type password"]] };
            case "run":
                return { icon: item.icon, title: item.value, subtitle: "Command", actions: [["Enter", "Run"], ["Ctrl+Enter", "Run in terminal"], ["Ctrl+C", "Copy command"]] };
            case "ai": {
                const answered = ai.key === item.key;
                if (answered && !ai.answer)
                    return { glyph: "✦", title: "Ask pi", subtitle: item.value, body: "Thinking…", footer: "pi is answering with your default model" };
                return { glyph: "✦", title: "Ask pi", subtitle: item.value, body: answered ? ai.answer : "", markdown: true, actions: answered ? [["Enter", "Copy answer"]] : [["Enter", "Ask pi"]] };
            }
            case "aiCommand": {
                const answered = ai.key === item.key;
                if (!selectedText)
                    return { glyph: "✦", title: item.title, subtitle: "Select some text in any window, then open Spotlight", footer: "Nothing selected" };
                if (answered && !ai.answer)
                    return { glyph: "✦", title: item.title, body: "Thinking…", footer: "pi is working on the selected text" };
                if (answered)
                    return { glyph: "✦", title: item.title, body: ai.answer, markdown: true, actions: item.command.output === "paste" ? [["Enter", "Replace selection"], ["Ctrl+C", "Copy result"]] : [["Enter", "Copy result"]] };
                return { glyph: "✦", title: item.title, subtitle: "Selected text", body: selectedText.slice(0, 2000), actions: [["Enter", "Run with pi"]] };
            }
            case "help": {
                const topic = item.topic;
                const actions = topic.mode ? [["Enter", "Open view"]] : topic.insert ? [["Enter", "Try it"]] : [];
                return { icon: item.icon, title: topic.title, subtitle: topic.keys, body: topic.text ?? "", actions, footer: actions.length ? "" : topic.section };
            }
            case "form":
                return { icon: item.icon, title: form.title, subtitle: `Step ${formStep + 1} of ${form.fields.length}: ${form.fields[formStep].label}`, details: Object.entries(formValues).map(([key, value]) => `${key}: ${value}`), footer: "Enter continues · Esc cancels" };
            case "url":
                return { icon: item.icon, title: item.title, subtitle: "Open in your browser", actions: [["Enter", "Open"], ["Ctrl+C", "Copy URL"]] };
            default:
                return { icon: item.icon, title: item.title, subtitle: "Search with Google", actions: [["Enter", "Search"]] };
            }
        }

        // two actions and a pointer to the Ctrl+K panel, unless a status overrides it
        function footerOf(info) {
            if (info.footer)
                return info.footer;
            const actions = info.actions ?? [];
            const shown = actions.slice(0, actions.length > 3 ? 2 : 3).map(([keys, label]) => `${keys} ${label}`);
            return [...shown, actions.length > 3 ? "Ctrl+K more" : "Ctrl+K actions"].join("  ·  ");
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
            list.positionViewAtIndex(current, ListView.Contain);
        }

        // a selection the user moved survives results arriving late (files)
        function pick(index) {
            keepSelection = true;
            select(index);
        }

        function refreshPeek() {
            peekText = "";
            peekMeta = "";
            const item = results[current];
            if (item?.store?.peek)
                item.store.peek(item);
            if (item?.kind === "window")
                captureWindows([item.window]);
            if (item?.kind !== "file")
                return;
            peek.forKey = item.key;
            peek.exec(["sh", "-c", 'stat -c "%s|%Y" -- "$1"; if [ -d "$1" ]; then ls -1Ap -- "$1" | head -n 40; elif [ "$2" = text ]; then head -c 3000 -- "$1"; fi', "sh", item.path, textTypes.includes(extension(item.title)) ? "text" : ""]);
        }

        function activate(item, keys) {
            if (!item)
                return;
            if (item.kind === "action") {
                runShortcut(actionTarget, item.shortcut);
                return;
            }
            if (item.confirm && armed !== item.key) {
                armed = item.key;
                return;
            }
            armed = "";
            if (item.store) {
                if (item.store.activate(item, keys))
                    Qt.quit();
                return;
            }
            switch (item.kind) {
            case "form":
                formNext(item.value);
                return;
            case "help":
                if (item.topic.mode) {
                    search.text = "";
                    mode = item.topic.mode;
                } else if (item.topic.insert) {
                    mode = "";
                    search.text = item.topic.insert;
                }
                return;
            case "mode":
                search.text = "";
                mode = item.mode;
                return;
            case "ai":
                if (ai.key !== item.key || !ai.answer) {
                    ai.ask(item.key, item.value, quickPrompt);
                    return;
                }
                Spot.copy(ai.answer);
                break;
            case "aiCommand":
                if (!selectedText) {
                    notify("Select some text in any window first, then open Spotlight");
                    return;
                }
                if (ai.key !== item.key || !ai.answer) {
                    ai.ask(item.key, `${item.command.prompt}\n\n---\n${selectedText}`, transformPrompt);
                    return;
                }
                if (item.command.output === "paste")
                    Spot.type(ai.answer);
                else
                    Spot.copy(ai.answer);
                break;
            case "app":
                Apps.launch(item.app);
                break;
            case "appAction":
                item.action.execute();
                break;
            case "command":
                Quickshell.execDetached(item.command);
                break;
            case "media":
                if (item.action === "toggle")
                    player.togglePlaying();
                else if (item.action === "next")
                    player.next();
                else
                    player.previous();
                break;
            case "window":
                Quickshell.execDetached(["scrollmsg", `[con_id=${item.window.id}] focus`]);
                break;
            case "file":
                Quickshell.execDetached(["xdg-open", keys.ctrl ? item.path.slice(0, item.path.lastIndexOf("/")) : item.path]);
                break;
            case "snippet":
            case "emoji":
                Spot.type(item.value);
                break;
            case "quicklink":
                for (const url of item.urls)
                    Quickshell.execDetached([...item.opener, url]);
                break;
            case "ssh":
                Quickshell.execDetached(["kitty", "-1", "kitten", "ssh", item.value]);
                break;
            case "password":
                Quickshell.execDetached(["sh", "-c", keys.ctrl ? passType : passCopy, "sh", item.value]);
                break;
            case "run":
                Quickshell.execDetached(keys.ctrl ? ["kitty", "-1", "--hold", "sh", "-c", item.value] : ["sh", "-c", item.value]);
                break;
            case "url":
            case "repo":
                Quickshell.execDetached(["xdg-open", item.value]);
                break;
            case "web":
                Quickshell.execDetached(["xdg-open", webSearch + encodeURIComponent(item.value)]);
                break;
            default:
                Spot.copy(item.value);
            }
            Qt.quit();
        }

        function copyItem(item) {
            if (!item || item.kind === "form" || item.kind === "action")
                return;
            if (item.store?.copy)
                item.store.copy(item);
            else if (item.kind === "password")
                Quickshell.execDetached(["sh", "-c", passCopy, "sh", item.value]);
            else if (item.kind === "ai" || item.kind === "aiCommand")
                Spot.copy(ai.key === item.key && ai.answer ? ai.answer : item.value ?? item.title);
            else if (item.kind === "snippet")
                Spot.copy(item.value.split("{cursor}").join(""));
            else if (item.kind === "quicklink")
                Spot.copy(item.urls.join("\n"));
            else
                Spot.copy(item.kind === "file" ? item.path : item.value ?? item.title);
            Qt.quit();
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
                Qt.quit();
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
        }
        HerdrStore {
            id: herdr
            host: win
        }

        FileView {
            path: win.configDir + "/spotlight.json"
            blockLoading: true
            watchChanges: true
            onFileChanged: reload()
            onLoaded: win.userConfig = JSON.parse(text())
        }
        FileView {
            path: Spot.home + "/.ssh/config"
            blockLoading: true
            printErrors: false
            onLoaded: win.sshHosts = win.parseSshConfig(text())
        }

        Source {
            id: windowList
            command: ["scrollmsg", "-t", "get_tree"]
            onItemsChanged: {
                if (win.mode === "windows")
                    win.captureWindows(items);
                else if (win.mode === "marks")
                    win.captureWindows(items.filter(window => window.marks.length));
            }
            parse: output => output.trim() ? win.windowsIn(JSON.parse(output), "") : []
        }
        Source {
            id: tailnet
            command: ["tailscale", "status", "--json"]
            parse: output => output.trim() ? Object.values(JSON.parse(output).Peer ?? {}).map(peer => ({ name: peer.HostName, dns: peer.DNSName.replace(/\.$/, ""), ip: peer.TailscaleIPs[0], os: peer.OS, online: peer.Online })) : []
        }
        Source {
            id: passwords
            command: ["sh", "-c", 'cd "${PASSWORD_STORE_DIR:-$HOME/.password-store}" && find . -name "*.gpg" -printf "%P\\n"']
            parse: output => output.split("\n").filter(line => line).map(line => line.slice(0, -4)).sort()
        }
        Source {
            id: repos
            command: ["gh", "repo", "list", "--limit", "300", "--json", "nameWithOwner,description,url,isPrivate,stargazerCount,updatedAt"]
            parse: win.rows
        }
        Source {
            id: frequent
            command: ["zoxide", "query", "--list"]
            parse: output => output.split("\n").filter(path => path && path !== Spot.home)
        }
        Source {
            id: homeDirs
            command: ["find", Spot.home, "-mindepth", "1", "-maxdepth", "1", "-type", "d", "-not", "-name", ".*"]
            parse: output => output.split("\n").filter(path => path).sort((a, b) => a.localeCompare(b))
        }
        Source {
            id: executables
            command: ["bash", "-c", "compgen -c | sort -u"]
            parse: output => output.split("\n").filter(line => line)
        }
        Source {
            id: emoji
            // every named codepoint the colour emoji font can draw, skipping ASCII
            command: ["python3", "-I", "-c", `
import json, subprocess, unicodedata
charset = subprocess.run(["fc-list", ":family=Noto Color Emoji", "charset"], capture_output=True, text=True, check=True).stdout
codes = set()
for span in charset.partition("=")[2].split():
    start, _, end = span.partition("-")
    codes.update(range(int(start, 16), int(end or start, 16) + 1))
print(json.dumps([{"char": chr(code), "name": unicodedata.name(chr(code)).lower()} for code in sorted(codes) if code > 0x7F and unicodedata.name(chr(code), "")]))
`]
            parse: win.rows
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
            id: fileSearch
            interval: 150
            onTriggered: {
                if ((win.mode === "" || win.mode === "files") && !win.form && !/^[:>]/.test(win.query) && win.query.length >= 2) {
                    fd.forQuery = win.query;
                    fd.exec(["fd", "--one-file-system", "--fixed-strings", "--ignore-case", "--absolute-path", "--max-results", "200", "--", win.query.split(/\s+/)[0], Spot.home]);
                } else {
                    win.files = [];
                }
            }
        }
        Timer {
            id: noticeTimer
            interval: 5000
            onTriggered: win.notice = ""
        }

        Process {
            id: fd
            property string forQuery: ""
            stdout: StdioCollector {
                onStreamFinished: {
                    if (fd.forQuery === win.query)
                        win.files = win.rankFiles(text, win.query);
                }
            }
        }

        Process {
            id: windowCapture
            property var queue: []
            property var pending: []
            readonly property string dir: Spot.cacheDir + "/windows"

            function next() {
                if (running || !queue.length)
                    return;
                pending = queue;
                queue = [];
                exec(["sh", "-c", 'dir=$1; shift; mkdir -p "$dir"; for id in "$@"; do grim -T "$id" -s 0.35 "$dir/$id.png" & done; wait', "sh", dir, ...pending]);
            }

            onExited: {
                const shots = Object.assign({}, win.windowShots);
                for (const ident of pending)
                    shots[ident] = `file://${dir}/${ident}.png`;
                pending = [];
                win.windowShots = shots;
                next();
            }
        }

        Process {
            id: peek
            property string forKey: ""
            stdout: StdioCollector {
                onStreamFinished: {
                    if (peek.forKey !== win.selectedKey)
                        return;
                    const newline = text.indexOf("\n");
                    const [bytes, modified] = (newline < 0 ? text : text.slice(0, newline)).split("|");
                    const content = newline < 0 ? "" : text.slice(newline + 1);
                    const entries = content.split("\n").filter(line => line).length;
                    const size = win.selection?.isDir ? `${entries}${entries === 40 ? "+" : ""} ${entries === 1 ? "item" : "items"}` : Spot.formatSize(Number(bytes));
                    win.peekMeta = size + "  ·  Modified " + new Date(Number(modified) * 1000).toLocaleString(Qt.locale(), Locale.ShortFormat);
                    win.peekText = content;
                }
            }
        }

        Process {
            id: ai
            property string key: ""
            property string answer: ""

            // pi -p waits on an open stdin, so it gets /dev/null
            function ask(forKey, prompt, system) {
                key = forKey;
                answer = "";
                exec(["sh", "-c", 'exec pi "$@" < /dev/null', "sh", "-p", "--no-session", "--no-tools", "--no-context-files", "--no-skills", "--no-prompt-templates", "--offline", "--system-prompt", system, "--", prompt]);
            }

            stdout: StdioCollector {
                onStreamFinished: ai.answer = text.trim()
            }
            onExited: exitCode => {
                if (exitCode !== 0 && !answer)
                    answer = `pi exited with code ${exitCode}.`;
            }
        }

        color: "transparent"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "qs-spotlight"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        exclusionMode: ExclusionMode.Ignore
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        MouseArea {
            anchors.fill: parent
            onClicked: Qt.quit()
        }

        component Label: Text {
            color: win.ink
            font.family: Theme.menuText
            font.pixelSize: 14
            textFormat: Text.PlainText
            renderType: Text.NativeRendering
        }

        RectangularShadow {
            anchors.fill: panel
            radius: panel.radius
            blur: 50
            offset.y: 18
            color: Qt.rgba(0, 0, 0, win.dark ? 0.55 : 0.3)
            opacity: panel.opacity
        }

        Item {
            id: panel
            readonly property bool expanded: win.results.length > 0 || win.notice !== ""
            property real radius: expanded ? 22 : bar.height / 2
            Behavior on radius { NumberAnimation { duration: 160 } }

            width: 820
            height: bar.height + (expanded ? 460 : 0)
            Behavior on height { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
            x: Math.round((parent.width - width) / 2)
            y: Math.round(parent.height * 0.2)

            NumberAnimation on opacity { from: 0; to: 1; duration: 140 }

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
                border.color: win.hairline
            }

            Item {
                id: bar
                width: parent.width
                height: 64

                Label {
                    id: glassIcon
                    x: 24
                    anchors.verticalCenter: parent.verticalCenter
                    text: "\uf002"
                    color: win.inkSoft
                    font.family: Theme.menu
                    font.pixelSize: 22
                }

                Rectangle {
                    id: tagPill
                    anchors.left: glassIcon.right
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    visible: win.tag !== ""
                    width: visible ? tagText.implicitWidth + 20 : 0
                    height: 28
                    radius: height / 2
                    color: Wallpaper.accent

                    Label {
                        id: tagText
                        anchors.centerIn: parent
                        text: win.tag
                        color: "white"
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                    }
                }

                TextInput {
                    id: search
                    anchors.left: tagPill.right
                    anchors.leftMargin: 12
                    anchors.right: chipRow.left
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    focus: true
                    clip: true
                    color: win.ink
                    selectionColor: Wallpaper.accent
                    selectedTextColor: "white"
                    font.family: Theme.menu
                    font.pixelSize: 26
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
                                win.pick(win.current + 1);
                            else
                                win.cycleMode(1);
                        } else if (event.key === Qt.Key_Backtab) {
                            if (listing)
                                win.pick(win.current - 1);
                            else
                                win.cycleMode(-1);
                        } else if (event.key === Qt.Key_Right && win.completion) {
                            search.text = win.results[0].title;
                        } else if (event.key === Qt.Key_Down) {
                            win.pick(win.current + 1);
                        } else if (event.key === Qt.Key_Up) {
                            win.pick(win.current - 1);
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
                        visible: search.text === ""
                        text: win.actionTarget ? `Search actions for ${win.actionTarget.title}` : win.formField ? win.formField.label : win.placeholders[win.mode]
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
                    anchors.rightMargin: 18
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4

                    Repeater {
                        model: win.chips

                        Rectangle {
                            id: chip
                            required property var modelData
                            readonly property bool active: win.mode === modelData.mode
                            width: 30
                            height: 30
                            radius: height / 2
                            color: active ? Wallpaper.accent : "transparent"

                            Label {
                                anchors.centerIn: parent
                                text: chip.modelData.glyph
                                color: chip.active ? "white" : win.inkSoft
                                font.family: Theme.menu
                                font.pixelSize: 14
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

                ListView {
                    id: list
                    x: 10
                    y: 8
                    width: 330
                    height: parent.height - 16
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    model: win.results

                    header: Row {
                        visible: win.mode === "clipboard" && !win.form
                        height: visible ? 38 : 0
                        spacing: 6
                        leftPadding: 6
                        topPadding: 4

                        Repeater {
                            model: clipboard.filters

                            Rectangle {
                                id: pill
                                required property string modelData
                                readonly property bool active: clipboard.filter === modelData
                                width: pillText.implicitWidth + 22
                                height: 26
                                radius: height / 2
                                color: active ? Wallpaper.accent : win.hairline

                                Label {
                                    id: pillText
                                    anchors.centerIn: parent
                                    text: pill.modelData[0].toUpperCase() + pill.modelData.slice(1)
                                    color: pill.active ? "white" : win.ink
                                    font.pixelSize: 12
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
                            topPadding: 6
                            text: "Ctrl+T"
                            color: win.inkSoft
                            font.pixelSize: 11
                        }
                    }

                    delegate: Column {
                        id: row
                        required property var modelData
                        required property int index
                        readonly property bool isCurrent: index === win.current
                        readonly property bool opensSection: index === 0 || win.results[index - 1].section !== modelData.section
                        width: ListView.view.width

                        Label {
                            visible: row.opensSection
                            leftPadding: 10
                            topPadding: row.index ? 12 : 4
                            bottomPadding: 4
                            text: row.modelData.section
                            color: win.inkSoft
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                        }

                        Rectangle {
                            width: parent.width
                            height: row.modelData.thumb ? 44 : 34
                            radius: 8
                            color: row.isCurrent ? Wallpaper.accent : "transparent"

                            Item {
                                id: rowIcon
                                x: 8
                                anchors.verticalCenter: parent.verticalCenter
                                width: row.modelData.thumb ? 36 : 22
                                height: row.modelData.thumb ? 32 : 22

                                Rectangle {
                                    anchors.fill: parent
                                    visible: !!row.modelData.swatch
                                    radius: 6
                                    color: row.modelData.swatch ?? "transparent"
                                    border.width: 1
                                    border.color: win.hairline
                                }
                                Image {
                                    anchors.fill: parent
                                    visible: !!row.modelData.thumb
                                    fillMode: Image.PreserveAspectCrop
                                    sourceSize: Qt.size(96, 96)
                                    source: row.modelData.thumb ?? ""
                                    cache: false
                                    asynchronous: true
                                }
                                Image {
                                    anchors.fill: parent
                                    visible: !row.modelData.glyph && !row.modelData.thumb && !row.modelData.swatch
                                    sourceSize: Qt.size(44, 44)
                                    source: visible ? Quickshell.iconPath(row.modelData.icon ?? "", "application-x-executable") : ""
                                    asynchronous: true
                                }
                                Label {
                                    anchors.centerIn: parent
                                    visible: !!row.modelData.glyph && !row.modelData.thumb
                                    text: row.modelData.glyph ?? ""
                                    color: row.isCurrent ? "white" : Wallpaper.accent
                                    font.family: "Noto Color Emoji"
                                    font.pixelSize: 17
                                }
                            }
                            Label {
                                id: rowHint
                                anchors.right: parent.right
                                anchors.rightMargin: 10
                                anchors.verticalCenter: parent.verticalCenter
                                width: Math.min(implicitWidth, parent.width * 0.4)
                                elide: Text.ElideRight
                                text: win.armed === row.modelData.key ? "Press Enter again" : win.armed === row.modelData.key + ":delete" ? "Ctrl+X again to delete" : row.modelData.hint ?? ""
                                color: row.isCurrent ? Qt.rgba(1, 1, 1, 0.75) : win.inkSoft
                                font.pixelSize: 12
                            }
                            Label {
                                anchors.left: rowIcon.right
                                anchors.leftMargin: 10
                                anchors.right: rowHint.left
                                anchors.rightMargin: 8
                                anchors.verticalCenter: parent.verticalCenter
                                elide: Text.ElideRight
                                maximumLineCount: 1
                                text: row.modelData.title.replace(/\s+/g, " ")
                                color: row.isCurrent ? "white" : win.ink
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: win.pick(row.index)
                                onDoubleClicked: win.activate(row.modelData, { ctrl: false, shift: false })
                            }
                        }
                    }
                }

                Rectangle {
                    id: divider
                    x: list.x + list.width + 10
                    y: 1
                    width: 1
                    height: parent.height - 1
                    color: win.hairline
                }

                Flickable {
                    id: preview
                    readonly property var info: win.selection ? win.describe(win.selection) : null
                    anchors.left: divider.right
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: noticeBar.top
                    anchors.margins: 24
                    clip: true
                    contentHeight: details.implicitHeight
                    boundsBehavior: Flickable.StopAtBounds
                    visible: info !== null

                    Column {
                        id: details
                        width: preview.width
                        spacing: 8

                        Image {
                            width: parent.width
                            height: 200
                            visible: !!preview.info?.image
                            fillMode: Image.PreserveAspectFit
                            sourceSize: Qt.size(800, 600)
                            source: preview.info?.image ?? ""
                            asynchronous: true
                        }
                        Rectangle {
                            width: parent.width
                            height: 140
                            visible: !!preview.info?.swatch
                            radius: 16
                            color: preview.info?.swatch ?? "transparent"
                            border.width: 1
                            border.color: win.hairline
                        }
                        Image {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 104
                            height: 104
                            visible: !preview.info?.image && !preview.info?.glyph && !preview.info?.swatch && !!preview.info?.icon
                            sourceSize: Qt.size(208, 208)
                            source: visible ? Quickshell.iconPath(preview.info?.icon ?? "", "application-x-executable") : ""
                            asynchronous: true
                        }
                        Label {
                            width: parent.width
                            visible: !!preview.info?.glyph
                            topPadding: 24
                            horizontalAlignment: Text.AlignHCenter
                            fontSizeMode: Text.HorizontalFit
                            minimumPixelSize: 18
                            text: preview.info?.glyph ?? ""
                            color: preview.info?.glyph === "✦" ? Wallpaper.accent : win.ink
                            font.family: win.selection?.kind === "emoji" ? "Noto Color Emoji" : Theme.menu
                            font.pixelSize: preview.info?.glyph?.length > 2 ? 48 : 72
                            font.weight: Font.Bold
                        }
                        Label {
                            width: parent.width
                            visible: text !== ""
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.Wrap
                            text: preview.info?.title ?? ""
                            font.family: Theme.menu
                            font.pixelSize: 20
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
                                font.pixelSize: 12
                            }
                        }
                        Rectangle {
                            width: parent.width
                            height: body.implicitHeight + 24
                            visible: !!preview.info?.body
                            radius: 10
                            color: win.hairline

                            Label {
                                id: body
                                x: 12
                                y: 12
                                width: parent.width - 24
                                wrapMode: Text.Wrap
                                textFormat: preview.info?.markdown ? Text.MarkdownText : Text.PlainText
                                text: preview.info?.body ?? ""
                                font.family: preview.info?.mono ? "Iosevka Nerd Font" : Theme.menuText
                                font.pixelSize: preview.info?.mono ? 11 : 13
                                onLinkActivated: link => Quickshell.execDetached(["xdg-open", link])
                            }
                        }
                        Label {
                            width: parent.width
                            readonly property bool confirming: win.armed !== "" && win.armed.startsWith(win.selectedKey)
                            visible: text !== ""
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.Wrap
                            text: confirming ? (win.armed.endsWith(":delete") ? "Press Ctrl+X again to delete it" : "Press Enter again to confirm") : preview.info ? win.footerOf(preview.info) : ""
                            color: confirming ? Wallpaper.accent : win.inkSoft
                            font.pixelSize: 12
                            font.weight: confirming ? Font.DemiBold : Font.Normal

                            MouseArea {
                                anchors.fill: parent
                                enabled: !!preview.info?.actions?.length && !win.actionTarget
                                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: win.openActions()
                            }
                        }
                    }
                }

                Rectangle {
                    id: noticeBar
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: 10
                    height: win.notice ? noticeText.implicitHeight + 16 : 0
                    visible: win.notice !== ""
                    radius: 10
                    color: Wallpaper.accent

                    Label {
                        id: noticeText
                        anchors.centerIn: parent
                        width: parent.width - 24
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.Wrap
                        text: win.notice
                        color: "white"
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                    }
                }
            }
        }
    }
}
