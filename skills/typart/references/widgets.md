# typart 0.2.1 — built-in widgets (parameter reference)

Extracted from the typart 0.2.1 README. Plain numbers are cm; documented heights are minimums (they grow to fit the text).

## List

### steps
A vertical numbered list of steps.

```typst
#steps(([Plan], [Execute], [Review], ([Deploy], rgb("#e64553"))))
```

| Parameter | Default | Description |
|---|---|---|
| `items` | — | Steps; label or `(label, color)` (colour overrides the box fill). |
| `accent` | `rgb("#73c25a")` | Number-circle fill. |
| `box-fill` | `rgb("#ebedf5")` | Default step box fill. |
| `text-fill` | `rgb("#1f1f3a")` | Text colour. |
| `size` | `18pt` | Text size. |
| `radius` | `8pt` | Box corner radius. |
| `gutter` | `10pt` | Space between steps and between circle and box. |
| `inset` | `14pt` | Box padding. |

### hlist
A horizontal row of equally sized coloured blocks.

```typst
#hlist(([Plan], [Execute], ([Review], rgb("#e64553"))))
```

| Parameter | Default | Description |
|---|---|---|
| `items` | — | Blocks; label or `(label, color)`. |
| `text-fill` | `white` | Text colour. |
| `size` | `18pt` | Text size. |
| `height` | `3cm` | Minimum block height; blocks grow to fit the tallest label. |
| `radius` | `8pt` | Block corner radius. |
| `gutter` | `10pt` | Gap between blocks. |
| `inset` | `12pt` | Block padding. |

### cards
Columns with a coloured header over a tinted body (horizontal bullet list). Headers share one height, and so do bodies.

```typst
#cards((
  ([Goals], list([Faster delivery], [Lower cost])),
  ([Risks], list([Scope creep], [Budget overrun]), rgb("#e64553")),
  ([Actions], [Weekly review of progress against the plan.]),
))
```

Items are tuples `(title, body)` or `(title, body, color)`.

| Parameter | Default | Description |
|---|---|---|
| `items` | — | Card tuples (see above). |
| `columns` | `auto` | Cards per row; `auto` = all in one row. Cards in a row share their header and body heights. |
| `text-fill` | `white` | Header text colour. |
| `body-fill` | `auto` | Body background; `auto` = the header colour lightened. |
| `body-text` | `rgb("#1f1f3a")` | Body text colour. |
| `size` | `18pt` | Header text size. |
| `body-size` | `14pt` | Body text size. |
| `gutter` | `10pt` | Gap between cards. |
| `radius` | `8pt` | Card corner radius. |
| `inset` | `12pt` | Header and body padding. |

### swot
A SWOT analysis as a 2×2 of cards (built on `cards`).

```typst
#swot(
  [- Experienced team \ - Unique dataset],
  [- Small budget],
  [- New market \ - Open data],
  [- Competition],
)
```

| Parameter | Default | Description |
|---|---|---|
| `strengths`, `weaknesses`, `opportunities`, `threats` | — | Body of each quadrant. |
| `titles` | `([Strengths], [Weaknesses], [Opportunities], [Threats])` | Quadrant titles (e.g. to translate them). |
| `colors` | green, red, sky, orange | Header colour of each quadrant. |
| `..style` | | Any `cards` parameter (`size`, `body-size`, `gutter`, `radius`, `inset`, …). |

### hexagons
A zig-zag strip of nested hexagons (honeycomb).

```typst
#hexagons(([Idea], [Design], ([Build], rgb("#e64553")), [Launch], [Learn]))
```

| Parameter | Default | Description |
|---|---|---|
| `items` | — | Hexagons; label or `(label, color)`. |
| `r` | `2` | Hexagon radius (centre to corner). |
| `gap` | `0.15` | Gap between neighbouring edges. |
| `text-fill` | `white` | Text colour. |
| `size` | `16pt` | Text size. |

## Process

### flow
Blocks joined by block arrows (basic process), horizontal or vertical.

```typst
#flow(([Input], [Process], [Review], ([Output], rgb("#e64553"))))
#flow(([Input], [Process], [Output]), dir: ttb)
```

