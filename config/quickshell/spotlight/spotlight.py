#!/usr/bin/env python3
"""Data helper for spotlight.qml: bookmarks/notes CRUD, Zen history and tabs,
pinned clipboard entries, calls to Herdr's socket API, the calculator beyond
arithmetic, recent files and the full-text index of documents. Read commands
print JSON; failures exit non-zero with the reason on stderr."""

import configparser
import html
import json
import os
import re
import shutil
import socket
import sqlite3
import subprocess
import sys
import tempfile
import time
import unicodedata
import urllib.request
from concurrent.futures import ThreadPoolExecutor
from datetime import date, datetime, timedelta
from itertools import islice
from pathlib import Path
from urllib.error import HTTPError
from urllib.parse import quote, unquote, urlparse
from xml.etree import ElementTree
from zoneinfo import ZoneInfo, available_timezones

import lz4.block

HOME = Path.home()
DATA = Path(os.environ.get("XDG_DATA_HOME", HOME / ".local/share")) / "spotlight"
STATE = Path(os.environ.get("XDG_STATE_HOME", HOME / ".local/state")) / "spotlight"
PINS = STATE / "pins"
ZEN = HOME / ".config/zen"
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
SCRIPTS = Path(__file__).resolve().parent / "scripts"
SCRIPT_META = re.compile(r"^\s*(?:#|//|--)\s*@(?:raycast|spotlight)\.(\w+)\s+(.*?)\s*$")
SCRIPT_TEMPLATE = """#!/usr/bin/env bash
# @spotlight.title {title}
# @spotlight.mode compact
# @spotlight.icon ⚡
# @spotlight.description
# @spotlight.argument1 {{ "type": "text", "placeholder": "Text", "optional": true }}

# mode: silent / compact notify the last line of output, fullOutput shows all
# of it in Spotlight. Arguments (up to 3) are asked one by one; a dropdown takes
# "type": "dropdown", "data": [{{ "title": "A", "value": "a" }}]
echo "$1"
"""
DATABASES = {"bookmarks": DATA / "bookmarks.db", "notes": DATA / "notes.db"}
IMAGE_MAGIC = (b"\x89PNG", b"\xff\xd8\xff", b"GIF8", b"BM")
CONTENTS = (
    Path(os.environ.get("XDG_CACHE_HOME", HOME / ".cache")) / "spotlight/contents.db"
)
CONTENT_ROOTS = [HOME / "Documents", HOME / "Desktop", HOME / "Downloads"]
CONVERTED = {"pdf", "docx", "odt", "epub", "fb2", "html", "htm", "ipynb"}
PLAIN = {"md", "txt", "tex", "norg", "org", "rst"}
MAX_TEXT = 2_000_000

ZONE_ALIASES = {
    "cdmx": "America/Mexico_City",
    "nyc": "America/New_York",
    "ny": "America/New_York",
    "la": "America/Los_Angeles",
    "sf": "America/Los_Angeles",
    "utc": "UTC",
    "gmt": "GMT",
}
CLOCK = re.compile(
    r"(?P<time>now|time|\d{1,2}(?::\d{2})?\s*(?:am|pm)?)\s+(?:(?P<source>.+?)\s+)?(?:in|to)\s+(?P<target>.+)",
    re.IGNORECASE,
)
COUNTDOWN = re.compile(
    r"(?P<unit>days|weeks)\s+(?P<direction>until|till|to|since)\s+(?P<date>.+)",
    re.IGNORECASE,
)
SPAN = re.compile(
    r"in\s+(?P<ahead>\d+\s+(?:day|week|month|year)s?)|(?P<span>\d+\s+(?:day|week|month|year)s?)\s+(?P<direction>from now|ago)",
    re.IGNORECASE,
)
CONVERSION = re.compile(r"(.*\d.*?)\s+(?:to|in|as)\s+([^\d\s]\S*)", re.IGNORECASE)
# qalc is case-sensitive: "100 f to c" means temperatures, "1 gb" gigabytes
UNIT_CASE = {"f": "°F", "c": "°C", "kb": "kB", "mb": "MB", "gb": "GB", "tb": "TB"}
BASES = {
    "hex",
    "hexadecimal",
    "bin",
    "binary",
    "oct",
    "octal",
    "dec",
    "decimal",
    "bases",
    "roman",
}


