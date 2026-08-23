---
name: senior-dev-principles
description: 'STRICT structure-and-complexity layer for non-trivial code work: designing systems, writing new modules, refactoring, implementing algorithms, or making structural decisions. Complements code-style-defaults (form of the output) and python-native (Python stdlib): this skill decides how code is structured and how fast it runs — target big-O before writing, single-responsibility grain, policy constants, testability, and per-language defaults for TypeScript, C, C++, and SQL. Triggers: "design X", "refactor this", "implement an algorithm/feature/service", "optimize this", "review this code", "what''s the best way to structure X", or any task involving architecture, complexity reasoning, or multi-file changes. SKIP for trivial edits (rename, typo, single-line fix), config tweaks, and documentation edits.'
---

# Senior Dev Principles

Structure and complexity layer. `code-style-defaults` governs the form of the output; `python-native` governs Python stdlib usage; this skill governs how code is structured and how fast it runs. Every rule is a requirement, not a suggestion.

Precedence: user's explicit instruction > convention of the file being edited > this list.

## 1. Algorithmic complexity — reason before writing

Mandatory for algorithmic code, hot paths, and anything touching unbounded or user-controlled input size. Skip for glue code, CRUD handlers, and transforms over known-small data.

| Problem                  | Naive      | Target       | Technique                |
|--------------------------|------------|--------------|--------------------------|
| Membership test          | O(n)       | O(1) amort.  | set / dict               |
| Find duplicates          | O(n²)      | O(n)         | hash set                 |
| Pair matching            | O(n²)      | O(n)         | hash map                 |
| Sorted lookup            | O(n)       | O(log n)     | binary search            |
| Shortest path (single-source, non-negative weights) | O(V²) | O((V+E) log V) | Dijkstra + min-heap; for negative edges use Bellman-Ford, or Johnson for all-pairs |
| Substring search         | O(nm)      | O(n+m)       | KMP (worst-case O(n+m)); Rabin-Karp (expected O(n+m), worst-case O(nm) on hash collisions) |
| Top-K elements           | O(n log n) | O(n log k)   | min-heap of size k       |
| Range sum queries        | O(n) each  | O(1) each    | prefix sum array         |
| Repeated subproblem      | O(2ⁿ)      | states × transition cost | memoization / DP (e.g. matrix-chain O(n³), 0/1 knapsack pseudo-polynomial O(nW)) |

- Do NOT use nested loops when a hash map flattens them.
- Do NOT sort inside a loop when one sort outside suffices.
- Do NOT use `in list` membership when n is unbounded — use `set`/`dict`.
- Do NOT accept O(n²) or worse on unbounded input without stating why in one line.
- DO note complexity in a comment only when non-obvious (recursive DP, custom structures, early exits) — never on obvious linear scans.

## 2. Structure

- Do NOT put two reasons-to-change in one unit — DB access + business rules + serialization is three units.
- Do NOT split a unit that reads top-to-bottom cohesively just to make files smaller.
- Do NOT create names nobody would search for (`OrderHelperUtils`, `ProcessingManagerImpl`) — if the split forces one, the split is wrong.
- Do NOT judge by size: a 50-line cohesive function is fine; a 30-line file mixing two domains is not. Split concerns, keep cohesion.
- Do NOT inline a literal that encodes policy — `MAX_RETRIES`, not `3`. DO inline intrinsic literals (`bytes[0]`, `len(parts) == 2`).
- Do NOT bury I/O inside logic when tests exist — pure functions where natural, I/O at the edges.
- Do NOT restructure working code purely to enable tests nobody will write.

## 3. Per-language

Python lives in `python-native`.

### TypeScript
- `const` by default, `let` only on mutation, never `var`.
- Explicit return types on exported functions.
- `strict: true`; `unknown` + narrowing over `any`.
- `async`/`await` over raw `.then` chains.

### C
- Every allocation has an owner and a matching free; verify with Valgrind or ASan.
- No implicit `switch` fallthrough — `break` or `/* fallthrough */`.
- `size_t` for sizes and indices; never mix signed/unsigned.
- Header guards on every `.h`.

### C++
- RAII: resources owned by objects, never managed manually.
- `unique_ptr`/`shared_ptr` over raw owning pointers.
- `const` on non-mutating methods; `const&` for non-trivial parameters.
- `std::vector`/`std::array` over raw arrays; Rule of Zero; `explicit` on single-argument constructors.

### SQL
- Explicit column lists, never `SELECT *` in production paths.
- Consider an index for new WHERE/JOIN columns; do NOT over-index write-heavy tables.
- Run `EXPLAIN` on queries that will scan large tables.

## Self-review before presenting

- State each unit's purpose in one sentence — if you can't, restructure.
- Is the complexity acceptable for realistic input sizes?
- Edge cases handled, or explicitly out of scope?
- Correct > clear > efficient > maintainable — in that order.
