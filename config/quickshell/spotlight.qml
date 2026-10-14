//@ pragma IconTheme Macjaro
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Effects

// Spotlight/Raycast-style launcher. It stays resident and hidden: spotlight.sh
// toggles it over IPC, optionally straight into a view, so opening it only
// maps a ready window. Every store loads its sources the first time a view or
// a search needs them and keeps them cached between openings (see Source).
// One query searches apps, windows, Herdr, commands, AI commands, SSH hosts,
// snippets, bookmarks, notes, passwords, GitHub repos and files, plus inline
// math, URLs and quicklinks, then offers a question to pi or a web search; the
// selection is previewed on the right. Each view is an entry of `views`; each
// kind of result belongs to a store (AppStore, FileStore, ...), which lists,
// describes and activates its own items. Keys are listed in help.js (Ctrl+?).
ShellRoot {
    PanelWindow {
        id: win
        visible: false

        readonly property bool dark: Theme.eyesDark
        readonly property color ink: dark ? "#f5f5f7" : "#1d1d1f"
        readonly property color inkSoft: dark ? Qt.rgba(1, 1, 1, 0.55) : Qt.rgba(0, 0, 0, 0.5)
        readonly property color glass: dark ? Qt.rgba(0.11, 0.11, 0.12, 0.68) : Qt.alpha(Qt.tint(Qt.rgba(0.96, 0.96, 0.97, 1), Qt.alpha(Wallpaper.tint, 0.18)), 0.68)
        readonly property color hairline: dark ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.1)

        // `chip`: listed in the bar, reachable with Ctrl+1..8 and Tab; `alias`
        // plus a space opens the view ("hr " → Herdr); `open` loads what it shows
        readonly property var views: [
            { mode: "apps", chip: "\uf009", title: "Search Apps", icon: "applications-other", sections: (tokens, raw) => [["Applications", apps.items(raw)]] },
            { mode: "files", chip: "\uf07b", alias: "fi", title: "Search Files", icon: "folder", open: () => files.load(), sections: tokens => files.sections(tokens, false) },
            { mode: "commands", chip: "\uf0e7", alias: "cmd", title: "Commands", placeholder: "Search Commands", icon: "system-run", open: () => herdr.load(), sections: tokens => [["Commands", commandItems(tokens)]] },
            { mode: "clipboard", chip: "\uf0ea", alias: "cb", title: "Clipboard History", placeholder: "Search Clipboard", icon: "edit-paste", open: () => clipboard.load(), sections: tokens => [["Clipboard", clipboard.items(tokens)]] },
            { mode: "windows", chip: "\uf2d0", alias: "win", title: "Switch Windows", placeholder: "Search Windows", icon: "preferences-system-windows", open: () => windows.load(), sections: tokens => [["Windows", windows.items(tokens, 80)]] },
            { mode: "snippets", chip: "\uf121", alias: "sn", title: "Search Snippets", icon: "insert-text", sections: tokens => [["Snippets", snippets.snippetItems(tokens)]] },
            { mode: "emoji", chip: "\uf118", title: "Search Emoji", icon: "face-smile", open: () => snippets.load(), sections: tokens => [["Emoji", snippets.emojiItems(tokens)]] },
            { mode: "passwords", chip: "\uf084", alias: "pw", title: "Search Passwords", icon: "dialog-password", open: () => passwords.load(), sections: tokens => [["Passwords", passwords.items(tokens)]] },
            { mode: "bookmarks", alias: "bm", title: "Search Bookmarks", icon: "user-bookmarks", open: () => library.load(), sections: tokens => [["Bookmarks", library.bookmarkItems(tokens)], ["Commands", library.commandItems(["bookmark"])]] },
            { mode: "notes", alias: "nt", title: "Search Notes", icon: "accessories-text-editor", open: () => library.load(), sections: tokens => [["Notes", library.noteItems(tokens)], ["Commands", library.commandItems(["note"])]] },
            { mode: "quicklinks", alias: "ql", title: "Quicklinks", placeholder: "Search Quicklinks", icon: "web-browser", sections: (tokens, raw) => [["Quicklinks", web.quicklinkItems(tokens, raw)]] },
            { mode: "processes", alias: "ps", title: "Kill Process", placeholder: "Search Processes", icon: "utilities-system-monitor", open: () => processes.refresh(), sections: tokens => [["Processes", processes.items(tokens)]] },
            { mode: "history", alias: "bh", title: "Search Browser History", icon: "web-browser", open: () => browser.loadHistory(), sections: tokens => [["History", browser.historyItems(tokens)]] },
            { mode: "tabs", alias: "bt", title: "Search Browser Tabs", icon: "web-browser", open: () => browser.loadTabs(), sections: tokens => [["Tabs", browser.tabItems(tokens)]] },
            { mode: "timers", alias: "tm", title: "Timers", placeholder: "Type a duration: 10m tea", icon: "alarm-clock", sections: (tokens, raw) => [["Timers", timers.items(tokens, raw, true)]] },
            { mode: "colors", alias: "co", title: "Color History", placeholder: "Search Colors", icon: "color-picker", sections: tokens => [["Colors", colors.items(tokens)]] },
            { mode: "ai", alias: "ac", title: "AI Commands", placeholder: "Search AI Commands", icon: "", glyph: "✦", sections: tokens => [["AI Commands", ai.commandItems(tokens)]] },
            { mode: "run", title: "Run Command", placeholder: "Type a command", icon: "system-run", open: () => run.load(), sections: (tokens, raw) => [["Run", run.items(raw, true)]] },
            { mode: "marks", alias: "mk", title: "Scroll Marks", placeholder: "Search marks or type a new one", icon: "bookmark-new", open: () => windows.reload(), sections: (tokens, raw) => [["Marks", marks.items(tokens, raw)]] },
            { mode: "herdr", alias: "hr", title: "Herdr", placeholder: "Search Herdr agents and workspaces", icon: "utilities-terminal", open: () => { herdr.load(); windows.load(); files.load(); }, sections: tokens => [["Agents", herdr.agentItems(tokens)], ["Workspaces", herdr.workspaceItems(tokens)], ["Herdr", herdr.commandItems(tokens)]] },
            { mode: "wallpapers", alias: "wp", title: "Wallpapers", placeholder: "Search Wallpapers", icon: "preferences-desktop-wallpaper", open: () => wallpapers.load(), sections: tokens => [["Wallpapers", wallpapers.items(tokens)]] },
            { mode: "tools", alias: "tl", title: "Tools", placeholder: "Search Tools", icon: "applications-utilities", sections: tokens => [["Tools", commands.toolItems(tokens)]] },
            { mode: "help", alias: "?", title: "Spotlight Help", placeholder: "Search shortcuts and features", icon: "help-about", sections: tokens => [["Help", help.items(tokens)]] }
        ]
        readonly property var chips: views.filter(view => view.chip)
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
        property bool keepSelection: false
        property string armed: ""
        property string notice: ""
        property var actionTarget: null   // the item whose Ctrl+K panel is open
        property string savedQuery: ""

        // a form runs its fields one by one through the search field
        property var form: null   // { title, fields: [{ key, label, value, options }], submit: values => closes, closeOnCancel }
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

        // the search of everything only needs its sources once something is typed
        onQueryChanged: {
            keepSelection = false;
            if (mode || !query)
                return;
            windows.load();
            herdr.load();
            library.load();
            passwords.load();
            ssh.load();
            files.load();
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
                if (win.visible)
                    win.close();
                else
                    win.open(mode);
            }
        }

        function open(requested) {
            windows.forget();
            if (requested === "mark-add")
                marks.promptAdd();
            else
                mode = views.some(view => view.mode === requested) ? requested : "";
            visible = true;
            search.forceActiveFocus();
            fadeIn.restart();
            clipboardNow.running = true;
            selectionNow.running = true;
            Wallpaper.refresh();
        }

        // everything goes back to an empty search, so the next opening starts clean
        function close() {
            visible = false;
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
                close();
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

        function actionItems() {
            const tokens = query.toLowerCase().split(/\s+/).filter(token => token);
            return (describe(actionTarget).actions ?? [])
                .filter(([keys, label]) => Spot.matches(label + " " + keys, tokens))
                .map(([keys, label]) => ({ key: "action:" + keys, kind: "action", section: "Actions · " + actionTarget.title, title: label, hint: keys, shortcut: keys, icon: actionTarget.icon, glyph: actionTarget.glyph, swatch: actionTarget.swatch }));
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
            return [...commands.items(tokens), ...commands.viewItems(tokens), ...commands.toolItems(tokens), ...library.commandItems(tokens), ...herdr.commandItems(tokens), ...colors.pickItem(tokens), ...commands.mediaItems(tokens), ...apps.actionItems(tokens)];
        }

        // the search of everything: [section, items] pairs, best kinds first
        function everything(tokens, raw) {
            if (!tokens.length)
                return [];
            const view = views.find(entry => entry.alias === raw.toLowerCase());
            const found = apps.items(raw);
            return [
                ["Views", view ? [Object.assign(commands.viewItem(view), { key: "alias:" + view.mode })] : []],
                ["Calculator", calculator.items(raw)],
                ["Website", web.urlItems(raw)],
                ["Quicklinks", web.quicklinkItems(tokens, raw).slice(0, 3)],
                ["SSH", tokens[0] === "ssh" ? ssh.items(tokens) : []],
                ["Timers", ["timer", "pomodoro"].includes(tokens[0]) ? timers.items(tokens, raw.replace(/^timer\s*/i, ""), false) : []],
                ["Top Hit", found.slice(0, 1)],
                ["Applications", found.slice(1, 6)],
                ["Windows", windows.items(tokens, 4)],
                ["Herdr", [...herdr.agentItems(tokens).slice(0, 3), ...herdr.workspaceItems(tokens).slice(0, 2)]],
                ["Commands", commandItems(tokens).filter(item => item.key !== "mode:" + view?.mode).slice(0, 5)],
                ["AI Commands", ai.commandItems(tokens).slice(0, 3)],
                ["SSH", tokens[0] === "ssh" ? [] : ssh.items(tokens).slice(0, 4)],
                ["Snippets", snippets.snippetItems(tokens).slice(0, 3)],
                ["Bookmarks", library.bookmarkItems(tokens).slice(0, 4)],
                ["Notes", library.noteItems(tokens).slice(0, 3)],
                ["Passwords", passwords.items(tokens).slice(0, 3)],
                ["GitHub", web.repoItems(tokens).slice(0, 4)],
                ...files.sections(tokens, true),
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
            const tokens = raw.replace(/^[:>]/, "").toLowerCase().split(/\s+/).filter(token => token);
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

        // `actions` are [keys, label] pairs: they feed the footer and the Ctrl+K panel
        function describe(item) {
            if (item.kind === "action")
                return describe(actionTarget);
            if (item.kind === "form")
                return { icon: item.icon, title: form.title, subtitle: `Step ${formStep + 1} of ${form.fields.length}: ${form.fields[formStep].label}`, details: Object.entries(formValues).map(([key, value]) => `${key}: ${value}`), footer: "Enter continues · Esc cancels" };
            return item.store.describe(item);
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
            const item = results[current];
            if (item?.store?.peek)
                item.store.peek(item);
        }

        function activate(item, keys) {
            if (!item)
                return;
            if (item.kind === "action") {
                runShortcut(actionTarget, item.shortcut);
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
            if (item.store.activate(item, keys))
                close();
        }

        function copyItem(item) {
            if (!item || item.kind === "form" || item.kind === "action")
                return;
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

        AppStore {
            id: apps
        }
        FileStore {
            id: files
            query: (win.mode === "" || win.mode === "files") && !win.form && !win.actionTarget && !/^[:>]/.test(win.query) ? win.query : ""
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

        FileView {
            path: Spot.home + "/.config/quickshell/spotlight.json"
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
            onClicked: win.close()
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
            Behavior on radius { enabled: win.visible; NumberAnimation { duration: 160 } }

            width: 820
            height: bar.height + (expanded ? 460 : 0)
            Behavior on height { enabled: win.visible; NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
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
                        text: win.actionTarget ? `Search actions for ${win.actionTarget.title}` : win.formField ? win.formField.label : win.currentView ? win.currentView.placeholder ?? win.currentView.title : "Spotlight Search  ·  Ctrl+? for help"
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
                                text: chip.modelData.chip
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
