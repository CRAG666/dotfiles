# Python Anti-Patterns

A catalog of common Python code that should be replaced with stdlib idioms or modern syntax.

Each entry is structured: **anti-pattern → why bad → modern fix**.

---

## 1. Correctness — Code That's Wrong or Fragile

### 1.1 Shadowing built-in names

```python
# Anti-pattern — overwrites the built-in `list`
list = [1, 2, 3]
cars = list()                  # TypeError: 'list' object is not callable

# Fix
numbers = [1, 2, 3]
cars = list()
```

Common offenders to avoid as variable names: `list`, `dict`, `set`, `tuple`, `type`, `id`,
`input`, `filter`, `map`, `str`, `bytes`, `len`, `range`, `min`, `max`, `sum`, `open`,
`format`, `vars`, `dir`, `next`, `iter`, `object`, `all`, `any`.

### 1.2 Assigning a `lambda` to a name

```python
# Anti-pattern — name shows as <lambda> in tracebacks
double = lambda x: 2 * x

# Fix — proper def
def double(x: int) -> int:
    return 2 * x
```

Use `lambda` only inline (sort keys, callbacks). If you're naming it, use `def`.

### 1.3 Bad `except` clause order

```python
# Anti-pattern — ZeroDivisionError is unreachable (shadowed by base class)
try:
    1 / 0
except Exception as e:
    ...
except ZeroDivisionError as e:    # never runs
    ...

# Fix — specific to general
try:
    1 / 0
except ZeroDivisionError as e:
    ...
except Exception as e:
    ...
```

Python 3.11+: for parallel exceptions, consider `ExceptionGroup` and `except*`.

### 1.4 Bare `except:` (no type)

```python
# Anti-pattern — swallows KeyboardInterrupt, SystemExit, MemoryError, etc.
try:
    result = a / b
except:
    result = None

# Fix — name what you handle
try:
    result = a / b
except ZeroDivisionError:
    result = None
```

`Exception` (not `BaseException`) is the widest sensible catch. Prefer specific exception types.

### 1.5 Mutable default arguments

```python
# Anti-pattern — the list is created ONCE, shared across all calls
def append(item, target=[]):
    target.append(item)
    return target

append(1)   # [1]
append(2)   # [1, 2]   ← surprise

# Fix — sentinel
def append(item, target=None):
    if target is None:
        target = []
    target.append(item)
    return target

# For dataclasses, use field(default_factory=...)
from dataclasses import dataclass, field

@dataclass
class Box:
    items: list[str] = field(default_factory=list)
```

### 1.6 Explicit `return` in `__init__`

```python
# Anti-pattern — TypeError at construction
class Rectangle:
    def __init__(self, w, h):
        self.area = w * h
        return self.area

# Fix — compute lazily
from functools import cached_property

class Rectangle:
    def __init__(self, w, h):
        self.w, self.h = w, h

    @cached_property
    def area(self):
        return self.w * self.h
```

`__init__` must implicitly return `None`. Move computed values to a property or method.

### 1.7 Wrong `__exit__` signature

```python
# Anti-pattern — wrong arity means __exit__ is silently never called on error
class Resource:
    def __enter__(self): ...
    def __exit__(self):                          # bug
        cleanup()

# Fix — exactly three args plus self
class Resource:
    def __enter__(self): ...
    def __exit__(self, exc_type, exc_value, traceback):
        cleanup()

# Better — use @contextmanager
from contextlib import contextmanager

@contextmanager
def resource():
    handle = setup()
    try:
        yield handle
    finally:
        teardown(handle)
```

### 1.8 Java-style getters and setters

```python
# Anti-pattern — Java in Python
class Square:
    def __init__(self, length):
        self._length = length
    def get_length(self):
        return self._length
    def set_length(self, value):
        self._length = value

# Fix 1 — just expose the attribute
class Square:
    def __init__(self, length):
        self.length = length

# Fix 2 — @property when validation/derivation is actually needed
class Square:
    def __init__(self, length):
        self.length = length
    @property
    def length(self):
        return self._length
    @length.setter
    def length(self, value):
        if value < 0:
            raise ValueError(value)
        self._length = value
```

### 1.9 Method missing `self` / `cls`

