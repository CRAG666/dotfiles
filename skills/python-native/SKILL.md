---
name: python-native
description: 'Push Python stdlib idioms over hand-rolled code. Use whenever the user writes, refactors, optimizes, or reviews Python — including one-liners and code-review feedback. Replaces common reinventions: manual dict counters with `Counter`, `dict.setdefault` loops with `defaultdict`, `isinstance` chains with `singledispatch` or `match`/`case`, hand-rolled memoization with `functools.cache`, `os.path.join` with `pathlib.Path`, `sorted(..., reverse=True)[:k]` with `heapq.nlargest`, manual class boilerplate with `dataclass(slots=True, frozen=True)`, `zip(lst, lst[1:])` with `itertools.pairwise`. Covers Python 3.9-3.14 with per-version reference files. Trigger phrases: "write a Python function", "refactor this Python", "Pythonic way to X", "optimize Python code", "make this more Pythonic", "implement X in Python", or any task whose answer involves Python source.'
---

# Python Native: Use the Standard Library Before Writing Code

Python's standard library is one of the largest and most polished in any language. Most "utility"
code written by AI assistants — custom dispatch tables, ad-hoc memoization, manual grouping loops,
hand-rolled context managers, reinvented `namedtuple`s — is already a one-liner in the stdlib.

> **Core Principle**: Before writing a loop, a class, or a helper, ask:
> *"Is this already in `functools`, `itertools`, `collections`, `operator`, or `contextlib`?"*
> The answer is "yes" more often than not. **Check the stdlib first.**

---

## 0. The Mental Checklist (Run This Before Writing Any Python)

Every time you're about to write Python, walk this checklist:

1. **Loop building up a dict/list/set?** → `collections.Counter`, `defaultdict`, comprehension, or `itertools`.
2. **Dispatching on type or value?** → `functools.singledispatch` or `match`/`case` (3.10+).
3. **Caching results of a pure function?** → `functools.cache` (3.9+) or `lru_cache`.
4. **Sorting/finding by an attribute or key?** → `operator.itemgetter` / `attrgetter`, not `lambda`.
5. **Combining or slicing iterables?** → `itertools.chain`, `islice`, `pairwise`, `batched`.
6. **Managing setup/teardown?** → `contextlib.contextmanager`, `ExitStack`, `suppress`, `nullcontext`.
7. **Holding plain data?** → `dataclasses.dataclass`, `typing.NamedTuple`, or `types.SimpleNamespace`.
8. **Enumerations or flags?** → `enum.Enum`, `IntEnum`, `Flag`, `StrEnum` (3.11+).
9. **Filesystem paths?** → `pathlib.Path`, never `os.path` string juggling.
10. **Priority queue / k-smallest / k-largest?** → `heapq.nsmallest`, `nlargest`, `heappush`.
11. **Sorted insertion / binary search?** → `bisect.insort`, `bisect_left`, `bisect_right`.
12. **Running statistics?** → `statistics.mean`, `median`, `stdev`, `fmean`, `correlation`.
13. **Cryptographic / token / password use?** → `secrets`, never `random`.
14. **Random sampling without replacement?** → `random.sample` (not a manual loop).
15. **Need an iterator-aware helper?** → `itertools.tee`, `accumulate`, `starmap`, `groupby`.

If any answer is "yes", **stop and use the stdlib feature**. Reinventing it is a code smell.

---

## 1. `functools` — The Most Under-Used Module

### 1.1 `singledispatch` — Polymorphism Without Class Hierarchies

Replace long `isinstance` chains and visitor patterns with type-dispatched functions.

```python
from functools import singledispatch

@singledispatch
def serialize(value):
    raise TypeError(f"Cannot serialize {type(value).__name__}")

@serialize.register
def _(value: int) -> str:
    return str(value)

@serialize.register
def _(value: list) -> str:
    return "[" + ", ".join(serialize(v) for v in value) + "]"

@serialize.register(dict)
def _(value):
    return "{" + ", ".join(f"{k}:{serialize(v)}" for k, v in value.items()) + "}"
```

