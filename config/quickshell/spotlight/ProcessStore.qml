import Quickshell
import Quickshell.Io
import QtQuick

// Your processes, busiest first. Enter ends the selected one (SIGTERM),
// Ctrl+Enter kills it (SIGKILL); both ask for a second press.
Scope {
    id: root
    property var host

    function refresh() {
        list.reload();
    }

    function items(tokens) {
        return Spot.take(list.items, process => Spot.matches(process.args, tokens, false), 150)
            .map(process => ({ key: "process:" + process.pid, kind: "process", store: root, process, title: process.name, hint: `${process.cpu}% · ${Spot.formatSize(process.memory)}`, icon: Spot.iconFor(process.name), confirm: true }));
    }

    function describe(item) {
        const process = item.process;
        return { icon: item.icon, title: process.name, metadata: [["PID", process.pid], ["CPU", process.cpu + "%"], ["Memory", Spot.formatSize(process.memory)]], body: process.args, mono: true, actions: [["Enter", "End (SIGTERM)"], ["Ctrl+Enter", "Kill (SIGKILL)"], ["Ctrl+C", "Copy PID"]] };
    }

    function activate(item, keys) {
        killer.exec(["kill", keys.ctrl ? "-KILL" : "-TERM", item.process.pid]);
        return false;
    }

    function copy(item) {
        Spot.copy(item.process.pid);
    }

    Source {
        id: list
        // the first line is the pid ps runs as, so the listing leaves itself out
        command: ["sh", "-c", 'echo $$; exec ps -u "$(id -u)" -o pid=,pcpu=,rss=,args= --sort=-pcpu']
        parse: output => {
            const [self, ...lines] = output.split("\n");
            return lines.filter(line => line.trim()).map(line => {
                const [pid, cpu, rss, ...args] = line.trim().split(/\s+/);
                return { pid, cpu, memory: Number(rss) * 1024, args: args.join(" "), name: args[0].split("/").pop() };
            }).filter(process => process.pid !== self.trim());
        }
    }

    Process {
        id: killer
        stderr: StdioCollector {
            id: killerErrors
        }
        onExited: exitCode => {
            if (exitCode !== 0)
                root.host.notify(killerErrors.text.trim());
            list.reload();
        }
    }
}
