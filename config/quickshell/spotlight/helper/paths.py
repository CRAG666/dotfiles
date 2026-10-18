"""Where Spotlight keeps its data, state and configuration."""

import os
from pathlib import Path

HOME = Path.home()


DATA = Path(os.environ.get("XDG_DATA_HOME", HOME / ".local/share")) / "spotlight"


STATE = Path(os.environ.get("XDG_STATE_HOME", HOME / ".local/state")) / "spotlight"


CONFIG_DIR = Path(os.environ.get("XDG_CONFIG_HOME", HOME / ".config")) / "spotlight"


CONFIG = CONFIG_DIR / "spotlight.json"
