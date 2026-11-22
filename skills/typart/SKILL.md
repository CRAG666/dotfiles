---
name: typart
description: 'Diagrams and paper figures in Typst with the typart 0.3.0 package: flowcharts (nodes, edges, groups; automatic, grid or relative layout), SmartArt-style widgets (steps, hlist, cards, swot, hexagons, flow, chevron, snake, stairs, stepper, timeline, vtimeline, gantt, donut, cycle, hierarchy, tree, venn, target, radial, arrows, opposing, equation, gears, pyramid, matrix, kpi, bars, gauges, waffle, process, card-table, pill-steps) and computer-science paper figures (sequence, network, autoencoder, contrastive, convnet, convnet3d, rnn, prisma, kfold, split, windows, signal, confusion, checks, layers, timing, packet, graph, pixels, annotate, panels, loop-ring, icon, hstack). Use when the user asks, in a Typst document (paper, thesis, poster, slides), for a flowchart, pipeline, method or decision diagram, state machine, sequence/protocol diagram, neural-network or CNN figure, PRISMA flow, cross-validation or data split, confusion matrix, related-work check table, packet header, timing diagram, graph/topology, figure with a), b)… sub-panels, timeline, Gantt chart, cycle, hierarchy/tree, Venn diagram, pyramid, 2x2 matrix, KPI cards, bars, gauges or styled table, or mentions typart. Do NOT use for continuous-data plots (use cetz/lilaq) or outside Typst.'
---

# typart 0.3.0

Native Typst primitives, no dependencies. Text always fits: boxes grow to their longest label; round and slanted shapes keep their size and shrink all labels to one shared size. A diagram never overflows its container: wider than the column, it scales down (and fails with a message rather than shrinking below 70%).

```typst
#import "@preview/typart:0.3.0": *
// or, to keep common names (matrix, process, node, fill, …) out of scope:
#import "@preview/typart:0.3.0" as ta   // #ta.cycle(..)
```

## Common conventions

**Items** — three equivalent forms, quickest first:

- **List** (preferred): bullet list = one label per item; term list = two-part items (`/ 2024: Start`, `/ Train: 70`, `/ 99%: Accuracy`). `#fill(color)` after an item colours it: `- Review #fill(red)`.
- **Array**: `([Plan], [Do], ([Act], red))`. A single item still needs its trailing comma: `(([Only], red),)`.
- **Dictionaries**: `((label: [Plan]), (label: [Act], color: red))`.

Items without a colour cycle through `palette` (lavender, green, amber, red, sky); use `palette.at(i)` for consistent highlights.

**Calling forms.** A list goes in a trailing content block, one item per line: `#donut(center: [Cycle])[` … `]`. Widgets with a leading label take two blocks: `#hierarchy[CEO][` … `]`, likewise `radial` and `contrastive`. Every widget takes one items argument — `panels((a, b))` and `waffle((a, b))` included; `flowchart(..children)` and `hstack(..items)` take loose arguments.

**Lengths** are Typst lengths and defaults are in `em`, so a diagram follows the surrounding font size (put it in a 9pt figure or on a 24pt slide). Bare numbers are no longer centimetres. Heights are minimums.

**Shared parameters of every diagram:**

| Parameter | Default | Meaning |
|---|---|---|
| `width` | `auto` | `auto` = natural size, scaled down if the container is narrower; list-like widgets (`hlist`, `steps`, `cards`, `bars`, `gantt`, …) fill the container. A length or ratio (`8cm`, `70%`) sets it: drawings scale, list-like widgets reflow. |
| `text-size` | `1em` | Label size relative to the surrounding text. |
| any theme key | — | e.g. `#flow(items, accent: gray, corner-radius: 0pt)`. |
| `theme` | `(:)` | The same overrides as one dictionary. |

Common names: `item-width`, `item-height`, `gap` (one length or `(x, y)`), `radius`, `node-radius`, `core-radius`, `columns`, `inset`, `fills` (per-part colours).

