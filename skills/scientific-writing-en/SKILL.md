---
name: scientific-writing-en
description: Use whenever the user writes, drafts, revises, edits, polishes, or translates scientific or academic prose in ENGLISH — research articles, papers, theses, dissertations, abstracts, introductions, methods, results, discussions, conclusions, acknowledgements, literature reviews, grant proposals, conference papers, or any IMRaD section. Provides 5000+ pre-cooked, idiomatic, native-academic phrases for every standard section of a scientific document, avoiding robotic / LLM-style prose. Triggers: "write the introduction", "draft the abstract", "help me with the discussion", "polish this scientific paragraph", "translate this paper to English", "this sounds like AI, rewrite it", "write the methods section", "I need phrases for...", "academic English", "make this sound more academic".
---

# Scientific Writing in English

## When to use this skill

Activate ALWAYS when the user asks to produce, correct, polish or improve scientific-academic text in English. The core purpose is to **replace the generic, telltale "LLM-default" prose with established academic English constructions** drawn from the Academic Phrasebank tradition.

## Non-negotiable principles

1. **Never start sentences with "delve", "navigate the complexities of", "tapestry", "in the realm of", "it is important to note that", "in today's fast-paced world"**, or any of the other LLM-tell phrases. These mark text as AI-generated.
2. **Hedge appropriately**: science is written with epistemic caution. Use "suggest", "indicate", "appear to", "the data are consistent with" instead of "prove", "show clearly", "demonstrate that" unless the evidence is genuinely conclusive. See `caution-hypothesis.md`.
3. **Vary connectives**: do not overuse "however", "moreover", "furthermore", "therefore". Rotate with the items in `connectors-time.md`.
4. **Tense discipline**:
   - **Past simple** for methods, completed studies, and reporting specific past findings ("Smith found…", "we measured…").
   - **Present simple** for established knowledge, general truths, and what the current paper does ("the data show…", "this paper argues…").
   - **Present perfect** for the body of accumulated literature ("research has shown…", "studies have indicated…").
5. **Citation grammar**: use the patterns in `references-citations.md`. Avoid repeated "According to [Author]". Prefer reporting verbs that signal stance: argues, contends, claims, demonstrates, suggests, posits.
6. **No emojis. No decorative bold. No bullet points** inside the body of a scientific paragraph (bullets are acceptable only in lists, methods steps, or genuine enumerations).
7. **US English by default**: this phrasebank is in native US academic English (analyze, behavior, organize, color, center, toward, focused, modeling, labeled, while, among). If the target journal explicitly requires British English, switch consistently throughout; otherwise stay US.
8. **Active voice when the agent matters; passive when the action matters.** Modern academic English allows "we measured", but the older convention "the samples were measured" remains common in methods.

## How to work

1. **Identify the section** the user needs (Abstract, Introduction, Methods, Results, Discussion, Conclusion, or a transverse function — comparing, defining, being critical, etc.).
2. **Read ONLY the relevant reference file** from `references/` before drafting. Do not load them all.
3. **Pick phrases from the bank** and adapt them to the user's content, replacing X, Y, Z and "Author" with their real terms.
4. **Combine and vary** — never chain three phrases from the same subsection in a row; the text must flow, not look like a phrasebook collage.
5. If the section doesn't fit any single file, read `critical-writing.md` and `connectors-time.md` — they cut across sections.

## Reference index

IMRaD structure and front matter:

- `acknowledgements-authors.md` — Acknowledgements, funding, conflicts of interest, about-the-author, contributor statements.
- `introduction.md` — Background, importance, literature synthesis, problem statement, controversy, knowledge gap, study aim, research questions, hypotheses, structure, limitations.
- `methods.md` — Type of study, data sources, design, justification of methodology, sample, procedure, instruments, methodological limitations.
- `results.md` — Referencing method, presenting data, tables/figures, positive/negative results, unexpected findings, questionnaires, qualitative data, summary.
- `discussion.md` — Background, linking results to discussion, agreement, contradiction, supporting prior literature, explaining results, caution, tentative hypotheses, consequences, future research.
- `conclusion-abstract.md` — Restating, summary, restatement of purpose, synthesis of findings, limitations, implications, contribution, recommendations for practice/policy.

Transverse functions (useful in every section):

- `critical-writing.md` — Limitations of argument, weaknesses of a study, general criticism, criticism of specific authors, constructive suggestions, evaluative adjectives.
- `classify-compare.md` — Classifications and lists; differences, similarities, contrasts and correspondences.
- `define-cause-effect.md` — Definitions, definitional difficulties, definitions from authors, exceptions, causality, correlation.
- `caution-hypothesis.md` — Distancing the author, hypothesizing explanations, caution about present/future, cautious interpretation, hypothesis, possibility/probability, assumption, implication, rhetorical questions.
- `viewpoints.md` — Agreement/support, disagreement/against, stating your own viewpoint.
- `references-citations.md` — General existing evidence, references to past and current research, multiple-author evidence, single-author references, synthesising sources, direct quotations.
- `exemplify.md` — Examples as main information, cases as support, what examples show.
- `connectors-time.md` — Past/present/future tense, duration, frequency, introducing and transitioning between sections, section summary.
- `support-contrast.md` — Contrasting your own work, supporting a viewpoint, stating features, giving explanations.
- `quantity-order-change-interpretation.md` — Quantity, order, change (increase/decrease), interpretation of findings.

## Quick reference: idiomatic replacements

To replace common "AI-default" English:

- Instead of **"This paper explores..."** → "This paper examines…", "This study investigates…", "The aim of this study is to…", "This article addresses…", "The present study focuses on…".
- Instead of **"It is important to note that..."** → "It is worth noting that…", "Notably…", "Importantly…", "A point worth noting is that…", "It should be emphasized that…".
- Instead of **"The results show that..."** repeatedly → alternate with "The findings suggest…", "The data indicate…", "It emerges from the results that…", "The results highlight…", "These results provide evidence that…".
- Instead of **"In conclusion,"** → "Taken together,", "On balance,", "In light of these findings,", "These findings suggest, on the whole, that…", "In sum,".
- Instead of **"As we all know..."** → eliminate; science does not appeal to the reader like this. Replace with "It is widely accepted that…" or "There is broad consensus that…" with citation.
- Instead of **"Delve into..."** / **"Navigate the complexities of..."** → "Examine in detail…", "Investigate in depth…", "Engage closely with…".
- Instead of **"In today's rapidly evolving world,"** → cut entirely or replace with a specific empirical claim, dated and cited.
- Instead of **"A myriad of"** → "A range of", "Several", "Numerous", "A variety of".
- Instead of **"It is worth mentioning that..."** → "Notably,", "It is worth noting that,", "Notably also,".
- Instead of **"Plays a crucial role"** repeated → vary with "plays a central role", "is integral to", "is fundamental to", "underpins", "is a key driver of".

## Attribution

Phrase bank adapted from *Academic Phrasebank* (Morley, 2014, University of Manchester) and *PhraseBook for Writing Papers and Research in English* (Howe & Henriksson, 2007), with structural framing inspired by *5000 frases precocinadas para textos científicos* (Margolles García, NeoScientia, CC BY-NC).