def connect(name: str) -> sqlite3.Connection:
    db = sqlite3.connect(DATABASES[name])
    db.row_factory = sqlite3.Row
    db.execute("PRAGMA foreign_keys = ON")
    return db


def category_id(db: sqlite3.Connection, name: str) -> int:
    db.execute("INSERT OR IGNORE INTO categories(name) VALUES (?)", (name,))
    return db.execute("SELECT id FROM categories WHERE name = ?", (name,)).fetchone()[
        "id"
    ]


def prune_categories(db: sqlite3.Connection) -> None:
    db.execute(
        "DELETE FROM categories WHERE id NOT IN (SELECT category_id FROM entries)"
    )


def ensure_unique(
    db: sqlite3.Connection, title: str, category: str, entry_id: int | None = None
) -> None:
    clash = db.execute(
        "SELECT e.id FROM entries e JOIN categories c ON c.id = e.category_id WHERE e.title = ? AND c.name = ?",
        (title, category),
    ).fetchone()
    if clash and clash["id"] != entry_id:
        sys.exit(f"'{title}' already exists in '{category}'")


def editor() -> str:
    return (
        os.environ.get("EDITOR")
        or shutil.which("nvim")
        or str(HOME / ".local/share/bob/nvim-bin/nvim")
    )


def edit_in_terminal(initial: str) -> str:
    with tempfile.NamedTemporaryFile("w+", suffix=".md", delete=False) as draft:
        draft.write(initial)
    try:
        subprocess.run(["ghostty", "-e", editor(), draft.name], check=True)
        return Path(draft.name).read_text().strip()
    finally:
        os.unlink(draft.name)


def list_entries(name: str) -> list[dict]:
    column = "e.url" if name == "bookmarks" else "e.content"
    with connect(name) as db:
        rows = db.execute(
            f"SELECT e.id, c.name AS category, e.title, {column} AS body FROM entries e "
            "JOIN categories c ON c.id = e.category_id ORDER BY lower(c.name), lower(e.title)"
        )
        return [dict(row) for row in rows]


def categories(name: str) -> list[str]:
    with connect(name) as db:
        return [
            row["name"]
            for row in db.execute("SELECT name FROM categories ORDER BY lower(name)")
        ]


def bookmark_save(entry_id: str, url: str, title: str, category: str) -> None:
    if not url.startswith(("http://", "https://")):
        sys.exit(f"not a web URL: {url}")
    with connect("bookmarks") as db:
        ensure_unique(db, title, category, int(entry_id) if entry_id else None)
        if entry_id:
            db.execute(
                "UPDATE entries SET url = ?, title = ?, category_id = ? WHERE id = ?",
                (url, title, category_id(db, category), int(entry_id)),
            )
        else:
            db.execute(
                "INSERT INTO entries(category_id, title, url) VALUES (?, ?, ?)",
                (category_id(db, category), title, url),
            )
        prune_categories(db)


def note_add(title: str, category: str) -> None:
    with connect("notes") as db:
        ensure_unique(db, title, category)
    content = edit_in_terminal("")
    if not content:
        sys.exit("empty note, nothing saved")
    with connect("notes") as db:
        db.execute(
            "INSERT INTO entries(category_id, title, content) VALUES (?, ?, ?)",
            (category_id(db, category), title, content),
        )


def note_edit(entry_id: str) -> None:
    with connect("notes") as db:
        current = db.execute(
            "SELECT content FROM entries WHERE id = ?", (int(entry_id),)
        ).fetchone()["content"]
    content = edit_in_terminal(current)
    if not content:
        sys.exit("empty note, kept the previous content")
    with connect("notes") as db:
        db.execute(
            "UPDATE entries SET content = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?",
            (content, int(entry_id)),
        )


def note_rename(entry_id: str, title: str, category: str) -> None:
    with connect("notes") as db:
        ensure_unique(db, title, category, int(entry_id))
        db.execute(
            "UPDATE entries SET title = ?, category_id = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?",
            (title, category_id(db, category), int(entry_id)),
        )
        prune_categories(db)


def entry_delete(name: str, entry_id: str) -> None:
    with connect(name) as db:
        db.execute("DELETE FROM entries WHERE id = ?", (int(entry_id),))
        prune_categories(db)


