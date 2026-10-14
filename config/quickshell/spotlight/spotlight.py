#!/usr/bin/env python3
"""Data helper for spotlight.qml: bookmarks/notes CRUD, Zen history and tabs,
pinned clipboard entries and calls to Herdr's socket API. Read commands print
JSON; failures exit non-zero with the reason on stderr."""

import configparser
import json
import os
import shutil
import socket
import sqlite3
import subprocess
import sys
import tempfile
import time
from pathlib import Path

import lz4.block

HOME = Path.home()
DATA = Path(os.environ.get("XDG_DATA_HOME", HOME / ".local/share")) / "spotlight"
STATE = Path(os.environ.get("XDG_STATE_HOME", HOME / ".local/state")) / "spotlight"
PINS = STATE / "pins"
ZEN = HOME / ".config/zen"
DATABASES = {"bookmarks": DATA / "bookmarks.db", "notes": DATA / "notes.db"}
IMAGE_MAGIC = (b"\x89PNG", b"\xff\xd8\xff", b"GIF8", b"BM")


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


def edit_in_terminal(initial: str) -> str:
    editor = (
        os.environ.get("EDITOR")
        or shutil.which("nvim")
        or str(HOME / ".local/share/bob/nvim-bin/nvim")
    )
    with tempfile.NamedTemporaryFile("w+", suffix=".md", delete=False) as draft:
        draft.write(initial)
    try:
        subprocess.run(["kitty", "-e", editor, draft.name], check=True)
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


def main() -> None:
    command, *args = sys.argv[1:]
    readers = {
        "list": lambda: list_entries(*args),
        "categories": lambda: categories(*args),
        "zen-history": zen_history,
        "zen-tabs": zen_tabs,
        "pins": pins,
        "herdr": lambda: herdr_call(*args),
    }
    writers = {
        "bookmark-save": bookmark_save,
        "note-add": note_add,
        "note-edit": note_edit,
        "note-rename": note_rename,
        "delete": entry_delete,
        "category-rename": category_rename,
        "pin-add": pin_add,
        "pin-remove": lambda name: (PINS / Path(name).name).unlink(),
    }
    if command in readers:
        json.dump(readers[command](), sys.stdout)
    elif command in writers:
        writers[command](*args)
    else:
        sys.exit(f"unknown command: {command}")


if __name__ == "__main__":
    main()
