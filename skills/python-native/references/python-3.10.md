# Python 3.10 — Native Features

3.10 introduced two language-level changes that dramatically reshape idiomatic Python:
structural pattern matching and PEP 604 union syntax.

---

## Structural Pattern Matching — `match` / `case` (PEP 634/635/636)

The single most impactful syntax change since f-strings. Replaces large `if/elif/isinstance` chains
and hand-rolled visitors.

### Literal and OR Patterns
```python
match command:
    case "start" | "begin":
        start()
    case "stop":
        stop()
    case _:
        unknown()
```

### Sequence Patterns
```python
match args:
    case []:
        do_nothing()
    case [x]:
        single(x)
    case [first, *rest]:
        many(first, rest)
```

### Mapping Patterns
```python
match request:
    case {"action": "create", "id": int(id), "payload": payload}:
        create(id, payload)
    case {"action": "delete", "id": id}:
        delete(id)
```

### Class Patterns (destructuring by attribute)
```python
@dataclass
class Point:
    x: float
    y: float

match p:
    case Point(x=0, y=0):
        origin()
    case Point(x=0, y=y):
        on_y_axis(y)
    case Point():
        elsewhere()
```

### Guards
```python
match obj:
    case Point(x=x, y=y) if x == y:
        on_diagonal()
```

### Capture vs. Constant
- `case x:` binds `x` to the subject (capture).
- `case Color.RED:` (dotted name) is a **value test**.
- To compare to a local constant, dot it: `case shape.CIRCLE:`.

> **Common bug**: writing `case CIRCLE:` thinking it tests a constant — it binds the name `CIRCLE`
> instead. Use `MyEnum.CIRCLE` or assign via `case _ if subject == CIRCLE:`.

---

## PEP 604 — `X | Y` Union Syntax

```python
def parse(value: int | str | None) -> list[int] | None: ...
```

- Replaces `Union[int, str, None]` and `Optional[int]`.
- Works at runtime (creates a `types.UnionType`), so `isinstance(x, int | str)` is legal too.
- For 3.9 source compatibility use `from __future__ import annotations`.

---

## `zip(..., strict=True)` (PEP 618)

```python
list(zip([1, 2, 3], [10, 20], strict=True))    # ValueError — lengths differ
```

Catches a class of bugs where two iterables silently get truncated. **Use it by default** when both
sides should be the same length.

---

## `dataclass(slots=True, kw_only=True)`

```python
from dataclasses import dataclass, field, KW_ONLY

@dataclass(slots=True, kw_only=True, frozen=True)
class Config:
    host: str
    port: int = 5432
```

- `slots=True` → memory-efficient, attribute-typo-resistant, faster attribute access.
- `kw_only=True` → forces all fields to be keyword-only; safer for evolving signatures.
- `KW_ONLY` sentinel → mark only fields *after* a point as keyword-only.

---

## `itertools.pairwise`

```python
from itertools import pairwise
list(pairwise([1, 2, 3, 4]))     # [(1,2), (2,3), (3,4)]
```

Use for windowed diffs, edge iteration in graphs, sliding-window-of-size-2 problems.

---

## Parenthesized Context Managers

```python
with (
    open("a") as a,
    open("b") as b,
    open("c") as c,
):
    process(a, b, c)
```

Cleaner than backslash continuations. Use for any chain of ≥2 context managers.

---

## Type Aliases — Explicit `TypeAlias`

```python
from typing import TypeAlias

JSON: TypeAlias = "int | float | str | bool | None | list[JSON] | dict[str, JSON]"
```

The runtime-friendlier `type` statement arrives in 3.12.

---

## Better Error Messages

3.10 added precise error locations (column carets), specific messages for missing colons, unclosed
brackets, misspelled keywords. No code change required — just a better debugging experience.

---

## Other Additions

- `int.bit_count()` — population count without `bin(n).count("1")`.
- `aiter()` / `anext()` built-ins for async iterators (mirroring `iter`/`next`).
- `inspect.get_annotations` — safer than reading `__annotations__` directly.
- `types.EllipsisType`, `types.NoneType` — useful in type annotations.
- `Counter.total()` — sum of all counts (avoid `sum(c.values())`).
- `statistics.covariance`, `correlation`, `linear_regression`.