| Parameter | Default | Description |
|---|---|---|
| `items` | — | Blocks; label or `(label, color)`. |
| `dir` | `ltr` | `ltr` for a row, `ttb` for a column. |
| `w` | `4` | Block width. |
| `h` | `2.4` | Minimum block height; blocks grow to fit the tallest label. |
| `gap` | `1.4` | Space between blocks (where the arrows sit). |
| `accent` | `luma(190)` | Arrow colour. |
| `text-fill` | `white` | Text colour. |
| `size` | `18pt` | Text size. |
| `radius` | `0.15` | Block corner radius. |

### chevron
A sequence of right-pointing chevron arrows.

```typst
#chevron(([Phase 1], [Phase 2], [Phase 3], [Phase 4]))
```

| Parameter | Default | Description |
|---|---|---|
| `items` | — | Chevrons; label or `(label, color)`. |
| `w` | `5` | Chevron width. |
| `h` | `2.4` | Minimum chevron height; grows to fit the tallest label. |
| `notch` | `0.9` | Depth of the arrow notch/point. |
| `text-fill` | `white` | Text colour. |
| `size` | `18pt` | Text size. |

### snake
A bending process that wraps into multiple rows.

```typst
#snake(([Step 1], [Step 2], [Step 3], [Step 4], [Step 5], [Step 6]))
```

| Parameter | Default | Description |
|---|---|---|
| `items` | — | Steps; label or `(label, color)`. |
| `cols` | `4` | Items per row before wrapping. |
| `w` | `4.5` | Box width. |
| `h` | `2.2` | Minimum box height; boxes grow to fit the tallest label. |
| `gx` | `1.4` | Horizontal gap between boxes. |
| `gy` | `1.4` | Vertical gap between rows. |
| `accent` | `rgb("#73c25a")` | Arrow colour. |
| `text-fill` | `white` | Text colour. |
| `size` | `16pt` | Text size. |
| `radius` | `0.15` | Box corner radius. |

### stairs
An ascending stair-step process.

```typst
#stairs(([Plan], [Develop], ([Launch], rgb("#e64553"))))
```

| Parameter | Default | Description |
|---|---|---|
| `items` | — | Steps; label or `(label, color)`. |
| `w` | `3.4` | Box width. |
| `h` | `1.7` | Minimum box height; boxes grow to fit the tallest label. |
| `dx` | `3.6` | Horizontal offset between steps (at least half a box plus room for the arrow). |
| `dy` | `1.9` | Vertical rise between steps (at least one box height, so steps never overlap). |
| `accent` | `luma(130)` | Arrow colour. |
| `text-fill` | `white` | Text colour. |
| `size` | `16pt` | Text size. |
| `radius` | `0.15` | Box corner radius. |

### timeline
A horizontal timeline with alternating labels above and below the line.

```typst
#timeline((("2024", [Start]), ("2025", [Pilot]), ("2026", [Launch])))
```

Items are tuples `(date, label)` or `(date, label, color)`.

| Parameter | Default | Description |
|---|---|---|
| `items` | — | Milestone tuples (see above). |
| `accent` | `rgb("#73c25a")` | Axis line and date colour. |
| `text-fill` | `rgb("#1f1f3a")` | Milestone label colour. |
| `size` | `16pt` | Label size. |
| `date-size` | `14pt` | Date size. |
| `step` | `5` | Horizontal distance between milestones. |

### vtimeline
A vertical timeline with cards alternating left and right of a central spine.

```typst
#vtimeline((
  ("2023", [Pilot study with 20 participants]),
  ("2024", [Data collection across three hospitals], rgb("#e64553")),
  ("2025", [Journal paper]),
  ("2026", [Product launch]),
))
```

Items are tuples `(date, body)` or `(date, body, color)`.

| Parameter | Default | Description |
|---|---|---|
| `items` | — | Milestone tuples (see above). |
| `accent` | `luma(200)` | Spine colour. |
| `text-fill` | `rgb("#1f1f3a")` | Card text colour. |
| `size` | `14pt` | Card text size. |
| `date-size` | `16pt` | Date size. |
| `gap` | `10pt` | Space between rows. |
| `radius` | `6pt` | Card corner radius. |

### stepper
Numbered milestones on a line, marking what is done, what is in progress and what is next.