```python
# Anti-pattern — area is a method but doesn't use the instance
class Rectangle:
    def area(width, height):                # missing self
        return width * height

# Fix — choose your intent:
class Rectangle:
    @staticmethod
    def area(width, height):                # no self, no cls
        return width * height

    @classmethod
    def from_pair(cls, pair):               # cls, not self
        return cls(*pair)
```

If a method doesn't reference `self` or `cls`, decorate it `@staticmethod` (or move it out of
the class).

### 1.10 `else` on a loop without `break`

```python
# Anti-pattern — `else` always runs, looks like dead code
def contains_magic(xs, target):
    for x in xs:
        if x == target:
            print("found")
    else:
        print("not found")              # also runs after a match

# Fix — pair `else` with `break` (its real purpose)
def contains_magic(xs, target):
    for x in xs:
        if x == target:
            print("found")
            break
    else:
        print("not found")              # only when no break
```

`for/else` is one of Python's least-known features. Use it correctly or not at all.

### 1.11 Old-style `super()` arguments

```python
# Anti-pattern — Python 2-style noise
class Square(Rectangle):
    def __init__(self, length):
        super(Square, self).__init__(length, length)

# Fix — Python 3 zero-arg
class Square(Rectangle):
    def __init__(self, length):
        super().__init__(length, length)
```

### 1.12 Manual frequency counter

```python
# Anti-pattern
freq = {}
for x in items:
    if x in freq:
        freq[x] += 1
    else:
        freq[x] = 1

# Fix
from collections import Counter
freq = Counter(items)
freq.most_common(3)         # top-3 by count, free
```

### 1.13 `if key not in d: d[key] = …` initialization

```python
# Anti-pattern
d = {}
if "k" not in d:
    d["k"] = []
d["k"].append(value)

# Fix 1 — defaultdict
from collections import defaultdict
d = defaultdict(list)
d["k"].append(value)

# Fix 2 — one-off setdefault
d = {}
d.setdefault("k", []).append(value)
```

### 1.14 Manual unpacking by index

```python
# Anti-pattern
l = [4, 7, 18]
l0 = l[0]
l1 = l[1]
l2 = l[2]

# Fix
l0, l1, l2 = l

# Variable-length unpacking
first, *middle, last = items

# Tuple swap / multiple update (no temp var)
a, b = b, a
a, b = b, a % b                  # Euclid's gcd inner step
```

### 1.15 Accessing `_protected` members from outside

```python
# Anti-pattern
r = Rectangle(5, 6)
print(r._width)                  # leading underscore = "don't touch"

# Fix — promote to public API, or use the documented accessor
print(r.width)
```

The underscore is a convention, but a strong one. If you find yourself reaching for `_x` from
outside, the class needs a public accessor.

---

## 2. Maintainability — Code That's Hard to Change

### 2.1 Wildcard imports

```python
# Anti-pattern — pollutes namespace, hides where names come from
from math import *

# Fix — name what you use
from math import ceil, floor, log

# When using many names from a module, qualify them
import math
x = math.ceil(y)

import multiprocessing as mp
pool = mp.Pool(8)
```

### 2.2 Not using `with` to open files

```python
# Anti-pattern — leaks the fd if anything in between raises
f = open("file.txt")
content = f.read()
1 / 0                            # f.close() never runs
f.close()

# Fix
with open("file.txt", encoding="utf-8") as f:
    content = f.read()

# Even simpler for whole-file reads
from pathlib import Path
content = Path("file.txt").read_text(encoding="utf-8")
```

Always pass `encoding=` explicitly for text files. The implicit default is platform-dependent.

### 2.3 Returning different types from one function

```python
# Anti-pattern — caller must type-check the result
def get_code(password):
    if password != "bicycle":
        return None
    return "42"

code = get_code(pw)
if code is None: ...             # branching at every call site

# Fix — raise on the error path
def get_code(password: str) -> str:
    if password != "bicycle":
        raise ValueError("wrong password")
    return "42"
```

If a function "either returns X or fails", raise. Reserve `X | None` for cases where `None`
is a meaningful, non-error result ("not found", "no value yet").

### 2.4 `global` for shared state

```python
# Anti-pattern
WIDTH = 0
def area(w, h):
    global WIDTH
    WIDTH = w
    return w * h

# Fix — encapsulate
from dataclasses import dataclass

@dataclass
class Rectangle:
    width: float
    height: float
    @property
    def area(self) -> float:
        return self.width * self.height
```

`global` is almost never necessary. State belongs in objects, configs passed as parameters,
or function returns.

