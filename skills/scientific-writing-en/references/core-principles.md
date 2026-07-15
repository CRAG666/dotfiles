# Core Principles

Read this file once per session, before drafting anything. These are not arbitrary rules; each prevents a specific failure mode that marks text as AI-generated or as non-native academic writing.

## What "Q1 quality" actually means

Reviewers at top-quartile journals reject not for missing data but for prose that reads as imprecise, overclaiming, padded, or structurally weak. Aim for all of the following simultaneously:

- **Clear rhetorical moves.** Every paragraph announces its function (claim, evidence, qualification, comparison). The reader should never wonder why a sentence is on the page.
- **Calibrated stance.** Claims are hedged to match evidence: strong evidence -> confident verb; weak or single-study evidence -> tentative verb. Overclaim and you sound naive; underclaim and you sound trivial.
- **Tight cohesion.** Sentences flow given-then-new: each sentence picks up a thread from the prior one and extends it. Connectives are varied and earn their place.
- **No padding.** Cut "it is important to note that", "in order to", "due to the fact that", "a wide range of". Q1 prose is dense, not chatty.
- **Discipline-appropriate voice.** Methods often passive; results often active with the data as subject ("the data show..."); discussion mixes both depending on whether agent or action matters.
- **Reporting verb stance.** Choose argues, contends, demonstrates, suggests, posits deliberately - they signal your view of the cited author. Repeated bare "Smith said" or "according to Smith" is a tell of inexperience.

## The 11 rules

1. **Avoid LLM-tell phrases.** "Delve into", "navigate the complexities of", "tapestry of", "in the realm of", "it is important to note that", "in today's fast-paced world", "a testament to", "stands as", "underscores the importance of [generic-noun]", "pivotal", "showcases", "leverages", "robust framework" (non-statistical use), "comprehensive understanding". These are statistical fingerprints of LLM output. See `quick-replacements.md`.
2. **Hedge with epistemic caution.** Prefer "suggest", "indicate", "appear to", "the data are consistent with" over "prove", "show clearly", "demonstrate" - unless evidence is genuinely conclusive. Overclaiming is a hallmark of inexperienced (or AI) writing. See `caution-hypothesis.md`.
3. **Vary connectives.** Repeated "however", "moreover", "furthermore", "therefore" make prose mechanical. Rotate with alternatives in `connectors-time.md`.
4. **Tense discipline.**
   - **Past simple** for methods, completed studies, specific past findings ("Smith found...", "we measured...").
   - **Present simple** for established knowledge and what the current paper does ("the data show...", "this paper argues...").
   - **Present perfect** for the accumulated body of literature ("research has shown...", "studies have indicated...").
5. **Citation grammar.** Use patterns in `references-citations.md`. Avoid repeated "According to [Author]". Prefer stance-signaling reporting verbs: argues, contends, claims, demonstrates, suggests, posits, maintains, holds.
6. **Paragraph structure.** Open with a topic sentence stating the claim; develop with evidence, examples, qualifications; close with an inference or transition. Never bury the claim. See `paragraph-structure.md`.
7. **No emojis. No decorative bold. No bullet points** inside the body of a scientific paragraph. Bullets only in genuine enumerations (methods steps, lists of conditions, research questions).
8. **US English only** (analyze, behavior, organize, color, center, toward, focused, modeling, labeled, while, among). Never British forms (analyse, behaviour, organise, colour, centre, fibre, defence, towards, whilst, amongst, modelling, labelled, per cent).
9. **Active voice when the agent matters; passive when the action matters.** "We measured" and "the samples were measured" are both defensible - consistency within the document is what counts.
10. **No contractions, no colloquialisms, no rhetorical questions in body prose.** "Don't" -> "do not"; "a lot of" -> "many"/"a considerable amount of"; assert claims directly instead of "What does this mean? It means that...". See `academic-style.md`.
11. **ASCII punctuation only - no decorative Unicode.** Do not emit typographic Unicode in delivered text:
    - Em dash / en dash -> hyphen with spaces, comma, colon, or parentheses. Never the dash glyph - the strongest single fingerprint of machine-generated text.
    - Curly/smart quotes -> straight quotes (" and ').
    - Horizontal ellipsis -> three plain periods (...), or cut it.
    - Non-breaking space, thin space, zero-width space -> normal ASCII space.
    - Bullet, arrows, multiplication sign, minus sign, middle dot -> spell out or use ASCII (-, ->, x, -).
    Keep output 7-bit ASCII; exceptions only for content genuinely requiring it (math symbols, accented author names, units).

## Rhetorical moves (Swales' CARS model)

Reviewers expect introductions to perform three moves, in order:
1. **Establish a territory.** State what the field cares about and why it matters, supported by literature (`introduction.md`, section Background/Synthesis).
2. **Establish a niche.** Identify a gap, conflict, or unanswered question (`introduction.md`, section Knowledge gap/Controversy/Weaknesses in prior literature).
3. **Occupy the niche.** State the study's aim, questions, and contribution (`introduction.md`, section Purpose/Research questions/Significance).

Discussions follow Hopkins & Dudley-Evans' move structure: (1) restate findings; (2) compare with prior literature (agreement/contradiction); (3) explain the result; (4) acknowledge limitations; (5) state implications and future work. `discussion.md` and `conclusion-abstract.md` map directly onto these moves.
