"""Where the time of a keystroke goes: the typing of `keystrokes`, recorded by
qmlprofiler from a sandbox started with QML debugging, and summed by self time
(a function's or binding's own time, without what it calls) per source line.
"""

import subprocess
import time
from collections import Counter
from pathlib import Path
from random import Random
from xml.etree import ElementTree

from equivalence import LOADED
from keystrokes import sequences, typing
from sandbox import sandbox

PORT = 3768
NESTED = {"Javascript", "Binding", "HandlingSignal", "Creating", "Compiling"}


def self_times(trace: Path) -> tuple[Counter, Counter, dict]:
    """Self and call count per event, and each event's description."""
    events: dict[int, dict] = {}
    ranges = []
    for _, element in ElementTree.iterparse(trace):
        if element.tag == "event":
            events[int(element.get("index"))] = {
                child.tag: child.text or "" for child in element
            }
            element.clear()
        elif element.tag == "range" and element.get("duration") is not None:
            ranges.append(
                (
                    int(element.get("startTime")),
                    int(element.get("duration")),
                    int(element.get("eventIndex")),
                )
            )
            element.clear()
    ranges = sorted(
        (r for r in ranges if events[r[2]].get("type") in NESTED),
        key=lambda r: (r[0], -r[1]),
    )
    own, calls = Counter(), Counter()
    stack: list[tuple[int, int, int]] = []
    for start, duration, index in ranges:
        while stack and stack[-1][0] + stack[-1][1] <= start:
            stack.pop()
        if stack:
            own[stack[-1][2]] -= duration
        stack.append((start, duration, index))
        own[index] += duration
        calls[index] += 1
    return own, calls, events


def profile(rev: str | None, count: int, mode: str, top: int) -> None:
    typed = sequences(Random(11), count)
    with sandbox(rev, debug_port=PORT) as instance:
        trace = instance.scratch / "trace.qtd"
        profiler = subprocess.Popen(
            [
                "/usr/lib/qt6/bin/qmlprofiler",
                "--interactive",
                "--record",
                "off",
                "-a",
                "localhost",
                "-p",
                str(PORT),
            ],
            stdin=subprocess.PIPE,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            text=True,
        )
        time.sleep(2)
        instance.probe(
            f"win.mode = {mode!r};\nloadAll();\nsettle(() => {LOADED}, () => done(true));"
        )
        profiler.stdin.write("r\n")
        profiler.stdin.flush()
        time.sleep(1)
        instance.probe(typing(typed, [], mode, settled=True), timeout=900)
        for command in ("r", f"f {trace}", "q"):
            profiler.stdin.write(command + "\n")
            profiler.stdin.flush()
            time.sleep(4)
        profiler.wait(timeout=60)
        own, calls, events = self_times(trace)
    total = sum(own.values())
    keystrokes = sum(map(len, typed))
    print(
        f"profile of {rev or 'the working tree'}: {keystrokes} keystrokes, {total / 1e6:.0f} ms of QML self time ({total / 1e6 / keystrokes:.2f} ms a keystroke)"
    )
    for index, nanoseconds in own.most_common(top):
        event = events[index]
        where = f"{event.get('filename', '').rsplit('/', 1)[-1]}:{event.get('line')}"
        print(
            f"  {nanoseconds / 1e6:8.1f} ms  {calls[index]:7d}×  {event.get('type', '')[:5]}  {where}  {event.get('details', '')[:70]}"
        )
