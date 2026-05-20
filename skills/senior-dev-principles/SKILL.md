---
name: senior-dev-principles
description: >
  Apply senior-level engineering judgment on non-trivial code work: designing systems,
  writing new modules, refactoring, implementing algorithms, or making structural
  decisions. Triggers: "design X", "refactor this", "implement an algorithm/feature/
  service", "optimize this", "review this code", "what's the best way to structure X",
  or any task that involves architecture, complexity reasoning, or multi-file changes.
  SKIP for trivial edits (rename, typo, single-line fix), config tweaks, documentation
  edits, or tasks already covered by the base "match request scope" guidance.
  Languages: Python, TypeScript, C, C++, SQL.
---

# Senior Code Quality

Principles for non-trivial code work. These are defaults and signals, not absolutes.
The base system prompt already enforces "match request scope, no speculative additions,
no premature abstraction" — this skill layers quality criteria on top for when you
genuinely are designing or building.

When a rule here conflicts with the system prompt's "don't over-engineer" guidance,
the system prompt wins.

---

## 1. Single Responsibility — balanced against YAGNI

Every unit should have one clear reason to change. But SRP taken too far fragments
code into a maze of tiny files and helpers nobody can navigate. Pick the right grain
for the project.

**Apply SRP when:**
- A unit mixes concerns touched by different kinds of changes (e.g. DB access + business rules + serialization).
- You can name each resulting piece with a single noun phrase, no "and".
- The split removes hidden coupling rather than introducing cross-file ceremony.

**Hold off on SRP when:**
- Three similar lines could become one shared helper — leave them. Premature DRY hurts more than duplication.
- A function is long but cohesive and reads top-to-bottom without abstraction jumps.
- Splitting forces names nobody would search for (`OrderHelperUtils`, `ProcessingManagerImpl`).

**Size is a signal, not a law.** A 50-line function doing one cohesive operation is
fine. A 400-line module that is mostly a dispatch table or a schema is fine. A 30-line
file mixing two domains is not. When a file or function feels heavy, ask whether the
weight is *cohesion* (keep) or *multiple concerns* (split).

---

## 2. Algorithmic complexity — when to reason about it

For algorithmic code, hot paths, and anything touching user-controlled input size,
reason about complexity before writing. For glue code, CRUD handlers, or a transform
over a known-small list, skip the analysis.

| Problem                  | Naive      | Target       | Technique                |
|--------------------------|------------|--------------|--------------------------|
| Membership test          | O(n)       | O(1) amort.  | set / dict               |
| Find duplicates          | O(n²)      | O(n)         | hash set                 |
| Pair matching            | O(n²)      | O(n)         | hash map                 |
| Sorted lookup            | O(n)       | O(log n)     | binary search            |
| Graph shortest path      | O(V²)      | O(E log V)   | Dijkstra + min-heap      |
| Substring search         | O(nm)      | O(n+m)       | KMP / Rabin-Karp         |
| Top-K elements           | O(n log n) | O(n log k)   | min-heap of size k       |
| Range sum queries        | O(n) each  | O(1) each    | prefix sum array         |
| Repeated subproblem      | O(2ⁿ)      | O(n²) / O(n) | memoization / DP         |

**Rules of thumb:**
- Don't use nested loops when a hash map flattens them.
- Don't sort inside a loop if a single sort outside suffices.
- Prefer `set` / `dict` membership over `in list` when n is unbounded.
- Note complexity in a comment **only when non-obvious** — recursive DP, custom data
  structures, loops with early exits. Don't annotate obvious linear scans.

---

## 3. Senior mindset

**Names are documentation.** Single letters are fine inside a short math formula or
tight loop. Outside, give the reader something to grip.

**Lift magic numbers when they encode policy.** `if retries > MAX_RETRIES` beats
`if retries > 3` when 3 is a tunable. Inline literals are fine when they're intrinsic
(`bytes[0]`, `len(parts) == 2`).

**Validate at boundaries, trust internals.** Check inputs at the system edge — HTTP
handlers, CLI parsing, file reads, external API responses. Don't re-validate every
internal call. If a function is only reachable from code you control and the
precondition is guaranteed, no defensive check.

```python
# At the boundary: validate, fail with context.
def handle_request(payload: dict) -> Response:
    user_id = payload.get("user_id")
    if not isinstance(user_id, int):
        raise BadRequest("user_id must be an integer")
    return _build_response(user_id)

# Internal: trust the caller.
def _build_response(user_id: int) -> Response:
    ...
```

**Write for testability when tests exist.** Pure functions where natural, I/O isolated
at the edges. Don't restructure working code purely to enable tests nobody will write.

**Default to no comments.** A comment is debt unless it captures a non-obvious
constraint, a workaround, or a surprise. "Increment counter" is noise; "Skip header
row from this vendor's CSV export" is signal.

---

## 4. Self-review before presenting code

- Does each unit have a purpose a peer could state in one sentence?
- For algorithmic work: is the complexity acceptable for realistic input sizes?
- Are edge cases handled, or explicitly out of scope?
- Are there names a reader would have to look up?
- Is duplicated logic worth extracting, or is it just three similar lines that should stay?

---

## 5. Language defaults

### Python
- Type hints on public APIs; skip for one-off internal helpers.
- Comprehensions for simple transforms; loops when there's branching or side effects.
- `dataclasses` / `pydantic` for structured data when the shape is used in more than one place.
- `with` for resources (files, locks, connections).

### TypeScript
- `const` by default, `let` only when mutation is necessary, never `var`.
- Explicit return types on exported functions.
- `strict: true`. Prefer `unknown` + narrowing over `any`; reach for `any` only when interop genuinely needs it.
- `async` / `await` over raw `.then` chains.

### C
- Every allocation has an owner and a matching free; verify with Valgrind or ASan.
- No implicit `switch` fallthrough — `break` or `/* fallthrough */`.
- `size_t` for sizes and indices; don't mix signed/unsigned.
- Header guards on every `.h`.

### C++
- RAII: resources owned by objects, not managed manually.
- `unique_ptr` / `shared_ptr` over raw owning pointers.
- `const` on non-mutating methods; `const&` for non-trivial parameters.
- `std::vector` / `std::array` over raw arrays. Rule of Zero when possible. `explicit` on single-argument constructors.

### SQL
- Explicit column lists, never `SELECT *` in production paths.
- Consider an index for new WHERE / JOIN columns — but watch for over-indexing on write-heavy tables.
- Run `EXPLAIN` on queries that will scan large tables.

---

Optimal code is correct, clear, efficient, and maintainable — in that order. The
shortest path to typing is rarely the right one; the goal is the path a future reader
will thank you for.
