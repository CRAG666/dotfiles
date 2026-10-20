"""What the files view previews of the selected file."""

import hashlib
import heapq
import locale
import os
import subprocess
import threading
from pathlib import Path

LISTED = 40
TEXT_BYTES = 3000

# folders list in ls' order, which is the locale's
locale.setlocale(locale.LC_COLLATE, "")


# its size and modification time, a thumbnail of a PDF or video (made once into
# `thumbs`), a PDF's page count or a video's duration, and the first entries of
# a folder or the first bytes of a text file; `kind` is pdf, video, text or ""
def peek(path: str, kind: str, thumbs: str) -> dict:
    file = Path(path)
    stat = file.stat()
    extra = ["", ""]
    content = ""
    if kind == "pdf":
        info = subprocess.run(
            ["pdfinfo", path], capture_output=True, text=True, check=False
        )
        pages = next(
            (line for line in info.stdout.splitlines() if line.startswith("Pages:")),
            "",
        )
        extra = ["Pages", pages.removeprefix("Pages:").strip()]
    elif kind == "video":
        probe = subprocess.run(
            ["ffprobe", "-v", "error", "-show_entries", "format=duration"]
            + ["-of", "csv=p=0", path],
            capture_output=True,
            text=True,
            check=False,
        )
        extra = ["Duration", probe.stdout.strip()]
    if file.is_dir():
        with os.scandir(file) as entries:
            names = (
                entry.name + ("/" if entry.is_dir(follow_symlinks=False) else "")
                for entry in entries
            )
            content = "\n".join(heapq.nsmallest(LISTED, names, key=locale.strxfrm))
    elif kind == "text":
        with file.open("rb") as text:
            content = text.read(TEXT_BYTES).decode(errors="replace")
    return {
        "bytes": stat.st_size,
        "modified": int(stat.st_mtime),
        "thumb": thumbnail(file, kind, Path(thumbs))
        if kind in ("pdf", "video")
        else "",
        "extra": extra,
        "content": content,
    }


# made into a temporary file and renamed, so two peeks of one file never
# leave a half-written thumbnail; "" when the tool fails
def thumbnail(file: Path, kind: str, thumbs: Path) -> str:
    thumb = thumbs / (hashlib.md5(bytes(file)).hexdigest() + ".png")
    if thumb.exists() and thumb.stat().st_mtime > file.stat().st_mtime:
        return str(thumb)
    thumbs.mkdir(parents=True, exist_ok=True)
    partial = thumb.with_suffix(f".{threading.get_ident()}.png")
    if kind == "pdf":
        command = ["pdftoppm", "-png", "-singlefile", "-f", "1", "-scale-to", "800"]
        command += [str(file), str(partial.with_suffix(""))]
    else:
        command = [
            "ffmpegthumbnailer",
            "-i",
            str(file),
            "-o",
            str(partial),
            "-s",
            "800",
        ]
    if subprocess.run(command, capture_output=True, check=False).returncode != 0:
        partial.unlink(missing_ok=True)
        return ""
    partial.replace(thumb)
    return str(thumb)
