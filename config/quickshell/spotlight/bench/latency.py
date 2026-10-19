"""How long a keystroke takes to reach the screen: from the field's change to
the swap of the frame that shows it, layout and rendering included, which a
hidden window never does. The sandbox's Spotlight opens in the background
layer, behind every window, with no keyboard focus and no input region, so it
takes nothing from the desktop. Each keystroke waits for the previous one's
frame. At 60 Hz a keystroke slower than a frame (16.7 ms) shows a frame late.
"""

import json
from pathlib import Path
from random import Random
from statistics import fmean, median, quantiles

from equivalence import LOADED
from keystrokes import sequences
from sandbox import sandbox

FRAME = 1000 / 60

BEHIND = (
    (
        "WlrLayershell.layer: shown ? WlrLayer.Overlay : WlrLayer.Background",
        "WlrLayershell.layer: WlrLayer.Background",
    ),
    (
        "WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None",
        "WlrLayershell.keyboardFocus: WlrKeyboardFocus.None",
    ),
    ("mask: shown ? null : noInput", "mask: noInput"),
)

TYPE = """
const states = [].concat(...JSON.parse(SEQUENCES));
const quick = win.contentItem.Window.window;
win.mode = MODE;
loadAll();
settle(() => LOADED, () => {
    win.open(MODE);
    const latencies = [], syncs = [];
    let index = -1, started = 0, sync = 0, waiting = false;
    const next = () => {
        if (++index >= states.length) {
            quick.frameSwapped.disconnect(swapped);
            win.close();
            done({ latencies, syncs });
            return;
        }
        started = Date.now();
        win.search.text = states[index];
        win.results.length;
        sync = Date.now() - started;
        waiting = true;
    };
    const swapped = () => {
        if (!waiting)
            return;
        waiting = false;
        latencies.push(Date.now() - started);
        syncs.push(sync);
        Qt.callLater(next);
    };
    quick.frameSwapped.connect(swapped);
    // the opening's fade settles first
    onTick = () => {
        tick.stop();
        next();
    };
    tick.interval = 600;
    tick.start();
});
"""


def behind(config: Path) -> None:
    spotlight = config / "spotlight/Spotlight.qml"
    text = spotlight.read_text()
    for old, new in BEHIND:
        if text.count(old) != 1:
            raise RuntimeError(
                f"Spotlight.qml changed; cannot keep the sandbox behind: {old}"
            )
        text = text.replace(old, new)
    spotlight.write_text(text)


def run(rev: str | None, typed: list[list[str]], mode: str) -> dict:
    body = (
        TYPE.replace("SEQUENCES", json.dumps(json.dumps(typed)))
        .replace("MODE", json.dumps(mode))
        .replace("LOADED", LOADED)
    )
    with sandbox(rev, prepare=behind) as instance:
        return instance.probe(body, timeout=900)


def summary(runs: list[dict]) -> dict:
    latencies = [time for run in runs for time in run["latencies"]]
    syncs = [time for run in runs for time in run["syncs"]]
    return {
        "keystrokes": len(latencies),
        "median ms": median(latencies),
        "p90 ms": quantiles(latencies, n=10)[8],
        "mean ms": round(fmean(latencies), 1),
        "late %": round(100 * fmean(time > FRAME for time in latencies), 1),
        "2+ frames late %": round(
            100 * fmean(time > 2 * FRAME for time in latencies), 1
        ),
        "sync median ms": median(syncs),
    }


def latency(rev: str, count: int, mode: str, repeat: int) -> None:
    typed = sequences(Random(11), count)
    print(
        f"latency: {sum(map(len, typed))} keystrokes in {mode or 'the search of everything'}, {repeat} run(s) a side, keystroke to frame"
    )
    sides = ((rev, rev), ("working tree", None))
    runs: dict[str, list[dict]] = {label: [] for label, _ in sides}
    for _ in range(repeat):
        for label, target in sides:
            runs[label].append(run(target, typed, mode))
    width = max(map(len, runs))
    for label, measured in runs.items():
        print(
            f"  {label:<{width}}  "
            + "  ".join(f"{name} {value}" for name, value in summary(measured).items())
        )
