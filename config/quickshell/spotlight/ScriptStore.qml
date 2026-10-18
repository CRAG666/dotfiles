import Quickshell
import Quickshell.Io
import QtQuick

// Script Commands, Raycast's format: executables in ~/.config/spotlight/scripts whose
// comment header names them (`# @raycast.title`, or `@spotlight.`), listed
// among the commands. Arguments (argument1..3: text or dropdown) are asked
// through a form; mode silent and compact notify the last line of output,
// fullOutput shows all of it in the preview. Ctrl+E edits the script.
Scope {
    id: root
    property var host
    property string outputKey: ""
    property string output: ""
    property bool running: false

    function load() {
        source.load();
    }

    // Raycast's icon is an emoji, an image path or a URL; only emoji show here
    function glyph(script) {
        return script.icon && !/[\/.]/.test(script.icon) ? script.icon : "";
    }

    function items(tokens) {
        return source.items
            .filter(script => Spot.matches(`${script.title} ${script.package} ${script.description} script`, tokens))
            .map(script => ({ key: "script:" + script.path, kind: "script", store: root, script, title: script.title, hint: script.error ? "Broken header" : script.package, icon: "system-run", glyph: glyph(script), confirm: script.confirm }));
    }

    function commandItems(tokens) {
        return Spot.matches("New Script Command", tokens) ? [{ key: "script:new", kind: "scriptNew", store: root, title: "New Script Command", icon: "document-new" }] : [];
    }

    function describe(item) {
        if (item.kind === "scriptNew")
            return { icon: item.icon, title: item.title, subtitle: "Creates ~/.config/spotlight/scripts/<name>.sh from a template and opens it", actions: [["Enter", "Create"]] };
        const script = item.script;
        const shown = outputKey === item.key;
        return {
            icon: item.icon,
            glyph: item.glyph,
            title: script.title,
            subtitle: script.error ?? script.description,
            metadata: [["Mode", script.mode], ["Arguments", script.arguments.map(argument => argument.placeholder ?? argument.type).join(", ")], ["File", Spot.tilde(script.path)]],
            body: shown ? (running ? "Running…" : output) : "",
            mono: true,
            actions: [["Enter", script.mode === "fullOutput" ? "Run and show output" : "Run"], ["Ctrl+E", "Edit script"], ["Ctrl+C", "Copy path"]]
        };
    }

    function label(argument, index) {
        return argument.placeholder ?? `Argument ${index + 1}`;
    }

    function run(item, values) {
        const script = item.script;
        if (script.mode !== "fullOutput") {
            Quickshell.execDetached(["sh", "-c", 'title=$1; cd "$2" || exit; shift 2; out=$("$@" 2>&1); code=$?; last=$(printf "%s\\n" "$out" | tail -n 1); if [ $code -ne 0 ]; then notify-send -u critical "$title" "${last:-exit $code}"; elif [ -n "$last" ]; then notify-send -t 3000 "$title" "$last"; fi', "sh", script.title, script.cwd, script.path, ...values]);
            return true;
        }
        outputKey = item.key;
        output = "";
        running = true;
        job.workingDirectory = script.cwd;
        job.exec([script.path, ...values]);
        return false;
    }

    function activate(item, keys) {
        if (item.kind === "scriptNew") {
            host.openForm({
                title: "New Script Command",
                fields: [{ key: "title", label: "Title", value: "" }],
                submit: values => {
                    creator.exec(Spot.helperCommand(["script-new", values.title]));
                    return true;
                }
            });
            return false;
        }
        const script = item.script;
        if (script.error) {
            host.notify(script.error);
            return false;
        }
        if (!script.arguments.length)
            return run(item, []);
        host.openForm({
            title: script.title,
            fields: script.arguments.map((argument, index) => ({ key: label(argument, index), label: label(argument, index), value: "", options: (argument.data ?? []).map(choice => choice.title), optional: argument.optional ?? false, strict: argument.type === "dropdown" })),
            submit: values => {
                const passed = script.arguments.map((argument, index) => {
                    const typed = values[label(argument, index)] ?? "";
                    const value = (argument.data ?? []).find(choice => choice.title === typed)?.value ?? typed;
                    return argument.percentEncoded ? encodeURIComponent(value) : value;
                });
                // a fullOutput result stays open on the script, its output in the preview
                if (!run(item, passed)) {
                    host.setQuery(script.title);
                    return false;
                }
                return true;
            }
        });
        return false;
    }

    function copy(item) {
        Spot.copy(item.script?.path ?? item.title);
    }

    function act(item, action) {
        if (item.kind !== "script" || action !== "edit")
            return false;
        Quickshell.execDetached([...host.userConfig.terminal, ...Spot.editor(item.script.path)]);
        source.reload();
        return true;
    }

    Source {
        id: source
        maxAge: 10000
        command: ["python3", Spot.helper, "scripts"]
    }

    // script-new returns when its editor closes, with the header filled in
    Process {
        id: creator
        onExited: source.reload()
    }

    Process {
        id: job
        stdout: StdioCollector {
            id: jobOut
        }
        stderr: StdioCollector {
            id: jobErrors
        }
        onExited: exitCode => {
            root.output = (jobOut.text + jobErrors.text).replace(/\x1b\[[0-9;]*m/g, "").replace(/\s+$/, "") || `(no output, exit ${exitCode})`;
            root.running = false;
        }
    }
}
