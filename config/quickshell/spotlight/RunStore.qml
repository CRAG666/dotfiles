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
            for (const name of startingWith(program, 40))
                list.push({ key: "run:" + name, kind: "run", store: root, title: name, hint: rest.join(" "), icon: Spot.iconFor(name), value: [name, ...rest].join(" ") });
        return list;
    }

    // up to `limit` executables that extend `prefix`: sorted, they sit together
    // from the first name not below it, found by binary search
    function startingWith(prefix, limit) {
        const names = executables.items;
        let low = 0;
        let high = names.length;
        while (low < high) {
            const middle = (low + high) >> 1;
            if (names[middle] < prefix)
                low = middle + 1;
            else
                high = middle;
        }
        const found = [];
        for (let at = low; at < names.length && found.length < limit && names[at].startsWith(prefix); at++)
            if (names[at] !== prefix)
                found.push(names[at]);
        return found;
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
        // in code-unit order, the one startingWith() searches by
        parse: output => output.split("\n").filter(line => line).sort()
    }
}
