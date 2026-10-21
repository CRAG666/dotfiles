---
name: typart
description: 'SmartArt-style diagrams in Typst with the typart 0.2.1 package: flowcharts (nodes, edges, groups; automatic or grid layout), figures with a), b)… sub-panels (panels, loop-ring, icon, hstack) and built-in widgets (steps, hlist, cards, swot, hexagons, flow, chevron, snake, stairs, timeline, vtimeline, stepper, gantt, cycle, donut, hierarchy, tree, venn, target, radial, arrows, opposing, equation, gears, matrix, pyramid, kpi, bars, gauges, waffle, pill-steps, process, card-table). Use when the user asks, in a Typst document (poster, paper, thesis, slides), for a flowchart, pipeline, method diagram, decision diagram, PRISMA diagram, figure with panels/sub-figures, timeline, Gantt chart, cycle, hierarchy, Venn diagram, pyramid, 2x2 matrix, KPI cards, bars, gauges or styled table, or mentions typart. Do NOT use for continuous-data plots (use cetz/lilaq) or outside Typst.'
---

# typart 0.2.1

Diagrams drawn with native Typst primitives, no dependencies. Text always fits: boxes grow to their longest label; round and slanted shapes keep their size and shrink all labels to one shared size.

Always import it from the package registry:

```typst
#import "@preview/typart:0.2.1": *
```

## Common conventions

- **Items:** almost every widget takes an array; each item is `[label]` or `([label], color)` to override its colour. Items without a colour cycle through `palette` (lavender, green, amber, red, sky), which is exported for your own use.
- **Units:** plain numbers (`w`, `h`, `radius`, `r`, …) are **cm**; any length also works (`2.5cm`, `40pt`).
- **Heights are minimums:** they grow to fit the text.
- **Single-item arrays** need a trailing comma: `steps(([Only],))`, `via: ((1.5, -1),)`.
- **Variadic vs array:** `waffle(..parts)`, `panels(..items)`, `flowchart(..children)` and `hstack(..items)` take loose arguments; every other widget takes **one** array `(…)`.
- `#set text(...)` before a widget sets the default font, size and weight (widgets with their own `size:` override it).
- For numbering and cross-references, wrap in `figure`: `#figure(flowchart(...), caption: [Method.]) <fig:method>`.
- `icon`, `pill-steps` and `process` need the **Font Awesome 7 Free** font installed (`fc-list | grep "Awesome 7"`).

## Which widget to use

Full parameter reference and one example per widget: [references/widgets.md](references/widgets.md). Read it before tuning any parameter not shown here.

| Intent | Widget | Minimal form |
|---|---|---|
| Vertical numbered list | `steps` | `steps(([Plan], [Execute], [Review]))` |
| Blocks in a row | `hlist` | `hlist(([A], [B], [C]))` |
| Columns with header + body | `cards` | `cards((([Goals], list([x], [y])), ([Risks], [text], red)), columns: 3)` |
| SWOT analysis | `swot` | `swot([S], [W], [O], [T])` |
| Honeycomb strip | `hexagons` | `hexagons(([Idea], [Design], [Build]))` |
| Process with block arrows | `flow` | `flow(([Input], [Process], [Output]), dir: ttb)` |
| Chevron phases | `chevron` | `chevron(([Phase 1], [Phase 2], [Phase 3]))` |
| Process wrapping into rows | `snake` | `snake(items, cols: 3)` |
| Ascending stairs | `stairs` | `stairs(([Plan], [Develop], [Launch]))` |
| Horizontal milestones | `timeline` | `timeline((("2024", [Start]), ("2025", [Pilot])))` |
| Vertical milestones with cards | `vtimeline` | `vtimeline((("2023", [Pilot study]), ("2024", [Data collection])))` |
| Done / current / upcoming progress | `stepper` | `stepper(([Proposal], [Data], [Model], [Thesis]), current: 2)` |
| Schedule | `gantt` | `gantt((("Review", 0, 6, 100), ("Experiments", 4, 18, 40)), span: 24, periods: ("Year 1", "Year 2"), today: 9)` |
| Cycle with arrows | `cycle` | `cycle(([Plan], [Do], [Check], [Act]))` |
| Segmented ring | `donut` | `donut(([A], [B], [C]), center: [Cycle])` |
| Root + children (one level) | `hierarchy` | `hierarchy([CEO], ([Eng], [Sales]))` |
| Multi-level tree | `tree` | `tree(([Root], (([Child], ([Leaf 1], [Leaf 2])), [Child 2])))` |
| Overlap of 2–3 sets | `venn` | `venn(([Signal], [Behavior], [Security]))` |
| Concentric bullseye | `target` | `target(([Vision], [Mission], [Goal]))` |
| Centre + satellites | `radial` | `radial([Goal], ([People], [Process], [Data]))` |
| Converging / diverging | `arrows` | `arrows(([A], [B], [C]), core: [Core])` |
| Two opposing forces | `opposing` | `opposing(([Pros], [Cons]))` |
| A + B = C | `equation` | `equation(([ECG], [PPG], [Fusion]))` |
| Gears (≤ 3) | `gears` | `gears(([Research], [Development], [Production]))` |
| 2×2 matrix | `matrix` | `matrix(([TL], [TR], [BL], [BR]), x-axis: ("Low", "High"), y-axis: ("High", "Low"))` |
| Pyramid / funnel | `pyramid` | `pyramid(([Vision], [Strategy], [Tactics]), flip: true)` |
| Big numbers | `kpi` | `kpi((("99%", [Accuracy]), ("< 1%", [EER])))` |
| Result bars | `bars` | `bars((([Ours], 94.2, red), ([Baseline], 88.7)), unit: "%", max: 100)` |
| Percentage rings | `gauges` | `gauges(((72, [Recall]), (91, [Precision])))` |
| Shares of a whole | `waffle` | `waffle(([Responders], 62), ([Partial], 23), ([No change], 15))` |
| Hub + icon steps | `pill-steps` | `pill-steps((([Research], [Requirements], icon("\u{f0eb}", size: 26pt)),), title: [STEPS])` |
| Ring with badges (≤ 6) | `process` | `process((("\u{f02d}", "1. Methods"), ("\u{f51e}", "2. Data")))` |
| Styled table | `card-table` | `card-table(("Study", "Method"), (("Guo", "CNN"), card-row(("This work", "Ours"), fill: green)))` |

