"""Calls to Herdr's socket API."""

import json
import os
import socket
import sys
from pathlib import Path

from paths import HOME


def herdr_socket() -> Path:
    if explicit := os.environ.get("HERDR_SOCKET_PATH"):
        return Path(explicit)
    base = HOME / ".config/herdr"
    session = os.environ.get("HERDR_SESSION")
    return (
        base / "sessions" / session / "herdr.sock" if session else base / "herdr.sock"
    )


# one newline-delimited JSON request/response over Herdr's unix socket
def herdr_call(method: str, params: str = "{}") -> dict:
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as connection:
        try:
            connection.connect(str(herdr_socket()))
        except (FileNotFoundError, ConnectionRefusedError):
            sys.exit("herdr is not running")
        connection.sendall(
            json.dumps(
                {"id": "spotlight", "method": method, "params": json.loads(params)}
            ).encode()
            + b"\n"
        )
        reply = connection.makefile("rb").readline()
    response = json.loads(reply)
    if "error" in response:
        sys.exit(f"herdr: {response['error']['message']}")
    return response["result"]


# starts a `kind` agent in the shell pane `target`, or in a new workspace when
# `target` is a folder; Herdr wants a name unique among live agents
def herdr_start(kind: str, target: str) -> None:
    if target.startswith("/"):
        created = herdr_call(
            "workspace.create",
            json.dumps({"cwd": target, "label": Path(target).name, "focus": True}),
        )
        target = created["root_pane"]["pane_id"]
    taken = {agent.get("name") for agent in herdr_call("agent.list")["agents"]}
    name, number = kind, 1
    while name in taken:
        number += 1
        name = f"{kind}-{number}"
    herdr_call(
        "agent.start", json.dumps({"name": name, "kind": kind, "pane_id": target})
    )