For instance methods, use `singledispatchmethod`:

```python
from functools import singledispatchmethod

class Renderer:
    @singledispatchmethod
    def render(self, node):
        raise NotImplementedError

    @render.register
    def _(self, node: str):
        return f"<text>{node}</text>"

    @render.register
    def _(self, node: list):
        return "".join(self.render(child) for child in node)
```

> **AI anti-pattern**: writing `if isinstance(x, int): ... elif isinstance(x, list): ...`.
> Use `singledispatch`. It's discoverable, extensible by registration, and removes the chain.

### 1.2 `cache` and `lru_cache` — Memoization in One Decorator

```python
from functools import cache, lru_cache

@cache                      # Python 3.9+, unbounded
def fib(n: int) -> int:
    return n if n < 2 else fib(n - 1) + fib(n - 2)

@lru_cache(maxsize=1024)    # bounded cache for hot paths
def expensive(query: str) -> bytes:
    ...
```

- `cache` = `lru_cache(maxsize=None)`, slightly faster — use it when memory is not a concern.
- Arguments must be hashable. Use `frozenset`, `tuple`, or convert before calling.
- `.cache_info()` and `.cache_clear()` are available on both.

### 1.3 `cached_property` — Lazy, Memoized Attributes

```python
from functools import cached_property

class Dataset:
    def __init__(self, path):
        self.path = path

    @cached_property
    def rows(self):
        return self._load()    # runs once, then stored as instance attribute
```

- Stored in `__dict__`, so it works only on classes without `__slots__` (unless you include `__dict__`).
- Replace `@property` + manual `_cache` attribute pattern entirely.

### 1.4 `partial` and `partialmethod` — Freezing Arguments

```python
from functools import partial

read_utf8 = partial(open, encoding="utf-8")
debug_log = partial(logger.log, logging.DEBUG)

# Use in callbacks and maps:
sorted(items, key=partial(score, weights=w))
```

Better than `lambda` because it's introspectable (has `.func`, `.args`, `.keywords`).

### 1.5 `reduce` — Last Resort for Accumulators

`reduce` is rarely needed: `sum`, `min`, `max`, `any`, `all`, `math.prod` cover most cases.

```python
from functools import reduce
from math import prod

prod([1, 2, 3, 4])          # → 24 (prefer this)
reduce(lambda a, b: a * b, [1, 2, 3, 4])  # works, but verbose
```

Use `reduce` only when the operation is genuinely non-builtin **and** a generator/loop wouldn't be clearer.

### 1.6 `wraps`, `total_ordering`, `reduce`

```python
from functools import wraps, total_ordering

def trace(fn):
    @wraps(fn)                          # preserves __name__, __doc__, __module__
    def inner(*args, **kw):
        print(fn.__name__, args, kw)
        return fn(*args, **kw)
    return inner

@total_ordering                          # Define __eq__ and one of <, <=, >, >= — get the rest for free
class Version:
    def __init__(self, parts): self.parts = parts
    def __eq__(self, other): return self.parts == other.parts
    def __lt__(self, other): return self.parts < other.parts
```

---

## 2. `itertools` — The Iterator Algebra

Iterators are O(1) memory. Use these primitives instead of building lists and re-iterating.

### 2.1 Combining Iterables

```python
from itertools import chain, zip_longest, product

list(chain([1, 2], [3, 4], [5]))                     # [1, 2, 3, 4, 5]
list(chain.from_iterable([[1, 2], [3, 4]]))          # [1, 2, 3, 4]   ← flatten one level
list(zip_longest("ABCD", "12", fillvalue="-"))       # [('A','1'),('B','2'),('C','-'),('D','-')]
list(product([0, 1], repeat=3))                      # all 3-bit tuples
```

