"""Bookmarks and notes: SQLite databases tracked in the dotfiles."""

import sqlite3
import sys

from paths import DATA
from terminal import edit_in_terminal

DATABASES = {"bookmarks": DATA / "bookmarks.db", "notes": DATA / "notes.db"}


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


def note_add(title: str, category: str, body: str = "") -> None:
    with connect("notes") as db:
        ensure_unique(db, title, category)
    content = edit_in_terminal(body)
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
