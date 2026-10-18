"""The agenda read from, and written to, the neorg workspaces."""

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


NORG_HEADING = re.compile(r"^\s*(\*+)\s+(.*?)\s*$")


NORG_ITEM = re.compile(r"^\s*-+\s+(?:\(([^)]*)\)\s*)?(.*?)\s*$")


NORG_SPAN = re.compile(r"^/(\d{1,2}:\d{2})(?:\s*-\s*(\d{1,2}:\d{2}))?/\s*(.*)$")


NORG_WHEN = re.compile(r"^(\d{4}-\d{2}-\d{2})(?:[ T](\d{1,2}:\d{2}))?$")


NORG_LINK = re.compile(r"(?:\[([^\]]*)\])?\{([^}]*)\}")


def fold(text: str) -> str:
    return "".join(
        char
        for char in unicodedata.normalize("NFD", text.lower())
        if not unicodedata.combining(char)
    )


def clock(text: str) -> str:
    hours, minutes = text.split(":")
    return f"{int(hours):02}:{minutes}"


# "[label]{url}" keeps its label, a bare "{url}" goes; the first web URL is the
# event's link (a meeting to join)
def norg_date(when: re.Match) -> date | None:
    try:
        return date.fromisoformat(when[1])
    except ValueError:
        # an impossible date such as 2026-02-30 is left as plain text
        return None


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
# - in any file, tasks with norg's timestamp extensions: `- ( |@ 2026-10-17
#   16:00) Call` happens then, `- ( |< 2026-10-20) Submit` is due then (and
#   overdue while not done)
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

    folders = [folder for folder in norg_workspaces().values() if folder.is_dir()]
    for path in sorted(path for folder in folders for path in folder.rglob("*.norg")):
        lines = path.read_text(errors="replace").splitlines()
        schedule = is_schedule(lines)
        context = None  # (heading level, weekday index or date)
        for number, line in enumerate(lines, 1):
            if heading := NORG_HEADING.match(line):
                level, text = len(heading[1]), heading[2]
                if schedule and fold(text) in WEEKDAYS:
                    context = (level, WEEKDAYS[fold(text)])
                elif (
                    schedule
                    and (when := NORG_WHEN.match(text))
                    and (day := norg_date(when))
                ):
                    context = (level, day)
                elif context and level <= context[0]:
                    context = None
                continue
            if not (item := NORG_ITEM.match(line)):
                continue
            state, *extensions = (item[1] or "").split("|")
            if state.strip() in ("x", "_"):
                continue
            stamped = False
            for extension in extensions:
                marker, value = extension.strip()[:1], extension.strip()[1:].strip()
                when = NORG_WHEN.match(value)
                if marker not in "@<" or not when or not (day := norg_date(when)):
                    continue
                stamped = True
                due = marker == "<"
                if today <= day < until or (due and day < today):
                    text = f"/{when[2]}/ {item[2]}" if when[2] else item[2]
                    add(day, text, "due" if due else "event", path, number)
            if stamped or not context:
                continue
            if isinstance(context[1], date):
                if today <= context[1] < until:
                    add(context[1], item[2], "event", path, number)
            else:
                # the window's days on that weekday: the first, then every 7th
                first = today + timedelta(days=(context[1] - today.weekday()) % 7)
                for offset in range(0, (until - first).days, 7):
                    add(
                        first + timedelta(days=offset),
                        item[2],
                        "schedule",
                        path,
                        number,
                        recurring=True,
                    )
    return sorted(events, key=lambda event: (event["date"], event["start"] or "~"))


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