**Theme** (`default-theme`): `palette` · `ink` (`auto` = text colour) · `surface` (`auto` = page fill) · `accent` (`rgb("#73c25a")`, arrows/highlights) · `line` (outlines, flowchart edges) · `panel` (neutral boxes) · `muted` · `stroke` (`0.08em`) · `thick` (`0.2em`) · `corner-radius` (`0.35em`) · `small` (`80%`) · `large` (`150%`) · `min-scale` (`70%`; `0%` lifts the overflow error) · `shadow` (`true`). Text on a fill automatically takes ink or surface, whichever contrasts more — never set text colours by hand.

- Document-wide, like a set rule: `#typart-theme(accent: luma(140), corner-radius: 0pt, shadow: false)`.
- Without the extra layout pass: `#let (flow, cycle) = themed(accent: luma(140))`.
- Dark slides need nothing: `#set page(fill: ..)` + `#set text(fill: white)` and the theme follows.

Icons (`icon`, `process`, glyph strings in `pill-steps`) need the **Font Awesome 7 Free** font (`fc-list | grep "Awesome 7"`).

## Which widget to use

Full parameter tables and one example per widget: [references/widgets.md](references/widgets.md). Read it before tuning any parameter not shown here.

Tables show the one-line array form; in a document prefer the list form (`#cycle[` + one `- item` per line + `]`; term items `/ a: b` map to the tuple `(a, b)`).

| Intent | Widget | Minimal form |
|---|---|---|
| Vertical numbered list | `steps` | `steps(([Plan], [Collect], ([Review], palette.at(2))))` |
| Blocks in a row | `hlist` | `hlist(([A], [B], [C]))` |
| Columns with header + body | `cards` | `cards((([Goals], list([x], [y])), ([Risks], [text], palette.at(3))), columns: 2)` |
| SWOT | `swot` | `swot([S], [W], [O], [T])` |
| Honeycomb strip | `hexagons` | `hexagons(([Idea], [Design], [Build]))` |
| Process with block arrows | `flow` | `flow(([Input], [Process], [Output]), dir: ttb)` |
| Chevron phases | `chevron` | `chevron(([Phase 1], [Phase 2], [Phase 3]))` |
| Process wrapping into rows | `snake` | `snake(([1], [2], [3], [4], [5], [6]), columns: 3)` |
| Ascending stairs | `stairs` | `stairs(([Plan], [Develop], [Launch]))` |
| Done / current / upcoming | `stepper` | `stepper(([Proposal], [Data], [Model], [Thesis]), current: 2)` |
| Horizontal milestones | `timeline` | `timeline((([2024], [Start]), ([2025], [Pilot])))` |
| Vertical milestones with cards | `vtimeline` | `vtimeline((([2023], [Pilot study]), ([2024], [Data collection])))` |
| Schedule | `gantt` | `gantt((("Review", 0, 6, 100), ("Experiments", 4, 18, 40)), span: 24, periods: ("Year 1", "Year 2"), today: 9)` |
| Segmented ring | `donut` | `donut(([Plan], [Build], [Test]), center: [Cycle])` |
| Cycle with arrows | `cycle` | `cycle(([Plan], [Do], [Check], [Act]))` |
| Root + one row of children | `hierarchy` | `hierarchy([CEO], ([Eng], [Sales]))` |
| Multi-level tree | `tree` | `tree(([Root], (([Child], ([Leaf 1], [Leaf 2])), [Child 2])), dir: ltr)` |
| Overlap of 2–3 sets | `venn` | `venn(([Signal], [Behavior], [Security]))` |
| Bullseye | `target` | `target(([Vision], [Mission], [Goal]))` |
| Centre + satellites | `radial` | `radial([Goal], ([People], [Process], [Data]))` |
| Converging / diverging | `arrows` | `arrows(([A], [B], [C]), core: [Core], diverge: true)` |
| Two opposing forces | `opposing` | `opposing(([Pros], [Cons]))` |
| A + B = C (or ⊕) | `equation` | `equation(([Plaintext], [Keystream], [Ciphertext]), operators: ($xor$, [=]))` |
| Gears (≤ 3) | `gears` | `gears(([Research], [Development], [Production]))` |
| Pyramid / funnel | `pyramid` | `pyramid(([Leads], [Trials], [Sales]), flip: true)` |
| 2×2 matrix | `matrix` | `matrix(([TL], [TR], [BL], [BR]), x-axis: ([Low], [High]), y-axis: ([High], [Low]))` |
| Big numbers | `kpi` | `kpi((([99%], [Accuracy]), ([< 1%], [EER])))` |
| Result bars | `bars` | `bars((([Ours], 94.2, palette.at(3)), ([Baseline], 88.7)), unit: "%", max: 100)` |
| Percentage rings | `gauges` | `gauges(((72, [Recall]), (91, [Precision])))` |
| Shares of a whole | `waffle` | `waffle((([Responders], 62), ([Partial], 23), ([No change], 15)))` |
| Ring with icon cards (≤ 6) | `process` | `process((("\u{f02d}", [1. Methods]), ("\u{f51e}", [2. Data])))` |
| Styled table | `card-table` | `card-table(("Study", "Method"), (([Guo], [CNN]), card-row(([This work], [Ours]), fill: palette.at(1))))` |
| Hub + pill steps | `pill-steps` | `pill-steps((([Research], [Review the literature], "\u{f0eb}"),), title: [STEPS])` |

