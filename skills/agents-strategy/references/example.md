# Worked example

Request: "Add a Cox survival pipeline: loader, model, tests." Base commit `abc1234`.

Gate check: three outcomes, two of them independent, tests depend on both. Delegation pays off. A rename across three files would not: one worker or do it yourself.

## Task map

| task | outcome | depends on | reads | writes | acceptance |
| --- | --- | --- | --- | --- | --- |
| T1 | `src/load.py`: `load(path: Path) -> pl.DataFrame` with columns from `data/schema.md` | none | `data/schema.md`, `pyproject.toml` | `src/load.py` | `ruff check src/load.py`; `python -c "from src.load import load"` |
| T2 | `src/model.py`: `fit(df: pl.DataFrame) -> CoxPHSurvivalAnalysis` | T1 interface (given as text, not T1's file) | `data/schema.md` | `src/model.py` | `ruff check src/model.py`; `python -c "from src.model import fit"` |
| T3 | `tests/test_pipeline.py` passing | T1, T2 accepted | `src/load.py`, `src/model.py` | `tests/test_pipeline.py` | `pytest tests/test_pipeline.py -q` |

Schedule: T1 and T2 in parallel (T2 receives the `load` signature as a snapshot, so it never reads T1's output). T3 after both handoffs are accepted.

## Launch

Claude Code:

```text
Agent(subagent_type: "general-purpose", model: "sonnet", prompt: <contract T2>)
```

pi:

```text
subagent({ name: "T2 model", agent: "worker", model: "<provider>/<mid-tier-id>", thinking: "medium", task: <contract T2> })
```

## Contract T2

```xml
<assignment id="T2" status="ready">
  <role>Worker. Execute only this assignment. Do not delegate or expand scope.</role>
  <outcome>src/model.py exposes fit(df: pl.DataFrame) -> CoxPHSurvivalAnalysis</outcome>
  <context>
    <decisions>Library: scikit-survival. Duration column: time. Event column: event (int).</decisions>
    <invariants>load(path: Path) -> pl.DataFrame is being written by another worker; treat the signature as fixed. Do not read or edit src/load.py.</invariants>
  </context>
  <inputs>
    <source path="data/schema.md" version="abc1234" scope="whole file">Column names and types; wins over the task text.</source>
  </inputs>
  <ownership>
    <write_set>src/model.py</write_set>
    <forbidden>src/load.py, tests/, pyproject.toml, any commit</forbidden>
  </ownership>
  <procedure>
    <step number="1">Read data/schema.md. Stop and report if time or event is missing.</step>
    <step number="2">Write src/model.py. Run ruff check src/model.py.</step>
    <step number="3">Run python -c "from src.model import fit".</step>
  </procedure>
  <budget>
    <operations>Max 5 file reads, 3 ruff runs. No installs, no web search, no repo-wide grep.</operations>
    <retries>One fix cycle for ruff; then report.</retries>
  </budget>
  <acceptance>
    <criterion id="A1"><property>ruff clean</property><check>ruff check src/model.py</check><pass>exit 0</pass></criterion>
    <criterion id="A2"><property>importable</property><check>python -c "from src.model import fit"</check><pass>exit 0</pass></criterion>
  </acceptance>
  <handoff mode="message">Changed paths, commands run with exit codes, open decisions.</handoff>
</assignment>
```

## Handoff T2

```text
base: abc1234
changed: src/model.py (new, 31 lines)
checks: ruff check src/model.py -> 0; python -c "from src.model import fit" -> 0
not done: no tests (T3)
open: schema.md types event as int; I treat nonzero as event. Confirm.
```

## Acceptance by the parent

- `git diff abc1234 -- src/` shows only `src/model.py`. Passed.
- Rerun A2 myself: exit 0. Passed.
- Open decision: nonzero means event. Accepted; written into T3's contract.
- T3 launched with T1 and T2 accepted. T2's handoff is not evidence that the pipeline works end to end; that is A1 of T3.
