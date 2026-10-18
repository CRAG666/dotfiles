"""Real texts to search (bookmarks, notes, files, commands, browser history)
and queries made from them the way people type: prefixes, whole words,
initials, several words, typos. Seeded, so every run asks the same.
"""

import json
import re
import subprocess
from pathlib import Path
from random import Random

HELPER = Path(__file__).resolve().parents[1] / "helper"
LETTERS = "abcdefghijklmnopqrstuvwxyz"


def helper(*args: str) -> list[dict]:
    return json.loads(
        subprocess.run(
            ["python3", str(HELPER), *args], capture_output=True, text=True, check=True
        ).stdout
    )


def lines(*command: str) -> list[str]:
    output = subprocess.run(command, capture_output=True, text=True, check=True).stdout
    return [line for line in output.splitlines() if line]


def texts(limit: int, rng: Random) -> list[str]:
    """Up to `limit` distinct texts of every kind Spotlight searches."""
    library = [
        f"{entry['title']} {entry['category']} {entry['body'][:200]}"
        for kind in ("bookmarks", "notes")
        for entry in helper("list", kind)
    ]
    visits = [f"{visit['title']} {visit['url']}" for visit in helper("zen-history")]
    paths = lines("fd", "--max-results", "4000", ".", str(Path.home()))
    commands = lines("bash", "-c", "compgen -c | sort -u")
    pools = [library, visits, paths, commands]
    picked = {
        text
        for pool in pools
        for text in rng.sample(pool, min(len(pool), limit // len(pools)))
    }
    return sorted(picked)


def words(text: str) -> list[str]:
    return [word for word in re.split(r"[^\w]+", text.lower()) if word]


def edit(word: str, rng: Random, first: bool = False) -> str:
    """One substitution, insertion, deletion or swap; at the first letter if `first`."""
    at = 0 if first else rng.randrange(1, len(word))
    match rng.randrange(4):
        case 0:
            return word[:at] + rng.choice(LETTERS) + word[at + 1 :]
        case 1:
            return word[:at] + rng.choice(LETTERS) + word[at:]
        case 2:
            return word[:at] + word[at + 1 :]
        case _:
            at = min(at, len(word) - 2)
            return word[:at] + word[at + 1] + word[at] + word[at + 2 :]


def queries_for(title: str, rng: Random) -> dict[str, str]:
    """The ways of typing `title`, by kind; kinds that do not apply are left out."""
    parts = words(title)
    if not parts:
        return {}
    first, long = parts[0], [word for word in parts if len(word) >= 5]
    found = {"whole": " ".join(parts), "prefix2": first[:2], "prefix3": first[:3]}
    if len(first) >= 5:
        found["prefix5"] = first[:5]
    if len(parts) >= 2:
        found["initials"] = "".join(word[0] for word in parts)
        found["two-words"] = f"{parts[0][:3]} {parts[1][:3]}"
        found["second-word"] = parts[1][:4]
    if long:
        word = rng.choice(long)
        found["typo"] = edit(word, rng)
        found["typo-first-letter"] = edit(word, rng, first=True)
        if len(word) >= 8:
            found["two-typos"] = edit(edit(word, rng), rng)
    return found


def matcher_queries(corpus: list[str], count: int, rng: Random) -> list[str]:
    """Queries for comparing two matchers: every kind, plus noise and punctuation."""
    found = {
        query
        for text in rng.sample(corpus, min(len(corpus), count))
        for query in queries_for(text, rng).values()
    }
    found |= {
        "".join(rng.choices(LETTERS, k=rng.randrange(1, 8))) for _ in range(count // 10)
    }
    found |= {
        "dot-files",
        "conf.d",
        "2026",
        "v4l2",
        "fi re",
        "x y z",
        "c++",
        "é",
        "über",
        "ñandú",
    }
    return sorted(found)
