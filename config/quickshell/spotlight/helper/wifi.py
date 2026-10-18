"""Wi-Fi through iwd: its D-Bus objects to list and scan, iwctl to connect (it
answers iwd's passphrase request itself)."""

import json
import subprocess
import sys

IWD = "net.connman.iwd"
SECURITY = {"open": "Open", "psk": "WPA", "8021x": "Enterprise", "wep": "WEP"}


def call(path: str, interface: str, method: str) -> list:
    reply = subprocess.check_output(
        ["busctl", "--system", "--json=short", "call", IWD, path, interface, method]
    )
    return json.loads(reply)["data"]


# the station's object path and the name iwctl knows its device by; None while
# Wi-Fi is off
def station() -> tuple[str, str] | None:
    objects = call("/", "org.freedesktop.DBus.ObjectManager", "GetManagedObjects")[0]
    for path, interfaces in objects.items():
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
    found = station()
    if found is None:
        return []
    path, _ = found
    objects = call("/", "org.freedesktop.DBus.ObjectManager", "GetManagedObjects")[0]
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


def wifi_scan() -> None:
    found = station()
    if found is None:
        sys.exit("Wi-Fi is off")
    run = subprocess.run(
        ["busctl", "--system", "call", IWD, found[0], f"{IWD}.Station", "Scan"],
        capture_output=True,
        text=True,
        check=False,
    )
    # a scan already running answers Busy, and its results come all the same
    if run.returncode and "Busy" not in run.stderr:
        sys.exit(run.stderr.strip())


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
