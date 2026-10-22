"""Spotlight's helper: runs one command and prints its JSON (readers) or does
its work (writers); a failure exits non-zero with the reason on stderr.
`serve` keeps it resident for Spotlight, which would otherwise wait ~100 ms
for Python to start and import at every call.
"""

import json
import os
import sys
import threading
import traceback
from importlib import import_module

# a command's module and function, imported on its first call
READERS = {
    "list": ("library", "list_entries"),
    "categories": ("library", "categories"),
    "zen-history": ("zen", "zen_history"),
    "zen-tabs": ("zen", "zen_tabs"),
    "pins": ("pins", "pins"),
    "herdr": ("herdr", "herdr_call"),
    "calc": ("calc", "calc"),
    "paper": ("papers", "paper"),
    "scripts": ("scripts", "scripts"),
    "agenda": ("agenda", "agenda"),
    "tasks": ("agenda", "tasks"),
    "recent-files": ("recent", "recent_files"),
    "contents": ("contents", "contents"),
    "wifi": ("wifi", "wifi"),
    "peek": ("peek", "peek"),
    "clip-peek": ("clipboard", "clip_peek"),
}
WRITERS = {
    "bookmark-save": ("library", "bookmark_save"),
    "note-add": ("library", "note_add"),
    "note-edit": ("library", "note_edit"),
    "note-rename": ("library", "note_rename"),
    "delete": ("library", "entry_delete"),
    "category-rename": ("library", "category_rename"),
    "herdr-start": ("herdr", "herdr_start"),
    "script-new": ("scripts", "script_new"),
    "agenda-add": ("agenda", "agenda_add"),
    "pin-add": ("pins", "pin_add"),
    "pin-remove": ("pins", "pin_remove"),
    "index-contents": ("contents", "index_contents"),
    "wifi-scan": ("wifi", "wifi_scan"),
    "wifi-connect": ("wifi", "wifi_connect"),
    "wifi-disconnect": ("wifi", "wifi_disconnect"),
    "wifi-forget": ("wifi", "wifi_forget"),
}


def run(command: str, *args: str) -> str:
    """A reader's JSON, or "" once a writer is done."""
    if command in READERS:
        module, function = READERS[command]
        return json.dumps(getattr(import_module(module), function)(*args))
    if command in WRITERS:
        module, function = WRITERS[command]
        getattr(import_module(module), function)(*args)
        return ""
    sys.exit(f"unknown command: {command}")


def answer(request: dict, answers, lock: threading.Lock) -> None:
    try:
        reply = {"id": request["id"], "output": run(*request["args"])}
    except SystemExit as error:
        reply = {"id": request["id"], "error": str(error.code)}
    except Exception as error:  # noqa: BLE001 - any failure is the caller's error reply
        traceback.print_exc()
        reply = {
            "id": request["id"],
            "error": "".join(traceback.format_exception_only(error)).strip(),
        }
    with lock:
        answers.write(json.dumps(reply) + "\n")
        answers.flush()


def serve() -> None:
    """Reads {"id", "args"} lines and answers each, in its own thread so a slow
    call (a paper, a Wi-Fi scan) holds up no other, with an {"id", "output"} or
    {"id", "error"} line. The protocol keeps its own descriptors: children and
    stray prints get /dev/null and stderr. Ends when Spotlight closes stdin."""
    requests = os.fdopen(os.dup(0), encoding="utf-8")
    answers = os.fdopen(os.dup(1), "w", encoding="utf-8")
    os.dup2(os.open(os.devnull, os.O_RDONLY), 0)
    os.dup2(2, 1)
    lock = threading.Lock()
    for line in requests:
        threading.Thread(
            target=answer, args=(json.loads(line), answers, lock), daemon=True
        ).start()


def main() -> None:
    if sys.argv[1:] == ["serve"]:
        serve()
    else:
        sys.stdout.write(run(*sys.argv[1:]))


if __name__ == "__main__":
    main()
