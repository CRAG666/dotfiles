"""Spotlight's helper: runs one command and prints its JSON (readers) or does
its work (writers); a failure exits non-zero with the reason on stderr.
"""

import json
import sys
from pathlib import Path

from agenda import agenda, agenda_add
from calc import calc
from contents import contents, index_contents
from herdr import herdr_call, herdr_start
from library import (
    bookmark_save,
    categories,
    category_rename,
    entry_delete,
    list_entries,
    note_add,
    note_edit,
    note_rename,
)
from papers import paper
from pins import PINS, pin_add, pins
from recent import recent_files
from scripts import script_new, scripts
from zen import zen_history, zen_tabs


def main() -> None:
    command, *args = sys.argv[1:]
    readers = {
        "list": lambda: list_entries(*args),
        "categories": lambda: categories(*args),
        "zen-history": zen_history,
        "zen-tabs": zen_tabs,
        "pins": pins,
        "herdr": lambda: herdr_call(*args),
        "calc": lambda: calc(*args),
        "paper": lambda: paper(*args),
        "scripts": scripts,
        "agenda": lambda: agenda(*args),
        "recent-files": recent_files,
        "contents": lambda: contents(*args),
    }
    writers = {
        "bookmark-save": bookmark_save,
        "note-add": note_add,
        "note-edit": note_edit,
        "note-rename": note_rename,
        "delete": entry_delete,
        "category-rename": category_rename,
        "herdr-start": herdr_start,
        "script-new": script_new,
        "agenda-add": agenda_add,
        "pin-add": pin_add,
        "pin-remove": lambda name: (PINS / Path(name).name).unlink(),
        "index-contents": index_contents,
    }
    if command in readers:
        json.dump(readers[command](), sys.stdout)
    elif command in writers:
        writers[command](*args)
    else:
        sys.exit(f"unknown command: {command}")


if __name__ == "__main__":
    main()