**Paper figures** (computer science, ML, signals, networks, security):

| Intent | Widget | Minimal form |
|---|---|---|
| Fully connected NN | `network` | `network(((4, [Input]), (8, [Hidden]), (2, [Output])))` |
| Autoencoder / bottleneck | `autoencoder` | `autoencoder(((784, [Input]), (16, [Latent]), (784, [Output])))` |
| Siamese / SimCLR / triplet | `contrastive` | `contrastive([ECG $x$], ([Augmentation], [Encoder $f$], [Projection $g$]))` |
| LeNet-style CNN (feature maps) | `convnet` | `convnet(((32, 1, [Input]), (28, 6, [Conv 1]), (14, 6, [Pool]), (1, 10, [Output])))` |
| VGG-style CNN (3D blocks) | `convnet3d` | `convnet3d(((224, 64, [Conv-1], 2), (112, 128, [Conv-2], 2), (1, 1000, [FC])))` |
| Unrolled RNN / LSTM | `rnn` | `rnn(($x_1$, $x_2$, ($x_3$, none, $y$)), cell: [LSTM])` |
| Systematic-review flow | `prisma` | `prisma((([Identified (n = 1240)], [Duplicates (n = 310)]), [Included (n = 42)]), stages: (([Identification], 1), ([Included], 1)))` |
| K-fold CV | `kfold` | `kfold(k: 5, test: 20%)` |
| Train/val/test or protocol phases | `split` | `split((([Train], 70), ([Validation], 15), ([Test], 15)))` |
| Sliding windows over a signal | `windows` | `windows(signal("ecg", cycles: 6, width: 24em), count: 4, overlap: 50%)` |
| Inline waveform | `signal` | `signal("ecg")` · `"ppg"`, `"sine"`, `"square"`, `"sawtooth"` |
| Confusion matrix / heatmap | `confusion` | `confusion(((46, 3), (4, 41)), ([Walk], [Run]), normalize: true)` |
| Related-work ✓/✗ table | `checks` | `checks(([Method], [Continuous], [On-device]), (([Guo], true, none), ([*Ours*], true, true)))` |
| Layered architecture / stack | `layers` | `layers((([App], ([Enrol], [Verify])), ([Sensors], ([ECG], [PPG]))))` |
| Protocol / handshake | `sequence` | `sequence((("u", [User]), ("s", [Server])), (("u", "s", [Request]), ("s", "u", [Reply], "reply")))` |
| Packet header / register | `packet` | `packet((([Version], 4), ([IHL], 4), ([Total length], 24)))` |
| Digital timing | `timing` | `timing((([CLK], "01010101"), ([CS], "10000001")))` |
| Graph / topology | `graph` | `graph(("Hub -- A", "Hub -- B", "Hub -> Cloud"), layout: "star")` |
| Image patch / kernel / S-box | `pixels` | `pixels(((1, 0, -1), (2, 0, -2)), mark: ((0, 0), (1, 1)))` |
| Callouts on an image or plot | `annotate` | `annotate(image("fig.png", width: 8cm), (((46%, 10%), [R peak]),))` |

