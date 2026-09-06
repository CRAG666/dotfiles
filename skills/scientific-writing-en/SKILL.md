---
name: scientific-writing-en
description: 'Use whenever the user writes, drafts, revises, edits, polishes, or translates scientific or academic prose in ENGLISH - Q1 research articles, theses, dissertations, abstracts, introductions, methods, results, discussions, conclusions, acknowledgments, literature reviews, grant proposals, conference papers, or any IMRaD section. Triggers: "write the introduction", "draft the abstract", "help me with the discussion", "polish this scientific paragraph", "translate this paper to English", "this sounds like AI, rewrite it", "write the methods section", "I need phrases for...", "academic English", "make this sound more academic", "make this Q1-ready".'
---

# Scientific Writing in English

Do NOT activate for code comments, docstrings, commit messages, casual emails and marketing copy.

## Goal

Improve the text to Q1 paper level. See `references/core-principles.md` for what "Q1 quality" means and the 11 non-negotiable rules (hedging, tense discipline, US spelling, ASCII-only punctuation, citation grammar, etc.) - read this file on first use in a session, before drafting anything.

## Steps

1. **Analyze the context and intent.** Determine the scope first:
   - **Single paragraph or short passage:** read it (plus any heading the user supplies); if its section is still ambiguous, infer it from rhetorical cues (tense, citations, "we measured" vs "this suggests"); if still ambiguous, ask.
   - **Whole file or long document (to correct, revise, translate, or draft):** read it section by section, never the whole file at once. Section boundaries are the document headings, which usually name the section explicitly ("Introduction", "3. Materials and Methods"). Process one section at a time and, within each section, apply the following steps paragraph by paragraph.
2. **Identify section and function.** Identify the section primarily from its heading; fall back to rhetorical cues (tense, citations, "we measured" vs "this suggests") when the heading is missing or uninformative. Then, per paragraph, determine the rhetorical functions it performs (caution, exemplify, contrast, ...) - see "## Reference index".
3. **Load references.** Read the references matching the current section and the functions of the paragraph being processed, if not already loaded this session. Decide each candidate now: load it or discard it with a reason - "maybe" is not an end state. Strong or universal claims in the paragraph ("the only", "no study has", "proves") make `references/caution-hypothesis.md` mandatory; register-level problems beyond the section bank make `references/academic-style.md` mandatory.
4. **Draft finished prose**, not a phrase menu. Pick phrases from the loaded bank, adapt them to the user's actual content (replace X/Y/Z/"Author" placeholders), and combine/vary them so the result reads as natural prose, not a phrasebook collage.
5. **Self-check** using `references/qa-checklist.md`; revise internally before moving on.
6. **Final pass:** scan against `references/quick-replacements.md` for LLM-tell phrases and padding. Cut or replace anything that matches.
7. **Deliver section by section**, in document order, before starting the next section.

## Reference index

- `references/academic-style.md` - Formality register, colloquialism/contraction/tautology/cliche avoidance, weak-verb replacement, bias-free language, nominalization, confused word pairs, US/British spelling conversion.
- `references/acknowledgments-authors.md` - Acknowledgments, funding, conflicts of interest, about-the-author, contributor statements.
- `references/introduction.md` - Background, importance, literature synthesis, problem statement, controversy, knowledge gap, study aim, research questions, hypotheses, structure, limitations. Follows Swales' CARS model (territory -> niche -> occupy niche).
- `references/methods.md` - Study type, data sources, design, methodology justification, sample, procedure, instruments, methodological limitations.
- `references/results.md` - Referencing method, presenting data, tables/figures, positive/negative/unexpected findings, questionnaires, qualitative data, summary.
- `references/discussion.md` - Background, linking results to discussion, agreement/contradiction with prior literature, explaining results, caution, tentative hypotheses, consequences, future research. Follows Hopkins & Dudley-Evans' move structure (restate -> compare -> explain -> limitations -> implications).
- `references/conclusion-abstract.md` - Restating, summary, synthesis of findings, strengths, limitations, implications, contribution, recommendations.
- `references/statistics-and-measurement.md` - Measurement/quantification language; statistical procedures and tests (t-test, ANOVA, regression, correlation, chi-square); reporting statistics, p-values, effect sizes; descriptive statistics; Likert-scale design. Mainly Methods/Results.
- `references/paragraph-structure.md` - Topic sentences, controlling idea + supporting detail, given-new ordering, cohesion devices.
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

Always read `references/critical-writing.md` and `references/connectors-time.md` regardless of the section being drafted: calibrated evaluative language and varied connectives are needed in every section, not only in Discussion.
