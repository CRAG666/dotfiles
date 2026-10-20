"""Wi-Fi through iwd: its D-Bus objects to list and scan, iwctl to connect (it
answers iwd's passphrase request itself)."""

import json
import subprocess
import sys
import time

IWD = "net.connman.iwd"
SECURITY = {"open": "Open", "psk": "WPA", "8021x": "Enterprise", "wep": "WEP"}
SCAN_LIMIT = 15


def call(path: str, interface: str, method: str) -> list:
    reply = subprocess.check_output(
        ["busctl", "--system", "--json=short", "call", IWD, path, interface, method]
    )
    return json.loads(reply)["data"]


def managed() -> dict:
    return call("/", "org.freedesktop.DBus.ObjectManager", "GetManagedObjects")[0]


# the station's object path and the name iwctl knows its device by; None while
# Wi-Fi is off
def station(objects: dict | None = None) -> tuple[str, str] | None:
    for path, interfaces in (objects or managed()).items():
        if f"{IWD}.Station" in interfaces:
            return path, interfaces[f"{IWD}.Device"]["Name"]["data"]
    return None


def device() -> str:
    found = station()
    if found is None:
        sys.exit("Wi-Fi is off")
    return found[1]


# the networks in range, strongest first
def wifi() -> list[dict]:
    objects = managed()
    found = station(objects)
    if found is None:
        return []
    path, _ = found
    networks = []
    for network, strength in call(path, f"{IWD}.Station", "GetOrderedNetworks")[0]:
        props = {
            key: value["data"]
            for key, value in objects[network][f"{IWD}.Network"].items()
        }
        networks.append(
            {
                "name": props["Name"],
                "security": SECURITY.get(props["Type"], props["Type"]),
                "connected": props["Connected"],
                "known": "KnownNetwork" in props,
                # dBm × 100: -50 dBm and above is full, -100 dBm is nothing
                "signal": max(0, min(100, 2 * (strength // 100 + 100))),
            }
        )
    return networks


def scanning(path: str) -> bool:
    reply = subprocess.check_output(
        ["busctl", "--system", "--json=short", "get-property", IWD, path]
        + [f"{IWD}.Station", "Scanning"]
    )
    return json.loads(reply)["data"]


# returns once the scan is over: iwd answers Scan as it starts and clears
# Scanning at the end. Wi-Fi off has nothing to scan, and a scan, connection or
# roam under way answers "already in progress" (busctl prints the message, not
# the error's name): its results come all the same
def wifi_scan() -> None:
    found = station()
    if found is None:
        return
    run = subprocess.run(
        ["busctl", "--system", "call", IWD, found[0], f"{IWD}.Station", "Scan"],
        capture_output=True,
        text=True,
        check=False,
    )
    if run.returncode and not any(
        busy in run.stderr for busy in ("already in progress", "Busy")
    ):
        sys.exit(run.stderr.strip())
    deadline = time.monotonic() + SCAN_LIMIT
    while scanning(found[0]) and time.monotonic() < deadline:
        time.sleep(0.25)


def iwctl(*args: str) -> None:
    run = subprocess.run(
        ["iwctl", "--dont-ask", *args], capture_output=True, text=True, check=False
    )
    if run.returncode:
        sys.exit((run.stdout + run.stderr).strip() or f"iwctl exited {run.returncode}")


def wifi_connect(name: str, passphrase: str = "") -> None:
    iwctl(
        *(["--passphrase", passphrase] if passphrase else []),
        "station",
        device(),
        "connect",
        name,
    )


def wifi_disconnect() -> None:
    iwctl("station", device(), "disconnect")


def wifi_forget(name: str) -> None:
    iwctl("known-networks", name, "forget")