### 2.5 Single-letter variable names

```python
# Anti-pattern
for k, v in d.items():
    for i in v:
        for k2, v2 in i.items():
            print(k2, v2)

# Fix — name them
for section, rows in data.items():
    for row in rows:
        for field, value in row.items():
            print(field, value)
```

Single letters are acceptable in **very** narrow scopes: `i, j` in tight numeric loops,
`x, y, z` for coordinates, `k, v` in a one-line dict comprehension, `_` for "ignored".

### 2.6 `setattr` / `getattr` with dynamically-built names

```python
# Anti-pattern — grep can't find these attributes
for key, value in data.items():
    setattr(self, key, value)

# Fix — keep data as data
self.attrs = dict(data)

# Or, if the schema is known, name the fields
@dataclass
class Record:
    id: int
    name: str
    value: float
```

Dynamic attribute creation is a maintenance nightmare. Use it only at well-documented plugin
boundaries (ORMs, RPC stubs), never inside business logic.

---

## 3. Readability — Code That's Hard to Read

### 3.1 LBYL instead of EAFP

```python
# Anti-pattern — "Look Before You Leap"; race condition between check and use
import os
if os.path.exists("file.txt"):
    os.unlink("file.txt")            # file may vanish in the gap

# Fix — "Easier to Ask Forgiveness than Permission"
from contextlib import suppress
with suppress(FileNotFoundError):
    os.unlink("file.txt")
```

EAFP is the canonical Python style. It's also race-safe — the act of using the resource is
atomic with checking its existence.

### 3.2 Comparing to `None` with `==`

```python
# Anti-pattern
if number == None: ...

# Fix
if number is None: ...
```

`None` is a singleton; identity (`is`) is correct, faster, and immune to `__eq__` overrides.
Same applies to `True` and `False` when you specifically need to test the singleton.

### 3.3 Comparing booleans with `==`

```python
# Anti-pattern
if flag == True: ...

# Fix — rely on truthiness
if flag: ...
```

In Python, `False`, `None`, `0`, `0.0`, `""`, `[]`, `{}`, `set()` are all falsy. Use that
directly. `is True` is only justified when you must distinguish the literal `True` from
other truthy values — rare.

### 3.4 `type(x) is SomeType` instead of `isinstance`

```python
# Anti-pattern — doesn't see subclasses
if type(r) is list: ...

# Fix
if isinstance(r, list): ...

# Better — for dispatch, use singledispatch or match
from functools import singledispatch

@singledispatch
def render(node): ...

@render.register
def _(node: list): return "[" + ", ".join(render(c) for c in node) + "]"
```

### 3.5 Iterating dict by key then indexing

```python
# Anti-pattern
for key in d:
    print(key, d[key])

# Fix
for key, value in d.items():
    print(key, value)
```

In Python 3, `.items()` / `.keys()` / `.values()` return live view objects — no memory
penalty. (The old `iteritems()` from Python 2 is gone.)

### 3.6 Returning a positional tuple for structured data

```python
# Anti-pattern
def get_name():
    return "Richard", "Xavier", "Jones"

name = get_name()
print(name[0])                      # what is [0]?

# Fix 1 — typing.NamedTuple
from typing import NamedTuple

class Name(NamedTuple):
    first: str
    middle: str
    last: str

# Fix 2 — frozen dataclass (when you want methods/defaults)
from dataclasses import dataclass

@dataclass(frozen=True, slots=True)
class Name:
    first: str
    middle: str
    last: str
```

If you `return a, b, c` and the caller has to remember position, it's begging to be a record.

### 3.7 `range(len(seq))` for iteration

```python
# Anti-pattern
for i in range(len(items)):
    print(i, items[i])

# Fix
for i, item in enumerate(items):
    print(i, item)

# Start at 1 instead of 0
for i, item in enumerate(items, start=1):
    ...
```

### 3.8 Manual index-paired iteration

```python
# Anti-pattern
for i in range(len(numbers)):
    print(numbers[i], letters[i])

# Fix
for n, l in zip(numbers, letters):
    print(n, l)

# 3.10+: catch length mismatch
for n, l in zip(numbers, letters, strict=True):
    ...
```

### 3.9 `map` / `filter` with `lambda` over a comprehension

