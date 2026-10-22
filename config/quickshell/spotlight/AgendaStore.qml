import Quickshell
import Quickshell.Io
import QtQuick
import "js/search.js" as Search

// The agenda of your neorg workspaces, read by the helper's agenda for the
// next 14 days: the weekly schedule and dated events of `categories: Schedule`
// files, plus tasks anywhere that happen `( |@ date time)`, start `( |> date)`
// or are due `( |< date)`, dates as Morg writes them or ISO.
// Enter joins an event's meeting link or opens its line in Neovim; "New Agenda
// Event" writes to agenda.norg. An empty search shows what starts within
// 15 minutes, and what is underway unless it is part of the weekly routine.
Scope {
    id: root
    property var host
    property double now: Date.now()
    readonly property string today: Qt.formatDate(new Date(now), "yyyy-MM-dd")
    readonly property var colors: ({ schedule: "#9a9a9a", event: "#4a8fe0", start: "#3aa88f", due: "#e5a03a", overdue: "#d9534f" })
    readonly property var kinds: ({ event: "Event", start: "Starts", due: "Deadline" })

    // whole minutes, the agenda's grain: a load in the same minute changes nothing
    function load() {
        now = Math.floor(Date.now() / 60000) * 60000;
        source.load();
    }

    function moment(event, time) {
        return new Date(`${event.date}T${time}:00`).getTime();
    }

    function finished(event) {
        return event.date === today && !!event.start && moment(event, event.end || event.start) < now;
    }

    function overdue(event) {
        return event.kind === "due" && event.date < today;
    }

    function when(event) {
        if (overdue(event))
            return "Overdue since " + Qt.formatDate(new Date(event.date + "T00:00:00"), "d MMM");
        const word = event.kind === "due" ? "Due" : event.kind === "start" ? "Starts" : "";
        const time = event.start ? event.start + (event.end ? "–" + event.end : "") : word || "All day";
        return word && event.start ? word + " " + time : time;
    }

    // one item per event and day, so a keystroke or a reopening hands the list the same rows
    readonly property var made: {
        source.items;
        today;
        return Object.create(null);
    }

    function item(event) {
        const key = `agenda:${event.file}:${event.line}:${event.date}:${event.kind}`;
        return made[key] ?? (made[key] = { key, kind: "agendaEvent", store: root, event, title: event.title, hint: when(event), swatch: colors[overdue(event) ? "overdue" : event.kind] });
    }

    function matching(tokens) {
        return Search.matching(source.items, "agenda", event => event.text, tokens);
    }

    function dayLabel(day) {
        const date = new Date(day + "T00:00:00");
        const offset = Math.round((date.getTime() - new Date(today + "T00:00:00").getTime()) / 86400000);
        return offset === 0 ? "Today" : offset === 1 ? "Tomorrow" : Qt.formatDate(date, "dddd d MMM");
    }

    // [section, items] per day, overdue deadlines first; what already ended
    // today and the routine of days after tomorrow stay out unless searched for
    function sections(tokens) {
        const events = matching(tokens).filter(event => tokens.length || !finished(event));
        const byDay = Object.create(null);
        for (const event of events) {
            if (!(event.date in byDay))
                byDay[event.date] = [];
            byDay[event.date].push(event);
        }
        const days = [["Overdue", events.filter(overdue).map(item)]];
        for (const day of Object.keys(byDay).filter(day => day >= today)) {
            const label = dayLabel(day);
            const shown = byDay[day].filter(event => tokens.length || !event.recurring || label === "Today" || label === "Tomorrow");
            days.push([label, shown.map(item)]);
        }
        return days;
    }

    function searchItems(tokens) {
        return Spot.take(matching(tokens), event => event.date >= today || overdue(event), 3).map(item);
    }

    function soonItems() {
        return source.items
            .filter(event => event.date === today && event.start)
            .filter(event => {
                const start = moment(event, event.start);
                const underway = event.end && start <= now && now < moment(event, event.end);
                return (start > now && start - now <= 15 * 60000) || (underway && !event.recurring);
            })
            .map(item);
    }

    function commandItems(tokens) {
        return Spot.matches("New Agenda Event", tokens) ? [{ key: "agenda:new", kind: "agendaNew", store: root, title: "New Agenda Event", icon: "appointment-new" }] : [];
    }

    function describe(item) {
        if (item.kind === "agendaNew")
            return { icon: item.icon, title: item.title, subtitle: "Writes it under its date in agenda.norg (life workspace)", actions: [["Enter", "Create"]] };
        const event = item.event;
        return {
            icon: "office-calendar",
            title: event.title,
            subtitle: `${dayLabel(event.date)} · ${when(event)}`,
            metadata: [["Kind", event.recurring ? "Weekly schedule" : kinds[event.kind]], ["Link", event.link ?? ""], ["Note", `${Spot.tilde(event.file)}:${event.line}`]],
            actions: event.link ? [["Enter", "Join"], ["Ctrl+Enter", "Open in Neovim"], ["Ctrl+C", "Copy link"]] : [["Enter", "Open in Neovim"], ["Ctrl+C", "Copy title"]]
        };
    }

    function openNote(event) {
        Quickshell.execDetached([...host.userConfig.terminal, ...Spot.editor(event.file, event.line)]);
    }

    function activate(item, keys) {
        if (item.kind === "agendaNew") {
            host.openForm({
                title: "New Agenda Event",
                fields: [
                    { key: "day", label: "Day (today, tomorrow, a weekday or YYYY-MM-DD)", value: "", options: ["today", "tomorrow", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"] },
                    { key: "time", label: "Time (10:00 or 10:00-11:00)", value: "", optional: true },
                    { key: "title", label: "Title (a {https://…} link becomes Join)", value: "" }
                ],
                submit: values => {
                    Spot.call(["agenda-add", values.day, values.time ?? "", values.title], (output, error) => {
                        root.host.notify(error || "Added to agenda.norg");
                        source.reload();
                    });
                    return false;
                }
            });
            return false;
        }
        if (item.event.link && !keys.ctrl)
            Spot.open(item.event.link);
        else
            openNote(item.event);
        return true;
    }

    function copy(item) {
        Spot.copy(item.event?.link ?? item.title);
    }

    Source {
        id: source
        maxAge: 60000
        request: ["agenda", "14"]
        // the text an event is found by, folded once as it loads
        parse: output => output.trim() ? JSON.parse(output).map(event => Object.assign(event, { text: Search.fold(`${event.title} ${event.kind === "due" ? "due deadline" : event.kind === "start" ? "start" : "event"} agenda`) })) : []
    }

    Timer {
        interval: 60000
        running: root.host.shown
        repeat: true
        onTriggered: root.now = Math.floor(Date.now() / 60000) * 60000
    }
}