`arrows` takes `diverge: true` to point outward. When no widget fits (branches, decisions, back edges, arbitrary grouping), use `flowchart`.

## flowchart

Three components, in any order inside `flowchart(...)`:

- `node(name, [(col, row)], body, ..style)` — a box holding any content (text, math, `icon`, `image`).
- `edge("a", "b", "c", ..)` — chains `a → b → c`; ends may be nodes or **groups with a `name`**.
- `group(title, "a", "b", ..)` — a dashed frame around nodes.

Two layout modes, **never mixed**: either every node has a position, or none does.

1. **Automatic** (no positions): each node goes one layer after its longest chain of predecessors (topological order), along `dir: ltr | ttb`. Best for pipelines and decisions; always start here.
2. **Grid** (`(col, row)` on every node): columns and rows take the size of their largest node. Fractions such as `(0.5, 1)` centre a node between two tracks. Negative rows are allowed. Use it when exact placement matters (PRISMA, lanes, paper figures).

Routing is automatic (straight when the shapes face each other, elbowed otherwise, around the row when blocked). Override only when the result is wrong: `route:`, `via:` (grid points, fractions allowed) or `bend:` (curve; positive bends left of the direction of travel).

### Example 1 — automatic pipeline with branches and groups

```typst
#set text(size: 10pt)
#flowchart(
  node("raw", [Raw EEG]),
  node("bp", [Band-pass \ 1–40 Hz]),
  node("ica", [ICA]),
  node("ep", [Epochs]),
  node("psd", [PSD]),
  node("csp", [CSP]),
  node("svm", [SVM], fill: rgb("#b4bcfa")),
  node("acc", [Accuracy], shape: "pill", fill: rgb("#a7dd9b")),
  edge("raw", "bp", "ica", "ep", "psd", "svm", "acc"),
  edge("ep", "csp", "svm"),
  group([Preprocessing], "bp", "ica", "ep"),
  group([Features], "psd", "csp", title-pos: bottom),
)
```

One long chain in a single `edge` defines the main axis; the branch (`ep → csp → svm`) opens on another row by itself and merges back.

### Example 2 — algorithm with a decision and a curved back edge

```typst
#flowchart(
  dir: ttb,
  node("init", [Initialise $theta_0$], shape: "pill", fill: rgb("#a7dd9b")),
  node("grad", [Compute $nabla L(theta_t)$]),
  node("upd", [$theta_(t+1) = theta_t - eta nabla L$]),
  node("conv", [$|Delta L| < epsilon$?], shape: "diamond", fill: rgb("#f9c74f")),
  node("save", [Save model], shape: "pill", fill: rgb("#a7dd9b")),
  edge("init", "grad", "upd", "conv"),
  edge("conv", "save", label: [yes]),
  edge("conv", "grad", label: [no], dash: "dashed", bend: -60deg),
)
```

