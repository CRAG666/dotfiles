"""What the files view previews of the selected file."""

import hashlib
import heapq
import html
import itertools
import json
import locale
import os
import re
import stat
import subprocess
import threading
from collections.abc import Callable
from pathlib import Path

LISTED = 40
TEXT_BYTES = 3000
FONT_SAMPLE = (
    "ABCDEFGHIJKLM\nNOPQRSTUVWXYZ\nabcdefghijklm\nnopqrstuvwxyz\n1234567890\n!$&*()[]{}"
)

# a token bat colours: bold, italic or underline codes, its RGB, its text, a reset
TOKEN = re.compile(r"\x1b\[((?:[134];)*)38;2;(\d+);(\d+);(\d+)m([^\x1b]*)\x1b\[0m")
ATTRIBUTES = {"1": "b", "3": "i", "4": "u"}

# folders list in ls' order, which is the locale's
locale.setlocale(locale.LC_COLLATE, "")


# a video's frame, or an audio file's cover
def frame(file: Path, out: Path) -> list[str]:
    return ["ffmpegthumbnailer", "-i", str(file), "-o", str(out), "-s", "800"]


# the first page, its imports reaching up to the repository, as yazi's preview-typst
def typst_page(file: Path, out: Path) -> list[str]:
    repo = next((folder for folder in file.parents if (folder / ".git").exists()), None)
    command = ["typst", "compile", "--format", "png", "--pages", "1"]
    root = ["--root", str(repo)] if repo else []
    return command + root + [str(file), str(out)]


# what draws each kind's thumbnail into `out`, as yazi's previewers; "image" are
# the formats Qt has no plugin for here
THUMBNAILERS: dict[str, Callable[[Path, Path], list[str]]] = {
    "pdf": lambda file, out: (
        ["pdftoppm", "-png", "-singlefile", "-f", "1", "-scale-to", "800"]
        + [str(file), str(out.with_suffix(""))]
    ),
    "video": frame,
    "audio": frame,
    "epub": lambda file, out: [
        "gnome-epub-thumbnailer",
        "-s",
        "800",
        str(file),
        str(out),
    ],
    "typst": typst_page,
    "font": lambda file, out: (
        ["magick", "-font", str(file), "-pointsize", "64", "-gravity", "center"]
        + ["-background", "white", "-fill", "black", "label:" + FONT_SAMPLE]
        + ["-bordercolor", "white", "-border", "32", str(out)]
    ),
    "image": lambda file, out: [
        "magick",
        f"{file}[0]",
        "-auto-orient",
        "-thumbnail",
        "800x800>",
        str(out),
    ],
}


# its size and modification time, a thumbnail (made once into `thumbs`), a PDF's
# pages or a video's or audio file's duration and tags, and the first entries
# of a folder or archive or the head of any other file, highlighted in bat's
# `theme` (styled); `kind` is a key of THUMBNAILERS, "archive", "file" or ""
# (none of these)
def peek(path: str, kind: str, thumbs: str, theme: str) -> dict:
    file = Path(path)
    status = file.stat()
    facts = []
    content = ""
    styled = False
    if file.is_dir():
        with os.scandir(file) as entries:
            names = (
                entry.name + ("/" if entry.is_dir(follow_symlinks=False) else "")
                for entry in entries
            )
            content = "\n".join(heapq.nsmallest(LISTED, names, key=locale.strxfrm))
    elif kind == "pdf":
        info = subprocess.run(
            ["pdfinfo", path], capture_output=True, text=True, check=False
        )
        pages = next(
            (line for line in info.stdout.splitlines() if line.startswith("Pages:")),
            "",
        )
        facts = [["Pages", pages.removeprefix("Pages:").strip()]]
    elif kind in ("video", "audio"):
        facts = media_facts(path, kind)
    elif kind == "archive":
        content = archive_entries(path)
    elif kind in ("file", "typst") and stat.S_ISREG(status.st_mode):
        content, styled = head(file, theme)
    return {
        "bytes": status.st_size,
        "modified": int(status.st_mtime),
        "thumb": thumbnail(file, THUMBNAILERS[kind], Path(thumbs))
        if kind in THUMBNAILERS
        else "",
        "facts": facts,
        "content": content,
        "styled": styled,
    }


