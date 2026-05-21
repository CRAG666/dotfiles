# Python 3.9 — Native Features

Python 3.9 was the cutoff for many idioms now considered "modern Python". If you're targeting 3.9
as the minimum, you can rely on all of the following.

---

## Built-in Generic Types (PEP 585)

You no longer need to import from `typing` to subscript built-ins.

```python
# 3.9+ — preferred
def lookup(rows: list[dict[str, int]]) -> tuple[int, ...]: ...

# Pre-3.9 — avoid in new code
from typing import List, Dict, Tuple
def lookup(rows: List[Dict[str, int]]) -> Tuple[int, ...]: ...
```

Affects: `list`, `dict`, `tuple`, `set`, `frozenset`, `type`, plus `collections.deque`,
`collections.OrderedDict`, `collections.defaultdict`, `collections.Counter`, `collections.ChainMap`,
`collections.abc.*`, `contextlib.AbstractContextManager`, `re.Pattern`, `re.Match`, etc.

---

## Dict Union Operators (PEP 584)

```python
a = {"x": 1, "y": 2}
b = {"y": 20, "z": 3}

merged = a | b           # {'x': 1, 'y': 20, 'z': 3}     ← new dict
a |= b                   # in-place merge
```

Replaces `{**a, **b}` and `a.update(b)` patterns. The `|` form preserves types — useful with
`defaultdict` and other dict subclasses. Note: `Counter | Counter` has multiset semantics
(max-union, not right-biased merge); see `collections.Counter` docs.

---

## `str.removeprefix` / `str.removesuffix` (PEP 616)

```python
"file.tar.gz".removesuffix(".gz")        # "file.tar"
"https://example.com".removeprefix("https://")   # "example.com"
```

Replaces the buggy idiom `s[len(prefix):] if s.startswith(prefix) else s`. The pre-3.9 form
silently strips an empty prefix to a different result.

---

## `functools.cache`

```python
from functools import cache

@cache
def fib(n: int) -> int:
    return n if n < 2 else fib(n-1) + fib(n-2)
```

Equivalent to `lru_cache(maxsize=None)`, slightly faster. Use for pure functions whose argument
space is bounded or whose memory cost is acceptable.

---

## `zoneinfo` — IANA Time Zones in the Stdlib (PEP 615)

```python
from zoneinfo import ZoneInfo
from datetime import datetime

dt = datetime(2026, 5, 20, 9, 0, tzinfo=ZoneInfo("America/Bogota"))
dt.astimezone(ZoneInfo("UTC"))
```

Replaces `pytz` for nearly all uses. No more `pytz.timezone(...).localize(...)`. On Windows install
`tzdata` package; on Linux/macOS the system zoneinfo is used.

---

## `graphlib.TopologicalSorter`

```python
from graphlib import TopologicalSorter

ts = TopologicalSorter({"build": {"compile"}, "compile": {"parse"}, "parse": set()})
list(ts.static_order())          # ['parse', 'compile', 'build']
```

Use for build orders, dependency resolution, plugin loading.

---

## `random.Random.randbytes`

```python
import random
random.randbytes(16)             # b'...'
```

For security tokens still use `secrets.token_bytes` instead.

---

## `os.pidfd_open` (Linux only)

Process descriptors — useful for race-free signaling of child processes.

---

## Other Notable Adds

- `ast.unparse(tree)` — turn an AST back into source code.
- `math.gcd` accepts arbitrary number of args; new `math.lcm`.
- `imp` module is officially deprecated — use `importlib`.

---

## What to Avoid on 3.9

Features introduced after 3.9 that you may NOT use unconditionally:

- `match` / `case` (3.10+)
- `X | Y` union annotations (3.10+ at runtime; `from __future__ import annotations` works for 3.9)
- `zip(..., strict=True)` (3.10+)
- `@dataclass(slots=, kw_only=)` (3.10+)
- `itertools.pairwise` (3.10+)
- Parenthesized context managers `with (a, b):` (3.10+)
- `tomllib`, `Self`, `StrEnum`, `TaskGroup`, `ExceptionGroup` (3.11+)
- `itertools.batched` (3.12+)

Use `sys.version_info` guards or import shims when you need a 3.10+ feature on 3.9.
