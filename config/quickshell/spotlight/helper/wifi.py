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


def band(frequency: int) -> str:
    if frequency < 3000:
        return "2.4 GHz"
    return "5 GHz" if frequency < 5925 else "6 GHz"


# the link of the connected network: its address, band, rates and access point.
# The diagnostics answer Busy or NotConnected while iwd connects or roams, and
# DHCP may not have given an address yet: the details then show what there is
def details(path: str, interface: str) -> list[list[str]]:
    rows = []
    address = json.loads(
        subprocess.check_output(["ip", "-j", "-4", "addr", "show", "dev", interface])
    )[0]["addr_info"]
    if address:
        rows.append(["IP", f"{address[0]['local']}/{address[0]['prefixlen']}"])
    run = subprocess.run(
        ["busctl", "--system", "--json=short", "call", IWD, path]
        + [f"{IWD}.StationDiagnostic", "GetDiagnostics"],
        capture_output=True,
        text=True,
        check=False,
    )
    if run.returncode:
        return rows
    diagnostics = {
        key: value["data"] for key, value in json.loads(run.stdout)["data"][0].items()
    }
    rows.append(
        [
            "Band",
            f"{band(diagnostics['Frequency'])} · channel {diagnostics['Channel']}"
            + (f" · {diagnostics['RxMode']}" if "RxMode" in diagnostics else ""),
        ]
    )
    # rates in 100 kbit/s
    if "RxBitrate" in diagnostics and "TxBitrate" in diagnostics:
        down, up = diagnostics["RxBitrate"] / 10, diagnostics["TxBitrate"] / 10
        rows.append(["Rate", f"{down:g} down · {up:g} up Mbit/s"])
    rows.append(["Access point", diagnostics["ConnectedBss"]])
    return rows


# the networks in range, strongest first
def wifi() -> list[dict]:
    objects = managed()
    found = station(objects)
    if found is None:
        return []
    path, interface = found
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
                "details": details(path, interface) if props["Connected"] else [],
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


def connect(command: str, name: str, passphrase: str) -> None:
    iwctl(
        *(["--passphrase", passphrase] if passphrase else []),
        "station",
        device(),
        command,
        name,
    )


# a saved WPA network whose handshake failed asks its passphrase again on the
# next connect, and keeps the new one once it works
def wifi_connect(name: str, passphrase: str = "") -> None:
    connect("connect", name, passphrase)


def wifi_connect_hidden(name: str, passphrase: str = "") -> None:
    connect("connect-hidden", name, passphrase)


def wifi_disconnect() -> None:
    iwctl("station", device(), "disconnect")


def wifi_forget(name: str) -> None:
    iwctl("known-networks", name, "forget")
