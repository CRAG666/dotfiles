import Quickshell
import QtQuick

// Shell commands (the "run" view, or "> cmd" from anywhere) and the
// executables on PATH that complete the program name. Ctrl+Enter runs in the terminal.
Scope {
    id: root
    property var host

    function load() {
        executables.load();
    }

    function items(commandLine, withExecutables) {
        if (!commandLine)
            return [];
        const [program, ...rest] = commandLine.split(/\s+/);
        const list = [{ key: "run:" + commandLine, kind: "run", store: root, title: `Run “${commandLine}”`, icon: "system-run", value: commandLine }];
        if (withExecutables)
            for (const name of executables.items.filter(name => name.startsWith(program) && name !== program).slice(0, 40))
                list.push({ key: "run:" + name, kind: "run", store: root, title: name, hint: rest.join(" "), icon: Spot.iconFor(name), value: [name, ...rest].join(" ") });
        return list;
    }

    function describe(item) {
        return { icon: item.icon, title: item.value, subtitle: "Command", actions: [["Enter", "Run"], ["Ctrl+Enter", "Run in terminal"], ["Ctrl+C", "Copy command"]] };
    }

    function activate(item, keys) {
        Quickshell.execDetached(keys.ctrl ? [...host.userConfig.terminal, ...Spot.hold(["sh", "-c", item.value])] : ["sh", "-c", item.value]);
        return true;
    }

    Source {
        id: executables
        maxAge: 300000
        command: ["bash", "-c", "compgen -c | sort -u"]
        parse: output => output.split("\n").filter(line => line)
    }
}