When no widget fits (branches, decisions, back edges, arbitrary grouping, architecture blocks), use `flowchart`.

## flowchart

The shortest flowchart is a chain: with no nodes declared, every name becomes a box — `#flowchart(edge("Input", "Model", "Output"))`.

Three components, in any order (nested arrays are flattened, so functions can return several):

- `node(name, [pos], body, ..style)` — box holding any content (text, math, `icon`, `image`, `signal`).
- `edge("a", "b", "c", ..)` — chains `a → b → c`; ends are nodes or **named groups**. `edge("x", "x")` is a self-loop.
- `group(title, ..members)` — dashed frame. Members are nodes **written inside it**, names of nodes/earlier named groups, or two `(col, row)` corners.

Once any node is declared, every name in an edge or group must exist — a typo is an error, not a new box.

**Positions** — give one to every node, or to none:

- None → **automatic**: each node goes one layer after its longest chain of predecessors, along `dir: ltr | ttb`. Start here for pipelines and decisions.
- `(col, row)` → grid cell from 0; fractions `(0.5, 1)` sit between tracks; negative rows allowed.
- `right` / `left` / `above` / `below` → next to the node declared just before (a chain = one line per box).
- `(below, "name")` → next to a named node.

Columns and rows take the size of their largest node; gaps widen to fit frames and arrows. Routing is automatic (straight when facing, elbowed otherwise, junction dots at forks/merges). Fix locally only when wrong: `shift: (dx, dy)` on a node, `exit`/`enter` sides, `label-pos`, `via` (grid points), `bend` (positive = left of travel), `route`, or `avoid-crossings: true` on the flowchart.

### Example 1 — automatic pipeline, group holding its nodes

```typst
#flowchart(
  node("data", [Raw data]), node("clean", [Cleaning]), node("feat", [Features]),
  group([Training], node("a", [Model A]), node("b", [Model B]), node("ens", [Ensemble])),
  node("out", [Report], shape: "pill", fill: palette.at(1)),
  edge("data", "clean", "feat", "a", "ens", "out"),
  edge("feat", "b", "ens"),
)
```

One long chain defines the main axis; the branch (`feat → b → ens`) opens on another row and merges back.

### Example 2 — decision with labels and a back edge

```typst
#flowchart(
  dir: ttb,
  avoid-crossings: true,
  node("start", [Start], shape: "pill", fill: palette.at(1)),
  node("read", [Read input]),
  node("ok", [Valid?], shape: "diamond", fill: palette.at(2)),
  node("run", [Process]),
  node("err", [Report error], fill: palette.at(3)),
  node("end", [End], shape: "pill", fill: palette.at(1)),
  edge("start", "read", "ok"),
  edge("ok", "run", label: [yes]),
  edge("ok", "err", label: [no]),
  edge("run", "end"),
  edge("err", "end"),
  edge("err", "read", dash: "dashed", label: [retry]),
)
```

Back edges go in their own `edge` with `dash`; `avoid-crossings` (or `bend`, `route: "detour"`) keeps them clear of nodes.

### Example 3 — relative positions, state machine with hand placement

```typst
#flowchart(
  node("idle", (0, 0), [Idle], shape: "circle"),
  node("run", right, [Running], shape: "circle", fill: palette.at(1)),
  node("done", right, [Done], shape: "circle", shift: (0em, 2.5em)),
  edge("idle", "run", label: [start]),
  edge("run", "run", label: [tick]),
  edge("run", "done", exit: right, enter: top, label: [finish], label-pos: 35%),
  edge("done", "idle", exit: bottom, enter: bottom, dash: "dashed", label: [reset]),
)
```

