"""How well the search of everything ranks what was meant. Every item it can
show (apps, bookmarks, notes, commands, snippets, quicklinks, SSH hosts) is
asked for the ways people type it, and its place in the results is scored:
Top-1, Top-3 and MRR@10 per kind of query. Random strings measure the noise:
how many results that are no fallback they still bring. queries.json, when
present, adds hand-written queries with the key each one should find.
"""

import json
from collections import Counter, defaultdict
from pathlib import Path
from random import Random
from statistics import fmean

from corpus import LETTERS, queries_for
from equivalence import LOADED
from sandbox import sandbox

CURATED = Path(__file__).with_name("queries.json")
FALLBACKS = {"Web", "AI"}

TARGETS = """
const pick = list => list.map(item => ({ key: item.key, title: item.title }));
done([
    ...pick(apps.items("")), ...pick(library.bookmarkItems([])), ...pick(library.noteItems([])),
    ...pick(win.commandItems([])), ...pick(snippets.snippetItems([])), ...pick(web.quicklinkItems([], "")), ...pick(ssh.items([]))
]);
"""

RANKS = """
const asked = JSON.parse(QUERIES);
const noise = JSON.parse(NOISE);
loadAll();
settle(() => LOADED, () => {
    const flat = query => [].concat(...win.everything(tokens(query), query).map(([section, list]) => list.map(item => [section, item.key])));
    const ranks = asked.map(({ query, expect }) => flat(query).findIndex(([, key]) => key === expect) + 1);
    const noiseCounts = noise.map(query => flat(query).filter(([section]) => !FALLBACKS.includes(section)).length);
    done({ ranks, noiseCounts });
});
"""


def targets(rev: str | None) -> list[dict]:
    with sandbox(rev) as instance:
        instance.probe(
            "loadAll();\nsettle(() => [library.bookmarkItems([]).length, ssh.items([]).length, Apps.indexed.length], () => done(true));"
        )
        found = instance.probe(TARGETS)
    titles = Counter(target["title"].lower() for target in found)
    return [target for target in found if titles[target["title"].lower()] == 1]


def asked(found: list[dict], rng: Random) -> list[dict]:
    generated = [
        {"query": query, "kind": kind, "expect": target["key"]}
        for target in found
        for kind, query in queries_for(target["title"], rng).items()
    ]
    curated = json.loads(CURATED.read_text()) if CURATED.exists() else []
    return generated + [entry | {"kind": "curated"} for entry in curated]


def ranks(rev: str | None, queries: list[dict], noise: list[str]) -> dict:
    body = (
        RANKS.replace("QUERIES", json.dumps(json.dumps(queries)))
        .replace("NOISE", json.dumps(json.dumps(noise)))
        .replace("FALLBACKS", json.dumps(sorted(FALLBACKS)))
        .replace("LOADED", LOADED)
    )
    with sandbox(rev) as instance:
        return instance.probe(body, timeout=900)


def metrics(places: list[int]) -> dict:
    return {
        "n": len(places),
        "top1": round(fmean(place == 1 for place in places), 3),
        "top3": round(fmean(0 < place <= 3 for place in places), 3),
        "mrr10": round(
            fmean(1 / place if 0 < place <= 10 else 0 for place in places), 3
        ),
    }


def precision(rev: str) -> dict:
    rng = Random(5)
    found = targets(None)
    queries = asked(found, rng)
    noise = ["".join(rng.choices(LETTERS, k=rng.randrange(4, 7))) for _ in range(200)]
    print(
        f"precision: {len(found)} targets, {len(queries)} queries, {len(noise)} noise strings"
    )
    report = {}
    for label, target in ((rev, rev), ("working tree", None)):
        answer = ranks(target, queries, noise)
        by_kind = defaultdict(list)
        for entry, place in zip(queries, answer["ranks"], strict=True):
            by_kind[entry["kind"]].append(place)
        report[label] = {
            "all": metrics(answer["ranks"]),
            **{kind: metrics(places) for kind, places in sorted(by_kind.items())},
            "noise results": round(fmean(answer["noiseCounts"]), 2),
        }
    kinds = list(report["working tree"])
    for kind in kinds:
        print(
            f"  {kind:<18}"
            + "".join(f"  {label}: {report[label].get(kind)}" for label in report)
        )
    return report