### 2.2 Slicing and Windowing

```python
from itertools import islice, takewhile, dropwhile, pairwise   # pairwise: 3.10+

islice(iterable, 10)                  # first 10 elements lazily — works on generators
list(pairwise([1, 2, 3, 4]))          # [(1,2), (2,3), (3,4)]
list(takewhile(lambda x: x < 5, [1, 3, 5, 2]))    # [1, 3]
```

For Python 3.12+: `itertools.batched(iterable, n)` chunks an iterable into n-tuples.

### 2.3 Grouping (Replaces Manual `defaultdict` Loops)

```python
from itertools import groupby
from operator import itemgetter

rows = sorted(rows, key=itemgetter("dept"))     # groupby requires sorted input!
for dept, group in groupby(rows, key=itemgetter("dept")):
    print(dept, list(group))
```

> **Common bug**: forgetting that `groupby` only groups **adjacent** equal keys. Sort first.

### 2.4 Accumulators and Counters

```python
from itertools import accumulate, count, cycle, repeat

list(accumulate([1, 2, 3, 4]))                      # [1, 3, 6, 10]   running sum
list(accumulate([1, 2, 3, 4], initial=100))         # [100, 101, 103, 106, 110]
list(accumulate([3, 1, 4, 1, 5], max))              # [3, 3, 4, 4, 5]  running max

for i in count(start=1):  ...                       # unbounded counter
for color in cycle(["r", "g", "b"]):  ...           # infinite cycle
```

### 2.5 Combinations and Permutations

```python
from itertools import combinations, permutations, combinations_with_replacement

list(combinations("ABC", 2))           # [('A','B'), ('A','C'), ('B','C')]
list(permutations("ABC", 2))           # [('A','B'),('A','C'),('B','A'),...]
```

Replace any nested loop that filters duplicates with the right combinatoric primitive.

### 2.6 `tee` and `starmap`

```python
from itertools import tee, starmap

a, b = tee(iterator)                       # split one iterator into two independent ones
list(starmap(pow, [(2, 3), (10, 2)]))      # [8, 100]   — like map() but unpacks each tuple
```

---

## 3. `collections` — Data Structures You Should Default To

### 3.1 `Counter` — Frequency Counting in One Line

```python
from collections import Counter

c = Counter("abracadabra")              # Counter({'a': 5, 'b': 2, 'r': 2, ...})
c.most_common(3)                        # [('a', 5), ('b', 2), ('r', 2)]
c + Counter("aaa")                      # multiset addition
c & Counter("abxxx")                    # multiset intersection
+c                                      # drop zero/negative counts
```

> **AI anti-pattern**: `freq = {}; for x in xs: freq[x] = freq.get(x, 0) + 1`. **Use `Counter(xs)`.**

### 3.2 `defaultdict` — Auto-Initialized Dicts

```python
from collections import defaultdict

groups = defaultdict(list)
for user, action in events:
    groups[user].append(action)

graph = defaultdict(set)
for a, b in edges:
    graph[a].add(b)
    graph[b].add(a)
```

Replaces the `dict.setdefault` pattern and the `if key not in d: d[key] = []` antipattern.

### 3.3 `deque` — O(1) Append/Pop at Both Ends

```python
from collections import deque

q = deque(maxlen=1000)                  # bounded ring buffer — drops oldest on overflow
q.appendleft(x); q.pop(); q.rotate(-1)
```

Use `deque` for:
- BFS queues
- Sliding windows
- Rolling logs / ring buffers (`maxlen`)
- Any FIFO — `list.pop(0)` is O(n).

### 3.4 `ChainMap` — Layered Lookups

```python
from collections import ChainMap

config = ChainMap(cli_args, env_vars, defaults)    # lookup falls through in order
```

Avoid manually merging dicts to implement precedence; `ChainMap` does it without copying.

### 3.5 `namedtuple` (and Why Often `dataclass` Wins)

