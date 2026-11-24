"""Zen's profiles, history and open tabs."""

import configparser
import json
import os
import re
import shutil
import sqlite3
import subprocess
import tempfile
from pathlib import Path

from paths import HOME

ZEN = HOME / ".config/zen"


TABCTL_BUS = "dev.slastra.TabCtl."


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


# the last answer and the files it came from, as (size, mtime) of each
history_cache: tuple[tuple, str] = ((), "")


# as JSON, which SQLite writes itself: the newest 3000 visits of each profile,
# newest first. Zen keeps places.sqlite locked, with recent visits in its WAL
# and no -shm to read that through, so a copy of both is queried (on tmpfs:
# SQLite's files cost more on btrfs than the copy), and none while neither
# file changed
def zen_history() -> str:
    global history_cache
    sources = [
        (profile, places)
        for profile, folder in zen_profiles()
        if (places := folder / "places.sqlite").exists()
    ]
    signature = tuple(
        (stat.st_size, stat.st_mtime_ns)
        for _, places in sources
        for path in (places, Path(f"{places}-wal"))
        if (stat := path.stat() if path.exists() else None)
    )
    if signature == history_cache[0]:
        return history_cache[1]
    with (
        tempfile.TemporaryDirectory() as scratch,
        sqlite3.connect(":memory:") as db,
    ):
        selects = []
        for index, (profile, places) in enumerate(sources):
            copy = Path(scratch) / f"{index}.sqlite"
            shutil.copy(places, copy)
            if (wal := Path(f"{places}-wal")).exists():
                shutil.copy(wal, f"{copy}-wal")
            db.execute(f"ATTACH DATABASE ? AS p{index}", (str(copy),))
            selects.append(
                f"SELECT * FROM (SELECT {index} AS source, ? AS profile, url, "
                "coalesce(nullif(title, ''), url) AS title, visit_count AS visits, "
                "last_visit_date AS stamp, last_visit_date / 1000000 AS last "
                f"FROM p{index}.moz_places WHERE hidden = 0 AND last_visit_date IS NOT NULL "
                "ORDER BY last_visit_date DESC LIMIT 3000)"
            )
        encoded = (
            db.execute(
                "SELECT json_group_array(json_object('profile', profile, 'url', url, "
                "'title', title, 'visits', visits, 'last', last)) FROM ("
                + " UNION ALL ".join(selects)
                + " ORDER BY last DESC, source, stamp DESC)",
                [profile for profile, _ in sources],
            ).fetchone()[0]
            if selects
            else "[]"
        )
        for index in range(len(sources)):
            db.execute(f"DETACH DATABASE p{index}")
    history_cache = (signature, encoded)
    return encoded


def parent_pid(pid: int) -> int:
    status = Path(f"/proc/{pid}/status").read_text()
    return int(re.search(r"^PPid:\s*(\d+)", status, re.MULTILINE)[1])


def zen_profile(browser: int) -> str:
    profiles = {folder: name for name, folder in zen_profiles()}
    for descriptor in Path(f"/proc/{browser}/fd").iterdir():
        try:
            target = Path(os.readlink(descriptor))
        except FileNotFoundError:
            continue
        if target.name == ".parentlock":
            return profiles[target.parent]
    raise RuntimeError(f"Zen process {browser} holds no profile lock")


def zen_tabs() -> list[dict]:
    buses = json.loads(
        subprocess.check_output(["busctl", "--user", "list", "--json=short"], text=True)
    )
    # tabctl's mediator, spawned by the browser once per profile, owns dev.slastra.TabCtl.<Browser><n>; its lowercase name prefixes the tab ids
    browsers = {
        bus["name"].removeprefix(TABCTL_BUS).lower(): parent_pid(bus["pid"])
        for bus in buses
        if bus["name"].startswith(TABCTL_BUS) and bus.get("pid")
    }
    clients = {
        client: (browser, zen_profile(browser))
        for client, browser in browsers.items()
        if Path(f"/proc/{browser}/exe").resolve().name == "zen-bin"
    }
    if not clients:
        return []
    listed = subprocess.check_output(["tabctl", "list", "--format", "json"], text=True)
    tabs = []
    for tab in json.loads(listed):
        client, window, _ = tab["id"].split(".")
        if tab["pinned"] or client not in clients:
            continue
        pid, profile = clients[client]
        tabs.append(
            {
                "id": tab["id"],
                "profile": profile,
                "pid": pid,
                "window": window,
                "url": tab["url"],
                "title": tab["title"] or tab["url"],
            }
        )
    return tabs
