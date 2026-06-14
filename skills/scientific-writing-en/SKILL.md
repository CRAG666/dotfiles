---
name: scientific-writing-en
description: Use whenever the user writes, drafts, revises, edits, polishes, or translates scientific or academic prose in ENGLISH - Q1 research articles, theses, dissertations, abstracts, introductions, methods, results, discussions, conclusions, acknowledgments, literature reviews, grant proposals, conference papers, or any IMRaD section. Provides 5000+ pre-cooked, idiomatic, native-academic phrases plus paragraph- and sentence-level guidance for every standard section of a scientific document, avoiding robotic / LLM-style prose. Triggers: "write the introduction", "draft the abstract", "help me with the discussion", "polish this scientific paragraph", "translate this paper to English", "this sounds like AI, rewrite it", "write the methods section", "I need phrases for...", "academic English", "make this sound more academic", "make this Q1-ready".
---

# Scientific Writing in English

## When to use this skill

Activate whenever the user asks to produce, correct, polish or translate scientific-academic text in English, with a particular focus on **Q1 (top-quartile) journal quality**. The core purpose is to **replace the generic, telltale "LLM-default" prose with established academic English constructions** drawn from the Academic Phrasebank tradition, and to lift drafts to the structural and rhetorical standards reviewers expect at top-tier journals.

**Do NOT activate for**: code comments, docstrings, commit messages, casual emails, marketing copy, fiction, or general non-academic writing. If the user is writing a blog post or popular-science piece, ask before invoking the academic register - these usually want lighter, more accessible prose.

## What "Q1 quality" actually means

Reviewers at top-quartile journals reject not for missing data but for prose that reads as imprecise, overclaiming, padded, or structurally weak. Aim for all of the following simultaneously:

- **Clear rhetorical moves.** Every paragraph announces its function (claim, evidence, qualification, comparison). The reader should never wonder *why* a sentence is on the page.
- **Calibrated stance.** Claims are hedged to match evidence: strong evidence -> confident verb; weak or single-study evidence -> tentative verb. Overclaim and you sound naive; underclaim and you sound trivial.
- **Tight cohesion.** Sentences flow given-then-new: each sentence picks up a thread from the prior one and extends it. Connectives are varied and earn their place.
- **No padding.** Cut "it is important to note that", "in order to", "due to the fact that", "a wide range of". Q1 prose is dense, not chatty.
- **Discipline-appropriate voice.** Methods often passive; results often active with the data as subject ("the data show..."); discussion mixes both depending on whether agent or action matters.
- **Reporting verb stance.** Choose *argues*, *contends*, *demonstrates*, *suggests*, *posits* deliberately - they signal your view of the cited author. Repeated bare "Smith said" or "according to Smith" is a tell of inexperience.

## Core principles

These are not arbitrary rules; each prevents a specific failure mode that marks text as AI-generated or as non-native academic writing.

1. **Avoid LLM-tell phrases.** Phrases like "delve into", "navigate the complexities of", "tapestry of", "in the realm of", "it is important to note that", "in today's fast-paced world", "a testament to", "stands as", "underscores the importance of [generic-noun]", "pivotal", "showcases", "leverages", "robust framework" (in non-statistical use), "comprehensive understanding" - these have become statistical fingerprints of LLM output. They will flag the text as AI-generated to any reader (or detector) familiar with the pattern. See the replacement list at the bottom of this file.
2. **Hedge with epistemic caution.** Science is written with calibrated uncertainty. Prefer "suggest", "indicate", "appear to", "the data are consistent with" over "prove", "show clearly", "demonstrate" - unless the evidence is genuinely conclusive. Overclaiming is a hallmark of inexperienced (or AI) writing. See `caution-hypothesis.md`.
3. **Vary connectives.** Repeated "however", "moreover", "furthermore", "therefore" make prose mechanical. Rotate with the alternatives in `connectors-time.md`.
4. **Tense discipline.** Different tenses signal different epistemic statuses:
   - **Past simple** for methods, completed studies, and specific past findings ("Smith found...", "we measured...").
   - **Present simple** for established knowledge and what the current paper does ("the data show...", "this paper argues...").
   - **Present perfect** for the accumulated body of literature ("research has shown...", "studies have indicated...").