```python
from collections import namedtuple

Point = namedtuple("Point", "x y")
p = Point(3, 4)
p.x, p.y, p._asdict(), p._replace(x=10)
```

- Use `namedtuple` for immutable lightweight records.
- Use `typing.NamedTuple` for type hints.
- Use `dataclass(frozen=True, slots=True)` when you want defaults, methods, or richer behavior.

---

## 4. `operator` — Functions for Operators

Replaces tiny lambdas with introspectable, pickleable callables.

```python
from operator import itemgetter, attrgetter, methodcaller, mul

sorted(people, key=attrgetter("age"))                   # vs. lambda p: p.age
sorted(rows, key=itemgetter("dept", "salary"))          # multi-key
list(map(methodcaller("strip"), lines))                 # vs. lambda s: s.strip()
list(map(mul, xs, ys))                                  # elementwise multiply
```

- `itemgetter("a", "b")` returns a tuple — useful for sort keys.
- `methodcaller("split", ",")` is callable; great in `map`, `filter`, `sort`.

---

## 5. `contextlib` — Context Managers Beyond `with open(...)`

### 5.1 `@contextmanager` — Build One in 4 Lines

```python
from contextlib import contextmanager

@contextmanager
def timer(label):
    start = time.perf_counter()
    try:
        yield
    finally:
        print(f"{label}: {time.perf_counter() - start:.3f}s")

with timer("load"):
    data = load()
```

### 5.2 `suppress`, `nullcontext`, `closing`, `redirect_stdout`

```python
from contextlib import suppress, nullcontext, closing, redirect_stdout
import io

with suppress(FileNotFoundError):
    os.remove(path)                          # silently no-op if missing

cm = open(path) if log else nullcontext()    # uniform `with` without branching
with cm as f: ...

with closing(urllib.request.urlopen(url)) as resp: ...

buf = io.StringIO()
with redirect_stdout(buf):
    noisy_function()
```

### 5.3 `ExitStack` — Dynamic Stacks of Context Managers

```python
from contextlib import ExitStack

with ExitStack() as stack:
    files = [stack.enter_context(open(p)) for p in paths]   # any number, any order
    process(files)
```

Replaces deeply nested `with` blocks and conditional setup/teardown.

---

## 6. `dataclasses` — The Right Default for Data Classes

```python
from dataclasses import dataclass, field, asdict, replace

@dataclass(frozen=True, slots=True, kw_only=True)        # slots, kw_only: 3.10+
class Order:
    id: int
    items: list[str] = field(default_factory=list)
    total: float = 0.0

o = Order(id=1, items=["a", "b"], total=9.99)
o2 = replace(o, total=10.5)                              # functional update
asdict(o)                                                # → plain dict
```

- `frozen=True` → hashable, safe in sets/dict keys.
- `slots=True` → smaller memory, faster attribute access, no accidental new attrs.
- `kw_only=True` → forces keyword args; prevents positional-arg bugs.
- `field(default_factory=list)` → never use a mutable default directly.

For inherited or computed fields, use `field(init=False, default=...)` and `__post_init__`.

---

## 7. `pathlib` — Stop Using `os.path` Strings

```python
from pathlib import Path

p = Path("/var/log") / "app" / "today.log"          # join with /
p.parent, p.name, p.stem, p.suffix
p.exists(), p.is_file(), p.with_suffix(".bak")
p.read_text(encoding="utf-8")
p.write_text("hello")
list(p.parent.glob("*.log"))
list(p.parent.rglob("*.py"))
Path.home(), Path.cwd()
```

`pathlib` is OS-agnostic, returns rich objects, and supports operators. There is no good reason
to use `os.path.join` in new code.

---

## 8. `heapq` and `bisect` — Specialized Algorithms

### 8.1 `heapq` — Priority Queues and Top-K