```typst
#stepper(([Proposal], [Data collection], [Model], [Paper], [Defense]), current: 2)
```

| Parameter | Default | Description |
|---|---|---|
| `items` | — | Milestone labels. |
| `current` | `0` | Index of the milestone in progress; earlier ones are done (✓), later ones upcoming. |
| `step` | `4.5` | Distance between milestones. |
| `node` | `0.55` | Circle radius. |
| `accent` | `rgb("#73c25a")` | Colour of done and current milestones. |
| `todo` | `luma(205)` | Colour of upcoming milestones. |
| `text-fill` | `rgb("#1f1f3a")` | Label colour. |
| `size` | `14pt` | Label size. |

### gantt
A Gantt chart with task bars, progress indicator, grid lines, and a "today" marker.

```typst
#gantt(
  (
    ("Planning",     0, 12, 100),
    ("Development",  6, 30, 60),
    ("Testing",     24, 40, 30),
    ("Papers",       0, 48, 20, false),
  ),
  span: 48, grid-step: 12,
  periods: ("Year 1", "Year 2", "Year 3", "Year 4"),
  today: 20,
)
```

Each task is a tuple `(name, start, end)`, `(name, start, end, progress)` or `(name, start, end, progress, group)` — `group: false` renders the bar greyed instead of in the accent colour.

| Parameter | Default | Description |
|---|---|---|
| `tasks` | — | List of task tuples (see above). |
| `span` | `48` | Total length of the time axis, in any unit (months, years, …). |
| `grid-step` | `auto` | Faint vertical line every N units; `auto` = one per period boundary. |
| `today` | `none` | Unit position of the dashed "Today" marker; `none` = off. |
| `today-label` | `[Today]` | Text under the "Today" marker. |
| `periods` | `()` | Axis header labels, spread evenly across the span. |
| `accent` | `rgb("#40a02b")` | Colour of highlighted task bars. |
| `base-color` | `luma(210)` | Bar fill for non-highlighted (`group: false`) tasks. |
| `done-color` | `rgb("#4c4f69")` | Progress fill for non-highlighted tasks; also the "today" marker colour. |
| `progress-color` | `auto` | Filled progress portion of every bar; `auto` = derive from the above. |
| `track-color` | `auto` | Unfilled bar colour; `auto` = `accent` lightened. |
| `row-gap` | `0pt` | Vertical space between task rows. |
| `period-gap` | `0pt` | Space between the period header and the first task. |
| `name-fr` | `15` | Width ratio of the task-name column. |
| `bar-fr` | `33` | Width ratio of the timeline column. |
| `gutter` | `10pt` | Gap between the name and timeline columns. |

## Cycle

### cycle
Nodes arranged on a ring connected by curved arrows.

```typst
#cycle(([Plan], [Do], [Check], ([Act], rgb("#e64553"))))
```

| Parameter | Default | Description |
|---|---|---|
| `items` | — | Nodes; label or `(label, color)`. |
| `radius` | `auto` | Ring radius; `auto` scales with the item count. Never smaller than needed to keep an arrow between neighbours. |
| `node` | `1.5` | Node circle radius. |
| `arrow` | `rgb("#73c25a")` | Arrow colour. |
| `text-fill` | `white` | Text colour. |
| `size` | `16pt` | Text size. |

### donut
A ring split into labelled segments (segmented cycle), clockwise from the top.

```typst
#donut(([Plan], [Build], [Test], ([Ship], rgb("#e64553"))), center: [Cycle])
```

| Parameter | Default | Description |
|---|---|---|
| `items` | — | Segments; label or `(label, color)`. |
| `center` | `none` | Label in the hole. |
| `radius` | `5` | Outer radius. |
| `thickness` | `2.2` | Ring width. |
| `text-fill` | `white` | Segment text colour. |
| `center-fill` | `rgb("#1f1f3a")` | Centre label colour. |
| `size` | `16pt` | Segment text size (the centre is 4pt larger). |

## Hierarchy

### hierarchy
A root node with a row of children beneath it.

```typst
#hierarchy([CEO], (([Eng], rgb("#a7dd9b")), [Sales], [HR]))
```

