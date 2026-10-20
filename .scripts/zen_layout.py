#!/usr/bin/env python3
"""Apply a pinned-tab layout to a Zen profile.

Usage: zen_layout.py <profile-name> <layout.json>

The layout lists spaces (matched by name) with their essentials and pinned URLs.
Pinned tabs in the same container and host are reused; pinned tabs the layout
does not list become normal tabs. Essentials past the per-container limit are
pinned instead. Spaces take Zen's default theme so the userChrome.css next to
the layout colors them, each with its eyes `accent`. shortcuts.json next to the
layout rebinds Zen shortcuts by id and disables any other one on the same keys.
The profile must be closed: Zen rewrites its session on exit.
"""

import configparser
import json
import os
import sys
import time
import uuid
from collections import Counter
from pathlib import Path
from urllib.parse import urlsplit

import lz4.block

ZEN_DIR = Path.home() / ".config/zen"
MOZLZ4_MAGIC = b"mozLz40\0"
ESSENTIALS_MAX = 12
DEFAULT_THEME = {"type": "gradient", "gradientColors": [], "opacity": 0.5, "texture": 0}
PASTEL_OF_ACCENT = {
    "green0": "winterGreen",
    "teal": "winterGreen",
    "blue0": "winterBlue",
    "aqua": "winterBlue",
    "violet": "winterBlue",
    "pink": "winterRed",
    "red": "winterRed",
    "orange0": "winterRed",
    "yellow": "winterYellow",
}
USER_PREFS = (
    'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);',
    'user_pref("zen.theme.content-element-separation", 0);',
    'user_pref("zen.view.use-single-toolbar", true);',
)


def profile_dir(name: str) -> Path:
    profiles = configparser.ConfigParser(interpolation=None)
    profiles.read(ZEN_DIR / "profiles.ini")
    for section in profiles.values():
        if section.get("Name") == name:
            path = Path(section["Path"])
            return ZEN_DIR / path if section.get("IsRelative") == "1" else path
    sys.exit(f"ERROR: Zen profile '{name}' not found in {ZEN_DIR}/profiles.ini")


def ensure_closed(profile: Path) -> None:
    lock = profile / "lock"
    if not lock.is_symlink():
        return
    comm = Path("/proc", os.readlink(lock).rpartition("+")[2], "comm")
    if comm.exists() and comm.read_text().strip() == "zen-bin":
        sys.exit(f"ERROR: close Zen (profile {profile.name}) first")


def read_session(path: Path) -> dict:
    if not path.exists():
        return {}
    raw = path.read_bytes()
    if not raw.startswith(MOZLZ4_MAGIC):
        sys.exit(f"ERROR: {path} is not a mozlz4 file")
    return json.loads(lz4.block.decompress(raw[len(MOZLZ4_MAGIC) :]))


def write_session(path: Path, session: dict) -> None:
    payload = json.dumps(session, separators=(",", ":")).encode()
    path.write_bytes(MOZLZ4_MAGIC + lz4.block.compress(payload))


def host(url: str) -> str | None:
    return urlsplit(url).hostname


def pinned_url(tab: dict) -> str:
    initial = tab.get("_zenPinnedInitialState") or {}
    return (initial.get("entry") or {}).get("url") or tab["entries"][0]["url"]


def new_pinned_tab(url: str) -> dict:
    now = int(time.time() * 1000)
    return {
        "entries": [
            {
                "url": url,
                "title": host(url),
                "triggeringPrincipal_base64": json.dumps({"1": {"0": url}}),
            }
        ],
        "index": 1,
        "lastAccessed": now,
        "hidden": False,
        "zenSyncId": f"{now}-{uuid.uuid4()}",
        "zenDefaultUserContextId": "true",
        "_zenPinnedInitialState": {
            "entry": {"url": url, "title": host(url)},
            "image": None,
        },
        "attributes": {},
    }


def take_pinned(pinned: list[dict], url: str, container: int, essential: bool):
    candidates = [
        tab
        for tab in pinned
        if tab.get("userContextId", 0) == container
        and host(pinned_url(tab)) == host(url)
    ]
    if not candidates:
        return None
    tab = next(
        (tab for tab in candidates if bool(tab.get("zenEssential")) == essential),
        candidates[0],
    )
    pinned.remove(tab)
    return tab


def install_styles(profile: Path, user_chrome: Path, accents: dict[str, str]) -> None:
    if unknown := set(accents.values()) - PASTEL_OF_ACCENT.keys():
        sys.exit(
            f"ERROR: unknown accents {unknown}, use one of {list(PASTEL_OF_ACCENT)}"
        )
    chrome = profile / "chrome"
    chrome.mkdir(exist_ok=True)
    link = chrome / "userChrome.css"
    if link.exists() and not link.is_symlink():
        sys.exit(f"ERROR: {link} is not a symlink; move it away first")
    link.unlink(missing_ok=True)
    link.symlink_to(user_chrome)
    (chrome / "zen-spaces.css").write_text(
        "".join(
            f':root:has(zen-workspace[active][id="{space_uuid}"]) '
            f"{{ --eyes-space-accent: var(--eyes-{name});"
            f" --eyes-space-pastel: var(--eyes-{PASTEL_OF_ACCENT[name]}); }}\n"
            for space_uuid, name in accents.items()
        )
    )
    user_js = profile / "user.js"
    existing = user_js.read_text() if user_js.exists() else ""
    with user_js.open("a") as stream:
        stream.writelines(pref + "\n" for pref in USER_PREFS if pref not in existing)


