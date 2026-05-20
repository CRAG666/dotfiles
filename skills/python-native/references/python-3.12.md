# Python 3.12 — Native Features

3.12 modernized generics syntax, added a few stdlib gems, and continued the perf push.

---

## PEP 695 — New Generic Syntax

The cleanest way to declare generics in Python's history:

```python
# 3.12+ — generic functions and classes
def first[T](xs: list[T]) -> T:
    return xs[0]

class Stack[T]:
    def __init__(self) -> None:
        self._items: list[T] = []
    def push(self, x: T) -> None: self._items.append(x)
    def pop(self) -> T: return self._items.pop()

# 3.12+ — type alias statement
type Vector = list[float]
type JSON = int | float | str | bool | None | list[JSON] | dict[str, JSON]
```

Replaces `TypeVar`, `Generic[T]`, `TypeAlias`. The new form is scoped, not module-global.

---

## `itertools.batched`

```python
from itertools import batched
list(batched("ABCDEFG", 3))      # [('A','B','C'), ('D','E','F'), ('G',)]
```

Use everywhere you wrote a manual chunk loop. **3.13** adds `strict=True` to raise on a short final batch.

---

## `@override` Decorator (PEP 698)

```python
from typing import override

class Animal:
    def speak(self) -> str: ...

class Dog(Animal):
    @override
    def speak(self) -> str: return "woof"
```

Static checkers verify the method actually overrides a parent method. Catches renames in the
superclass.

---

## f-strings: Fewer Restrictions (PEP 701)

f-strings are now parsed by the regular parser. You can:

- Reuse the same quotes inside the expression: `f"{'.join(parts)'}"` and `f"{ "x" }"` are valid.
- Use multi-line expressions and comments inside an f-string.
- Backslashes are allowed in expression parts: `f"{path.replace('\\', '/')}"`.

---

## `pathlib.Path.walk()`

```python
for root, dirs, files in Path("/etc").walk():
    ...
```

`os.walk`-style API but returning `Path` objects. Use this instead of `os.walk` in new code.

---

## Per-Interpreter GIL (Foundation Work, PEP 684)

Subinterpreters now have isolated GILs at the C-API level. Not yet exposed cleanly in Python, but
groundwork for true parallelism without subprocesses.

---

## Other Additions

- `Unpack[TypedDict]` for typing `**kwargs` precisely (PEP 692).
- `calendar.Month`, `calendar.Day` enums.
- `random.binomialvariate(n, p)` — sample from a binomial distribution.
- `sys.monitoring` — low-overhead instrumentation hooks (debuggers, coverage) (PEP 669).
- `array.array` supports `clear()`.
- Improved `asyncio` performance — eager task factories, faster `gather`.
- Many small `typing` improvements: `@deprecated`, `Buffer` protocol.

---

## Removals / Pending Removals

- `distutils` removed — use `setuptools` / `hatchling` / a modern build backend.
- `imp` removed.
- `smtpd`, `asynchat`, `asyncore` removed.

If you target 3.12+, you can stop importing `distutils` entirely.

---

## Performance Notes

- Comprehension inlining — list/dict/set comprehensions no longer create a hidden function frame,
  noticeably faster.
- Smaller object headers — about 10% less memory for object-heavy workloads.