5. **Citation grammar.** Use the patterns in `references-citations.md`. Avoid repeated "According to [Author]". Prefer reporting verbs that signal stance: argues, contends, claims, demonstrates, suggests, posits, maintains, holds.
6. **Paragraph structure.** Open paragraphs with a topic sentence that states the claim; develop it with evidence, examples, qualifications; close with an inference or transition. Never bury the claim. See `paragraph-structure.md`.
7. **No emojis. No decorative bold. No bullet points** inside the body of a scientific paragraph. Bullets are acceptable only in genuine enumerations (methods steps, lists of conditions, research questions).
8. **US English only** (analyze, behavior, organize, color, center, toward, focused, modeling, labeled, while, among). Use US spelling, vocabulary, and punctuation conventions consistently. Do NOT use British forms: never *analyse, behaviour, organise, colour, centre, fibre, defence, towards, whilst, amongst, modelling, labelled, per cent*; always their US equivalents (*analyze, behavior, organize, color, center, fiber, defense, toward, while, among, modeling, labeled, percent*).
9. **Active voice when the agent matters; passive when the action matters.** Modern academic English allows "we measured", but "the samples were measured" remains common in methods sections - both are defensible; consistency within the document is what counts.
10. **No contractions, no colloquialisms, no rhetorical questions in body prose.** "Don't" -> "do not"; "a lot of" -> "many" or "a considerable amount of"; "What does this mean? It means that..." -> assert the claim directly. See `academic-style.md`.
11. **ASCII punctuation only - no decorative Unicode characters.** Do NOT emit typographic Unicode in the delivered text. (The characters below are named by their Unicode code point on purpose, so that this rule itself stays pure ASCII.) Use plain ASCII equivalents:
    - Em dash (U+2014) and en dash (U+2013): use a hyphen with spaces, a comma, a colon, or parentheses, whichever the sentence calls for. Never the em/en dash glyph - this is the strongest single fingerprint of machine-generated text.
    - Curly/smart double quotes (U+201C, U+201D) and single quotes (U+2018, U+2019): use straight quotes (" and ').
    - Horizontal ellipsis (U+2026): use three plain periods (...), or simply cut it.
    - Non-breaking space (U+00A0), thin space (U+2009), zero-width space (U+200B): use a normal ASCII space.
    - Bullet (U+2022), arrows (U+2192, U+21D2), multiplication sign (U+00D7), minus sign (U+2212), middle dot (U+00B7): spell them out or use ASCII (-, ->, x, -).
    This is the single most common giveaway of copy-pasted or AI text and it breaks many journal submission systems, LaTeX pipelines, and plain-text encodings. Keep the output 7-bit ASCII; the only exceptions are characters genuinely required by the content (e.g. mathematical symbols, accented author names, units).

## Rhetorical moves (Swales' CARS model)

Reviewers expect introductions to perform three moves, in order:

1. **Establish a territory.** State what the field cares about and why it matters - supported by literature (`introduction.md` section Background, Synthesis).
2. **Establish a niche.** Identify a gap, conflict, or unanswered question (`introduction.md` section Knowledge gap, Controversy, Weaknesses in prior literature).
3. **Occupy the niche.** State the present study's aim, questions, and contribution (`introduction.md` section Purpose, Research questions, Significance).

Discussions follow Hopkins & Dudley-Evans' move structure: (1) restate findings; (2) compare with prior literature (agreement / contradiction); (3) explain the result; (4) acknowledge limitations; (5) state implications and future work. Files `discussion.md` and `conclusion-abstract.md` map directly onto these moves.

## How to work

1. **Identify the section** the user needs (Abstract, Introduction, Methods, Results, Discussion, Conclusion, or a transverse function - comparing, defining, being critical, etc.).
2. **Read ONLY the relevant reference file** from `references/` before drafting. Do not load them all - each file is several hundred lines.
3. **Pick phrases from the bank** and adapt them to the user's content, replacing X, Y, Z and "Author" placeholders with their real terms.
4. **Combine and vary** - never chain three phrases from the same subsection in a row; the text must flow as prose, not look like a phrasebook collage.
5. **Apply paragraph structure.** Before writing, decide the topic sentence and the role of each subsequent sentence (evidence, qualification, example, transition). See `paragraph-structure.md` for the controlling-idea + supporting-detail pattern.
6. **Run a final pass for LLM-tells and padding.** Re-read for the phrases in the replacement list below, for repeated connectives, and for vacuous intensifiers ("very", "really", "extremely", "absolutely"). Cut or replace.
7. **Deliver finished prose, not a phrase menu.** Default output is a polished paragraph the user can paste into their document. Only return a list of phrase options if the user explicitly asks "give me options" or "show me alternatives".
8. If the user's request doesn't fit any single file, read `critical-writing.md` and `connectors-time.md` - they cut across sections.

## Self-check before delivering

Before returning a draft, verify:

- [ ] Each paragraph has an identifiable topic sentence.
- [ ] No banned LLM-tell phrase appears (see list below).
- [ ] Connectives are varied; "however" / "moreover" / "furthermore" appear at most once each per paragraph.
- [ ] Hedging matches evidence strength (no "proves" without conclusive proof; no "may suggest the possibility of" when the result is unambiguous).
- [ ] Citation grammar is varied (not five "According to X" in a row).
- [ ] No contractions, colloquialisms, rhetorical questions in body prose.
- [ ] Tense use is consistent within section (past for completed methods/findings; present perfect for the literature; present for established knowledge and what the paper does).
- [ ] No tautology ("past history", "future prospects", "positive benefit"). See `academic-style.md`.
- [ ] No decorative Unicode: no em dash (U+2014), en dash (U+2013), curly quotes (U+201C/201D/2018/2019), ellipsis glyph (U+2026), or non-breaking spaces. Use a spaced hyphen, straight quotes, three periods, and normal spaces instead. Output is plain ASCII.

## Reference index

IMRaD structure and front matter:

- `acknowledgments-authors.md` - Acknowledgments, funding, conflicts of interest, about-the-author, contributor statements.
- `introduction.md` - Background, importance, literature synthesis, problem statement, controversy, knowledge gap, study aim, research questions, hypotheses, structure, limitations.
- `methods.md` - Type of study, data sources, design, justification of methodology, sample, procedure, instruments, methodological limitations. For statistical procedures, tests and questionnaire/Likert design, see `statistics-and-measurement.md`.
- `results.md` - Referencing method, presenting data, tables/figures, positive/negative results, unexpected findings, questionnaires, qualitative data, summary. For reporting test statistics and p-values, see `statistics-and-measurement.md`.
- `discussion.md` - Background, linking results to discussion, agreement, contradiction, supporting prior literature, explaining results, caution, tentative hypotheses, consequences, future research.
- `conclusion-abstract.md` - Restating, summary, restatement of purpose, synthesis of findings, strengths, limitations, implications, contribution, recommendations for practice/policy.
- `statistics-and-measurement.md` - Measurement and quantification operations; statistical procedures (software, reliability, significance thresholds); statistical tests and analyses (t-test, ANOVA, regression, correlation, chi-square); reporting test statistics, p-values and effect sizes; descriptive statistics (means, SDs, ranges, ratios); proportions and percentages; questionnaire and Likert-scale design. Used mainly in Methods and Results.

Structural and stylistic craft (use across all sections):

- `paragraph-structure.md` - Topic sentences, controlling idea + supporting detail, given-new ordering, cohesion devices, paragraph-level moves, worked examples.
- `academic-style.md` - Formality register, avoiding colloquialism / contraction / tautology, weak-verb replacement, vague intensifiers, bias-free language, nominalization.
- `shared-knowledge-signposting.md` - Indicating shared knowledge ("It is widely accepted..."), previewing sections, transitioning between sections, summarizing and re-orienting the reader.
- `punctuation-articles.md` - Mechanical correctness rules: comma / semicolon / colon / quotation-mark / dash / apostrophe usage, and article use (a/an/the/zero) with countable, uncountable, plural nouns and names. Use when editing for correctness, not phrasing.

Transverse functions (useful in every section):

- `critical-writing.md` - Limitations of argument, weaknesses of a study, general criticism, criticism of specific authors, constructive suggestions, evaluative adjectives, positive evaluation.
- `classify-compare.md` - Classifications and lists; differences, similarities, contrasts and correspondences.
- `define-cause-effect.md` - Definitions, definitional difficulties, definitions from authors, exceptions, causality, correlation.
- `caution-hypothesis.md` - Distancing the author, hypothesizing explanations, caution about present/future, cautious interpretation, hypothesis, possibility/probability, assumption, implication, rhetorical questions.
- `viewpoints.md` - Agreement/support, disagreement/against, stating your own viewpoint.
- `references-citations.md` - General existing evidence, references to past and current research, multiple-author evidence, single-author references, synthesizing sources, direct quotations.
- `exemplify.md` - Examples as main information, cases as support, what examples show, illustration.
- `connectors-time.md` - Past/present/future tense, duration, frequency, introducing and transitioning between sections, section summary.
- `support-contrast.md` - Contrasting your own work, supporting a viewpoint, stating features, giving explanations.
- `quantity-order-change-interpretation.md` - Quantity, order, change (increase/decrease), interpretation of findings.

## Quick reference: idiomatic replacements

Common "AI-default" English and acceptable substitutes:

- **"This paper explores..."** -> "This paper examines...", "This study investigates...", "The aim of this study is to...", "This article addresses...", "The present study focuses on...".
- **"It is important to note that..."** -> "It is worth noting that...", "Notably,", "Importantly,", "A point worth noting is that...", "It should be emphasized that...", or just cut and assert the point.
- **"The results show that..."** repeatedly -> alternate with "The findings suggest...", "The data indicate...", "It emerges from the results that...", "The results highlight...", "These results provide evidence that...", "Analysis revealed that...".
- **"In conclusion,"** -> "Taken together,", "On balance,", "In light of these findings,", "These findings suggest, on the whole, that...", "In sum,".
- **"As we all know..."** -> eliminate; science does not appeal to the reader like this. Replace with "It is widely accepted that..." or "There is broad consensus that..." with citation.
- **"Delve into..."** / **"Navigate the complexities of..."** -> "Examine in detail...", "Investigate in depth...", "Engage closely with...", "Analyze...".
- **"In today's rapidly evolving world,"** / **"In today's fast-paced..."** -> cut entirely or replace with a specific, dated, cited empirical claim.
- **"A myriad of"** / **"A plethora of"** -> "A range of", "Several", "Numerous", "A variety of".
- **"It is worth mentioning that..."** -> "Notably,", "It is worth noting that,", or cut.
- **"Plays a crucial role"** repeated -> "plays a central role", "is integral to", "is fundamental to", "underpins", "is a key driver of", "mediates".
- **"A testament to..."** -> "evidence of...", "an indication that...".
- **"Stands as..."** -> just "is".
- **"Underscores the importance of..."** -> "highlights the need for...", "emphasizes...", or simply state the implication.
- **"Pivotal"** / **"crucial"** / **"vital"** as filler -> use only when the literal meaning fits; otherwise "important", "central", or cut.
- **"Showcases"** -> "shows", "demonstrates", "presents".
- **"Leverages"** -> "uses", "draws on", "exploits", "applies".
- **"Robust" / "comprehensive"** as generic praise -> either name what makes it robust/comprehensive, or cut.
- **"In order to"** -> "to".
- **"Due to the fact that"** -> "because".
- **"A wide range of"** -> "a range of", or be specific.
- **"It can be seen that..."** repeated -> "The data show...", "X is evident...", "As shown in Figure N,...".
- **"This study aims to shed light on..."** -> "This study examines...", "This study investigates...".
- **Vacuous intensifiers** ("very", "really", "extremely", "absolutely", "incredibly") -> cut, or pick a precise adjective ("substantial", "marked", "negligible", "consistent").

## Attribution

Phrase bank adapted from *PhraseBook for Writing Papers and Research in English* (Howe & Henriksson, 2007, EnglishforResearch.com) and *Academic Phrasebank* (Morley, 2021, University of Manchester), with structural framing inspired by *5000 frases precocinadas para textos científicos* (Margolles García, NeoScientia, CC BY-NC) and the Swales (1990) CARS model for research-article introductions.