```python
# Anti-pattern
doubles = list(map(lambda x: x * 2, values))
evens = list(filter(lambda x: x % 2 == 0, values))

# Fix
doubles = [x * 2 for x in values]
evens = [x for x in values if x % 2 == 0]
```

`map` / `filter` are fine **with named functions** (`map(str.strip, lines)`). With `lambda`,
a comprehension is almost always more readable.

### 3.10 Positional string formatting from a dict

```python
# Anti-pattern — fragile to schema changes
print("{0} {1} is {2}".format(person["first"], person["last"], person["age"]))

# Fix — f-string (3.6+)
print(f"{person['first']} {person['last']} is {person['age']}")

# Or **-expansion
print("{first} {last} is {age}".format(**person))

# Debug shorthand (3.8+)
print(f"{person=}")              # → person={'first': 'Tobin', ...}
```

### 3.11 Hungarian notation (type in the name)

```python
# Anti-pattern
n_int = "Hello, World!"          # the name lies
4 / n_int                        # TypeError

# Fix — name by role, type via annotation
greeting: str = "Hello, World!"
```

Names describe *what the value is for*. Types are checked by the type checker.

### 3.12 `is` for value equality

```python
# Anti-pattern — relies on CPython interning, not a language guarantee
a = 1000
b = 1000
print(a is b)                    # may print True (small-int cache) or False

# Fix — `==` for value, `is` only for identity
print(a == b)
```

`is` is correct only for: singletons (`None`, `True`, `False`), sentinel objects,
explicit "same object?" checks.

### 3.13 `CamelCase` for functions and variables

```python
# Anti-pattern
def doSomeThing(): ...
myVariable = 42

# Fix — PEP 8
def do_something(): ...
my_variable = 42

# Classes still use CapWords
class HttpClient: ...
```

### 3.14 Verbose dict construction

```python
# Anti-pattern
my_dict = dict([(n, n * 2) for n in numbers])

# Fix — dict comprehension
my_dict = {n: n * 2 for n in numbers}

# Same for sets
my_set = {n * 2 for n in numbers}
```

---

## 4. Performance — Hand-Rolled vs Stdlib Algorithms

### 4.1 Membership testing on a list

```python
# Anti-pattern — O(n) per lookup
items_list = [1, 2, 3, 4, 5]
if 3 in items_list: ...

# Fix — O(1)
items_set = {1, 2, 3, 4, 5}
if 3 in items_set: ...

# Pre-convert when testing many queries against a fixed collection
seen = set(big_list)
hits = [q for q in queries if q in seen]
```

Same applies to `dict` — keys lookup is O(1).

### 4.2 Top-k via full sort

```python
# Anti-pattern — O(n log n) to find the largest k
top10 = sorted(items, key=score, reverse=True)[:10]

# Fix — O(n log k)
import heapq
top10 = heapq.nlargest(10, items, key=score)
```

### 4.3 `list.pop(0)` as a FIFO queue

```python
# Anti-pattern — O(n) per pop
q = []
q.append(x)
front = q.pop(0)

# Fix — O(1) at both ends
from collections import deque
q = deque()
q.append(x)
front = q.popleft()
```

### 4.4 String concatenation in a loop

```python
# Anti-pattern — quadratic in many implementations
s = ""
for line in lines:
    s += line + "\n"

# Fix
s = "\n".join(lines) + "\n"

# Streaming
import io
buf = io.StringIO()
for line in lines:
    buf.write(line)
    buf.write("\n")
s = buf.getvalue()
```

### 4.5 Reading whole files into memory unnecessarily

```python
# Anti-pattern
content = open(path).read()
for line in content.splitlines():
    process(line)

# Fix — iterate the file lazily
with open(path, encoding="utf-8") as f:
    for line in f:
        process(line)
```

Same principle for huge dicts: `for k, v in d.items():` is already a view — no copy.

### 4.6 Sorted insertion via repeated `sort()`

```python
# Anti-pattern
sorted_list.append(x)
sorted_list.sort()               # O(n log n) per insertion

# Fix
import bisect
bisect.insort(sorted_list, x)    # O(n) insert, O(log n) search
```

---

## 5. Security

### 5.1 `exec` / `eval` of constructed strings

```python
# Anti-pattern — code injection waiting to happen
s = f"print({user_input})"
exec(s)

# Fix — refactor to functions or a dispatch table
operations = {"print": print, "abs": abs}
operations[command](value)
```

