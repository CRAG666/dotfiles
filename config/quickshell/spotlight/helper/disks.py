"""The volumes of external drives (USB sticks, external disks, cards, which
udisks marks HintSystem false) through udisks2's D-Bus objects: listing,
mounting, LUKS unlocking and powering a drive off. Internal drives would ask
polkit for an administrator."""

import json
import subprocess
import sys

UDISKS = "org.freedesktop.UDisks2"
BLOCK = f"{UDISKS}.Block"
FILESYSTEM = f"{UDISKS}.Filesystem"
ENCRYPTED = f"{UDISKS}.Encrypted"
DRIVE = f"{UDISKS}.Drive"
NO_OPTIONS = ("a{sv}", "0")


def call(path: str, interface: str, method: str, *args: str) -> list:
    run = subprocess.run(
        ["busctl", "--system", "--json=short", "call", UDISKS, path, interface, method]
        + list(args),
        capture_output=True,
        text=True,
        check=False,
    )
    if run.returncode:
        sys.exit(run.stderr.strip() or f"busctl exited {run.returncode}")
    return json.loads(run.stdout)["data"] if run.stdout.strip() else []


def managed() -> dict:
    return call(
        "/org/freedesktop/UDisks2",
        "org.freedesktop.DBus.ObjectManager",
        "GetManagedObjects",
    )[0]


def props(interface: dict) -> dict:
    return {key: value["data"] for key, value in interface.items()}


# udisks hands paths over as NUL-ended byte arrays
def text(chars: list[int]) -> str:
    return bytes(chars).rstrip(b"\0").decode()


# the block a volume sits on the drive as: a LUKS cleartext device's container,
# any other block itself
def physical(objects: dict, path: str) -> str:
    backing = objects[path][BLOCK]["CryptoBackingDevice"]["data"]
    return path if backing == "/" else backing


def drive_of(objects: dict, path: str) -> str:
    return objects[physical(objects, path)][BLOCK]["Drive"]["data"]


def disks() -> list[dict]:
    objects = managed()
    volumes = []
    for path, interfaces in objects.items():
        if BLOCK not in interfaces or not (
            FILESYSTEM in interfaces or ENCRYPTED in interfaces
        ):
            continue
        block = props(interfaces[BLOCK])
        outer = props(objects[physical(objects, path)][BLOCK])
        if block["HintIgnore"] or outer["HintSystem"]:
            continue
        locked = FILESYSTEM not in interfaces
        # an unlocked container shows as its cleartext volume
        if locked and interfaces[ENCRYPTED]["CleartextDevice"]["data"] != "/":
            continue
        drive = (
            props(objects[outer["Drive"]][DRIVE]) if outer["Drive"] in objects else {}
        )
        mounts = interfaces[FILESYSTEM]["MountPoints"]["data"] if not locked else []
        volumes.append(
            {
                "path": path,
                "device": text(block["Device"]),
                "label": block["IdLabel"],
                "type": block["IdType"],
                "size": block["Size"],
                "mountpoint": text(mounts[0]) if mounts else "",
                "locked": locked,
                "backing": ""
                if block["CryptoBackingDevice"] == "/"
                else block["CryptoBackingDevice"],
                "drive": f"{drive.get('Vendor', '')} {drive.get('Model', '')}".strip(),
                "media": drive.get("Media")
                or ("removable" if drive.get("MediaRemovable") else "disk"),
            }
        )
    return volumes


# the mount point
def disk_mount(path: str) -> str:
    return call(path, FILESYSTEM, "Mount", *NO_OPTIONS)[0]


def disk_unmount(path: str) -> None:
    call(path, FILESYSTEM, "Unmount", *NO_OPTIONS)


# the passphrase goes through a pipe, not the command line
def disk_unlock(path: str, passphrase: str) -> str:
    objects = managed()
    run = subprocess.run(
        [
            "udisksctl",
            "unlock",
            "-b",
            text(objects[path][BLOCK]["Device"]["data"]),
            "--key-file",
            "/dev/stdin",
        ],
        input=passphrase.encode(),
        capture_output=True,
        check=False,
    )
    if run.returncode:
        sys.exit(
            (run.stdout + run.stderr).decode().strip()
            or f"udisksctl exited {run.returncode}"
        )
    cleartext = managed()[path][ENCRYPTED]["CleartextDevice"]["data"]
    return disk_mount(cleartext)


# `path` is the LUKS container; its cleartext volume is unmounted first
def disk_lock(path: str) -> None:
    objects = managed()
    cleartext = objects[path][ENCRYPTED]["CleartextDevice"]["data"]
    if cleartext in objects and objects[cleartext][FILESYSTEM]["MountPoints"]["data"]:
        disk_unmount(cleartext)
    call(path, ENCRYPTED, "Lock", *NO_OPTIONS)


# unmounts and locks every volume of the drive `path` is on, then powers the
# drive off (or ejects its media) so it can be unplugged
def disk_eject(path: str) -> None:
    objects = managed()
    drive = drive_of(objects, path)
    on_drive = {
        other: interfaces
        for other, interfaces in objects.items()
        if BLOCK in interfaces and drive_of(objects, other) == drive
    }
    for other, interfaces in on_drive.items():
        if FILESYSTEM in interfaces and interfaces[FILESYSTEM]["MountPoints"]["data"]:
            disk_unmount(other)
    for other, interfaces in on_drive.items():
        if (
            ENCRYPTED in interfaces
            and interfaces[ENCRYPTED]["CleartextDevice"]["data"] != "/"
        ):
            call(other, ENCRYPTED, "Lock", *NO_OPTIONS)
    if drive not in objects:
        return
    able = props(objects[drive][DRIVE])
    if able["CanPowerOff"]:
        call(drive, DRIVE, "PowerOff", *NO_OPTIONS)
    elif able["Ejectable"]:
        call(drive, DRIVE, "Eject", *NO_OPTIONS)