```python
import heapq

heap = []
for x in xs:
    heapq.heappush(heap, x)
smallest = heapq.heappop(heap)

heapq.nsmallest(5, items, key=lambda x: x.cost)         # O(n log k), not full sort
heapq.nlargest(10, scores)
```

> **AI anti-pattern**: `sorted(xs)[:k]` to get the k smallest. Use `nsmallest(k, xs)` — O(n log k).

### 8.2 `bisect` — Sorted Lists Without Re-Sorting

```python
import bisect

bisect.insort(sorted_list, value)              # insert keeping sort order
i = bisect.bisect_left(sorted_list, value)     # leftmost insertion point
j = bisect.bisect_right(sorted_list, value)    # rightmost — count = j - i
```

Use `bisect` for sorted in-memory indexes, range queries, and rank lookups.

---

## 9. `enum` — Real Enumerations

```python
from enum import Enum, IntEnum, Flag, auto

class Status(Enum):
    PENDING = auto()
    ACTIVE = auto()
    DONE = auto()

class Permission(Flag):
    READ = auto()
    WRITE = auto()
    EXEC = auto()
    ALL = READ | WRITE | EXEC

Permission.READ | Permission.WRITE   # composable bitfield
```

- Use `Enum` for closed sets of named constants.
- Use `IntEnum` only when integer interop matters.
- Use `StrEnum` (3.11+) for string-based enums (no manual `.value` everywhere).
- Use `Flag` / `IntFlag` for bitfields.

---

## 10. `typing` — Use the Modern Forms

```python
from typing import Protocol, NamedTuple, TypedDict, Literal, Annotated, Self, TypeAlias

# Structural typing — duck typing with checking
class Closeable(Protocol):
    def close(self) -> None: ...

# Lightweight schema for dicts
class User(TypedDict):
    id: int
    name: str

# Constrain accepted values
Mode = Literal["r", "w", "a"]

# Builder pattern with self-type (3.11+)
class Query:
    def where(self, **kw) -> Self: ...
    def order_by(self, key) -> Self: ...
```

- Built-in generics: `list[int]`, `dict[str, int]`, `tuple[int, ...]` (3.9+) — no need for `List`, `Dict`.
- `X | Y` union syntax (3.10+) replaces `Union[X, Y]`. `X | None` replaces `Optional[X]`.
- `TypeAlias` (3.10+) for documented aliases; `type` statement (3.12+).

---

## 11. `match` / `case` — Structural Pattern Matching (3.10+)

```python
def evaluate(node):
    match node:
        case {"op": "add", "left": l, "right": r}:
            return evaluate(l) + evaluate(r)
        case [first, *rest]:
            return [evaluate(first), *map(evaluate, rest)]
        case int() | float():
            return node
        case Point(x=0, y=y):
            return f"on y-axis at {y}"
        case _:
            raise ValueError(node)
```

- Patterns include literals, types, sequences, mappings, class patterns, OR (`|`), guards (`if`).
- Names in patterns **bind** — `case x:` matches anything and binds. Use `case _:` for wildcard.
- Use class patterns to destructure dataclasses by attribute.

---

## 12. Walrus Operator (`:=`) — Use Where It Reduces Repetition

```python
# Read in chunks until EOF
while chunk := f.read(4096):
    process(chunk)

# Reuse a computed value in a comprehension
results = [(x, y) for x in xs if (y := compute(x)) is not None]

# Avoid double-call in an if
if (match := pattern.search(line)) is not None:
    use(match.group(1))
```

Don't use it just to be clever; use it when it removes a duplicated computation.

---

## 13. f-strings — Use the Full Format Spec

```python
f"{value:>10.2f}"          # right-aligned, width 10, 2 decimals
f"{value:,.0f}"            # thousands separators
f"{value:.2%}"             # percent
f"{n:#06x}"                # 0x00ff
f"{name!r}"                # repr()
f"{obj=}"                  # → "obj=<value>"  (3.8+, great for debug)
f"{dt:%Y-%m-%d}"           # datetime format
f"{a + b = :,}"            # debug + format spec combined
```

