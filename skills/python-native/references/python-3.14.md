# Python 3.14 — Native Features

Released **2025-10-07**. 3.14 ships deferred annotations, template strings, first-class
subinterpreters, and graduates the free-threaded build to officially supported.

---

## PEP 649 — Deferred Evaluation of Annotations

Annotations on functions, classes, and modules are no longer evaluated eagerly. They are stored
in a special annotate function and computed lazily on access.

```python
class Node:
    children: list[Node]              # works without quoting or `from __future__ import annotations`
    parent: Node | None
```

To inspect annotations, use the new `annotationlib` module instead of reading `__annotations__`
directly:

```python
from annotationlib import get_annotations, Format

get_annotations(Node, format=Format.VALUE)        # real objects (default)
get_annotations(Node, format=Format.FORWARDREF)   # unresolved names become ForwardRef
get_annotations(Node, format=Format.STRING)       # original source strings
```

- Eager evaluation is preserved when `from __future__ import annotations` is in effect (legacy mode).
- Migration: code that did `cls.__annotations__` should switch to `annotationlib.get_annotations(cls)`.

---

## PEP 750 — Template Strings (`t""`)

A new string prefix produces a `string.templatelib.Template` object instead of a `str`.
The literal parts and interpolation values are kept separate, enabling libraries to perform
context-aware escaping (SQL parameters, HTML attributes, shell args).

```python
from string.templatelib import Template

variety = "Stilton"
template: Template = t"Try some {variety} cheese!"
type(template)                       # <class 'string.templatelib.Template'>
```

`Template` is not a `str` — it must be processed by a library that understands it. Treat `t""` as
the safe default for any string sent to a system that can be injected (SQL, HTML, shell).

---

## PEP 734 — Multiple Interpreters in the Stdlib

Subinterpreters (each with its own GIL, courtesy of 3.12's PEP 684) get a first-class Python API.

```python
from concurrent import interpreters

interp = interpreters.create()
interp.exec("print('hello from subinterpreter')")
interp.close()
```

Plus a pool executor that fans out across interpreters:

```python
from concurrent.futures import InterpreterPoolExecutor

with InterpreterPoolExecutor() as pool:
    results = list(pool.map(work, items))
```

Use when you want CPU parallelism without `multiprocessing`'s fork/serialize overhead.

---

## PEP 779 — Free-Threaded Python Officially Supported

The `python3.14t` build (GIL disabled) is no longer flagged experimental.

- Specializing adaptive interpreter is now enabled on the free-threaded build.
- Single-threaded overhead reduced to ~5-10% versus the GIL build.
- New flags: `-X context_aware_warnings`, `-X thread_inherit_context`.
- Most popular C extensions ship free-threaded wheels.

Still a separate ABI / build — choose based on workload; not a drop-in for every project.

---

## JIT — Binary Releases

The experimental JIT (from 3.13) now ships in Windows and macOS binary releases. Still opt-in;
enable with `PYTHON_JIT=1`. Build-time flag `--enable-experimental-jit` remains.

---

## `pathlib.Path` — Recursive Copy/Move

```python
from pathlib import Path

src = Path("project")
src.copy("backup")                # recursive copy to destination path
src.copy_into("archives/")        # recursive copy INTO an existing directory
src.move("renamed")
src.move_into("trash/")
```

Replaces most `shutil.copytree` / `shutil.move` calls for path-oriented code.

---

## Other Additions

- `argparse` — subparser aliases, improved deprecation messages.
- `asyncio` — eager task creation hooks, better introspection.
- `string.templatelib` — supporting module for `t""` literals (see PEP 750).
- `annotationlib` — supporting module for PEP 649 (see above).

---

## Removals / Cleanups

Several long-deprecated APIs reach end-of-life. The `typing` aliases (`typing.List`,
`typing.Dict`, etc.) remain importable but are firmly deprecated — use built-in generics
(`list[int]`, `dict[str, int]`) instead.

---

## Migration Guidance for Pre-3.14 Code

1. **Annotations**: stop quoting forward references; you can remove `from __future__ import annotations`
   once the floor is 3.14. To read annotations, switch to `annotationlib.get_annotations`.
2. **SQL / HTML helpers**: migrate `f""` patterns that touch untrusted data to `t""` once the
   consuming library supports `string.templatelib.Template`.
3. **Subinterpreters**: consider `concurrent.interpreters` / `InterpreterPoolExecutor` for
   CPU-bound fan-out that previously used `multiprocessing`.
4. **Free-threaded build**: viable for pure-Python parallel workloads; measure single-threaded
   penalty before committing.
