"""The agenda and open tasks read from, and the agenda written to, the neorg
workspaces."""

import os
import re
import sys
import unicodedata
from datetime import date, datetime, timedelta
from pathlib import Path

from paths import HOME

NEORG_CONFIG = HOME / ".config/nvim/lua/pack/specs/opt/neorg.lua"


WEEKDAYS = {
    name: index
    for index, names in enumerate(
        [
            ("lunes", "monday"),
            ("martes", "tuesday"),
            ("miercoles", "wednesday"),
            ("jueves", "thursday"),
            ("viernes", "friday"),
            ("sabado", "saturday"),
            ("domingo", "sunday"),
        ]
    )
    for name in names
}


NORG_HEADING = re.compile(r"^\s*(\*+)\s+(?P<text>.*?)\s*$")


# list items, definitions and footnotes: what besides headings can be a task
NORG_ITEM = re.compile(r"^\s*(?:-+|~+|\$\$?|\^\^?)\s+(?P<text>.*?)\s*$")


NORG_EXTENSION = re.compile(r"^\(([^)]*)\)\s+(.*)$")


NORG_SPAN = re.compile(r"^/(\d{1,2}:\d{2})(?:\s*-\s*(\d{1,2}:\d{2}))?/\s*(.*)$")


NORG_ISO = re.compile(r"^(\d{4})-(\d{1,2})-(\d{1,2})(?:[ T](\d{1,2}):(\d{2}))?")


# "Thu, 22 Oct 2026", as Morg writes it, or neorg's "Thursday 22nd October"
NORG_SPEC = re.compile(
    r"^(?:[a-z]+,?\s+)?(\d{1,3})(?:st|nd|rd|th)?\s+([a-z]+)(?:\s+(\d{4}))?"
    r"(?:\s+(\d{1,2}):(\d{2}))?",
    re.IGNORECASE,
)


MONTHS = [
    "january",
    "february",
    "march",
    "april",
    "may",
    "june",
    "july",
    "august",
    "september",
    "october",
    "november",
    "december",
]


NORG_LINK = re.compile(r"(?:\[([^\]]*)\])?\{([^}]*)\}")


# the status of a task, by its order in Morg's task list
STATUSES = "!- ?=+x_"


# the date markers of a task's extension
MARKERS = {"@": "event", "<": "due", ">": "start"}


def fold(text: str) -> str:
    return "".join(
        char
        for char in unicodedata.normalize("NFD", text.lower())
        if not unicodedata.combining(char)
    )


def clock(text: str) -> str:
    hours, minutes = text.split(":")
    return f"{int(hours):02}:{minutes}"


# a date as Morg's parseNorgDate reads it, ISO or "[weekday,] day month [year]
# [time]" (any unambiguous start of an English month, this year if none), and
# its time ("" for none); an impossible date such as 2026-02-30 is none
def norg_when(text: str, today: date) -> tuple[date, str] | None:
    text = text.strip()
    if iso := NORG_ISO.match(text):
        year, month, day, hour, minute = iso.groups()
    elif spec := NORG_SPEC.match(text):
        day, word, year, hour, minute = spec.groups()
        months = [
            number
            for number, name in enumerate(MONTHS, 1)
            if name.startswith(word.lower())
        ]
        if len(months) != 1:
            return None
        month, year = months[0], year or today.year
    else:
        return None
    try:
        when = date(int(year), int(month), int(day))
    except ValueError:
        return None
    return when, clock(f"{hour}:{minute}") if hour else ""


# the status, the other segments and the title of a task: "( |< Thu, 22 Oct
# 2026|# A) Call" is (" ", ["< Thu, 22 Oct 2026", "# A"], "Call"). As in Morg,
# the status is the segment that is blank, one of STATUSES or a recurrence
# ("+ Fri"); an extension without one makes no task
def norg_task(text: str) -> tuple[str, list[str], str] | None:
    if not (extension := NORG_EXTENSION.match(text)):
        return None
    segments = [segment.strip() for segment in extension[1].split("|")]
    at = next(
        (
            index
            for index, segment in enumerate(segments)
            if not segment or segment in STATUSES or segment.startswith("+ ")
        ),
        None,
    )
    if at is None:
        return None
    details = [
        segment for index, segment in enumerate(segments) if segment and index != at
    ]
    return segments[at][:1] or " ", details, extension[2]