Multi-line f-strings (3.12+) allow nested same-quote strings:

```python
f"{ ', '.join(f'{x.name!r}' for x in items) }"
```

---

## 14. Generators and Comprehensions

- Prefer **generator expressions** for one-shot iteration: `sum(x*x for x in xs)` — no list built.
- Use `yield from` for delegation: `yield from inner()` is equivalent to a `for` loop.
- A function with `yield` is already an iterator; no class needed.
- Generators are O(1) memory — chain them with `itertools.chain` for streaming pipelines.

```python
def lines_of(path):
    with open(path) as f:
        yield from f                       # yields lines lazily

def non_empty(it):
    return (line.strip() for line in it if line.strip())

for line in non_empty(lines_of("big.txt")):
    process(line)
```

---

## 15. Built-in Functions That Are Often Forgotten

| Function | What it does that you might re-implement |
|---|---|
| `any(p(x) for x in xs)` | Short-circuit "exists" — don't loop and return early manually. |
| `all(...)` | Short-circuit "for all". |
| `sum(iter, start)` | Note the `start` arg — works for non-numeric monoids too. Use `math.prod` for products. |
| `min(iter, key=, default=)` / `max(...)` | Use `key=` instead of pre-sorting. `default=` for empty iterables. |
| `sorted(iter, key=, reverse=)` | Stable sort. `key` is computed once per element. |
| `reversed(iter)` | O(1) lazy iterator — don't slice `[::-1]` if you only iterate. |
| `enumerate(iter, start=N)` | Pass `start=` instead of `i + offset`. |
| `zip(*iters, strict=True)` | `strict=True` (3.10+) raises on length mismatch — use it. |
| `divmod(a, b)` | Returns `(quotient, remainder)` — replaces two operations. |
| `pow(b, e, mod)` | Modular exponentiation — vastly faster than `(b**e) % mod`. |
| `round(x, n)` | Banker's rounding by default; pass `ndigits` for precision. |
| `iter(callable, sentinel)` | Loops calling `callable()` until it returns `sentinel`. |
| `next(iter, default)` | Pass a default to avoid `StopIteration` handling. |
| `vars(obj)` | Inspect attributes — sometimes simpler than `__dict__`. |
| `getattr(obj, name, default)` | Don't try/except `AttributeError` — pass `default`. |
| `hash(x)` | Test hashability quickly. |
| `id(x)` / `is` | Identity, not equality. Don't use `==` for `None` / singletons. |

---

## 16. Other Stdlib Modules Worth Reaching For