def category_rename(name: str, old: str, new: str) -> None:
    with connect(name) as db:
        if db.execute("SELECT 1 FROM categories WHERE name = ?", (new,)).fetchone():
            sys.exit(f"category '{new}' already exists")
        db.execute("UPDATE categories SET name = ? WHERE name = ?", (new, old))


def zen_profiles() -> list[tuple[str, Path]]:
    ini = configparser.ConfigParser(interpolation=None)
    ini.read(ZEN / "profiles.ini")
    return [
        (
            section["Name"],
            ZEN / section["Path"]
            if section.get("IsRelative", "1") == "1"
            else Path(section["Path"]),
        )
        for name, section in ini.items()
        if name.startswith("Profile") and "Path" in section
    ]


def zen_history() -> list[dict]:
    visits = []
    with tempfile.TemporaryDirectory() as scratch:
        for profile, folder in zen_profiles():
            places = folder / "places.sqlite"
            if not places.exists():
                continue
            # Zen keeps places.sqlite locked and recent visits in the WAL, so query a copy of both
            copy = Path(scratch) / f"{folder.name}.sqlite"
            shutil.copy(places, copy)
            if (wal := folder / "places.sqlite-wal").exists():
                shutil.copy(wal, f"{copy}-wal")
            with sqlite3.connect(copy) as db:
                rows = db.execute(
                    "SELECT url, title, visit_count, last_visit_date FROM moz_places "
                    "WHERE hidden = 0 AND last_visit_date IS NOT NULL ORDER BY last_visit_date DESC LIMIT 3000"
                )
                visits += [
                    {
                        "profile": profile,
                        "url": url,
                        "title": title or url,
                        "visits": count,
                        "last": last // 1_000_000,
                    }
                    for url, title, count, last in rows
                ]
    return sorted(visits, key=lambda visit: visit["last"], reverse=True)


def read_mozlz4(path: Path) -> dict:
    blob = path.read_bytes()
    if not blob.startswith(b"mozLz40\0"):
        raise ValueError(f"{path} is not a mozlz4 file")
    return json.loads(lz4.block.decompress(blob[8:]))


def zen_tabs() -> list[dict]:
    tabs = []
    for profile, folder in zen_profiles():
        candidates = [
            folder / "sessionstore-backups/recovery.jsonlz4",
            folder / "sessionstore.jsonlz4",
        ]
        session = next((path for path in candidates if path.exists()), None)
        if session is None:
            continue
        for window_index, window in enumerate(read_mozlz4(session).get("windows", [])):
            for tab in window.get("tabs", []):
                entries = tab.get("entries", [])
                if not entries:
                    continue
                current = entries[min(tab.get("index", len(entries)), len(entries)) - 1]
                tabs.append(
                    {
                        "profile": profile,
                        "window": window_index + 1,
                        "url": current.get("url", ""),
                        "title": current.get("title") or current.get("url", ""),
                        "pinned": tab.get("pinned", False),
                    }
                )
    return tabs


def pins() -> list[dict]:
    PINS.mkdir(parents=True, exist_ok=True)
    listed = []
    for path in sorted(
        PINS.iterdir(), key=lambda pin: pin.stat().st_mtime, reverse=True
    ):
        head = path.read_bytes()[:4096]
        image = head.startswith(IMAGE_MAGIC) or head[8:12] == b"WEBP"
        listed.append(
            {
                "name": path.name,
                "path": str(path),
                "image": image,
                "text": "" if image else head.decode(errors="replace"),
            }
        )
    return listed


def pin_add(clip_id: str) -> None:
    PINS.mkdir(parents=True, exist_ok=True)
    content = subprocess.run(
        ["cliphist", "decode", clip_id], capture_output=True, check=True
    ).stdout
    (PINS / str(time.time_ns())).write_bytes(content)


def herdr_socket() -> Path:
    if explicit := os.environ.get("HERDR_SOCKET_PATH"):
        return Path(explicit)
    base = HOME / ".config/herdr"
    session = os.environ.get("HERDR_SESSION")
    return (
        base / "sessions" / session / "herdr.sock" if session else base / "herdr.sock"
    )


# one newline-delimited JSON request/response over Herdr's unix socket
def herdr_call(method: str, params: str = "{}") -> dict:
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as connection:
        try:
            connection.connect(str(herdr_socket()))
        except (FileNotFoundError, ConnectionRefusedError):
            sys.exit("herdr is not running")
        connection.sendall(
            json.dumps(
                {"id": "spotlight", "method": method, "params": json.loads(params)}
            ).encode()
            + b"\n"
        )
        reply = connection.makefile("rb").readline()
    response = json.loads(reply)
    if "error" in response:
        sys.exit(f"herdr: {response['error']['message']}")
    return response["result"]