def norg_detail(details: list[str], marker: str) -> str | None:
    return next(
        (detail[1:].strip() for detail in details if detail.startswith(marker)), None
    )


# "[label]{url}" keeps its label, a bare "{url}" goes; the first web URL is the
# event's link (a meeting to join)
def norg_text(text: str) -> tuple[str, str | None]:
    links = [target for _, target in NORG_LINK.findall(text)]
    link = next((target for target in links if target.startswith("http")), None)
    title = NORG_LINK.sub(lambda match: match[1] or "", text)
    return " ".join(title.split()), link


# the folders of neorg's core.dirman workspaces, read from the nvim config
def norg_workspaces() -> dict[str, Path]:
    block = re.search(
        r"workspaces\s*=\s*\{(.*?)\}", NEORG_CONFIG.read_text(), re.DOTALL
    )
    if not block:
        sys.exit(f"no neorg workspaces in {NEORG_CONFIG}")
    return {
        name: Path(folder).expanduser()
        for name, folder in re.findall(r"(\w+)\s*=\s*'([^']+)'", block[1])
    }


def agenda_file() -> Path:
    return norg_workspaces()["life"] / "agenda.norg"


def is_schedule(lines: list[str]) -> bool:
    if not lines or lines[0].strip() != "@document.meta":
        return False
    for line in lines[1:]:
        if line.strip() == "@end":
            return False
        if line.startswith("categories:") and "schedule" in line.lower():
            return True
    return False


# The agenda of the norg files in neorg's workspaces for `days` days from today:
# - in files whose metadata has `categories: Schedule`, items under a weekday
#   heading (* Lunes) repeat every week and items under a date heading
#   (* 2026-10-16) happen that day; "/10:00-11:00/ title" gives the time
# - in any file, open tasks with norg's date extensions (see norg_when):
#   `- ( |@ Sat, 17 Oct 2026 16:00) Call` happens then, `( |> …)` starts then
#   and `( |< …)` is due then (and overdue while not done)
def agenda(days: str = "14") -> list[dict]:
    today = datetime.now().astimezone().date()
    until = today + timedelta(days=int(days))
    events = []

    def add(day, text, kind, path, number, recurring=False):
        start = end = ""
        if span := NORG_SPAN.match(text):
            start, end, text = (
                clock(span[1]),
                clock(span[2]) if span[2] else "",
                span[3],
            )
        title, link = norg_text(text)
        events.append(
            {
                "title": title,
                "date": day.isoformat(),
                "start": start,
                "end": end,
                "kind": kind,
                "recurring": recurring,
                "link": link,
                "file": str(path),
                "line": number,
            }
        )

    # whether the task has a date, adding those within the window
    def dated(task, path, number):
        _, details, title = task
        found = False
        for detail in details:
            kind = MARKERS.get(detail[:1])
            if not kind or not (when := norg_when(detail[1:], today)):
                continue
            found = True
            day, time = when
            if today <= day < until or (kind == "due" and day < today):
                add(day, f"/{time}/ {title}" if time else title, kind, path, number)
        return found

    folders = [folder for folder in norg_workspaces().values() if folder.is_dir()]
    for path in sorted(path for folder in folders for path in folder.rglob("*.norg")):
        lines = path.read_text(errors="replace").splitlines()
        schedule = is_schedule(lines)
        context = None  # (heading level, weekday index or date)
        for number, line in enumerate(lines, 1):
            # outside a schedule only dated tasks count, and their date follows a "|"
            if not schedule and "|" not in line:
                continue
            heading = NORG_HEADING.match(line)
            if heading:
                level, text = len(heading[1]), heading["text"]
                if schedule and fold(text) in WEEKDAYS:
                    context = (level, WEEKDAYS[fold(text)])
                elif schedule and (when := norg_when(text, today)):
                    context = (level, when[0])
                elif context and level <= context[0]:
                    context = None
            elif not (item := NORG_ITEM.match(line)):
                continue
            text = (heading or item)["text"]
            if task := norg_task(text):
                if task[0] in "x_" or dated(task, path, number):
                    continue
                text = task[2]
            # a heading is never an entry of the schedule
            if heading or not context:
                continue
            if isinstance(context[1], date):
                if today <= context[1] < until:
                    add(context[1], text, "event", path, number)
            else:
                # the window's days on that weekday: the first, then every 7th
                first = today + timedelta(days=(context[1] - today.weekday()) % 7)
                for offset in range(0, (until - first).days, 7):
                    add(
                        first + timedelta(days=offset),
                        text,
                        "schedule",
                        path,
                        number,
                        recurring=True,
                    )
    return sorted(events, key=lambda event: (event["date"], event["start"] or "~"))