| Parameter | Default | Description |
|---|---|---|
| `root` | — | Root node label. |
| `children` | — | Child items; label or `(label, color)`. |
| `root-fill` | `rgb("#aab4f7")` | Root box fill. |
| `box-fill` | `auto` | Child box fill; `auto` = cycle the palette. A `(label, color)` child always keeps its own colour. |
| `text-fill` | `rgb("#1f1f3a")` | Text colour. |
| `accent` | `rgb("#73c25a")` | Connector line colour. |
| `box-w` | `5.2` | Box width. |
| `box-h` | `1.7` | Minimum box height; all boxes grow to fit the tallest label. |
| `gap-x` | `1.0` | Horizontal gap between children. |
| `level-gap` | `3.2` | Vertical distance between root and children. |
| `size` | `18pt` | Text size. |

### tree
A multi-level tree hierarchy. A node is a label, `(label, children)`, `(label, color)`, or `((label, color), children)`. Box heights grow automatically to fit wrapped text.

```typst
#tree(([CEO], (([Eng], ([Web], [Mobile])), [Sales])))
```

| Parameter | Default | Description |
|---|---|---|
| `root` | — | Root node (see node forms above). |
| `box-w` | `4` | Box width. |
| `box-h` | `1.5` | Minimum box height. |
| `xstep` | `4.6` | Horizontal spacing per leaf. |
| `ystep` | `2.8` | Vertical spacing between levels. |
| `root-fill` | `rgb("#aab4f7")` | Root box fill. |
| `box-fill` | `rgb("#a7dd9b")` | Non-root box fill. |
| `text-fill` | `rgb("#1f1f3a")` | Text colour. |
| `accent` | `rgb("#73c25a")` | Connector line colour. |
| `size` | `15pt` | Text size. |
| `filled` | `true` | `false` draws outlined boxes instead of filled ones. |
| `outline` | `2.5pt` | Outline thickness when `filled: false`. |
| `pad` | `0.3` | Vertical padding around wrapped text. |

## Relationship

### venn
A 2- or 3-circle Venn diagram.

```typst
#venn((([Behavior], rgb("#aab4f7")), [Signal], [Security]))
```

| Parameter | Default | Description |
|---|---|---|
| `items` | — | 2 or 3 items; label or `(label, color)`. |
| `radius` | `3.4` | Circle radius. |
| `text-fill` | `rgb("#1f1f3a")` | Label colour. |
| `size` | `20pt` | Label size. |
| `transparency` | `45%` | Circle fill transparency (higher = more see-through). |

### target
Concentric rings (bullseye), outermost item first.

```typst
#target(([Vision], [Mission], [Goal]))
```

| Parameter | Default | Description |
|---|---|---|
| `items` | — | Rings from outside in; label or `(label, color)`. |
| `radius` | `5` | Outer ring radius. |
| `text-fill` | `white` | Label colour. |
| `size` | `16pt` | Label size. |

### radial
A centre circle joined by spokes to satellite circles.

```typst
#radial([Goal], ([People], [Process], ([Tools], rgb("#e64553")), [Data]))
```

| Parameter | Default | Description |
|---|---|---|
| `center` | — | Label of the centre circle. |
| `items` | — | Satellites, clockwise from the top; label or `(label, color)`. |
| `radius` | `auto` | Minimum centre-to-satellite distance; satellites always stay apart and clear of the centre. |
| `node` | `1.4` | Satellite radius. |
| `core-r` | `1.9` | Centre radius. |
| `core-fill` | `rgb("#1f1f3a")` | Centre fill. |
| `accent` | `luma(190)` | Spoke colour. |
| `text-fill` | `white` | Satellite text colour. |
| `size` | `16pt` | Text size (the centre is 2pt larger). |

### arrows
Converging or diverging arrows around a central core.

```typst
// converging
#arrows(([Idea 1], [Idea 2], [Idea 3]), core: [Core])

// diverging
#arrows(([Branch 1], [Branch 2]), diverge: true)
```

| Parameter | Default | Description |
|---|---|---|
| `items` | — | Outer boxes; label or `(label, color)`. |
| `core` | `none` | Label inside the central circle. |
| `diverge` | `false` | `true` points the arrows outward instead of inward. |
| `radius` | `4.8` | Distance from centre to the boxes; grows if an arrow would be shorter than 0.8cm. |
| `bw` | `3.6` | Box width. |
| `bh` | `1.6` | Minimum box height; boxes grow to fit the tallest label. |
| `text-fill` | `white` | Text colour. |
| `size` | `16pt` | Text size. |
| `core-fill` | `rgb("#1f1f3a")` | Central circle fill. |
| `core-r` | `1.4` | Central circle radius. |