# starts a `kind` agent in the shell pane `target`, or in a new workspace when
# `target` is a folder; Herdr wants a name unique among live agents
def herdr_start(kind: str, target: str) -> None:
    if target.startswith("/"):
        created = herdr_call(
            "workspace.create",
            json.dumps({"cwd": target, "label": Path(target).name, "focus": True}),
        )
        target = created["root_pane"]["pane_id"]
    taken = {agent.get("name") for agent in herdr_call("agent.list")["agents"]}
    name, number = kind, 1
    while name in taken:
        number += 1
        name = f"{kind}-{number}"
    herdr_call(
        "agent.start", json.dumps({"name": name, "kind": kind, "pane_id": target})
    )


def fetch(url: str, accept: str = "*/*") -> str:
    request = urllib.request.Request(
        url, headers={"Accept": accept, "User-Agent": "spotlight (quickshell)"}
    )
    with urllib.request.urlopen(request, timeout=15) as response:
        return response.read().decode()


# Crossref sends an entry on one line: split it at the commas outside braces
def bibtex_entry(text: str) -> tuple[str, str, list[tuple[str, str]]]:
    kind, body = html.unescape(text).strip().split("{", 1)
    body = body.rstrip().removesuffix("}")
    parts, depth, start = [], 0, 0
    for index, char in enumerate(body):
        depth += {"{": 1, "}": -1}.get(char, 0)
        if char == "," and depth == 0:
            parts.append(body[start:index])
            start = index + 1
    parts.append(body[start:])
    key, *fields = [part.strip() for part in parts if part.strip()]
    pairs = [
        (name.strip(), value.strip())
        for name, value in (field.split("=", 1) for field in fields)
    ]
    # Crossref writes `month = July`, which BibTeX reads as an undefined macro
    return (
        kind,
        key,
        [
            (
                name,
                value[:3].lower()
                if name.lower() == "month" and value.isalpha()
                else value,
            )
            for name, value in pairs
        ],
    )


def open_access_pdf(doi: str) -> str | None:
    try:
        work = json.loads(
            fetch(
                f"https://api.openalex.org/works/doi:{quote(doi)}?select=best_oa_location"
            )
        )
    except HTTPError as error:
        if error.code == 404:
            return None
        raise
    return (work["best_oa_location"] or {}).get("pdf_url")


# `identifier` is "doi:<doi>" or "arxiv:<id>"; BibTeX comes from doi.org (or
# arXiv's own, with eprint fields), the open access PDF from OpenAlex
def paper(identifier: str) -> dict:
    scheme, value = identifier.split(":", 1)
    if scheme == "arxiv":
        page, pdf = f"https://arxiv.org/abs/{value}", f"https://arxiv.org/pdf/{value}"
        text = fetch(f"https://arxiv.org/bibtex/{value}")
    else:
        page = f"https://doi.org/{value}"
        with ThreadPoolExecutor() as pool:
            pending_pdf = pool.submit(open_access_pdf, value)
            try:
                text = fetch(page, "application/x-bibtex")
            except HTTPError as error:
                sys.exit(f"doi.org: {value} {error.reason.lower()}")
            pdf = pending_pdf.result()
    if not text.lstrip().startswith("@"):
        sys.exit(f"no BibTeX for {value}")
    kind, key, fields = bibtex_entry(text)
    values = {name.lower(): value.strip("{}") for name, value in fields}
    return {
        "id": value,
        "scheme": scheme,
        "key": key,
        "title": values.get("title", value),
        "authors": values.get("author", "").split(" and "),
        "year": values.get("year", ""),
        "venue": values.get("journal")
        or values.get("booktitle")
        or values.get("publisher", ""),
        "page": page,
        "pdf": pdf,
        "bibtex": f"{kind}{{{key},\n"
        + ",\n".join(f"  {name} = {value}" for name, value in fields)
        + "\n}",
    }


