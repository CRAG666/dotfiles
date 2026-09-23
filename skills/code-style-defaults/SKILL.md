---
name: code-style-defaults
description: 'Personal defaults for any generated or edited code, any language (incl. Typst/LaTeX) – files, patches, chat snippets, scripts, config, notebooks: check for an existing library first, then emit the smallest correct code with no AI filler (no unrequested comments, docstrings, demos, defensive scaffolding). KISS/YAGNI/DRY/SRP; less code is less debt. Governs the form of the output, not the architecture. Precedence: user instruction > file convention > this list. Skip only on explicit user contradiction or strong local convention.'
---

# Code Style Defaults

Goal: The correct implementation, with nothing around it the user did not ask for.
Precedence: user's explicit instruction > convention of the file being edited > this list > language idiom.

## 0. Before writing – find what exists
For non-trivial code (parser, client, retry, date/units/path/config, named algorithm or data structure): search the web and read the candidate's docs – version, maintenance, license, API; never memory. Prefer, in order: stdlib > a manifest dependency > established third-party > writing your own. Announce in one line the library and what it replaces; write it yourself only if it is unmaintained/overkill or the task is a few lines. Never skip because writing looks faster. No web fetch for one-liners, fixes inside existing code, or what the project already solved.

## 1. Principles
- Less code is less debt: prefer deleting to adding, calling to writing, configuring to coding.
- KISS: no pattern, layer, or indirection the problem does not force.
- YAGNI: nothing for unstated requirements – no hooks, flags, "might need it".
- DRY: extract at the third occurrence, not the second; never extract two similar lines.
- SRP: no two reasons-to-change in one unit; no fragmenting a cohesive unit either.
- Before emitting: can it be shorter, flatter, or removed entirely?

## 2. Output
- **Filler:** no demos (`__main__` blocks, `main()`, "Example usage"), `print`/`console.log` tracing in non-CLI code, placeholders presented as done (`pass`, `TODO: implement`), README/CHANGELOG/usage docs, single-call wrappers, classes where a function suffices, config objects for two parameters, argparse for argument-less scripts, emoji/decorative alignment, or restating the request as a docstring, header, or variable name.
- **Comments/docstrings:** none by default – no banners or dividers, no restating lines, no annotating the obvious, no typing in prose what the signature says. Rename variables instead of commenting. Keep what exists (delete it with its code; never keep commented-out code – VCS keeps history). One line only for a non-obvious constraint or workaround, on request, or when every sibling is documented alike.
- **Prose:** no preamble, recap, or "Key improvements". One or two sentences: what changed, library used, assumptions, anything skipped or failing.
- **Scope:** no unrequested helpers, flags, or hooks; no out-of-task refactors; no handling of impossible cases; no single-caller abstraction. Adjacent breakage gets one line, not an unprompted fix.
- **Naming:** no `data`, `result`, `tmp`, `helper`, `manager`, `utils`; no single letters outside a tight loop or math; match the file's casing; the name carries what a comment would.

## 3. Details
- **Errors:** no swallowed errors (`except: pass`), no `None`/`null` signalling a failure that deserves an exception, no `try` without a specific expected and differently-handled failure. Validate at boundaries (CLI args, HTTP payloads, file reads, external API responses); do not re-validate inside. Fail loud, with context.
- **Types:** no `Any`/`any` as an escape hatch. Annotate everything exported or crossing a module boundary; skip obvious short local helpers.
- **Tests:** only when asked, or when project convention makes an untested change incomplete. Never mock the thing under test or assert what the code does not guarantee just to go green. Test behaviour, one assertion theme per test.
- **Dependencies:** never add a package without saying so, or pin a version you have not verified exists.
- **Formatting:** never hand-format against a configured formatter (`ruff`, `black`, `prettier`, `clang-format`, `.editorconfig`). After generating or editing a code file, run the project's configured formatter on it (`ruff format`, `prettier --write`, `gofmt`, etc.) and show the code as formatted; if no formatter is configured for the language, say so instead of guessing.
- **Edits:** patch existing files (unified diff or search/replace blocks), never re-emit the whole file unless rewriting it entirely; include only the minimum context needed. A snippet shown in chat is not a file edit – emit it in full.
- **Verification:** verify with a command (compiler, interpreter, linter, formatter check mode), never by re-reading the output. If no command exists for the language, say the code is unverified.
