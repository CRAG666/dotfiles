"""How long Spotlight takes to answer each keystroke, and how much garbage
collection that costs, typing real queries letter by letter (with a backspace
now and then) in a hidden sandbox; `warm` first runs that many queries, as a
long session would.
"""

import json
import re
from random import Random
from statistics import fmean, median, quantiles

from corpus import matcher_queries, texts, words
from equivalence import LOADED
from sandbox import sandbox

GC_RULES = "qt.qml.gc.stepExecution.debug=true;qt.qml.gc.allocatorStats.debug=true"
STEP = re.compile(r"Performed \w+ in (\d+) microseconds")

TYPE = """
const sequences = JSON.parse(SEQUENCES);
const warmQueries = JSON.parse(WARM);
win.mode = MODE;
loadAll();
SETTLE(() => LOADED, () => {
    for (const query of warmQueries)
        win.everything(tokens(query), query);
    console.log("BENCH-BEGIN");
    const times = [], arrivals = [];
    for (const typed of sequences) {
        for (const text of typed) {
            const started = Date.now();
            win.search.text = text;
            win.results.length;
            times.push(Date.now() - started);
        }
        // fd's files landing for the typed query, as they do 150 ms after it rests
        const started = Date.now();
        files.found = files.found.slice();
        win.results.length;
        arrivals.push(Date.now() - started);
    }
    win.search.text = "";
    win.mode = "";
    console.log("BENCH-END");
    done({ times, arrivals });
});
"""


def sequences(rng: Random, count: int) -> list[list[str]]:
    """What the field holds after each keystroke, for `count` typed queries."""
    corpus = texts(2000, rng)
    typed = []
    for text in rng.sample(corpus, count):
        parts = words(text)[:2]
        if not parts:
            continue
        target = " ".join(parts)[:18]
        states = [target[:end] for end in range(1, len(target) + 1)]
        if len(target) > 4 and rng.random() < 0.3:
            at = rng.randrange(2, len(target))
            states[at:at] = [target[: at - 1], target[:at]]
        typed.append(states)
    return typed


def typing(
    typed: list[list[str]], warm: list[str], mode: str, settled: bool = False
) -> str:
    """The probe that types `typed`; `mode` a view, "" the search of everything;
    `settled` when the sources already loaded, so it types at once."""
    return (
        TYPE.replace("SETTLE", "((_, then) => then())" if settled else "settle")
        .replace("SEQUENCES", json.dumps(json.dumps(typed)))
        .replace("WARM", json.dumps(json.dumps(warm)))
        .replace("MODE", json.dumps(mode))
        .replace("LOADED", LOADED)
    )


def measure(
    rev: str | None, typed: list[list[str]], warm: list[str], mode: str
) -> dict:
    """One sandbox's samples: time per keystroke and per source landing,
    garbage collection cycles and time, resident memory."""
    body = typing(typed, warm, mode)
    with sandbox(rev, GC_RULES) as instance:
        answer = instance.probe(body, timeout=600)
        rss = instance.rss()
        log = instance.lines()
    window = log[
        log.index(next(line for line in log if "BENCH-BEGIN" in line)) : next(
            index for index, line in enumerate(log) if "BENCH-END" in line
        )
    ]
    steps = [int(match[1]) for line in window if (match := STEP.search(line))]
    return {
        "times": answer["times"],
        "arrivals": answer["arrivals"],
        "gc cycles": sum("End GC" in line for line in window),
        "gc ms": sum(steps) / 1000,
        "rss": rss,
    }


def summary(runs: list[dict]) -> dict:
    """Statistics over the samples of every run together."""
    times = [time for run in runs for time in run["times"]]
    arrivals = [time for run in runs for time in run["arrivals"]]
    return {
        "keystrokes": len(times),
        "median ms": median(times),
        "p90 ms": quantiles(times, n=10)[8],
        "max ms": max(times),
        "mean ms": round(fmean(times), 2),
        "arrival median ms": median(arrivals),
        "arrival max ms": max(arrivals),
        "gc cycles/run": round(fmean(run["gc cycles"] for run in runs), 1),
        "gc ms/run": round(fmean(run["gc ms"] for run in runs), 1),
        "rss MB": round(fmean(run["rss"] for run in runs)),
    }


def keystrokes(rev: str, count: int, warm: int, mode: str, repeat: int = 1) -> None:
    """`repeat` runs each side that many times, alternating, so a slow moment
    of the machine falls on both."""
    rng = Random(11)
    typed = sequences(rng, count)
    warming = matcher_queries(texts(3000, rng), warm, rng)[:warm] if warm else []
    print(
        f"keystrokes: {sum(map(len, typed))} keystrokes in {len(typed)} queries in {mode or 'the search of everything'}, after {len(warming)} warm-up queries, {repeat} run(s) a side"
    )
    sides = ((rev, rev), ("working tree", None))
    runs: dict[str, list[dict]] = {label: [] for label, _ in sides}
    for _ in range(repeat):
        for label, target in sides:
            runs[label].append(measure(target, typed, warming, mode))
    width = max(map(len, runs))
    for label, measured in runs.items():
        print(
            f"  {label:<{width}}  "
            + "  ".join(f"{name} {value}" for name, value in summary(measured).items())
        )