| Module | Use when… |
|---|---|
| `statistics` | Mean, median, stdev, mode, correlation, linear regression — no need for NumPy on small data. |
| `math` | `gcd`, `lcm`, `isclose`, `prod`, `comb`, `perm`, `hypot`. |
| `secrets` | Tokens, passwords, anything security-sensitive. Never `random` here. |
| `random` | Non-security randomness. Use `random.choices` (weighted), `sample` (no replacement). |
| `hashlib` | Hashing. Use `hashlib.file_digest` (3.11+) for streaming file hashes. |
| `struct` | Pack/unpack binary data. |
| `io.StringIO`, `io.BytesIO` | In-memory file-like objects for testing or pipelines. |
| `tempfile` | `TemporaryDirectory`, `NamedTemporaryFile`. Don't hand-roll temp files. |
| `shutil` | File ops (`copy`, `move`, `rmtree`, `which`, `make_archive`). |
| `subprocess` | `subprocess.run(..., check=True, capture_output=True, text=True)`. |
| `argparse` | Don't parse `sys.argv` by hand. |
| `logging` | Use the logging tree — don't sprinkle `print()`. |
| `json` | Use `default=` hook for custom serializers; `indent=2` for human output. |
| `csv` | `csv.DictReader` / `DictWriter` — never `split(",")`. |
| `sqlite3` | Built-in DB. Great for caches, tests, prototypes. |
| `concurrent.futures` | `ThreadPoolExecutor` / `ProcessPoolExecutor` — don't manage threads by hand. |
| `asyncio` | `asyncio.run`, `gather`, `TaskGroup` (3.11+), `to_thread`. |
| `weakref` | `WeakValueDictionary`, `WeakSet` — caches that don't keep objects alive. |
| `types.SimpleNamespace` | Quick attribute-bag without defining a class. |
| `types.MappingProxyType` | Read-only view of a dict. |
| `abc` | `ABC`, `@abstractmethod` for interfaces. |
| `dataclasses` | See §6. |
| `typing` | See §10. |
| `textwrap` | `dedent`, `indent`, `fill`, `shorten`. |
| `string` | `string.Template`, `string.ascii_letters`, `digits`, `Formatter`. |
| `unicodedata` | Normalize, categorize, strip accents. |
| `decimal` | Exact decimal arithmetic (money). Never use `float` for currency. |
| `fractions` | Exact rationals. |
| `ipaddress` | Parse and manipulate IPs/networks; don't regex them. |
| `urllib.parse` | URL parsing / encoding; don't string-manipulate URLs. |
| `inspect` | Introspect signatures, source, callables. |
| `traceback` | Format/print tracebacks programmatically. |
| `pprint` | Readable structure dumps. |

---

## 17. Things AI Routinely Reinvents (Stop Doing These)

| Reinvention | Replace with |
|---|---|
| Manual `freq = {}` loop | `Counter(iterable)` |
| `dict.setdefault(k, []).append(v)` | `defaultdict(list)` |
| `if x not in d: d[x] = …` | `dict.setdefault` or `defaultdict` |
| `sorted(x)[:k]` for top-k | `heapq.nsmallest(k, x)` |
| `list.pop(0)` for queues | `collections.deque` |
| `isinstance` chains | `functools.singledispatch` or `match` |
| `lambda p: p.attr` for sort | `operator.attrgetter("attr")` |
| Hand-rolled memo dict | `functools.cache` / `lru_cache` |
| Hand-rolled context manager class | `@contextlib.contextmanager` |
| Manual flattening with nested loops | `itertools.chain.from_iterable` |
| Manual pairwise loop | `itertools.pairwise` (3.10+) |
| Manual chunking loop | `itertools.batched` (3.12+) |
| Hand-rolled `Result`/`Maybe` for dispatch | `match` / `case` |
| `class Foo: __init__: self.x=x; self.y=y; __repr__=...` | `@dataclass` |
| `os.path.join(...)` strings | `pathlib.Path(...)` |
| Manual `try/except` for "absent file" deletion | `contextlib.suppress(FileNotFoundError)` |
| Hand-rolled CLI parsing | `argparse` |
| `random.SystemRandom()` for tokens | `secrets.token_urlsafe(n)` |

---

## 18. Version Support Strategy (3.9 → 3.14)

This skill works on Python 3.9+. When a feature is newer, prefer it on supported versions but fall
back to the stdlib equivalent on older ones. **Always check the target's Python version first.**

- Look in `references/python-3.X.md` for the precise list of features introduced or changed.
- When unsure of version: `python --version`, or read `pyproject.toml` (`requires-python`).
- Use `sys.version_info >= (3, 11)` for runtime branches; do not rely on `try/except ImportError`
  unless the feature actually moved between modules.

### Compatibility Cheat-Sheet (Highlights)

