"""The full-text index of documents and its search."""

import json
import os
import re
import sqlite3
import subprocess
import textwrap
from html.parser import HTMLParser
from pathlib import Path
from xml.etree import ElementTree

from paths import HOME

CONTENTS = (
    Path(os.environ.get("XDG_CACHE_HOME", HOME / ".cache")) / "spotlight/contents.db"
)


CONTENT_ROOTS = [HOME / "Documents", HOME / "Desktop", HOME / "Downloads"]


CONVERTED = {"pdf", "docx", "odt", "epub", "fb2", "html", "htm", "ipynb"}


PLAIN = {"md", "txt", "tex", "norg", "org", "rst"}


MAX_TEXT = 2_000_000


PASSAGE = 3000  # characters per indexed stretch of unpaged text, about a PDF page


NAME_WEIGHT = 5.0  # BM25 weight of a document's file name against its text


def contents_db() -> sqlite3.Connection:
    CONTENTS.parent.mkdir(parents=True, exist_ok=True)
    db = sqlite3.connect(CONTENTS)
    fresh = not db.execute(
        "SELECT 1 FROM sqlite_master WHERE name = 'passages'"
    ).fetchone()
    db.executescript(
        "DROP TABLE IF EXISTS pages;"
        "CREATE TABLE IF NOT EXISTS files(path TEXT PRIMARY KEY, stamp TEXT NOT NULL);"
        "CREATE VIRTUAL TABLE IF NOT EXISTS passages USING fts5("
        "path UNINDEXED, page UNINDEXED, name, body, "
        "tokenize = 'unicode61 remove_diacritics 2')"
    )
    if fresh:
        # an index from before passages held no file names: extract everything again
        db.execute("DELETE FROM files")
    return db


# FTS5 rows of a document: its file name, weighted in contents(), with each PDF
# page or each PASSAGE-long stretch of unpaged text, so BM25 weighs texts of a
# similar length
def passages(path: Path, pages: dict[int, str]) -> list[tuple[str, int, str, str]]:
    name = re.sub(r"[_\-.]+", " ", path.stem)
    return [
        (str(path), page, name, part)
        for page, text in pages.items()
        for part in (
            textwrap.wrap(text, PASSAGE, break_on_hyphens=False)
            if page == 0
            else [text]
        )
    ]


class HtmlText(HTMLParser):
    def __init__(self) -> None:
        super().__init__()
        self.parts: list[str] = []
        self.hidden = 0

    def handle_starttag(self, tag: str, attrs: list) -> None:
        self.hidden += tag in ("script", "style")

    def handle_endtag(self, tag: str) -> None:
        self.hidden -= tag in ("script", "style")

    def handle_data(self, data: str) -> None:
        if not self.hidden:
            self.parts.append(data)


def html_text(source: str) -> str:
    parser = HtmlText()
    parser.feed(source)
    return " ".join(parser.parts)


# page number (0 for unpaged text) → text; pdftotext ends every PDF page with a
# form feed, anydoc converts office documents and ebooks
def extract(path: Path) -> dict[int, str]:
    kind = path.suffix[1:].lower()
    try:
        if kind in PLAIN:
            text = path.read_text(errors="replace")
        elif kind in ("html", "htm"):
            text = html_text(path.read_text(errors="replace"))
        elif kind == "ipynb":
            cells = json.loads(path.read_text())["cells"]
            text = "\n\n".join("".join(cell["source"]) for cell in cells)
        elif kind == "fb2":
            text = " ".join(ElementTree.parse(path).getroot().itertext())
        else:
            command = (
                ["pdftotext", "-q", str(path), "-"]
                if kind == "pdf"
                else ["anydoc", str(path)]
            )
            text = subprocess.check_output(command, stderr=subprocess.DEVNULL).decode(
                errors="replace"
            )
    except (
        subprocess.CalledProcessError,
        json.JSONDecodeError,
        KeyError,
        ElementTree.ParseError,
    ):
        return {}  # a broken or scanned document stays out of the index
    text = text[:MAX_TEXT]
    if kind == "pdf":
        return {
            number: page
            for number, page in enumerate(text.split("\f"), 1)
            if page.strip()
        }
    return {0: text}


# brings the index up to date with the documents under CONTENT_ROOTS, by
# modification time and size; run niced in the background
def index_contents() -> None:
    listed = subprocess.check_output(
        ["fd", "--type", "f", "--one-file-system", "--absolute-path"]
        + [f"--extension={ext}" for ext in sorted(CONVERTED | PLAIN)]
        + [".", *(str(root) for root in CONTENT_ROOTS if root.is_dir())],
        text=True,
    ).splitlines()
    with contents_db() as db:
        known = dict(db.execute("SELECT path, stamp FROM files"))
        for name in listed:
            path = Path(name)
            stat = path.stat()
            stamp = f"{stat.st_mtime_ns}:{stat.st_size}"
            if known.get(name) == stamp:
                continue
            if name in known:
                db.execute("DELETE FROM passages WHERE path = ?", (name,))
            db.executemany(
                "INSERT INTO passages VALUES (?, ?, ?, ?)",
                passages(path, extract(path)),
            )
            db.execute("INSERT OR REPLACE INTO files VALUES (?, ?)", (name, stamp))
            db.commit()
        for gone in known.keys() - set(listed):
            db.execute("DELETE FROM passages WHERE path = ?", (gone,))
            db.execute("DELETE FROM files WHERE path = ?", (gone,))


# documents whose file name and text hold every word of three letters or more
# (as a prefix), best page first by BM25, the name counting NAME_WEIGHT times
def contents(query: str) -> list[dict]:
    words = [word for word in re.findall(r"\w+", query) if len(word) >= 3]
    if not words or not CONTENTS.exists():
        return []
    hits: dict[str, dict] = {}
    # ORDER BY rank sorts inside FTS5 with the rank function given by MATCH, so
    # snippet() runs only for the rows read, not for every match (61k for "the")
    with contents_db() as db:
        rows = db.execute(
            "SELECT path, page, snippet(passages, 3, '', '', '…', 14) FROM passages "
            f"WHERE passages MATCH ? AND rank MATCH 'bm25(0, 0, {NAME_WEIGHT}, 1)' "
            "ORDER BY rank LIMIT 300",
            (" ".join(f'"{word}"*' for word in words),),
        )
        for path, page, snippet in rows:
            if path not in hits and Path(path).exists():
                hits[path] = {
                    "path": path,
                    "page": page,
                    "snippet": " ".join(snippet.split()),
                }
                if len(hits) == 40:
                    break
    return list(hits.values())