### opposing
Two block arrows facing each other.

```typst
#opposing(([Pros], [Cons]))
```

| Parameter | Default | Description |
|---|---|---|
| `items` | — | Exactly 2 items; label or `(label, color)`. |
| `w` | `6.5` | Arrow width. |
| `h` | `2.6` | Minimum arrow height; grows to fit the labels. |
| `notch` | `1.3` | Depth of the arrow point. |
| `gap` | `0.5` | Gap between the two points. |
| `text-fill` | `white` | Text colour. |
| `size` | `18pt` | Text size. |

### equation
An A + B = C equation-style diagram (last item is the result).

```typst
#equation(([Input 1], [Input 2], [Output]))
```

| Parameter | Default | Description |
|---|---|---|
| `items` | — | Operands then result; label or `(label, color)`. |
| `w` | `3.6` | Box width. |
| `h` | `2.4` | Minimum box height; boxes grow to fit the tallest label. |
| `gap` | `1.6` | Gap between boxes (where operators sit). |
| `text-fill` | `white` | Text colour. |
| `size` | `18pt` | Text size. |
| `op-size` | `32pt` | Operator (`+`, `=`) size. |
| `op-fill` | `rgb("#1f1f3a")` | Operator colour. |
| `radius` | `0.15` | Box corner radius. |

### gears
Up to 3 interlocking cogwheels (extra items are ignored).

```typst
#gears(([Research], [Development], [Production]))
```

| Parameter | Default | Description |
|---|---|---|
| `items` | — | Up to 3 gears; label or `(label, color)`. Neighbouring gears always mesh, whatever the tooth count. |
| `r` | `2.6` | Gear radius. |
| `teeth` | `10` | Number of teeth per gear. |
| `text-fill` | `rgb("#1f1f3a")` | Label colour. |
| `size` | `15pt` | Label size. |

## Matrix and pyramid

### matrix
A 2x2 matrix with optional axis labels. Cells in order: top-left, top-right, bottom-left, bottom-right.

```typst
#matrix(([TL], [TR], [BL], [BR]),
  x-axis: ("Low", "High"),
  y-axis: ("High", "Low"))
```

| Parameter | Default | Description |
|---|---|---|
| `cells` | — | 4 cells; label or `(label, color)`. |
| `x-axis` | `none` | `(left, right)` labels below the matrix. |
| `y-axis` | `none` | `(top, bottom)` labels beside the matrix. |
| `cw` | `6` | Cell width. |
| `ch` | `4` | Minimum cell height; cells grow to fit the tallest label. |
| `gutter` | `0.3` | Gap between cells. |
| `text-fill` | `white` | Cell text colour. |
| `size` | `18pt` | Text size. |
| `axis-fill` | `rgb("#1f1f3a")` | Axis label colour. |
| `radius` | `0.12` | Cell corner radius. |

### pyramid
A pyramid or funnel diagram (use `flip: true` for a funnel).

```typst
#pyramid(([Vision], [Strategy], [Tactics]))
```

| Parameter | Default | Description |
|---|---|---|
| `levels` | — | Top-to-bottom levels; label or `(label, color)`. |
| `width` | `18` | Base width. |
| `height` | `12` | Total height. |
| `text-fill` | `white` | Label colour. |
| `size` | `22pt` | Label size. |
| `gap` | `0.18` | Gap between levels. |
| `flip` | `false` | `true` renders an inverted pyramid (funnel). |

## Data and poster

### kpi
Stat cards displaying a large value and a caption.

```typst
#kpi((("< 1%", [Target EER]),
      ("99%", [Accuracy], rgb("#40a02b")),
      ("500+", [Users])))
```

Items are tuples `(value, caption)` or `(value, caption, color)`.