Back edges go in their own `edge`, with `dash` and `bend` (or `route: "detour"`) so they stay clear of the main chain.

### Example 3 — PRISMA diagram on the grid

```typst
#let side = rgb("#f5e0dc")
#flowchart(
  spacing: (10mm, 8mm),
  node("db", (0, 0), [Records identified \ from databases (n = 1245)], width: 5cm),
  node("dup", (1, 0), [Duplicates removed \ (n = 312)], fill: side, width: 4.5cm),
  node("scr", (0, 1), [Records screened \ (n = 933)], width: 5cm),
  node("exc", (1, 1), [Excluded on title \ and abstract (n = 801)], fill: side, width: 4.5cm),
  node("ft", (0, 2), [Full texts \ assessed (n = 132)], width: 5cm),
  node("exf", (1, 2), [Excluded (n = 94): \ no control group, \ no metrics], fill: side, width: 4.5cm),
  node("inc", (0, 3), [Studies included \ (n = 38)], fill: rgb("#a7dd9b"), width: 5cm),
  edge("db", "scr", "ft", "inc"),
  edge("db", "dup"),
  edge("scr", "exc"),
  edge("ft", "exf"),
  group([Identification], "db", "dup"),
  group([Screening], "scr", "exc", "ft", "exf"),
  group([Included], "inc", stretch: right),
)
```

A fixed `width` evens out the columns and wraps the text inside; `stretch: right` extends the frame to the diagram's edge so it lines up with the groups above.

### Example 4 — paper figure: icons, a group as an edge end, `loop` and `via`

```typst
#set text(size: 11pt, weight: "bold")
#let (blue, green, amber, violet) = (rgb("#89b4fa"), rgb("#a7dd9b"), rgb("#f9b98a"), rgb("#b4bcfa"))
#flowchart(
  node-stroke: 1.2pt + black,
  edge-stroke: 1.8pt + black,
  radius: 8pt,
  spacing: (14mm, 12mm),
  title-style: (weight: "regular", fill: luma(110), size: 13pt),
  caption-style: (size: 9pt, weight: "regular"),
  node("h1", (0, 0), icon("\u{f0f8}", fill: rgb("#e53935"), size: 30pt), shape: none, caption: [Hospital A]),
  node("h2", (0, 1), icon("\u{f0f8}", fill: rgb("#1e88e5"), size: 30pt), shape: none, caption: [Hospital B]),
  node("h3", (0, 2), icon("\u{f0f8}", fill: rgb("#43a047"), size: 30pt), shape: none, caption: [Hospital C]),
  node("t1", (1, 0), [Local training], fill: blue),
  node("t2", (1, 1), [Local training], fill: blue),
  node("t3", (1, 2), [Local training], fill: blue),
  node("agg", (2.5, 1), [FedAvg \ $w = sum_k n_k / n thin w_k$], fill: amber),
  node("glob", (2.5, 2), [Global model], fill: violet),
  node("round", (2.5, 0), [Round $r + 1$], shape: "loop", fill: white, stroke: 4pt + green),
  edge("h1", "t1"), edge("h2", "t2"), edge("h3", "t3"),
  edge("clients", "agg", label: text(weight: "regular")[$Delta w_k$]),
  edge("agg", "glob"),
  edge("glob", "clients", via: ((2.5, 2.7), (1, 2.7)), dash: "dashed",
    label: text(weight: "regular")[broadcast]),
  group([Clients (private data)], "h1", "h2", "h3", "t1", "t2", "t3", name: "clients", inside: true),
  group([Server], "round", "agg", "glob", inside: true),
)
```

Key points: `shape: none` + `caption` for icons or pictures (`image("fig.svg", width: 3cm)`, resolved from your own document); a `name` on a group makes it an edge end (`"clients"`); `via` draws a back edge underneath through fractional grid points; `shape: "loop"` is a ring with an arrowhead coloured by `stroke`.

### More techniques

- **Independent lanes:** `independent-columns: true` lets each lane (columns joined by nodes at fractional positions) size its own rows, so a tall node does not stretch the others.
- **Joined frames:** `group(none, "kfold", name: "k", stretch: right)` + `group([Validation], .., stretch: bottom, join: "k")` draws both as one outline. Groups stretch in declaration order.
- **Two branches leaving a node upwards:** `edge("auth", "rej", via: ((1.75, -1),))` and `edge("auth", "acc", via: ((2.25, -1),))`.
- **Bidirectional / no arrowhead:** `marks: "<->"`, `"-"`.

### Parameters

