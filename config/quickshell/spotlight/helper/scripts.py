"""Script commands in Raycast's format."""

import json
import os
import re
import subprocess
import sys
from itertools import islice
from pathlib import Path

from paths import CONFIG_DIR
from terminal import editor, terminal

SCRIPTS = CONFIG_DIR / "scripts"


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
    subprocess.run([*terminal(), editor(), str(path)], check=True)