# The open tasks of every workspace, as Morg's task list: by status (urgent, in
# progress, to do, needs input, on hold, recurring), then soonest due
def tasks() -> list[dict]:
    today = datetime.now().astimezone().date()
    found = []

    def day(details, marker):
        when = norg_when(norg_detail(details, marker) or "", today)
        return when[0].isoformat() if when else ""

    for name, folder in norg_workspaces().items():
        if not folder.is_dir():
            continue
        for path in sorted(folder.rglob("*.norg")):
            lines = path.read_text(errors="replace").splitlines()
            for number, line in enumerate(lines, 1):
                if "(" not in line:
                    continue
                match = NORG_HEADING.match(line) or NORG_ITEM.match(line)
                if not match or not (task := norg_task(match["text"])):
                    continue
                status, details, text = task
                if status in "x_":
                    continue
                found.append(
                    {
                        "title": norg_text(text)[0],
                        "status": status,
                        "due": day(details, "<"),
                        "start": day(details, ">"),
                        "priority": norg_detail(details, "#") or "",
                        "workspace": name,
                        "file": str(path),
                        "line": number,
                    }
                )
    return sorted(
        found, key=lambda task: (STATUSES.index(task["status"]), task["due"] or "~")
    )


def agenda_day(text: str) -> date:
    folded, today = fold(text.strip()), datetime.now().astimezone().date()
    if folded in ("today", "hoy"):
        return today
    if folded in ("tomorrow", "manana"):
        return today + timedelta(days=1)
    if folded in WEEKDAYS:
        return today + timedelta(days=(WEEKDAYS[folded] - today.weekday()) % 7 or 7)
    return date.fromisoformat(folded)


# adds "- /time/ title" under the date's heading of agenda.norg in the life
# workspace (a Schedule file), keeping the date headings in order
def agenda_add(day_text: str, time_text: str, title: str) -> None:
    path = agenda_file()
    day = agenda_day(day_text).isoformat()
    span = time_text.strip().replace(" ", "")
    if span and not re.fullmatch(r"\d{1,2}:\d{2}(-\d{1,2}:\d{2})?", span):
        sys.exit(f"not a time or a time range: {time_text}")
    entry = f"  - /{span}/ {title}" if span else f"  - {title}"
    if not path.exists():
        stamp = datetime.now().astimezone().strftime("%Y-%m-%dT%H:%M:%S%z")
        path.write_text(
            f"@document.meta\ntitle: agenda\ndescription: Eventos con fecha\n"
            f"authors: {os.environ.get('USER', '')}\ncategories: Schedule\n"
            f"created: {stamp}\nupdated: {stamp}\nversion: 1.1.1\n@end\n"
        )
    lines = path.read_text().splitlines()
    headings = [
        (index, match[1])
        for index, line in enumerate(lines)
        if (match := re.match(r"^\* (\d{4}-\d{2}-\d{2})\s*$", line))
    ]
    same = next((index for index, heading in headings if heading == day), None)
    if same is None:
        later = next((index for index, heading in headings if heading > day), None)
        at = len(lines) if later is None else later
        lines[at:at] = [f"* {day}", entry]
    else:
        end = next(
            (
                index
                for index in range(same + 1, len(lines))
                if lines[index].startswith("*")
            ),
            len(lines),
        )
        while end > same + 1 and not lines[end - 1].strip():
            end -= 1
        lines.insert(end, entry)
    path.write_text("\n".join(lines) + "\n")