# Script Commands: executables in SCRIPTS described by Raycast's comment header
# (`# @raycast.title …`, also spelled `@spotlight.`); a header that fails to
# parse is listed with its error instead of hiding the script
def scripts() -> list[dict]:
    found = []
    for path in sorted(SCRIPTS.iterdir()) if SCRIPTS.is_dir() else []:
        if (
            path.name.startswith(".")
            or not path.is_file()
            or not os.access(path, os.X_OK)
        ):
            continue
        with path.open(errors="replace") as lines:
            meta = dict(
                match.groups()
                for line in islice(lines, 60)
                if (match := SCRIPT_META.match(line))
            )
        if "title" not in meta:
            continue
        entry = {
            "path": str(path),
            "title": meta["title"],
            "mode": meta.get("mode", "compact"),
            "icon": meta.get("icon", ""),
            "description": meta.get("description", ""),
            "package": meta.get("packageName", ""),
            "confirm": meta.get("needsConfirmation") == "true",
            "cwd": str(Path(meta.get("currentDirectoryPath", SCRIPTS)).expanduser()),
            "arguments": [],
        }
        for name in ("argument1", "argument2", "argument3"):
            if name not in meta:
                continue
            try:
                entry["arguments"].append(json.loads(meta[name]))
            except json.JSONDecodeError as error:
                entry["error"] = f"@raycast.{name}: {error}"
        found.append(entry)
    return found


def script_new(title: str) -> None:
    slug = re.sub(r"[^a-z0-9]+", "-", title.lower()).strip("-")
    path = SCRIPTS / f"{slug}.sh"
    if path.exists():
        sys.exit(f"{path} already exists")
    SCRIPTS.mkdir(parents=True, exist_ok=True)
    path.write_text(SCRIPT_TEMPLATE.format(title=title))
    path.chmod(0o755)
    subprocess.run(["ghostty", "-e", editor(), str(path)], check=True)


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
    window = [today + timedelta(days=offset) for offset in range(int(days))]
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
                elif schedule and (when := NORG_WHEN.match(text)):
                    context = (level, date.fromisoformat(when[1]))
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
                if marker not in "@<" or not (when := NORG_WHEN.match(value)):
                    continue
                stamped = True
                day = date.fromisoformat(when[1])
                due = marker == "<"
                if day in window or (due and day < today):
                    text = f"/{when[2]}/ {item[2]}" if when[2] else item[2]
                    add(day, text, "due" if due else "event", path, number)
            if stamped or not context:
                continue
            if isinstance(context[1], date):
                if context[1] in window:
                    add(context[1], item[2], "event", path, number)
            else:
                for day in window:
                    if day.weekday() == context[1]:
                        add(day, item[2], "schedule", path, number, recurring=True)
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


def zone(name: str) -> ZoneInfo | None:
    key = name.lower().replace(" ", "_")
    if key in ZONE_ALIASES:
        return ZoneInfo(ZONE_ALIASES[key])
    return next(
        (
            ZoneInfo(tz)
            for tz in sorted(available_timezones())
            if key in (tz.lower(), tz.lower().rsplit("/", 1)[-1])
        ),
        None,
    )


def zone_label(moment: datetime) -> str:
    key = getattr(moment.tzinfo, "key", None)
    return key.rsplit("/", 1)[-1].replace("_", " ") if key else "local"


# "5pm cdmx in tokyo", "17:30 in london", "time in tokyo"; the source defaults
# to the local zone
def zone_time(text: str) -> dict | None:
    match = CLOCK.fullmatch(text)
    if not match:
        return None
    target = zone(match["target"])
    source = (
        zone(match["source"]) if match["source"] else datetime.now().astimezone().tzinfo
    )
    if target is None or source is None:
        return None
    moment = datetime.now(source)
    spoken = match["time"].lower()
    if spoken not in ("now", "time"):
        clock = re.fullmatch(r"(\d{1,2})(?::(\d{2}))?\s*(am|pm)?", spoken)
        hour, minute = int(clock[1]), int(clock[2] or 0)
        if clock[3]:
            hour = hour % 12 + (12 if clock[3] == "pm" else 0)
        if hour > 23 or minute > 59:
            return None
        moment = moment.replace(hour=hour, minute=minute, second=0, microsecond=0)
    there = moment.astimezone(target)
    return {
        "value": f"{there:%H:%M}",
        "detail": f"{moment:%H:%M} {zone_label(moment)} is {there:%A %-d %B} in {zone_label(there)}",
    }


