# Python 3.11 — Native Features

3.11 brought a ~25% interpreter speedup, structured exception groups, and several quality-of-life
features that simplify common idioms.

---

## `tomllib` — TOML Parsing in the Stdlib (PEP 680)

```python
import tomllib
from pathlib import Path

with Path("pyproject.toml").open("rb") as f:        # NB: binary mode
    config = tomllib.load(f)
```

Read-only. For writing TOML you still need a third-party library (`tomli-w`, `tomlkit`).

---

## `ExceptionGroup` and `except*` (PEP 654)

Aggregate multiple exceptions raised concurrently (e.g., in a `TaskGroup`) and handle them by type
without manual unpacking.

```python
try:
    raise ExceptionGroup("multi", [ValueError("a"), KeyError("b")])
except* ValueError as eg:
    handle_value_errors(eg.exceptions)
except* KeyError as eg:
    handle_key_errors(eg.exceptions)
```

- `except*` matches and **strips** exceptions by type while preserving the group.
- Use `eg.split(ExcType)` to partition manually.

---

## `asyncio.TaskGroup` (PEP 654 companion)

Replaces ad-hoc `asyncio.gather` + cancellation logic with a structured concurrency primitive.

```python
import asyncio

async def main():
    async with asyncio.TaskGroup() as tg:
        tg.create_task(fetch("a"))
        tg.create_task(fetch("b"))
    # all tasks have completed here; any exceptions become an ExceptionGroup
```

Cancellation is automatic if one task fails. Use this instead of `gather(..., return_exceptions=True)`.

---

## `Self` Type (PEP 673)

```python
from typing import Self

class QueryBuilder:
    def where(self, **kw) -> Self: ...
    def order_by(self, *cols) -> Self: ...
```

`Self` correctly refers to the *subclass* when inherited — no more `TypeVar` ceremony for builders.

---

## `StrEnum` and `EnumType` Improvements

```python
from enum import StrEnum, auto

class Color(StrEnum):
    RED = auto()        # "red"
    BLUE = auto()       # "blue"

Color.RED == "red"      # True
```

`StrEnum` members behave as both enum and `str`. Useful for JSON-friendly enums. Same idea as
`IntEnum` but for strings.

---

## Exception Notes (`__notes__`)

Attach context to an exception without wrapping:

```python
try:
    parse(payload)
except ValueError as e:
    e.add_note(f"while processing user={user_id}")
    raise
```

Notes are rendered in the traceback. Great for adding context in middleware.

---

## Fine-Grained Tracebacks

3.11 tracebacks underline the *exact* expression that raised. No code change needed:

```
File "x.py", line 5, in <module>
    result = a / b * c
             ~~^~~
ZeroDivisionError: division by zero
```

---

## `hashlib.file_digest`

```python
import hashlib
from pathlib import Path

with Path("big.bin").open("rb") as f:
    digest = hashlib.file_digest(f, "sha256").hexdigest()
```

Streams the file efficiently. Replaces manual `while chunk := f.read(...)` digest loops.

---

## Variadic Generics (PEP 646)

```python
from typing import TypeVarTuple, Unpack

Shape = TypeVarTuple("Shape")

class Tensor[*Shape]: ...                          # PEP 695 syntax (3.12+)

def add(a: Tensor[*Shape], b: Tensor[*Shape]) -> Tensor[*Shape]: ...
```

Primarily for typed array libraries (numpy, jax, torch shape typing).

---

## Other Additions

- `LiteralString` type — for SQL/HTML APIs that must reject user-built strings.
- `Required` / `NotRequired` for `TypedDict` per-field optionality (PEP 655).
- `dataclasses.dataclass(weakref_slot=True)` — allow weakref on slotted dataclasses.
- `typing.assert_type`, `typing.assert_never` — exhaustiveness checks for type checkers.
- `tomllib`, faster startup (lazy imports of many stdlib modules).
- `string.Template.get_identifiers` — list template variables.
- `inspect.getmembers_static` — non-eager `getmembers`.

---

## Performance Notes

- The faster CPython project (PEP 659) shipped — typical workloads ~25% faster than 3.10, no code change.
- Use 3.11+ for production whenever possible; the speedup is free.