| Parameter | Default | Description |
|---|---|---|
| `items` | — | Card tuples (see above). |
| `h` | `3.6cm` | Minimum card height; cards grow to fit their content. |
| `value-size` | `38pt` | Big value size. |
| `label-size` | `16pt` | Caption size. |
| `text-fill` | `white` | Text colour. |
| `gutter` | `12pt` | Gap between cards. |
| `radius` | `10pt` | Card corner radius. |
| `inset` | `14pt` | Card padding. |

### bars
Labelled horizontal bars with their values: results tables made visual. A value that does not fit inside its bar is drawn right after it.

```typst
#bars(
  (([Ours], 94.2, rgb("#e64553")), ([Baseline A], 88.7), ([Baseline B], 81.3), ([Baseline C], 12.5)),
  unit: "%", max: 100,
)
```

Items are tuples `(label, value)` or `(label, value, color)`.

| Parameter | Default | Description |
|---|---|---|
| `items` | — | Bar tuples (see above). |
| `max` | `auto` | Value of a full bar; `auto` = the largest value. |
| `unit` | `""` | Suffix after each value, e.g. `"%"`. |
| `accent` | `rgb("#aab4f7")` | Bar colour for items without their own. |
| `track` | `luma(238)` | Background of each bar. |
| `text-fill` | `rgb("#1f1f3a")` | Label colour (and of values outside their bar). |
| `value-fill` | `white` | Colour of values inside their bar. |
| `size` | `16pt` | Label size (values are 85% of it). |
| `bar-h` | `0.9cm` | Bar height. |
| `gap` | `8pt` | Space between bars. |

### gauges
Progress rings with a big percentage and a caption.

```typst
#gauges(((72, [Recall]), (91, [Precision], rgb("#e64553")), (100, [Coverage])))
```

Items are tuples `(percent, caption)` or `(percent, caption, color)`.

| Parameter | Default | Description |
|---|---|---|
| `items` | — | Gauge tuples (see above); percent from 0 to 100. |
| `radius` | `1.8` | Ring radius. |
| `thickness` | `0.35` | Ring thickness. |
| `track` | `luma(232)` | Unfilled part of the ring. |
| `text-fill` | `rgb("#1f1f3a")` | Text colour. |
| `value-size` | `24pt` | Percentage size. |
| `label-size` | `14pt` | Caption size. |
| `gutter` | `12pt` | Space between gauges. |

### waffle
A grid of squares showing shares of a whole, with a legend; cells beyond the parts stay grey.

```typst
#waffle(([Responders], 62), ([Partial], 23), ([No change], 15, rgb("#e64553")))
```

Each part is `(label, count)` or `(label, count, color)`.

| Parameter | Default | Description |
|---|---|---|
| `..parts` | — | Parts, in order (see above). |
| `total` | `100` | Number of cells. |
| `columns` | `10` | Cells per row. |
| `cell` | `0.55cm` | Cell size. |
| `gap` | `3pt` | Space between cells. |
| `rest` | `luma(232)` | Colour of cells not covered by any part. |
| `text-fill` | `rgb("#1f1f3a")` | Legend text colour. |
| `size` | `14pt` | Legend text size. |