def gnu_date(expression: str) -> date | None:
    run = subprocess.run(
        ["date", "-d", expression, "+%F"], capture_output=True, text=True, check=False
    )
    return date.fromisoformat(run.stdout.strip()) if run.returncode == 0 else None


# "days until dec 25", "weeks since 2026-01-01", "in 3 weeks", "10 days ago"
def date_math(text: str) -> dict | None:
    if match := COUNTDOWN.fullmatch(text):
        when = gnu_date(match["date"])
        if when is None:
            return None
        today = datetime.now().astimezone().date()
        since = match["direction"].lower() == "since"
        if not since and when < today and not re.search(r"\d{4}", match["date"]):
            when = gnu_date(match["date"] + " +1 year")
        days = abs((when - today).days)
        unit = match["unit"].lower()
        amount = days if unit == "days" else round(days / 7, 1)
        return {
            "value": f"{amount:g} {unit.rstrip('s') if amount == 1 else unit}",
            "detail": f"{'Since' if since else 'Until'} {when:%A, %-d %B %Y}",
        }
    if match := SPAN.fullmatch(text):
        ago = (match["direction"] or "").lower() == "ago"
        when = gnu_date((match["ahead"] or match["span"]) + (" ago" if ago else ""))
        return {"value": f"{when:%A, %-d %B %Y}", "detail": text} if when else None
    return None


# units, currencies, percentages and number bases; None when qalc did not
# understand the text, which it then reports as an error or a warning
def qalculate(text: str) -> dict | None:
    if not re.search(r"\d", text):
        return None
    expression = re.sub(r"(\d)\s*%\s*of\s+", r"\1% * ", text, flags=re.IGNORECASE)
    if conversion := CONVERSION.fullmatch(expression):
        amount = re.sub(
            r"[a-z]+",
            lambda word: UNIT_CASE.get(word[0].lower(), word[0]),
            conversion[1],
            flags=re.IGNORECASE,
        )
        target = UNIT_CASE.get(conversion[2].lower(), conversion[2])
        # a leading "-" keeps "5 km to mi" from answering in miles, yards and inches
        expression = (
            f"{amount} to {target if target.lower() in BASES else '-' + target}"
        )
    run = subprocess.run(
        [
            "qalc",
            "-s",
            "save config 0",
            "-s",
            "upxrates 1",
            "-s",
            "percent 1",
            expression,
        ],
        capture_output=True,
        text=True,
        stdin=subprocess.DEVNULL,
        timeout=5,
        check=False,
    )
    lines = run.stdout.strip().splitlines()
    if (
        run.returncode
        or not lines
        or re.search(r"^(error|warning):", run.stdout, re.MULTILINE)
    ):
        return None
    parts = re.split(r" ([=≈]) ", lines[-1])
    if len(parts) < 3 or parts[-1].lower() == text.lower():
        return None
    return {"value": parts[-1], "detail": f"{parts[0]} {parts[-2]}"}


def calc(query: str) -> dict | None:
    text = " ".join(query.removeprefix("=").split())
    return zone_time(text) or date_math(text) or qalculate(text)


def recent_files() -> list[dict]:
    xbel = (
        Path(os.environ.get("XDG_DATA_HOME", HOME / ".local/share"))
        / "recently-used.xbel"
    )
    if not xbel.exists():
        return []
    found = []
    for bookmark in ElementTree.parse(xbel).getroot().iter("bookmark"):
        href = bookmark.get("href", "")
        path = Path(unquote(urlparse(href).path))
        if href.startswith("file://") and path.exists():
            used = max(bookmark.get("visited", ""), bookmark.get("modified", ""))
            found.append({"path": str(path), "isDir": path.is_dir(), "used": used})
    return sorted(found, key=lambda entry: entry["used"], reverse=True)[:100]


def contents_db() -> sqlite3.Connection:
    CONTENTS.parent.mkdir(parents=True, exist_ok=True)
    db = sqlite3.connect(CONTENTS)
    db.executescript(
        "CREATE TABLE IF NOT EXISTS files(path TEXT PRIMARY KEY, stamp TEXT NOT NULL);"
        "CREATE VIRTUAL TABLE IF NOT EXISTS pages USING fts5("
        "path UNINDEXED, page UNINDEXED, body, tokenize = 'unicode61 remove_diacritics 2')"
    )
    return db


