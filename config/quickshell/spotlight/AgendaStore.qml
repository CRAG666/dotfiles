import Quickshell
import Quickshell.Io
import QtQuick

// The agenda of your neorg workspaces, read by the helper's agenda for the
// next 14 days: the weekly schedule and dated events of `categories: Schedule`
// files, plus tasks stamped `( |@ date time)` or due `( |< date)` anywhere.
// Enter joins an event's meeting link or opens its line in Neovim; "New Agenda
// Event" writes to agenda.norg. An empty search shows what starts within
// 15 minutes, and what is underway unless it is part of the weekly routine.
Scope {
    id: root
    property var host
    property double now: Date.now()
    readonly property string today: Qt.formatDate(new Date(now), "yyyy-MM-dd")
    readonly property var colors: ({ schedule: "#9a9a9a", event: "#4a8fe0", due: "#e5a03a", overdue: "#d9534f" })

    function load() {
        now = Date.now();
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
        const time = event.start ? event.start + (event.end ? "–" + event.end : "") : event.kind === "due" ? "Due" : "All day";
        return event.kind === "due" && event.start ? "Due " + time : time;
    }

    function item(event) {
        return { key: `agenda:${event.file}:${event.line}:${event.date}`, kind: "agendaEvent", store: root, event, title: event.title, hint: when(event), swatch: colors[overdue(event) ? "overdue" : event.kind] };
    }

    function matching(tokens) {
        return source.items.filter(event => Spot.matches(`${event.title} ${event.kind === "due" ? "due deadline" : "event"} agenda`, tokens));
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
        const days = [["Overdue", events.filter(overdue).map(item)]];
        for (const day of [...new Set(events.map(event => event.date))].filter(day => day >= today)) {
            const shown = events.filter(event => event.date === day && (tokens.length || !event.recurring || dayLabel(day) === "Today" || dayLabel(day) === "Tomorrow"));
            days.push([dayLabel(day), shown.map(item)]);
        }
        return days;
    }

    function searchItems(tokens) {
        return matching(tokens).filter(event => event.date >= today || overdue(event)).slice(0, 3).map(item);
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
            metadata: [["Kind", event.recurring ? "Weekly schedule" : event.kind === "due" ? "Deadline" : "Event"], ["Link", event.link ?? ""], ["Note", `${Spot.tilde(event.file)}:${event.line}`]],
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
                    writer.exec(["python3", Spot.helper, "agenda-add", values.day, values.time ?? "", values.title]);
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
        command: ["python3", Spot.helper, "agenda", "14"]
    }

    Process {
        id: writer
        stderr: StdioCollector {
            id: writerErrors
        }
        onExited: exitCode => {
            root.host.notify(exitCode === 0 ? "Added to agenda.norg" : writerErrors.text.trim());
            source.reload();
        }
    }

    Timer {
        interval: 60000
        running: root.host.shown
        repeat: true
        onTriggered: root.now = Date.now()
    }
}