### Example 4 — research pipeline: presets, frames, relative rows

```typst
#set text(size: 8pt)
#let (key, model, dct) = (palette.at(0), palette.at(4), palette.at(2)).map(c => node.with(fill: c))
#flowchart(
  gap: 3em,
  node("ecg", (0, 1), [ECG signal]), node("ppg", below, [PPG signal]),
  group([Projection],
    key("pwd", (3, 0), [Password]), key("sha", right, [SHA-256]), model("smat", right, [$S in RR^(d times n)$])),
  group([Signal fusion], title-pos: bottom,
    dct("dct1", (1, 1), [DCT]), dct("dct2", below, [DCT]),
    node("cat", (2, 1), [Concatenate]), dct("idct", right, [IDCT])),
  model("tpl", (5, 1), [Template \ $t = S x$]),
  node("match", (below, "tpl"), [Cosine matcher], fill: palette.at(3)),
  edge("pwd", "sha", "smat", "tpl"),
  edge("ecg", "dct1", "cat", "idct", "tpl", "match"),
  edge("ppg", "dct2", "cat"),
)
```

`node.with(fill: ..)` makes a style preset. For long figures, `#let` each part (a `group`, an array of edges) and finish with `#flowchart(part1, part2, arrows)`.

### Example 5 — icons, a named group as an edge end, a `loop` node, `via`

```typst
#set text(size: 9pt, weight: "bold")
#flowchart(
  line: black, stroke: 0.12em, corner-radius: 0.6em,
  title-style: (weight: "regular", fill: luma(110), size: 1.15em),
  gap: (3.4em, 3em),
  node("h1", (0, 0), icon("\u{f0f8}", fill: rgb("#e53935"), size: 2.6em), shape: none, caption: [Hospital A]),
  node("h2", (0, 1), icon("\u{f0f8}", fill: rgb("#1e88e5"), size: 2.6em), shape: none, caption: [Hospital B]),
  node("t1", (1, 0), [Local training], fill: palette.at(4)),
  node("t2", (1, 1), [Local training], fill: palette.at(4)),
  group([Clients], "h1", "h2", "t1", "t2", name: "clients", inside: true),
  node("agg", (2.5, 0.5), [FedAvg \ $w = sum_k n_k / n thin w_k$], fill: palette.at(2)),
  node("round", (2.5, -0.5), [Round $r + 1$], shape: "loop"),
  group([Server], "round", "agg", inside: true),
  edge("h1", "t1"), edge("h2", "t2"),
  edge("clients", "agg", label: text(weight: "regular")[$Delta w_k$]),
  edge("agg", "clients", via: ((2.5, 1.7), (1, 1.7)), dash: "dashed", label: text(weight: "regular")[broadcast]),
)
```

`shape: none` + `caption` for icons or pictures (`image("fig.svg", width: 3cm)`, resolved from your document); a `name` on a group makes it an edge end; `via` routes a back edge underneath through fractional grid points; `shape: "loop"` is an open ring with an arrowhead.

### More techniques

- **Independent lanes:** `independent-columns: true` lets each lane size its own rows.
- **Joined frames:** `group(none, node(..), name: "k", stretch: right)` + `group([Validation], .., stretch: bottom, join: "k")` draws one outline. Groups stretch in declaration order; `group-stretch` sets a default.
- **Two branches leaving a node upwards:** `edge("auth", "rej", via: ((1.75, -1),))`, `edge("auth", "acc", via: ((2.25, -1),))`.
- **Repeated blocks:** a function returning `(node(..), node(..), edge(..))` (e.g. CBC: `block(1), block(2), block(3)`).
- **Residual connections:** `edge("in", "norm1", bend: -50deg)`; repetition as the frame title: `group([× N], ..)`.
- **Arrowheads:** `marks: "->" | "<-" | "<->" | "-"`.

### Parameters