| Feature | Introduced |
|---|---|
| `functools.cache`, `dict \| dict` merge, `removeprefix/suffix`, built-in generics (`list[int]`) | 3.9 |
| `match` / `case`, `X \| Y` unions, `zip(strict=True)`, `dataclass(slots=, kw_only=)`, `itertools.pairwise`, parenthesized context managers | 3.10 |
| `tomllib`, `ExceptionGroup`, `except*`, `Self`, `StrEnum`, `TaskGroup`, `hashlib.file_digest`, exception notes (`__notes__`) | 3.11 |
| `itertools.batched`, `type` statement, PEP 695 generics, `@override`, PEP 701 f-strings, per-interpreter GIL (PEP 684), comprehension inlining, `pathlib.Path.walk`, `random.binomialvariate` | 3.12 |
| Free-threaded build (PEP 703 experimental), JIT (PEP 744 experimental), `dbm.sqlite3`, new REPL, `itertools.batched(strict=)`, `copy.replace`, `typing.TypeIs`/`ReadOnly`, TypeVar defaults (PEP 696), `os.process_cpu_count`, removal of 19 dead-battery modules | 3.13 |
| Deferred annotations (PEP 649) + `annotationlib`, t-strings (PEP 750), `concurrent.interpreters` (PEP 734), `InterpreterPoolExecutor`, free-threaded officially supported (PEP 779), `pathlib.Path.copy`/`move` | 3.14 |

See the `references/` directory for the full feature list per version.

---

## 19. Reference Files

For per-version deep dives, consult:

- `references/python-3.9.md`  — built-in generics, `cache`, `removeprefix/suffix`, dict union
- `references/python-3.10.md` — `match`/`case`, `X | Y`, `zip(strict=)`, `dataclass(slots=)`, parenthesized `with`
- `references/python-3.11.md` — `ExceptionGroup`, `Self`, `StrEnum`, `tomllib`, `TaskGroup`, fine-grained tracebacks
- `references/python-3.12.md` — PEP 695 generics, `type` statement, `@override`, `itertools.batched`
- `references/python-3.13.md` — free-threaded build, JIT, `dbm.sqlite3`, removals
- `references/python-3.14.md` — PEP 649 deferred annotations + `annotationlib`, t-strings (PEP 750), `concurrent.interpreters` (PEP 734), PEP 779 free-threaded official, `pathlib.Path.copy`/`move`
- `references/stdlib-decision-tree.md` — "I want to do X; which module?" lookup table
- `references/anti-patterns.md` — full catalog organized by Correctness / Maintainability / Readability / Performance / Security, expanded from QuantifiedCode's *Python Anti-Patterns* book and modernized for Python 3.9+

---

## Sources

Content in this skill was verified against the official "What's New in Python" pages:

- Python 3.9:  https://docs.python.org/3/whatsnew/3.9.html
- Python 3.10: https://docs.python.org/3/whatsnew/3.10.html
- Python 3.11: https://docs.python.org/3/whatsnew/3.11.html
- Python 3.12: https://docs.python.org/3/whatsnew/3.12.html
- Python 3.13: https://docs.python.org/3/whatsnew/3.13.html
- Python 3.14: https://docs.python.org/3/whatsnew/3.14.html

For PEPs: https://peps.python.org/  (e.g. PEP 585 → https://peps.python.org/pep-0585/).
For module references: https://docs.python.org/3/library/<module>.html.

---

## Quick Reference Card

```
BEFORE writing a loop:        Can it be a comprehension / itertools call?
BEFORE writing a class:       Can it be @dataclass / NamedTuple / SimpleNamespace?
BEFORE writing isinstance:    Can it be singledispatch / match?
BEFORE writing a cache dict:  Use functools.cache.
BEFORE writing os.path:       Use pathlib.Path.
BEFORE writing lambda key:    Use operator.itemgetter / attrgetter.
BEFORE writing try/except:    Use contextlib.suppress where applicable.
BEFORE manual freq counting:  Use collections.Counter.
BEFORE list.pop(0):           Use collections.deque.
BEFORE sorted(...)[:k]:       Use heapq.nsmallest.
WHEN dispatching:             functools.singledispatch or match/case.
WHEN in doubt:                Search the stdlib index before writing code.
```
