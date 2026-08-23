---
name: code-style-defaults
description: 'Personal default directives for any generated or edited code: check for an existing library before writing anything, then emit the smallest correct code with no AI filler. Apply whenever writing, editing, refactoring, or emitting code in any language — new files, patches, snippets in chat, scripts, config, notebooks. Enforces KISS, YAGNI, DRY, SRP and "less code is less debt"; bans unrequested comments, docstrings, demo blocks, defensive scaffolding, and explanatory padding around the diff. SKIP only when the user gives an explicit instruction that contradicts a rule here (their instruction wins) or when an existing file has a strong local convention. Decides the form of the output, not the architecture.'
---

# Code Style Defaults

Goal: pure code. The smallest correct implementation, with nothing around it that the user did not ask for.

Precedence: user's explicit instruction > convention of the file being edited > this list > language idiom.

## 0. Before writing any code — look for what already exists
- Do NOT write an implementation before checking whether a library already does it.
- DO search the web with WebSearch, and read the candidate's real docs with WebFetch, before writing anything non-trivial (a parser, a client, a retry policy, a date/units/path/config handling routine, a data structure, an algorithm with a name).
- DO check, in this order: the language's standard library → a library already in this project's manifest → an established third-party library → your own code, last.
- DO verify against the fetched docs: current version, maintenance status, license, actual API. Do NOT rely on memory for a library's API surface.
- DO tell the user in one line which library you found and what it replaces, before adding it.
- DO write it yourself when the library is unmaintained, heavyweight for the need, or the task is genuinely a few lines.
- Do NOT skip this step because writing it looks faster. Code you write is code someone maintains forever.
- Do NOT fetch the web for a one-line change, a fix inside existing code, or something the project already solved elsewhere.

## 1. Principles
- **Less code is less debt.** The best change is the one that adds no code. Prefer deleting to adding, calling to writing, configuring to coding.
- **KISS.** Do NOT introduce a pattern, layer, or indirection the problem does not force. The obvious solution wins until it demonstrably fails.
- **YAGNI.** Do NOT build for a requirement that has not been stated. No hooks, no flags, no "we might need it".
- **DRY.** Do NOT copy logic a third time — extract at the third occurrence, not the second. Do NOT extract two similar lines just to avoid repetition.
- **SRP.** Do NOT put two reasons-to-change in one unit. Do NOT split a cohesive unit into fragments to satisfy the rule.

## 2. No AI filler
- Do NOT add an `if __name__ == "__main__"` block, a `main()` demo, or "Example usage" nobody requested.
- Do NOT add `print` / `console.log` tracing to code that is not a CLI.
- Do NOT emit placeholder bodies (`pass`, `TODO: implement`, `...`) and present them as done.
- Do NOT generate a README, a CHANGELOG, or usage docs unless asked.
- Do NOT wrap a single call in a function that adds nothing.
- Do NOT create a class where a function is enough, or a config object for two parameters.
- Do NOT add argparse/CLI plumbing to a script that takes no arguments.
- Do NOT add emoji, ASCII art, decorative alignment, or banner separators anywhere.
- Do NOT restate the request back as a docstring, a header, or a variable named after the prompt.

## 3. Comments and docstrings
- Do NOT write comments.
- Do NOT write docstrings.
- Do NOT write module headers, section banners, `# --- helpers ---` dividers, or unrequested `TODO`s.
- Do NOT restate in a comment what the line does.
- Do NOT annotate obvious code ("increment counter", "loop over items", "return the result").
- Do NOT describe parameters or return types in prose when the signature already says it.
- Do NOT delete comments or docstrings that already exist in the file, unless the code they describe is gone.
- DO write one line when it records a non-obvious constraint, a workaround, or a bug being worked around.
- DO write documentation when the user asks for it.
- DO match the file's existing convention when every sibling unit is documented the same way.
- DO rename the variables instead, when the code would need a comment to be readable.

## 4. Explanation around the code
- Do NOT open with a preamble ("Here's what I'll do", "Great question").
- Do NOT close with a summary that restates the diff.
- Do NOT emit "Key improvements" / "Note that" / bullet recaps of obvious edits.
- DO state, in one or two sentences: what changed, which library you used, any assumption made under ambiguity, anything skipped, any test that failed.

## 5. Scope
- Do NOT add helpers, flags, options, or hooks that were not requested.
- Do NOT refactor code that was not part of the task.
- Do NOT add defensive handling for cases that cannot occur in this codebase.
- Do NOT introduce an abstraction that has one caller.
- DO say in one line if something adjacent is broken; do NOT fix it unprompted.

## 6. Naming
- Do NOT use `data`, `result`, `tmp`, `helper`, `manager`, `utils` as a whole name.
- Do NOT use single letters outside a tight loop or a math formula.
- Do NOT impose your casing on a file that uses another one.
- DO put in the name the meaning a comment would have carried.

## 7. Errors
- Do NOT swallow errors (`except: pass`, empty `catch`).
- Do NOT return `None`/`null` to signal a failure that deserves an exception.
- Do NOT wrap code in `try` unless a specific failure is expected and handled differently.
- Do NOT re-validate inputs already validated at the boundary.
- DO validate at boundaries: CLI args, HTTP payloads, file reads, external API responses.
- DO fail loud, with context.

## 8. Types
- Do NOT use `Any` / `any` as an escape hatch.
- Do NOT annotate short local helpers whose types are obvious at the call site.
- DO annotate anything exported or crossing a module boundary.

## 9. Tests
- Do NOT write tests unless asked, or unless the project's convention makes an untested change incomplete.
- Do NOT mock the thing under test.
- Do NOT assert something the code does not guarantee just to make it green.
- DO test behaviour, one assertion theme per test.

## 10. Dependencies
- Do NOT add a package without saying so.
- Do NOT add a dependency for something the standard library already does.
- Do NOT pin a version you have not verified exists.
- DO prefer one well-maintained dependency over a hand-rolled equivalent (see §0).

## 11. Formatting
- Do NOT hand-format against a configured formatter (`ruff`, `black`, `prettier`, `clang-format`, `.editorconfig`).
- Do NOT reformat lines the change does not touch.

## Before emitting code
- Did I check for an existing library? If not, go back to §0.
- Delete any comment or docstring nobody asked for.
- Delete any demo, example, or debug output nobody asked for.
- Delete anything outside the requested scope.
- Can this be shorter, flatter, or removed entirely?