# tags differ in case between formats (ID3's "artist", Vorbis' "ARTIST")
def media_facts(path: str, kind: str) -> list[list[str]]:
    probe = subprocess.run(
        ["ffprobe", "-v", "error", "-of", "json", "-show_entries"]
        + ["format=duration:format_tags", path],
        capture_output=True,
        text=True,
        check=False,
    )
    media = json.loads(probe.stdout or "{}").get("format", {})
    tags = {key.lower(): value for key, value in media.get("tags", {}).items()}
    named = ["artist", "album"] if kind == "audio" else []
    facts = [[tag.title(), tags.get(tag, "")] for tag in named]
    return facts + [["Duration", media.get("duration", "")]]


# bsdtar lists the tar inside a compressed one, where 7z lists that tar alone;
# stopped after the entries shown, as reading a large archive through takes long
def archive_entries(path: str) -> str:
    with subprocess.Popen(
        ["bsdtar", "-tf", path],
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        text=True,
        errors="replace",
    ) as lister:
        entries = "".join(itertools.islice(lister.stdout, LISTED))
        lister.kill()
    return entries


# the first bytes of a text (no NUL among them, as git tells it from binary),
# highlighted, or what `file` says of anything else, as yazi's fallback preview
def head(file: Path, theme: str) -> tuple[str, bool]:
    with file.open("rb") as opened:
        start = opened.read(TEXT_BYTES)
    if b"\0" not in start:
        return highlighted(start.decode(errors="replace"), file.name, theme)
    described = subprocess.run(
        ["file", "--brief", "--dereference", str(file)],
        capture_output=True,
        text=True,
        check=False,
    )
    return described.stdout.strip(), False


# bat's colours as StyledText markup, which collapses spaces: runs of them and
# one opening a line or token become entities, single ones stay for wrapping at
# words; the plain text when bat lacks `theme` (its cache unbuilt), as its
# fallback, Monokai, is unreadable on the light pane
def highlighted(text: str, name: str, theme: str) -> tuple[str, bool]:
    bat = subprocess.run(
        ["bat", "--color=always", "--italic-text=always", "--style=plain", "--tabs=4"]
        + [f"--theme={theme}", f"--file-name={name}", "-"],
        input=text,
        capture_output=True,
        text=True,
        check=True,
        env=os.environ | {"COLORTERM": "truecolor"},
    )
    if "Unknown theme" in bat.stderr:
        return text, False
    markup = TOKEN.sub(font, html.escape(bat.stdout, quote=False))
    kept = re.sub(r"(?<![^\n>]) +|  +", lambda run: "&nbsp;" * len(run[0]), markup)
    return kept.replace("\n", "<br>"), True


def font(token: re.Match) -> str:
    attributes, red, green, blue, text = token.groups()
    for code in attributes.split(";")[:-1]:
        tag = ATTRIBUTES[code]
        text = f"<{tag}>{text}</{tag}>"
    return f'<font color="#{int(red):02x}{int(green):02x}{int(blue):02x}">{text}</font>'


# made into a temporary file and renamed, so two peeks of one file never
# leave a half-written thumbnail; "" when the tool fails
def thumbnail(file: Path, draw: Callable[[Path, Path], list[str]], thumbs: Path) -> str:
    thumb = thumbs / (hashlib.md5(bytes(file)).hexdigest() + ".png")
    if thumb.exists() and thumb.stat().st_mtime > file.stat().st_mtime:
        return str(thumb)
    thumbs.mkdir(parents=True, exist_ok=True)
    partial = thumb.with_suffix(f".{threading.get_ident()}.png")
    command = draw(file, partial)
    if subprocess.run(command, capture_output=True, check=False).returncode != 0:
        partial.unlink(missing_ok=True)
        return ""
    partial.replace(thumb)
    return str(thumb)
