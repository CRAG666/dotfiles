"""Opening files in $EDITOR in the configured terminal."""

import json
import os
import shutil
import subprocess
import tempfile
from pathlib import Path

from paths import CONFIG, HOME


def editor() -> str:
    return (
        os.environ.get("EDITOR")
        or shutil.which("nvim")
        or str(HOME / ".local/share/bob/nvim-bin/nvim")
    )


def terminal() -> list[str]:
    return json.loads(CONFIG.read_text())["terminal"]


def edit_in_terminal(initial: str) -> str:
    with tempfile.NamedTemporaryFile("w+", suffix=".md", delete=False) as draft:
        draft.write(initial)
    try:
        subprocess.run([*terminal(), editor(), draft.name], check=True)
        return Path(draft.name).read_text().strip()
    finally:
        os.unlink(draft.name)
