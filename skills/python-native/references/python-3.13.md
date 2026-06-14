# Python 3.13 — Native Features

3.13 ships two major experimental builds (free-threaded, JIT) plus a steady refinement of the
stdlib and typing.

---

## Free-Threaded CPython (PEP 703, Experimental)

A separate build (`python3.13t`) where the GIL is disabled. Pure-Python code on a free-threaded
build sees real parallelism with `threading`.

- **Status**: experimental. Many C extensions need updates to be thread-safe.
- **API**: no language change. You write the same `threading.Thread` code.
- **Decision**: don't rely on free-threading in production yet; do prototype with it for CPU-bound
  pure-Python workloads.

```python
import threading

def worker(): ...                 # real parallelism on the t-build
threads = [threading.Thread(target=worker) for _ in range(8)]
for t in threads: t.start()
for t in threads: t.join()
```

---

## JIT Compiler (PEP 744, Experimental)

A copy-and-patch JIT. Off by default; enable with `PYTHON_JIT=1`. Modest speedups today; foundation
for larger gains later. No code changes required.

---

## `dbm.sqlite3`

A SQLite-backed `dbm` backend — fast and durable key/value store using only stdlib. Concurrency semantics follow `sqlite3`/`dbm` locking; test for your workload.

```python
import dbm

with dbm.open("cache.db", "c") as db:
    db[b"key"] = b"value"
    print(db[b"key"])
```

Use as the default in new code over `dbm.gnu` / `dbm.ndbm`.

---

## REPL: New Interactive Shell

3.13's REPL has:
- Multi-line editing.
- Color-coded tracebacks and prompts.
- `exit` works without parentheses.
- `help`, `clear` as proper commands.

No code impact, but interactive workflows are noticeably nicer.

---

## `itertools.batched(..., strict=True)`

```python
from itertools import batched
list(batched(range(10), 3, strict=True))     # raises if the last batch is short
```

Pair with `strict=True` when you require exact-size batches.

---

## `copy.replace`

```python
import copy
new = copy.replace(obj, field1=new_value)
```

Generic functional update. Works on objects that implement `__replace__` (named tuples, dataclasses,
many stdlib types).

---

## Typing Additions

- `typing.TypeIs` — a narrower, more accurate cousin of `TypeGuard` for type narrowing.
- `typing.ReadOnly` for `TypedDict` fields.
- `warnings.deprecated`: the `@deprecated` decorator (PEP 702). The runtime symbol lives in `warnings`, never `typing`, and is new in 3.13.
- PEP 696 — type parameter defaults: `class Box[T = int]: ...`.

---

## `os.process_cpu_count` and CPU-Count Overrides

```python
import os
os.process_cpu_count()           # CPUs *this process* may use (respects affinity / cgroups)
os.cpu_count()                   # total logical CPUs (existing behavior)
```

Also new: `-X cpu_count=N` command-line flag and `PYTHON_CPU_COUNT` env var to override the
detected count — useful in containers where cgroup quotas mislead the runtime.

Prefer `os.process_cpu_count()` over `os.cpu_count()` for pool sizing in 3.13+.

---

## Other Additions

- `random` module gains a CLI (`python -m random`).
- `ntpath.isreserved` (and `PureWindowsPath.is_reserved`) for Windows reserved filenames. Exposed as `os.path.isreserved` only on Windows (where `os.path` is `ntpath`); not present on POSIX. `PurePath.is_reserved` was deprecated at the same time.
- `argparse` deprecation hints, suggestion messages.
- Better error messages for `NameError`, `AttributeError`, `ImportError` — common typos suggested.
- `array.array` supports `clear()` (added in 3.13).

---

## Removals

PEP 594 dead-battery modules removed in 3.13 (19 total):

`aifc`, `audioop`, `cgi`, `cgitb`, `chunk`, `crypt`, `imghdr`, `mailcap`, `msilib`,
`nis`, `nntplib`, `ossaudiodev`, `pipes`, `sndhdr`, `spwd`, `sunau`, `telnetlib`, `uu`,
`xdrlib`.

Separately removed (not PEP 594): `lib2to3` (the `2to3` Python source-migration tool).

If your code imports any of these, plan replacements **before** upgrading. The Python
3.13 What's New page links each removal to a suggested replacement.

---

## Performance Notes

- Incremental cyclic GC — shorter pause times.
- Smaller memory footprint for many objects.
- Free-threaded build adds overhead in single-threaded code (~5-10%); pick the right build for the workload.