`flowchart`: `dir` (`ltr`) · `spacing` (`(1.4cm, 1cm)`, minimum gap between columns and rows) · `node-fill` · `node-stroke` · `edge-stroke` · `loop-stroke` · `radius` (`4pt`) · `inset` (`7pt`) · `group-stroke` (dashed `luma(150)`) · `group-inset` (`10pt`) · `title-style` (`(weight: "bold")`) · `caption-style` (`(:)`) · `independent-columns` (`false`).

`node`: `shape` (`"rect"`, `"pill"`, `"circle"`, `"ellipse"`, `"diamond"`, `"loop"`, `none`) · `caption` · `fill` · `stroke` · `width` (`auto`; fixed = text wraps) · `height` (minimum) · `inset`.

`edge`: `marks` (`"->"`, `"<-"`, `"<->"`, `"-"`) · `label` (on the longest leg) · `stroke` · `dash` (`"dashed"`, `"dotted"`) · `route` (`"straight"`, `"hv"`, `"vh"`, `"hvh"`, `"vhv"`, `"detour"`) · `via` · `bend`.

`group`: `name` · `inside` (title inside, centred) · `title-pos` (`top`/`bottom`) · `fill` · `stroke` · `stretch` (`bottom`, `right`, `(bottom, right)`, …) · `join` (name of another group).

## panels

A grid of framed sub-figures, with the caption inside and an a), b)… label below. Each item is `(body, caption)` or just `body`; **the body can be any content**, including other typart widgets, a `flowchart`, an `image`, an equation or an `hstack` of icons. Panels in one row share their height.

### Example 5 — results figure composing widgets

```typst
#set text(size: 10pt)
#figure(
  panels(columns: 2,
    (bars((([CNN], 94.2, rgb("#e64553")), ([SVM], 88.7), ([k-NN], 81.3)),
      unit: "%", max: 100, size: 11pt, bar-h: 0.6cm), [Accuracy per model]),
    (gauges(((91, [Precision]), (72, [Recall])), radius: 1.3, value-size: 16pt, label-size: 10pt),
      [Best model metrics]),
    (waffle(([Healthy], 58), ([Arrhythmia], 30), ([Noise], 12, rgb("#e64553")), cell: 0.32cm, size: 10pt),
      [Class distribution]),
    (flowchart(node("x", [ECG]), node("f", [CNN]), node("y", [Class], shape: "pill"), edge("x", "f", "y")),
      [Architecture]),
  ),
  caption: [Summary of results.],
) <fig:results>
```

Inside a panel, shrink the widgets' `size`/`radius`/`cell`: their defaults are sized for posters.

### Example 6 — icons, an equation and `loop-ring`, custom style

```typst
#set text(size: 10pt)
#let op(t) = text(size: 18pt, t)
#panels(columns: 3, numbering: "(i)", fill: rgb("#f5f6fb"), radius: 6pt,
  stroke: 0.8pt + luma(180), caption-size: 1.1em,
  (hstack(icon("\u{f21e}", fill: rgb("#e53935")), op[+], icon("\u{f06e}", fill: rgb("#26a69a"))),
    [ECG + iris fusion]),
  ($ hat(y) = arg max_c P(c | x) $, [Decision rule]),
  (loop-ring(icon("\u{f3cf}", fill: rgb("#1e88e5"), size: 28pt), stroke: 3pt + rgb("#a7dd9b")),
    [Continuous verification]),
)
```

`numbering` takes any Typst pattern (`"a)"`, `"1)"`, `"(i)"`, `"A."`) or `none` to hide the labels.

### Parameters

`panels`: `columns` (`2`) · `numbering` (`"a)"`) · `stroke` (dashed `luma(120)`) · `fill` (`none`) · `radius` (`0pt`) · `caption-fill` (`luma(110)`) · `caption-size` (`1.3em`) · `label-size` (`1.5em`) · `inset` (`12pt`) · `gutter` (`18pt`).

`icon(glyph, fill: auto, size: 34pt, font: "Font Awesome 7 Free")` — a glyph by codepoint, e.g. `"\u{f023}"`.
`hstack(..items, gap: 1em)` — items in a row on a common middle line.
`loop-ring(body, stroke: 3pt + rgb("#a7dd9b"), inset: 6pt)` — a "repeat / continuous" ring around any content.

## Verification

Always compile after writing a diagram (`typst compile doc.typ`, or `typst compile doc.typ out.png --ppi 110` to inspect the image) and check it visually: crossing edges, overlapping frames, tiny text from round shapes that are too small. Fix with `spacing`, `width` or positions first, and only then with `route`/`via`.
