import Quickshell
import Quickshell.Io
import QtQuick

// Herdr (terminal workspace manager for coding agents) through its socket API,
// called by spotlight.py. Agents are listed most urgent first (needs input,
// done, working, idle) with their recent output as preview; Enter focuses an
// agent or workspace in Herdr and raises the terminal running it, Ctrl+E sends
// an agent a prompt, Ctrl+R renames a workspace. Closing workspaces is left to
// Herdr itself, since it ends their shells and agents. Everything else only
// reads the session; the view refreshes every 2 s while it is open.
Scope {
    id: root
    property var host
    property var windows
    property var files
    readonly property var snapshot: snapshotSource.items[0] ?? null
    readonly property var statusOrder: ["blocked", "done", "working", "idle", "unknown"]
    readonly property var statusLabels: ({ blocked: "Needs input", done: "Done", working: "Working", idle: "Idle", unknown: "Unknown" })
    readonly property var statusColors: ({ blocked: "#e5a03a", done: "#4caf72", working: "#4a8fe0", idle: "#9a9a9a", unknown: "#9a9a9a" })
    property string peekKey: ""
    property string peekText: ""

    function load() {
        snapshotSource.load();
        sessions.load();
    }

    function workspace(id) {
        return snapshot?.workspaces.find(candidate => candidate.workspace_id === id) ?? null;
    }

    function agentName(agent) {
        return agent.display_agent ?? agent.agent ?? agent.name ?? "agent";
    }

    function agentItems(tokens) {
        if (!snapshot)
            return [];
        return snapshot.agents
            .map(agent => ({ agent, space: workspace(agent.workspace_id) }))
            .filter(({ agent, space }) => Spot.matches(`herdr agent ${agentName(agent)} ${statusLabels[agent.agent_status]} ${space?.label ?? ""} ${agent.title ?? ""} ${agent.cwd ?? ""}`, tokens))
            .sort((a, b) => statusOrder.indexOf(a.agent.agent_status) - statusOrder.indexOf(b.agent.agent_status))
            .map(({ agent, space }) => ({ key: "herdr-agent:" + agent.pane_id, kind: "herdrAgent", store: root, agent, space, title: `${agentName(agent)} · ${space?.label ?? agent.workspace_id}`, hint: statusLabels[agent.agent_status], swatch: statusColors[agent.agent_status] }));
    }

    function workspaceItems(tokens) {
        if (!snapshot)
            return [];
        return snapshot.workspaces
            .filter(space => Spot.matches(`herdr workspace ${space.label}`, tokens))
            .map(space => ({ key: "herdr-ws:" + space.workspace_id, kind: "herdrWorkspace", store: root, space, title: space.label, hint: space.agent_status === "unknown" ? `${space.tab_count} ${space.tab_count === 1 ? "tab" : "tabs"}` : statusLabels[space.agent_status], icon: "utilities-terminal" }));
    }

    function commandItems(tokens) {
        const commands = [{ action: "open", title: "Open Herdr", icon: "utilities-terminal" }, { action: "new-workspace", title: "New Herdr Workspace", icon: "folder-new" }];
        for (const session of sessions.items.filter(session => !session.default))
            commands.push({ action: "attach", session: session.name, title: `Attach Herdr Session “${session.name}”`, icon: "utilities-terminal" });
        return commands
            .filter(command => Spot.matches(command.title, tokens))
            .map(command => Object.assign({ key: "herdr:" + command.action + (command.session ?? ""), kind: "herdrCommand", store: root }, command));
    }

    function describe(item) {
        if (item.kind === "herdrAgent") {
            const agent = item.agent;
            return { icon: "utilities-terminal", title: agentName(agent), subtitle: `${statusLabels[agent.agent_status]} · ${item.space?.label ?? agent.workspace_id}`, metadata: [["Folder", (agent.cwd ?? "").replace(Spot.home, "~")]], body: peekKey === item.key ? peekText : "", mono: true, actions: [["Enter", agent.agent_status === "blocked" ? "Answer in Herdr" : "Focus in Herdr"], ...(agent.agent_status === "blocked" ? [] : [["Ctrl+E", "Send prompt"]]), ["Ctrl+C", "Copy pane id"]] };
        }
        if (item.kind === "herdrWorkspace") {
            const space = item.space;
            const agents = snapshot.agents.filter(agent => agent.workspace_id === space.workspace_id).map(agent => `${agentName(agent)} — ${statusLabels[agent.agent_status]}`);
            return { icon: item.icon, title: space.label, subtitle: `${space.tab_count} ${space.tab_count === 1 ? "tab" : "tabs"} · ${space.pane_count} ${space.pane_count === 1 ? "pane" : "panes"}`, body: agents.join("\n"), actions: [["Enter", "Focus in Herdr"], ["Ctrl+R", "Rename"]] };
        }
        if (item.action === "open")
            return { icon: item.icon, title: item.title, subtitle: snapshot ? "Raise the terminal running Herdr" : "Herdr is not running; Enter starts it", actions: [["Enter", "Open"]] };
        if (item.action === "new-workspace")
            return { icon: item.icon, title: item.title, subtitle: "Pick a folder; frequent ones are suggested", actions: [["Enter", "Create"]] };
        return { icon: item.icon, title: item.title, subtitle: "Opens in a new kitty window", actions: [["Enter", "Attach"]] };
    }

    function peek(item) {
        if (item.kind !== "herdrAgent")
            return;
        peekKey = item.key;
        peekText = "";
        reader.exec(["python3", Spot.helper, "herdr", "agent.read", JSON.stringify({ target: item.agent.pane_id, source: "recent", lines: 40, strip_ansi: true })]);
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

    function activate(item, keys) {
        switch (item.kind) {
        case "herdrAgent":
            Spot.helperDetached(["herdr", "agent.focus", JSON.stringify({ target: item.agent.pane_id })]);
            raiseTerminal();
            return true;
        case "herdrWorkspace":
            Spot.helperDetached(["herdr", "workspace.focus", JSON.stringify({ workspace_id: item.space.workspace_id })]);
            raiseTerminal();
            return true;
        }
        switch (item.action) {
        case "open":
            raiseTerminal();
            return true;
        case "attach":
            Quickshell.execDetached(["kitty", "-1", "herdr", "session", "attach", item.session]);
            return true;
        }
        host.openForm({
            title: "New Herdr Workspace",
            fields: [{ key: "cwd", label: "Folder", value: "", options: files.frequentPaths.map(path => path.replace(Spot.home, "~")) }],
            submit: values => {
                const cwd = values.cwd.replace(/^~/, Spot.home);
                Spot.helperDetached(["herdr", "workspace.create", JSON.stringify({ cwd, label: cwd.split("/").pop(), focus: true })]);
                raiseTerminal();
                return true;
            }
        });
        return false;
    }

    function copy(item) {
        Spot.copy(item.agent?.pane_id ?? item.space?.workspace_id ?? item.title);
    }

    function act(item, action) {
        // a blocked agent needs its own interactive answer, so it can't be prompted
        if (item.kind === "herdrAgent" && action === "edit" && item.agent.agent_status !== "blocked") {
            host.openForm({
                title: "Prompt " + agentName(item.agent),
                fields: [{ key: "text", label: "Prompt", value: "" }],
                submit: values => {
                    call("agent.prompt", { target: item.agent.pane_id, text: values.text });
                    host.notify(`Sent to ${agentName(item.agent)}`);
                    return false;
                }
            });
        } else if (item.kind === "herdrWorkspace" && action === "rename") {
            host.openForm({
                title: "Rename Workspace",
                fields: [{ key: "label", label: "Label", value: item.space.label }],
                submit: values => {
                    call("workspace.rename", { workspace_id: item.space.workspace_id, label: values.label });
                    return false;
                }
            });
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
