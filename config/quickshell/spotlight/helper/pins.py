"""Pinned clipboard entries, kept apart from cliphist."""

import subprocess
import time

from paths import STATE

PINS = STATE / "pins"


IMAGE_MAGIC = (b"\x89PNG", b"\xff\xd8\xff", b"GIF8", b"BM")


def pins() -> list[dict]:
    PINS.mkdir(parents=True, exist_ok=True)
    listed = []
    for path in sorted(
        PINS.iterdir(), key=lambda pin: pin.stat().st_mtime, reverse=True
    ):
        head = path.read_bytes()[:4096]
        image = head.startswith(IMAGE_MAGIC) or head[8:12] == b"WEBP"
        listed.append(
            {
                "name": path.name,
                "path": str(path),
                "image": image,
                "text": "" if image else head.decode(errors="replace"),
            }
        )
    return listed


def pin_add(clip_id: str) -> None:
    PINS.mkdir(parents=True, exist_ok=True)
    content = subprocess.check_output(["cliphist", "decode", clip_id])
    (PINS / str(time.time_ns())).write_bytes(content)
