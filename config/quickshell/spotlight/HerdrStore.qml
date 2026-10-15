import Quickshell
import Quickshell.Io
import QtQuick

// Herdr (terminal workspace manager for coding agents) through its socket API,
// called by spotlight.py. Agents are listed most urgent first (needs input,
// done, working, idle), then workspaces, tabs and the panes that run no agent;
// agents and panes preview their recent output. Enter focuses any of them in
// Herdr and raises the terminal running it, Ctrl+R renames, Ctrl+X closes
// (twice, since it ends their shells and agents), Ctrl+E prompts an agent or
// runs a command in a pane; the rest (keys, zoom, splits, starting agents, tabs,
// worktrees) lives in the Ctrl+K panel. The view refreshes every 2 s while open.
Scope {
    id: root
    property var host
    property var windows
    property var files
    readonly property var snapshot: snapshotSource.items[0] ?? null
    readonly property var kinds: manifests.items.map(manifest => manifest.agent)
    readonly property var statusOrder: ["blocked", "done", "working", "idle", "unknown"]
    readonly property var statusLabels: ({ blocked: "Needs input", done: "Done", working: "Working", idle: "Idle", unknown: "Unknown" })
    readonly property var statusColors: ({ blocked: "#e5a03a", done: "#4caf72", working: "#4a8fe0", idle: "#9a9a9a", unknown: "#9a9a9a" })
    // logical key names as `agent send-keys` takes them
    readonly property var commonKeys: ["esc", "enter", "ctrl+c", "y", "n", "1", "2", "3"]
    readonly property var paneActions: [["", "Send keys…", "keys"], ["", "Zoom pane", "zoom"], ["", "Split right", "split-right"], ["", "Split down", "split-down"]]
    property string peekKey: ""
    property string peekText: ""

    function load() {
        snapshotSource.load();
        sessions.load();
        manifests.load();
    }

    function workspace(id) {
        return snapshot?.workspaces.find(candidate => candidate.workspace_id === id) ?? null;
    }

    function tab(id) {
        return snapshot?.tabs.find(candidate => candidate.tab_id === id) ?? null;
    }

    function agentName(agent) {
        return agent.name ?? agent.display_agent ?? agent.agent ?? "agent";
    }

    function paneName(pane) {
        return pane.label || pane.terminal_title_stripped || (pane.cwd ?? pane.pane_id).replace(Spot.home, "~");
    }

    function plural(count, noun) {
        return `${count} ${noun}${count === 1 ? "" : "s"}`;
    }

    function agentItems(tokens) {
        if (!snapshot)
            return [];
        return snapshot.agents
            .map(agent => ({ agent, space: workspace(agent.workspace_id) }))
            .filter(({ agent, space }) => Spot.matches(`herdr agent ${agentName(agent)} ${statusLabels[agent.agent_status]} ${space?.label ?? ""} ${agent.title ?? ""} ${agent.cwd ?? ""}`, tokens))
            .sort((a, b) => statusOrder.indexOf(a.agent.agent_status) - statusOrder.indexOf(b.agent.agent_status))
            .map(({ agent, space }) => ({ key: "herdr-agent:" + agent.pane_id, kind: "herdrAgent", store: root, agent, paneId: agent.pane_id, space, title: `${agentName(agent)} · ${space?.label ?? agent.workspace_id}`, hint: statusLabels[agent.agent_status], swatch: statusColors[agent.agent_status] }));
    }

    function workspaceItems(tokens) {
        if (!snapshot)
            return [];
        return snapshot.workspaces
            .filter(space => Spot.matches(`herdr workspace ${space.label}`, tokens))
            .map(space => ({ key: "herdr-ws:" + space.workspace_id, kind: "herdrWorkspace", store: root, space, title: space.label, hint: space.agent_status === "unknown" ? plural(space.tab_count, "tab") : statusLabels[space.agent_status], icon: "utilities-terminal" }));
    }

    function tabItems(tokens) {
        if (!snapshot)
            return [];
        return snapshot.tabs
            .map(entry => ({ entry, space: workspace(entry.workspace_id) }))
            .filter(({ entry, space }) => Spot.matches(`herdr tab ${entry.label} ${space?.label ?? ""}`, tokens))
            .map(({ entry, space }) => ({ key: "herdr-tab:" + entry.tab_id, kind: "herdrTab", store: root, tab: entry, space, title: `${entry.label} · ${space?.label ?? entry.workspace_id}`, hint: plural(entry.pane_count, "pane"), icon: "tab-new" }));
    }

    function paneItems(tokens) {
        if (!snapshot)
            return [];
        const agentPanes = new Set(snapshot.agents.map(agent => agent.pane_id));
        return snapshot.panes
            .filter(pane => !agentPanes.has(pane.pane_id))
            .map(pane => ({ pane, space: workspace(pane.workspace_id), tab: tab(pane.tab_id) }))
            .filter(({ pane, space, tab }) => Spot.matches(`herdr pane ${paneName(pane)} ${pane.cwd ?? ""} ${space?.label ?? ""} ${tab?.label ?? ""}`, tokens))
            .map(({ pane, space, tab }) => ({ key: "herdr-pane:" + pane.pane_id, kind: "herdrPane", store: root, pane, paneId: pane.pane_id, space, tab, title: paneName(pane), hint: `${space?.label ?? pane.workspace_id} › ${tab?.label ?? pane.tab_id}`, icon: "utilities-terminal" }));
    }

    function commandItems(tokens) {
        const commands = [
            { action: "open", title: "Open Herdr", icon: "utilities-terminal" },
            { action: "new-workspace", title: "New Herdr Workspace", icon: "folder-new" },
            { action: "new-agent", title: "New Herdr Agent", icon: "utilities-terminal" },
            { action: "new-worktree", title: "New Herdr Worktree", icon: "folder-new" },
            { action: "reload-config", title: "Reload Herdr Config", icon: "view-refresh" }
        ];
        for (const session of sessions.items.filter(session => !session.default))
            commands.push({ action: "attach", session: session.name, title: `Attach Herdr Session “${session.name}”`, icon: "utilities-terminal" });
        return commands
            .filter(command => Spot.matches(command.title, tokens))
            .map(command => Object.assign({ key: "herdr:" + command.action + (command.session ?? ""), kind: "herdrCommand", store: root }, command));
    }

    function describe(item) {
        switch (item.kind) {
        case "herdrAgent": {
            const agent = item.agent;
            const blocked = agent.agent_status === "blocked";
            return { icon: "utilities-terminal", title: agentName(agent), subtitle: `${statusLabels[agent.agent_status]} · ${item.space?.label ?? agent.workspace_id}`, metadata: [...(agent.name ? [["Kind", agent.display_agent ?? agent.agent ?? ""]] : []), ["Folder", (agent.cwd ?? "").replace(Spot.home, "~")]], body: peekKey === item.key ? peekText : "", mono: true, actions: [["Enter", blocked ? "Answer in Herdr" : "Focus in Herdr"], ...(blocked ? [] : [["Ctrl+E", "Send prompt"]]), ["Ctrl+R", "Rename agent"], ["Ctrl+X", "Close pane"], ["Ctrl+C", "Copy pane id"], ...paneActions] };
        }
        case "herdrPane": {
            const pane = item.pane;
            return { icon: item.icon, title: item.title, subtitle: item.hint, metadata: [["Folder", (pane.foreground_cwd ?? pane.cwd ?? "").replace(Spot.home, "~")]], body: peekKey === item.key ? peekText : "", mono: true, actions: [["Enter", "Focus in Herdr"], ["Ctrl+E", "Run command"], ["Ctrl+R", "Rename pane"], ["Ctrl+X", "Close pane"], ["Ctrl+C", "Copy pane id"], ["", "Start agent here…", "start"], ...paneActions] };
        }
        case "herdrTab": {
            const panes = snapshot.panes.filter(pane => pane.tab_id === item.tab.tab_id).map(pane => paneName(pane));
            return { icon: item.icon, title: item.tab.label, subtitle: `${item.space?.label ?? item.tab.workspace_id} · ${plural(item.tab.pane_count, "pane")}`, body: panes.join("\n"), actions: [["Enter", "Focus in Herdr"], ["Ctrl+R", "Rename tab"], ["Ctrl+X", "Close tab"], ["Ctrl+C", "Copy tab id"]] };
        }
        case "herdrWorkspace": {
            const space = item.space;
            const agents = snapshot.agents.filter(agent => agent.workspace_id === space.workspace_id).map(agent => `${agentName(agent)} — ${statusLabels[agent.agent_status]}`);
            return { icon: item.icon, title: space.label, subtitle: `${plural(space.tab_count, "tab")} · ${plural(space.pane_count, "pane")}`, body: agents.join("\n"), actions: [["Enter", "Focus in Herdr"], ["Ctrl+R", "Rename"], ["Ctrl+X", "Close workspace"], ["Ctrl+C", "Copy workspace id"], ["", "New tab", "new-tab"], ["", "New worktree…", "worktree"]] };
        }
        }
        switch (item.action) {
        case "open":
            return { icon: item.icon, title: item.title, subtitle: snapshot ? "Raise the terminal running Herdr" : "Herdr is not running; Enter starts it", actions: [["Enter", "Open"]] };
        case "new-workspace":
            return { icon: item.icon, title: item.title, subtitle: "Pick a folder; frequent ones are suggested", actions: [["Enter", "Create"]] };
        case "new-agent":
            return { icon: item.icon, title: item.title, subtitle: "Pick a folder and an agent kind; it starts in a new workspace", actions: [["Enter", "Start"]] };
        case "new-worktree":
            return { icon: item.icon, title: item.title, subtitle: "Pick a repository and a branch; it opens as a linked workspace", actions: [["Enter", "Create"]] };
        case "reload-config":
            return { icon: item.icon, title: item.title, subtitle: "Re-read config.toml in the running server", actions: [["Enter", "Reload"]] };
        }
        return { icon: item.icon, title: item.title, subtitle: "Opens in a new kitty window", actions: [["Enter", "Attach"]] };
    }

    function peek(item) {
        if (!item.paneId)
            return;
        peekKey = item.key;
        peekText = "";
        reader.exec(["python3", Spot.helper, "herdr", "pane.read", JSON.stringify({ pane_id: item.paneId, source: "recent", lines: 40, strip_ansi: true })]);
    }

    // the Herdr client titles its terminal exactly "<host>: <workspace label>"
    function raiseTerminal() {
        const labels = (snapshot?.workspaces ?? []).map(space => space.label);
        const terminal = windows.list.find(window => Spot.terminals.includes(window.appId) && window.title.indexOf(": ") > 0 && labels.includes(window.title.slice(window.title.indexOf(": ") + 2)));
        if (terminal)
            Quickshell.execDetached(["scrollmsg", `[con_id=${terminal.id}] focus`]);
        else
            Quickshell.execDetached(["kitty", "-1", "herdr"]);
    }

    function call(method, params) {
        job.exec(["python3", Spot.helper, "herdr", method, JSON.stringify(params)]);
    }

    function focusIn(method, params) {
        Spot.helperDetached(["herdr", method, JSON.stringify(params)]);
        raiseTerminal();
        return true;
    }

    function folderOptions() {
        return files.frequentPaths.map(path => path.replace(Spot.home, "~"));
    }

    function expandHome(path) {
        return path.replace(/^~/, Spot.home);
    }

    // `target` is a shell pane id, or a folder that gets a new workspace first
    function startAgent(target) {
        host.openForm({
            title: "Start Agent",
            fields: [{ key: "kind", label: "Agent", value: "", options: kinds }],
            submit: values => {
                Spot.helperDetached(["herdr-start", values.kind, target]);
                raiseTerminal();
                return true;
            }
        });
    }

    function activate(item, keys) {
        switch (item.kind) {
        case "herdrAgent":
            return focusIn("agent.focus", { target: item.paneId });
        case "herdrPane":
            return focusIn("pane.focus", { pane_id: item.paneId });
        case "herdrTab":
            return focusIn("tab.focus", { tab_id: item.tab.tab_id });
        case "herdrWorkspace":
            return focusIn("workspace.focus", { workspace_id: item.space.workspace_id });
        }
        switch (item.action) {
        case "open":
            raiseTerminal();
            return true;
        case "attach":
            Quickshell.execDetached(["kitty", "-1", "herdr", "session", "attach", item.session]);
            return true;
        case "reload-config":
            call("server.reload_config", {});
            host.notify("Herdr config reloaded");
            return false;
        case "new-agent":
            host.openForm({
                title: "New Herdr Agent",
                fields: [{ key: "cwd", label: "Folder", value: "", options: folderOptions() }, { key: "kind", label: "Agent", value: "", options: kinds }],
                submit: values => {
                    Spot.helperDetached(["herdr-start", values.kind, expandHome(values.cwd)]);
                    raiseTerminal();
                    return true;
                }
            });
            return false;
        case "new-worktree":
            host.openForm({
                title: "New Herdr Worktree",
                fields: [{ key: "cwd", label: "Repository", value: "", options: folderOptions() }, { key: "branch", label: "Branch", value: "" }],
                submit: values => focusIn("worktree.create", { cwd: expandHome(values.cwd), branch: values.branch, focus: true })
            });
            return false;
        }
        host.openForm({
            title: "New Herdr Workspace",
            fields: [{ key: "cwd", label: "Folder", value: "", options: folderOptions() }],
            submit: values => {
                const cwd = expandHome(values.cwd);
                return focusIn("workspace.create", { cwd, label: cwd.split("/").pop(), focus: true });
            }
        });
        return false;
    }

    function copy(item) {
        Spot.copy(item.paneId ?? item.tab?.tab_id ?? item.space?.workspace_id ?? item.title);
    }

    function rename(title, label, value, apply) {
        host.openForm({
            title,
            fields: [{ key: "value", label, value }],
            submit: values => {
                apply(values.value);
                return false;
            }
        });
    }

    function act(item, action) {
        const paneId = item.paneId;
        switch (`${item.kind} ${action}`) {
        // a blocked agent needs its own interactive answer, so it can't be prompted
        case "herdrAgent edit":
            if (item.agent.agent_status === "blocked")
                return false;
            host.openForm({
                title: "Prompt " + agentName(item.agent),
                fields: [{ key: "text", label: "Prompt", value: "" }],
                submit: values => {
                    call("agent.prompt", { target: paneId, text: values.text });
                    host.notify(`Sent to ${agentName(item.agent)}`);
                    return false;
                }
            });
            return false;
        case "herdrPane edit":
            host.openForm({
                title: "Run in " + item.title,
                fields: [{ key: "text", label: "Command", value: "" }],
                submit: values => {
                    call("pane.send_input", { pane_id: paneId, text: values.text, keys: ["enter"] });
                    return false;
                }
            });
            return false;
        // Herdr only accepts [a-z][a-z0-9_-]{0,31} as an agent name
        case "herdrAgent rename":
            rename("Rename Agent", "Name", item.agent.name ?? "", name => call("agent.rename", { target: paneId, name }));
            return false;
        case "herdrPane rename":
            rename("Rename Pane", "Label", item.pane.label ?? "", label => call("pane.rename", { pane_id: paneId, label }));
            return false;
        case "herdrTab rename":
            rename("Rename Tab", "Label", item.tab.label, label => call("tab.rename", { tab_id: item.tab.tab_id, label }));
            return false;
        case "herdrWorkspace rename":
            rename("Rename Workspace", "Label", item.space.label, label => call("workspace.rename", { workspace_id: item.space.workspace_id, label }));
            return false;
        case "herdrAgent delete":
        case "herdrPane delete":
            call("pane.close", { pane_id: paneId });
            return false;
        case "herdrTab delete":
            call("tab.close", { tab_id: item.tab.tab_id });
            return false;
        case "herdrWorkspace delete":
            call("workspace.close", { workspace_id: item.space.workspace_id });
            return false;
        case "herdrWorkspace new-tab":
            return focusIn("tab.create", { workspace_id: item.space.workspace_id, focus: true });
        case "herdrWorkspace worktree":
            host.openForm({
                title: "New Worktree of " + item.space.label,
                fields: [{ key: "branch", label: "Branch", value: "" }],
                submit: values => focusIn("worktree.create", { workspace_id: item.space.workspace_id, branch: values.branch, focus: true })
            });
            return false;
        case "herdrPane start":
            startAgent(paneId);
            return false;
        }
        switch (action) {
        case "keys":
            host.openForm({
                title: "Send Keys to " + item.title,
                fields: [{ key: "keys", label: "Keys (space-separated)", value: "", options: commonKeys }],
                submit: values => {
                    call("pane.send_keys", { pane_id: paneId, keys: values.keys.split(/\s+/) });
                    return false;
                }
            });
            return false;
        case "zoom":
            return focusIn("pane.zoom", { pane_id: paneId, mode: "toggle" });
        case "split-right":
        case "split-down":
            return focusIn("pane.split", { target_pane_id: paneId, direction: action.slice(6), cwd: item.agent?.cwd ?? item.pane?.foreground_cwd ?? item.pane?.cwd ?? null, focus: true });
        }
        return false;
    }

    Source {
        id: snapshotSource
        maxAge: 2000
        command: ["python3", Spot.helper, "herdr", "session.snapshot"]
        parse: output => output.trim() ? [JSON.parse(output).snapshot] : []
    }

    Source {
        id: sessions
        maxAge: 60000
        command: ["herdr", "session", "list", "--json"]
        parse: output => output.trim() ? JSON.parse(output).sessions : []
    }

    Source {
        id: manifests
        command: ["python3", Spot.helper, "herdr", "server.agent_manifests"]
        parse: output => output.trim() ? JSON.parse(output).manifests : []
    }

    Process {
        id: reader
        stdout: StdioCollector {
            onStreamFinished: root.peekText = text.trim() ? JSON.parse(text).read.text.replace(/\s+$/, "") : ""
        }
    }

    Process {
        id: job
        stderr: StdioCollector {
            id: jobErrors
        }
        onExited: exitCode => {
            if (exitCode !== 0)
                root.host.notify(jobErrors.text.trim());
            snapshotSource.reload();
        }
    }

    Timer {
        interval: 2000
        running: root.host.mode === "herdr"
        repeat: true
        onTriggered: snapshotSource.reload()
    }
}
