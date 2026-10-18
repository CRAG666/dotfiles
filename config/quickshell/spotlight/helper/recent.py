"""Recently used and saved files."""

import json
import os
import subprocess
import time
from datetime import datetime
from pathlib import Path
from urllib.parse import unquote, urlparse
from xml.etree import ElementTree

from contents import CONTENT_ROOTS
from paths import HOME, STATE

RECENT_ROOTS = [*CONTENT_ROOTS, HOME / "Pictures", HOME / "Videos", HOME / "Music"]


RECENT_DAYS = 30


# what Spotlight opened, what GTK apps recorded and what was saved or downloaded
# into RECENT_ROOTS in the last RECENT_DAYS, newest first; hidden paths and
# partial downloads are left out
def recent_files() -> list[dict]:
    since = time.time() - RECENT_DAYS * 86400
    used: dict[Path, float] = {}

    def add(path: Path, when: float) -> None:
        if when >= since and not any(part.startswith(".") for part in path.parts):
            used[path] = max(used.get(path, 0), when)

    picks = STATE / "picks.json"
    if picks.exists():
        for key, (_, last) in json.loads(picks.read_text()).items():
            kind, _, picked = key.partition(":")
            if kind in ("file", "content"):
                add(Path(picked), last / 1000)
    xbel = (
        Path(os.environ.get("XDG_DATA_HOME", HOME / ".local/share"))
        / "recently-used.xbel"
    )
    if xbel.exists():
        for bookmark in ElementTree.parse(xbel).getroot().iter("bookmark"):
            href = bookmark.get("href", "")
            if href.startswith("file://"):
                stamp = max(bookmark.get("visited", ""), bookmark.get("modified", ""))
                add(
                    Path(unquote(urlparse(href).path)),
                    datetime.fromisoformat(stamp).timestamp(),
                )
    roots = [str(root) for root in RECENT_ROOTS if root.is_dir()]
    changed = subprocess.check_output(
        ["fd", "--type", "f", "--changed-within", f"{RECENT_DAYS}d", "--absolute-path"]
        + ["--exclude", "*.part", "--exclude", "*.crdownload", ".", *roots],
        text=True,
    )
    for line in changed.splitlines():
        try:
            add(Path(line), Path(line).stat().st_mtime)
        except FileNotFoundError:
            continue  # removed since fd listed it
    newest = sorted(used.items(), key=lambda entry: entry[1], reverse=True)
    return [
        {
            "path": str(path),
            "isDir": path.is_dir(),
            "used": datetime.fromtimestamp(when).astimezone().isoformat(),
        }
        for path, when in newest
        if path.exists()
    ][:100]