### pill-steps
A central hub with connected pill-shaped step rows. Requires [Font Awesome 7 Free](https://fontawesome.com) for icons.

```typst
#pill-steps(
  (
    ([Research], [Gather requirements],
      icon("\u{f0eb}", size: 26pt)),
    ([Develop],  [Build the solution],
      icon("\u{f0ae}", size: 26pt), rgb("#74c7ec")),
  ),
  title: [PROJECT STEPS],
)
```

Items are tuples `(title, body)`, `(title, body, icon)`, or `(title, body, icon, color)`. The icon may be a Font Awesome glyph string or any pre-styled content. Pill heights grow automatically to fit wrapped text.

| Parameter | Default | Description |
|---|---|---|
| `items` | — | Step tuples (see above). |
| `title` | `[INFOGRAPHIC \ STEPS]` | Text inside the hub circle. |
| `hub-body` | `none` | Optional smaller text under the hub title. |
| `hub-r` | `3.6cm` | Hub circle radius. |
| `step-r` | `1.1cm` | Step-number circle radius. |
| `pill-w` | `15cm` | Pill width. |
| `pill-h` | `2.4cm` | Minimum pill height. |
| `vgap` | `0.6cm` | Vertical gap between pills. |
| `gap-hub` | `1.8cm` | Gap between the hub and the pills. |
| `text-fill` | `white` | Pill title colour. |
| `body-fill` | `white.transparentize(12%)` | Pill body text colour. |
| `hub-fill` | `rgb("#1f1f3a")` | Hub circle fill. |
| `hub-text` | `white` | Hub text colour. |
| `step-circle-fill` | `white` | Step-number circle fill (outlined in the pill colour). |
| `step-text-fill` | `auto` | Step number colour; `auto` = the pill's colour. |
| `connector` | `luma(170)` | Connector curve colour. |
| `connector-dot-fill` | `white` | Connector dot fill. |
| `dot-stroke` | `luma(150)` | Connector dot outline. |
| `icon-color` | `auto` | Icon colour; `auto` = leave the icon content as given. |
| `icon-font` | `"Font Awesome 7 Free"` | Font used when the icon is a glyph string. |
| `icon-size` | `26pt` | Icon size for glyph strings. |
| `title-size` | `20pt` | Pill title size. |
| `body-size` | `12pt` | Pill body size. |
| `step-size` | `28pt` | Step number size. |
| `pad-y` | `0.3cm` | Vertical padding inside each pill. |

### process
A heartbeat-ring process diagram with icon badges and connector arms. Requires [Font Awesome 7 Free](https://fontawesome.com).

```typst
#process(
  (
    ("\u{f02d}", "1. Review methods"),
    ("\u{f51e}", "2. Data collection"),
    ("\u{f83e}", "3. Signal analysis"),
  ),
)
```

Items are up to 6 tuples `(icon-glyph, label)` or `(icon-glyph, label, color)`; the first three render on the left, the last three mirrored on the right. Any Font Awesome codepoint works as the glyph.

| Parameter | Default | Description |
|---|---|---|
| `items` | — | List of item tuples (see above). |
| `core` | heartbeat icon | Content shown at the centre of the ring. |
| `accent` | `rgb("#73c25a")` | Tab, connector, and ring-dot colour. |
| `badge-color` | `rgb("#a7dd9b")` | Icon badge fill. |
| `icon-color` | `white` | Icon glyph colour inside the badge. |
| `ring` | `rgb("#e64553")` | Central ring colour. |
| `box-fill` | `rgb("#ebedf5")` | Label card background. |
| `box-radius` | `0pt` | Label card corner radius. |
| `box-h` | `3cm` | Badge diameter and minimum card height; cards grow to fit their text. |
| `ring-radius` | `3` | Central ring radius. |

### card-table
A card-style table with rounded cells, coloured header, and alternating row fills.

```typst
#card-table(
  ("Study", "Approach", "Dataset"),
  (
    ("Guo et al.",  "Propose two...", "Homemade"),
    ("Gurunathan",  "Exhaustive...", "PUT Vein"),
    ("Zhang et al.", "ML-based",     "InHouse"),
  ),
)
```

| Parameter | Default | Description |
|---|---|---|
| `headers` | — | Tuple of header cells. |
| `rows` | — | List of rows; each row is a tuple of cells or a `card-row(...)`. |
| `weights` | `none` | Relative column widths, e.g. `(2, 1, 1)`. `none` = all equal. |
| `header-fill` | `rgb("#aab4f7")` | Header row background. |
| `row-fills` | `(rgb("#f5e6e2"), rgb("#ecd0d2"))` | Alternating row backgrounds (cycled). |
| `text-fill` | `rgb("#1f1f3a")` | Body text colour. |
| `header-text-fill` | `auto` | Header text colour; `auto` = same as `text-fill`. |
| `size` | `18pt` | Text size. |
| `radius` | `12pt` | Cell corner radius. |
| `gutter` | `8pt` | Gap between cells and rows. |
| `inset` | `12pt` | Cell padding. |

To override a single row's colours, wrap it with `card-row`:

```typst
#card-row(("This work", "Ours", "New"), fill: rgb("#a7dd9b"), text-fill: white)
```

| Parameter | Default | Description |
|---|---|---|
| `cells` | — | Tuple of cells for the row. |
| `fill` | `none` | Row background; `none` = keep the alternating fill. |
| `text-fill` | `none` | Row text colour; `none` = keep `text-fill` of the table. |
