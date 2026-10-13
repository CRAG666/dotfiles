import Quickshell
import Quickshell.Io
import QtQuick

// Timers ("timer 10m tea", "timer 1h30m") and a pomodoro (4 × 25 min focus +
// 5 min break) run as transient systemd user units, so they outlive Spotlight
// and ring with a notification and a sound. Running ones are listed with their
// time left; Enter on one cancels it.
Scope {
    id: root
    property var host
    property var timers: []
    property double now: Date.now()
    readonly property var running: timers.filter(timer => timer.end > now)
    readonly property string sounds: "/usr/share/sounds/freedesktop/stereo"
    readonly property int focusMinutes: 25
    readonly property int breakMinutes: 5
    readonly property int rounds: 4

    function save(list) {
        timers = list;
        state.setText(JSON.stringify(list));
    }

    // "10m tea", "1h30m", "90s", "10" (minutes) → { seconds, name }
    function parse(text) {
        const match = text.match(/^((?:\d+\s*[hms]\s*)+|\d+)(.*)$/i);
        if (!match)
            return null;
        const pattern = /(\d+)\s*([hms]?)/gi;
        let seconds = 0;
        for (let part = pattern.exec(match[1]); part; part = pattern.exec(match[1]))
            seconds += Number(part[1]) * ({ h: 3600, m: 60, s: 1 }[part[2].toLowerCase()] ?? 60);
        return seconds > 0 ? { seconds, name: match[2].trim() } : null;
    }

    function clock(milliseconds) {
        const total = Math.max(0, Math.round(milliseconds / 1000));
        const hours = Math.floor(total / 3600);
        const rest = `${String(Math.floor(total / 60) % 60).padStart(2, "0")}:${String(total % 60).padStart(2, "0")}`;
        return hours ? `${hours}:${rest}` : rest;
    }

    function duration(seconds) {
        const hours = Math.floor(seconds / 3600);
        const minutes = Math.floor(seconds / 60) % 60;
        return [hours && `${hours} h`, minutes && `${minutes} min`, seconds % 60 && `${seconds % 60} s`].filter(part => part).join(" ");
    }

    function phase(timer) {
        const cycle = (focusMinutes + breakMinutes) * 60000;
        const elapsed = now - timer.start;
        const round = Math.min(rounds, Math.floor(elapsed / cycle) + 1);
        const inCycle = elapsed % cycle;
        const focusing = inCycle < focusMinutes * 60000;
        return { round, focusing, left: (focusing ? focusMinutes * 60000 : cycle) - inCycle };
    }

    function items(tokens, spec, listAll) {
        const list = [];
        const parsed = parse(spec);
        if (parsed)
            list.push({ key: "timer:start", kind: "timerStart", store: root, title: `Start ${duration(parsed.seconds)} timer${parsed.name ? ` “${parsed.name}”` : ""}`, icon: "alarm-clock", spec: parsed });
        if (listAll || Spot.matches("pomodoro", tokens))
            list.push({ key: "timer:pomodoro", kind: "pomodoroStart", store: root, title: "Start Pomodoro", hint: `${rounds} × ${focusMinutes} + ${breakMinutes} min`, icon: "alarm-clock" });
        for (const timer of running) {
            const left = timer.kind === "pomodoro" ? phase(timer).left : timer.end - now;
            list.push({ key: "timer:" + timer.unit, kind: "timer", store: root, timer, title: timer.name, hint: clock(left) + " left", icon: "alarm-clock", confirm: true });
        }
        return list;
    }

    function describe(item) {
        if (item.kind === "timerStart")
            return { icon: item.icon, title: item.title, subtitle: "Rings at " + Qt.formatTime(new Date(now + item.spec.seconds * 1000), "HH:mm"), actions: [["Enter", "Start"]] };
        if (item.kind === "pomodoroStart")
            return { icon: item.icon, title: item.title, subtitle: `${rounds} rounds of ${focusMinutes} min focus and ${breakMinutes} min break`, actions: [["Enter", "Start"]] };
        if (item.timer.kind === "pomodoro") {
            const current = phase(item.timer);
            return { glyph: clock(current.left), title: `Round ${current.round}/${rounds} · ${current.focusing ? "Focus" : "Break"}`, subtitle: "Pomodoro ends at " + Qt.formatTime(new Date(item.timer.end), "HH:mm"), actions: [["Enter", "Cancel"]] };
        }
        return { glyph: clock(item.timer.end - now), title: item.timer.name, subtitle: "Rings at " + Qt.formatTime(new Date(item.timer.end), "HH:mm"), actions: [["Enter", "Cancel"]] };
    }

    function activate(item, keys) {
        const unit = `spotlight-${item.kind === "pomodoroStart" ? "pomodoro" : "timer"}-${Date.now()}`;
        if (item.kind === "timerStart") {
            const name = item.spec.name || `${duration(item.spec.seconds)} timer`;
            Quickshell.execDetached(["systemd-run", "--user", "--quiet", "--unit=" + unit, `--on-active=${item.spec.seconds}s`, "--timer-property=AccuracySec=1s", "--", "sh", "-c", 'notify-send -u critical -i alarm-clock "$1" "Time is up"; pw-play "$2"', "sh", name, sounds + "/alarm-clock-elapsed.oga"]);
            save([...running, { unit, name, kind: "timer", start: now, end: now + item.spec.seconds * 1000 }]);
            return true;
        }
        if (item.kind === "pomodoroStart") {
            Quickshell.execDetached(["systemd-run", "--user", "--quiet", "--unit=" + unit, "--", "sh", "-c", `for round in $(seq ${rounds}); do
    notify-send -i alarm-clock "Pomodoro $round/${rounds}" "Focus for ${focusMinutes} minutes"
    sleep ${focusMinutes * 60}
    pw-play "$1/complete.oga"
    notify-send -u critical -i alarm-clock "Pomodoro $round/${rounds}" "Take a ${breakMinutes} minute break"
    sleep ${breakMinutes * 60}
done
pw-play "$1/alarm-clock-elapsed.oga"
notify-send -u critical -i alarm-clock Pomodoro "All ${rounds} rounds done"`, "sh", sounds]);
            save([...running, { unit, name: "Pomodoro", kind: "pomodoro", start: now, end: now + rounds * (focusMinutes + breakMinutes) * 60000 }]);
            return true;
        }
        Quickshell.execDetached(["systemctl", "--user", "stop", item.timer.unit + ".timer", item.timer.unit + ".service"]);
        save(running.filter(timer => timer.unit !== item.timer.unit));
        return false;
    }

    FileView {
        id: state
        path: Spot.stateDir + "/timers.json"
        blockLoading: true
        blockWrites: true
        printErrors: false
        onLoaded: root.timers = JSON.parse(text() || "[]")
    }

    Timer {
        interval: 1000
        running: root.running.length > 0
        repeat: true
        onTriggered: root.now = Date.now()
    }
}