`flowchart`: `dir` (`ltr`) · `gap` (`(3.6em, 2.6em)`) · `inset` (`0.65em`) · `group-inset` (`0.9em`) · `group-stretch` (`none`) · `title-style` (`(weight: "bold")`) · `caption-style` (`(:)`) · `independent-columns` (`false`) · `avoid-crossings` (`false`) · plus theme keys: `line` (outlines/edges), `stroke`, `corner-radius`, `panel` (node fill), `accent` (loop nodes). Edges are 1.4 × `stroke`.

`node`: `shape` (`"rect"`, `"pill"`, `"circle"`, `"ellipse"`, `"diamond"`, `"loop"`, `none`) · `caption` · `fill` · `stroke` · `width` (fixed = text wraps) · `height` (minimum) · `inset` · `shift`.

`edge`: `marks` · `label` · `label-pos` (`0%`–`100%`) · `stroke` (partial: `red` keeps thickness, `2pt` keeps colour) · `dash` (`"dashed"`, `"dotted"`) · `route` (`"straight"`, `"hv"`, `"vh"`, `"hvh"`, `"vhv"`, `"detour"`) · `exit`/`enter` (`left`, `right`, `top`, `bottom`) · `via` · `bend`.

`group`: `name` · `inside` · `title-pos` (`top`/`bottom`) · `fill` · `stroke` · `stretch` (`bottom`, `right`, `(bottom, right)`, …) · `join`.

## panels

A grid of framed sub-figures with an a), b)… label below. Items: `body` or `(body, caption)`; **the body can be any content** — another widget, a `flowchart`, an `image`, an equation, an `hstack` of icons. Panels in a row share their height.

```typst
#set text(size: 9pt)
#figure(
  panels(columns: 2, (
    (bars((([CNN], 94.2, palette.at(3)), ([SVM], 88.7), ([k-NN], 81.3)), unit: "%", max: 100), [Accuracy per model]),
    (gauges(((91, [Precision]), (72, [Recall]))), [Best model]),
    (confusion(((46, 3), (4, 41)), ([Walk], [Run]), normalize: true), [Confusion matrix]),
    (flowchart(edge("ECG", "CNN", "Class")), [Architecture]),
    (hstack(icon("\u{f21e}", fill: palette.at(3)), [+], icon("\u{f06e}", fill: palette.at(4))), [ECG + iris fusion]),
    (loop-ring(hstack(icon("\u{f21e}"), [Verification])), [Continuous]),
  )),
  caption: [Summary of results.],
) <fig:results>
```

`panels`: `columns` (`2`) · `numbering` (`"a)"`, any pattern, `none` hides) · `gap` (`1.1em`) · `inset` (`0.7em`) · `fill` (`none`) · `width`, `theme` (no `text-size`).
`icon(glyph, fill: auto, size: 2em, font: "Font Awesome 7 Free")` · `hstack(..items, gap: 1em)` · `loop-ring(body, inset: 0.4em)` (accent colour, `thick` stroke).

Because sizes are in `em`, shrink a whole panel's contents with `#set text(size: ..)` rather than per-widget sizes.

## Pitfalls from 0.2 code

Old 0.2 code fails loudly in 0.3 (unknown arguments are errors). Translate: `w`/`h`/`box-w`/`bar-h` → `item-width`/`item-height`; `r`/`core-r`/`hub-r` → `radius`/`core-radius`/`hub-radius`; `gutter`/`spacing`/`gx`/`dx` → `gap`; `cols` → `columns`; `size`/`value-size`/`label-size` → `text-size`; `text-fill`/`box-fill`/`node-stroke`/`edge-stroke`/corner `radius` → theme keys (`ink`, `panel`, `line`, `stroke`, `corner-radius`); `pyramid(width:)` → `base:`; `waffle(a, b)`/`panels(a, b)` → one array; bare numbers → lengths.

## Verification

Always compile after writing a diagram (`typst compile doc.typ`, or `typst compile doc.typ out.png --ppi 110` to inspect it) and check it visually: crossing edges, overlapping frames, labels shrunk by round shapes that are too small. typart's errors name the widget, the parameter and the fix — read them. Fix layout with `gap`, `width` or positions first, then `exit`/`enter`, `via` or `avoid-crossings`.