def key_combo(shortcut: dict) -> tuple:
    modifiers = shortcut["modifiers"]
    return (
        (shortcut.get("key") or shortcut["keycode"] or "").lower(),
        bool(modifiers.get("control") or modifiers.get("accel")),
        bool(modifiers.get("alt")),
        bool(modifiers.get("shift")),
        bool(modifiers.get("meta")),
    )


def apply_shortcuts(profile: Path, wanted: dict[str, str]) -> None:
    path = profile / "zen-keyboard-shortcuts.json"
    if not path.exists():
        print(f"    no {path.name} yet: start Zen once with this profile, then rerun")
        return
    saved = json.loads(path.read_text())
    by_id = {shortcut["id"]: shortcut for shortcut in saved["shortcuts"]}
    if unknown := wanted.keys() - by_id.keys():
        sys.exit(f"ERROR: unknown Zen shortcut ids {unknown}")
    for shortcut_id, combo in wanted.items():
        *modifiers, key = combo.split("+")
        if extra := set(modifiers) - {"Ctrl", "Alt", "Shift"}:
            sys.exit(f"ERROR: {combo}: use Ctrl, Alt or Shift, not {extra}")
        by_id[shortcut_id].update(
            key=key.lower(),
            keycode="",
            disabled=False,
            modifiers={
                "control": False,
                "alt": "Alt" in modifiers,
                "shift": "Shift" in modifiers,
                "meta": False,
                "accel": "Ctrl" in modifiers,
            },
        )
    taken = {key_combo(by_id[shortcut_id]) for shortcut_id in wanted}
    for shortcut in saved["shortcuts"]:
        if (
            shortcut["id"] not in wanted
            and not shortcut["disabled"]
            and key_combo(shortcut) in taken
        ):
            shortcut["disabled"] = True
            print(f"    disabled {shortcut['id']}, its keys are taken")
    path.write_text(json.dumps(saved))


def main() -> None:
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    profile = profile_dir(sys.argv[1])
    ensure_closed(profile)
    layout_path = Path(sys.argv[2]).resolve()
    layout = json.loads(layout_path.read_text())
    session_path = profile / "zen-sessions.jsonlz4"
    session = read_session(session_path)

    spaces_by_name = {space["name"]: space for space in session.get("spaces", [])}
    wanted = []
    essentials_used = Counter()
    accents = {}
    layout_spaces = []
    for entry in layout["spaces"]:
        space = spaces_by_name.pop(entry["name"], None) or {
            "uuid": f"{{{uuid.uuid4()}}}",
            "name": entry["name"],
        }
        container = entry["container"]
        space.update(icon=entry["icon"], theme=DEFAULT_THEME, containerTabId=container)
        layout_spaces.append(space)
        accents[space["uuid"]] = entry["accent"]
        fits = max(ESSENTIALS_MAX - essentials_used[container], 0)
        essentials_used[container] += len(entry["essentials"][:fits])
        wanted += [(space, url, True) for url in entry["essentials"][:fits]]
        wanted += [
            (space, url, False) for url in entry["essentials"][fits:] + entry["pinned"]
        ]
    session["spaces"] = layout_spaces + list(spaces_by_name.values())
    wanted.sort(key=lambda item: not item[2])

    tabs = session.get("tabs", [])
    pinned = [tab for tab in tabs if tab.get("pinned")]
    managed = []
    for space, url, essential in wanted:
        container = space["containerTabId"]
        tab = take_pinned(pinned, url, container, essential) or new_pinned_tab(url)
        tab.update(
            pinned=True,
            zenEssential=essential,
            zenWorkspace=space["uuid"],
            userContextId=container,
        )
        initial = tab.get("_zenPinnedInitialState") or {
            "entry": {"title": host(url)},
            "image": None,
        }
        initial["entry"]["url"] = url
        tab["_zenPinnedInitialState"] = initial
        managed.append(tab)
    for tab in pinned:
        tab.update(pinned=False, zenEssential=False)
        tab.pop("_zenPinnedInitialState", None)

    session["tabs"] = managed + [tab for tab in tabs if not tab.get("pinned")]
    install_styles(profile, layout_path.with_name("userChrome.css"), accents)
    apply_shortcuts(
        profile, json.loads(layout_path.with_name("shortcuts.json").read_text())
    )
    write_session(session_path, session)
    essentials = sum(1 for tab in managed if tab["zenEssential"])
    print(
        f"    {essentials} essentials, {len(managed) - essentials} pinned,"
        f" {len(pinned)} unpinned"
    )


if __name__ == "__main__":
    main()
