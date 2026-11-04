---
name: scientific-writing-en
description: 'Use whenever the user writes, drafts, revises, edits, polishes, or translates scientific or academic prose in ENGLISH - Q1 research articles, theses, dissertations, abstracts, introductions, methods, results, discussions, conclusions, acknowledgments, literature reviews, grant proposals, conference papers, or any IMRaD section. Triggers: "write the introduction", "draft the abstract", "help me with the discussion", "polish this scientific paragraph", "translate this paper to English", "this sounds like AI, rewrite it", "write the methods section", "I need phrases for...", "academic English", "make this sound more academic", "make this Q1-ready".'
---

# Scientific Writing in English

Not for code comments, docstrings, commit messages, casual emails, or marketing copy.

## Rules

This skill is a fixed procedure for every model and harness.

- Run steps 0-7 in order. Never skip, merge, reorder, or shorten a step. If a step cannot be completed, stop and say which and why.
- Do not be creative: remove only defects that a reference file names.
- Time pressure never justifies reading less or skipping checks. To go faster, process fewer paragraphs, and say so.
- Never claim the skill was followed if any step was skipped or partial.

## Step 0. Precedence

User instructions > project instructions (`AGENTS.md`, `CLAUDE.md`, memory) > this skill > references. List the applicable writing preferences (for example "no colons or dashes inside paragraphs", "existing paragraphs: grammar only"); they override any reference.

## Step 1. Scope and mode

Number the paragraphs P1, P2, ... under their section heading. Take the mode from the request, or ask if unclear:

- **Correct:** spelling, grammar, punctuation only.
- **Polish:** fix only defects named by a reference.
- **Draft:** new prose only from content the user supplied.
- **Translate:** translate, then apply Polish.

Process a document one section at a time, steps 2-7 per section.

## Step 2. Load references in full (gate)

Loaded means every line read in the current context. Headings, grep, line ranges, or "relevant sections" do not count; read long files in chunks to the end. After a summary or compaction, reread.

**Always:** `core-principles.md`, `qa-checklist.md`, `quick-replacements.md`, `punctuation-articles.md`, `paragraph-structure.md`, `academic-style.md`, `connectors-time.md`, `caution-hypothesis.md`, `critical-writing.md`.

**By section:**

| Section | Files |
|---|---|
| Introduction, problem, justification, questions, hypothesis, objectives, contributions, scope | `introduction.md` |
| State of the art, related work | `introduction.md`, `references-citations.md`, `classify-compare.md`, `support-contrast.md` |
| Theoretical framework, background | `define-cause-effect.md`, `classify-compare.md`, `shared-knowledge-signposting.md` |
| Methods, protocol | `methods.md`, `grammar-numbers-units.md`, `statistics-and-measurement.md` |
| Results | `results.md`, `grammar-numbers-units.md`, `quantity-order-change-interpretation.md` |
| Discussion | `discussion.md`, `support-contrast.md`, `viewpoints.md` |
| Abstract, conclusions | `conclusion-abstract.md` |
| Acknowledgments | `acknowledgments-authors.md` |

**By trigger** (literal scan of each paragraph, not a judgment):

| Paragraph contains | Files |
|---|---|
| Citation | `references-citations.md` |
| Number, unit, or quantity word (many, most, few, several) | `grammar-numbers-units.md`, `quantity-order-change-interpretation.md` |
| Statistic, metric, test, error rate | `statistics-and-measurement.md` |
| for example, for instance, such as, e.g. | `exemplify.md` |
| Definition (is defined as, refers to, is termed) | `define-cause-effect.md` |
| because, since, as, causes, leads to, therefore, thus | `define-cause-effect.md` |
| than, unlike, whereas, in contrast, compared with, rather than | `classify-compare.md`, `support-contrast.md` |
| List or classification | `classify-compare.md` |
| Evaluation of other work or a gap | `critical-writing.md`, `viewpoints.md` |
| Preview, roadmap, cross-reference | `shared-knowledge-signposting.md` |

## Step 3. Ledger (gate)

Before any edit, print the step 0 preferences, each required file with its line count, and the triggers per paragraph. A missing file sends you back to step 2.

## Step 4. Diagnose

Per paragraph, list each defect as: quoted text | defect | reference file and section. "Sounds better" is not a defect. Paragraphs without defects stay unchanged.

## Step 5. Edit

Make the smallest change that removes each diagnosed defect.

Allowed: spelling, grammar, agreement, articles, punctuation; phrases listed in `quick-replacements.md` or `academic-style.md`; recalibrating an overclaim per `caution-hypothesis.md` without changing the claim; replacing a repeated connective; reordering within a sentence for given-new order; splitting a run-on or comma splice. Correct mode allows only the first item.

Forbidden: adding claims, examples, transitions, or citations; deleting claims, citations, numbers, or qualifiers; changing technical or author terms, numbers, units, citation keys, labels, cross-references, or math; synonyms for domain terms; merging, splitting, or reordering paragraphs; bank phrases without a diagnosed defect; changing meaning or claim strength.

Draft mode uses only the user's content and passes steps 4-6.

## Step 6. Verify

With commands when the text is in a file: the diff touches only diagnosed sentences; citation keys, numbers, labels, and math are unchanged; output is ASCII except accented names and math; no step 0 forbidden punctuation; the project compiles. Then check `qa-checklist.md` and `quick-replacements.md`. Any failure returns to step 5.

## Step 7. Report

In the user's language: the ledger; per paragraph, original | revised | defect | reference ("no defect found" otherwise); the step 6 results; deviations, or "No deviations".

## Reference index

All files are in `references/`.

- `academic-style.md` - register, tautology, cliches, nominalization, confused words, US spelling
- `acknowledgments-authors.md` - acknowledgments, funding, contributor statements
- `caution-hypothesis.md` - hedging, hypothesizing, possibility, assumption, implication
- `classify-compare.md` - classifications, lists, similarities, contrasts
- `conclusion-abstract.md` - summary, synthesis, contribution, implications
- `connectors-time.md` - time expressions, connectives, transitions
- `core-principles.md` - Q1 criteria and the 11 rules
- `critical-writing.md` - limitations, weaknesses, evaluative language
- `define-cause-effect.md` - definitions, exceptions, causality
- `discussion.md` - restate, compare, explain, limit, imply
- `exemplify.md` - examples and illustration
- `grammar-numbers-units.md` - plurals, agreement, numbers, SI units
- `introduction.md` - territory, niche, gap, aim, structure (CARS)
- `methods.md` - design, sample, procedure, instruments
- `paragraph-structure.md` - topic sentences, given-new order, cohesion
- `punctuation-articles.md` - punctuation, abbreviations, capitals, articles
- `qa-checklist.md` - final self-check
- `quantity-order-change-interpretation.md` - quantity, order, change
- `quick-replacements.md` - LLM-tell phrases and padding
- `references-citations.md` - reporting verbs, synthesis, quotations
- `results.md` - presenting findings, tables, figures
- `shared-knowledge-signposting.md` - previews, transitions, summaries
- `statistics-and-measurement.md` - statistical reporting
- `support-contrast.md` - contrasting own work, support, explanation
- `viewpoints.md` - agreement, disagreement, own position