# page number (0 for unpaged text) → text; rga-preproc converts PDFs and office
# documents and prefixes every PDF line with "Page N: "
def extract(path: Path) -> dict[int, str]:
    if path.suffix[1:].lower() in PLAIN:
        return {0: path.read_text(errors="replace")[:MAX_TEXT]}
    run = subprocess.run(["rga-preproc", str(path)], capture_output=True, check=False)
    if run.returncode:
        return {}
    pages: dict[int, list[str]] = {}
    size = 0
    for line in run.stdout.decode(errors="replace").splitlines():
        if line.startswith(str(path)) and " adapter: " in line:
            continue
        paged = re.match(r"Page (\d+): ", line)
        text = line[paged.end() :] if paged else line
        pages.setdefault(int(paged[1]) if paged else 0, []).append(text)
        size += len(text)
        if size > MAX_TEXT:
            break
    return {page: "\n".join(lines) for page, lines in pages.items()}


# brings the index up to date with the documents under CONTENT_ROOTS, by
# modification time and size; run niced in the background
def index_contents() -> None:
    listed = subprocess.run(
        ["fd", "--type", "f", "--one-file-system", "--absolute-path"]
        + [f"--extension={ext}" for ext in sorted(CONVERTED | PLAIN)]
        + [".", *(str(root) for root in CONTENT_ROOTS if root.is_dir())],
        capture_output=True,
        text=True,
        check=True,
    ).stdout.splitlines()
    with contents_db() as db:
        known = dict(db.execute("SELECT path, stamp FROM files"))
        for name in listed:
            path = Path(name)
            stat = path.stat()
            stamp = f"{stat.st_mtime_ns}:{stat.st_size}"
            if known.get(name) == stamp:
                continue
            if name in known:
                db.execute("DELETE FROM pages WHERE path = ?", (name,))
            db.executemany(
                "INSERT INTO pages(path, page, body) VALUES (?, ?, ?)",
                [(name, page, text) for page, text in extract(path).items()],
            )
            db.execute("INSERT OR REPLACE INTO files VALUES (?, ?)", (name, stamp))
            db.commit()
        for gone in known.keys() - set(listed):
            db.execute("DELETE FROM pages WHERE path = ?", (gone,))
            db.execute("DELETE FROM files WHERE path = ?", (gone,))


# documents whose text holds every word of three letters or more (as a
# prefix), best page first
def contents(query: str) -> list[dict]:
    words = [word for word in re.findall(r"\w+", query) if len(word) >= 3]
    if not words or not CONTENTS.exists():
        return []
    with contents_db() as db:
        rows = db.execute(
            "SELECT path, page, snippet(pages, 2, '', '', '…', 14) FROM pages "
            "WHERE pages MATCH ? ORDER BY rank LIMIT 300",
            (" ".join(f'"{word}"*' for word in words),),
        ).fetchall()
    hits: dict[str, dict] = {}
    for path, page, snippet in rows:
        if path not in hits and Path(path).exists():
            hits[path] = {
                "path": path,
                "page": page,
                "snippet": " ".join(snippet.split()),
            }
    return list(hits.values())[:40]


def main() -> None:
    command, *args = sys.argv[1:]
    readers = {
        "list": lambda: list_entries(*args),
        "categories": lambda: categories(*args),
        "zen-history": zen_history,
        "zen-tabs": zen_tabs,
        "pins": pins,
        "herdr": lambda: herdr_call(*args),
        "calc": lambda: calc(*args),
        "paper": lambda: paper(*args),
        "scripts": scripts,
        "agenda": lambda: agenda(*args),
        "recent-files": recent_files,
        "contents": lambda: contents(*args),
    }
    writers = {
        "bookmark-save": bookmark_save,
        "note-add": note_add,
        "note-edit": note_edit,
        "note-rename": note_rename,
        "delete": entry_delete,
        "category-rename": category_rename,
        "herdr-start": herdr_start,
        "script-new": script_new,
        "agenda-add": agenda_add,
        "pin-add": pin_add,
        "pin-remove": lambda name: (PINS / Path(name).name).unlink(),
        "index-contents": index_contents,
    }
    if command in readers:
        json.dump(readers[command](), sys.stdout)
    elif command in writers:
        writers[command](*args)
    else:
        sys.exit(f"unknown command: {command}")


if __name__ == "__main__":
    main()
