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