`exec` / `eval` are reserved for genuine metaprogramming (REPLs, templating engines). For
business logic, the answer is always a dict, a class, or `getattr`.

### 5.2 `random` for tokens / passwords

```python
# Anti-pattern — predictable PRNG
import random, string
token = "".join(random.choices(string.ascii_letters, k=32))

# Fix
import secrets
token = secrets.token_urlsafe(24)
api_key = secrets.token_hex(32)
```

### 5.3 String comparison for tokens / digests

```python
# Anti-pattern — timing leak (early-exit comparison)
if user_token == expected:
    grant_access()

# Fix — constant-time comparison
import hmac
if hmac.compare_digest(user_token, expected):
    grant_access()
```

### 5.4 Unstripped paths from user input

```python
# Anti-pattern — directory traversal
target = base / user_supplied_filename
target.read_text()               # could be ../../etc/passwd

# Fix — resolve and bound
from pathlib import Path
base = Path("/srv/uploads").resolve()
target = (base / user_supplied_filename).resolve()
if not target.is_relative_to(base):    # 3.9+
    raise ValueError("path traversal")
```

---

## 6. Modern Additions (Beyond the Book)

Stdlib idioms that postdate the QuantifiedCode book or are otherwise not in it. Each links
back to the main `SKILL.md` section.

### 6.1 `os.path` string juggling → `pathlib.Path`

See SKILL §7.

### 6.2 Hand-rolled context manager classes → `@contextlib.contextmanager`

See SKILL §5.

### 6.3 Hand-rolled memo dict → `functools.cache` / `lru_cache`

```python
# Anti-pattern
_cache = {}
def get(k):
    if k not in _cache:
        _cache[k] = compute(k)
    return _cache[k]

# Fix
from functools import cache
@cache
def get(k):
    return compute(k)
```

See SKILL §1.2.

### 6.4 `isinstance` chains for dispatch → `functools.singledispatch` or `match`/`case`

See SKILL §1.1, §11.

### 6.5 Hand-rolled `Result` / `Maybe` types → `match`/`case` (3.10+)

```python
match response:
    case {"ok": True, "data": data}:
        use(data)
    case {"ok": False, "error": msg}:
        report(msg)
```

See SKILL §11.

### 6.6 Manual chunking and pairwise loops

```python
# Pairwise (3.10+)
from itertools import pairwise
for a, b in pairwise(items): ...

# Chunking (3.12+)
from itertools import batched
for chunk in batched(items, 100): ...
```

See SKILL §2.2.

### 6.7 Manual flattening → `itertools.chain.from_iterable`

```python
flat = list(chain.from_iterable(nested))
```

See SKILL §2.1.

### 6.8 Forgotten built-ins

- `divmod(a, b)` — quotient and remainder in one call.
- `pow(base, exp, mod)` — fast modular exponentiation.
- `iter(callable, sentinel)` — call until sentinel.
- `next(it, default)` — avoid `try`/`except StopIteration`.

See SKILL §15.

### 6.9 Plain class for data → `@dataclass(slots=True, frozen=True)`

```python
# Anti-pattern
class Point:
    def __init__(self, x, y): self.x, self.y = x, y
    def __repr__(self): return f"Point({self.x}, {self.y})"
    def __eq__(self, other): return (self.x, self.y) == (other.x, other.y)
    def __hash__(self): return hash((self.x, self.y))

# Fix
from dataclasses import dataclass

@dataclass(frozen=True, slots=True)
class Point:
    x: float
    y: float
```

See SKILL §6.

### 6.10 Hand-rolled CLI parsing → `argparse`

```python
# Anti-pattern
import sys
verbose = "--verbose" in sys.argv
path = sys.argv[1]

# Fix
import argparse
p = argparse.ArgumentParser()
p.add_argument("path")
p.add_argument("--verbose", action="store_true")
args = p.parse_args()
```

### 6.11 `try / except` for `getattr` / `dict` lookups

```python
# Anti-pattern
try:
    name = obj.name
except AttributeError:
    name = "anon"

# Fix
name = getattr(obj, "name", "anon")
value = d.get(key, default)
```

### 6.12 `len(x) == 0` and `range(len(x))`

```python
# Anti-patterns
if len(items) == 0: ...
if len(items) > 0: ...
for i in range(len(items)): ...

# Fixes
if not items: ...
if items: ...
for i, item in enumerate(items): ...
```
