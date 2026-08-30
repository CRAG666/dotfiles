---
name: scientific-writing-en
description: 'Use whenever the user writes, drafts, revises, edits, polishes, or translates scientific or academic prose in ENGLISH - Q1 research articles, theses, dissertations, abstracts, introductions, methods, results, discussions, conclusions, acknowledgments, literature reviews, grant proposals, conference papers, or any IMRaD section. Provides 5000+ pre-cooked, idiomatic, native-academic phrases plus paragraph- and sentence-level guidance for every standard section of a scientific document, avoiding robotic / LLM-style prose. Triggers: "write the introduction", "draft the abstract", "help me with the discussion", "polish this scientific paragraph", "translate this paper to English", "this sounds like AI, rewrite it", "write the methods section", "I need phrases for...", "academic English", "make this sound more academic", "make this Q1-ready".'
allowed-tools: Read, Grep, Glob
---

# Scientific Writing in English

Do NOT activate for code comments, docstrings, commit messages, casual emails and marketing copy.

## Goal

Replace generic "LLM-default" prose with established academic English constructions, and lift drafts to Q1-journal structural and rhetorical standards. See `references/core-principles.md` for what "Q1 quality" means and the 11 non-negotiable rules (hedging, tense discipline, US spelling, ASCII-only punctuation, citation grammar, etc.) - read this file on first use in a session, before drafting anything.

## Steps

1. **Analyze the context and intent.** Read the section or the indicated paragraph; if you are asked to correct a file, read it section by section.
2. **Identify the section or function** the text belongs to (see "Reference index").
3. **Load references.** Read `references/core-principles.md` AND the relevant `references/*.md` if not already loaded this session.
4. **Draft finished prose**, not a phrase menu. Pick phrases from the loaded bank, adapt them to the user's actual content (replace X/Y/Z/"Author" placeholders), and combine/varry them so the result reads as natural prose, not a phrasebook collage.
5. **Self-check before delivering** using `references/qa-checklist.md`. If the draft fails any check, revise it internally before moving on.
6. **Final pass:** scan against `references/quick-replacements.md` for LLM-tell phrases and padding. Cut or replace anything that matches.

Default output is a polished paragraph ready to paste into the document. Only return a list of phrase options if the user explicitly asks for alternatives.

## Reference index

- `references/acknowledgments-authors.md` - Acknowledgments, funding, conflicts of interest, about-the-author, contributor statements.
- `references/introduction.md` - Background, importance, literature synthesis, problem statement, controversy, knowledge gap, study aim, research questions, hypotheses, structure, limitations. Follows Swales' CARS model (territory -> niche -> occupy niche).
- `references/methods.md` - Study type, data sources, design, methodology justification, sample, procedure, instruments, methodological limitations.
- `references/results.md` - Referencing method, presenting data, tables/figures, positive/negative/unexpected findings, questionnaires, qualitative data, summary.
- `references/discussion.md` - Background, linking results to discussion, agreement/contradiction with prior literature, explaining results, caution, tentative hypotheses, consequences, future research. Follows Hopkins & Dudley-Evans' move structure (restate -> compare -> explain -> limitations -> implications).
- `references/conclusion-abstract.md` - Restating, summary, synthesis of findings, strengths, limitations, implications, contribution, recommendations.
- `references/statistics-and-measurement.md` - Measurement/quantification language; statistical procedures and tests (t-test, ANOVA, regression, correlation, chi-square); reporting statistics, p-values, effect sizes; descriptive statistics; Likert-scale design. Mainly Methods/Results.

- `references/paragraph-structure.md` - Topic sentences, controlling idea + supporting detail, given-new ordering, cohesion devices.
- `references/academic-style.md` - Formality register, colloquialism/contraction/tautology/cliche avoidance, weak-verb replacement, bias-free language, nominalization, confused word pairs, US/British spelling conversion.
- `references/shared-knowledge-signposting.md` - Indicating shared knowledge, previewing/transitioning between sections, summarizing and re-orienting the reader.
- `references/punctuation-articles.md` - Comma/semicolon/colon/quotation/dash/apostrophe rules, abbreviations, capitalization, article use (a/an/the/zero). Use when editing for mechanical correctness.
- `references/grammar-numbers-units.md` - Irregular plurals (datum/data, criterion/criteria...), subject-verb agreement on borrowed nouns, noncount nouns, number style, SI units. Use when editing Methods/Results for correctness.

- `references/critical-writing.md` - Limitations, weaknesses, criticism of specific authors, constructive suggestions, evaluative language.
- `references/classify-compare.md` - Classifications, lists, differences, similarities, contrasts.
- `references/define-cause-effect.md` - Definitions, exceptions, causality, correlation.
- `references/caution-hypothesis.md` - Distancing the author, hypothesizing, cautious interpretation, possibility/probability, assumption, implication.
- `references/viewpoints.md` - Agreement/support, disagreement, stating your own viewpoint.
- `references/references-citations.md` - Reporting-verb stance (argues, contends, demonstrates, suggests, posits), synthesizing sources, direct quotations. Avoid repeated "According to X".
- `references/exemplify.md` - Examples, cases, illustration.
- `references/connectors-time.md` - Tense/time connectives, frequency, section transitions. Use to vary repeated "however/moreover/furthermore/therefore".
- `references/support-contrast.md` - Contrasting own work, supporting a viewpoint, explanations.
- `references/quantity-order-change-interpretation.md` - Quantity, order, change (increase/decrease), interpretation of findings.

If a request doesn't map to a single file, read `references/critical-writing.md` and `references/connectors-time.md` - they cut across sections.

## Attribution

Phrase bank adapted from *PhraseBook for Writing Papers and Research in English* (Howe & Henriksson, 2007, EnglishforResearch.com) and *Academic Phrasebank* (Morley, 2021, University of Manchester), with structural framing from *5000 frases precocinadas para textos cientificos* (Margolles Garcia, NeoScientia, CC BY-NC) and Swales (1990) CARS model.
