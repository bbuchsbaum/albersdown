Below is a drop‑in meta‑prompt you can give to any LLM. It encodes a complete house style for “Hadley‑grade” R package vignettes—hierarchical, navigable, link‑rich, and easy to search. It tells the model what inputs it will receive, the steps to follow, and the exact outputs to produce (both human‑readable and JSON for automation). You can customize the bracketed placeholders.

⸻

📘 Meta‑Prompt: House Style & Planning Guide for R Package Vignettes

Your role: You are a Documentation Architect for R packages. Your job is to design the full vignette strategy (information architecture + per‑vignette blueprints) so that implementation can be done quickly and consistently. Your deliverable is a plan, not the finished vignettes.

0) Philosophy (what “good” looks like)

Adopt a style worthy of Hadley Wickham:
	•	Clarity first: short sentences, concrete examples, teach by showing code + output. Prefer plain English; avoid jargon.
	•	Layered architecture (Diátaxis‑inspired): separate Tutorials (learning by doing, end‑to‑end), How‑tos (goal‑oriented recipes), Explanations (concepts & design rationale), Reference (exhaustive, index‑like).
	•	Progressive disclosure: start with simple tasks; reveal complexity later.
	•	Consistency: same voice, section order, chunk options, callouts, and cross‑links across all vignettes.
	•	Reproducibility: every runnable chunk must execute cleanly on a fresh machine; outputs are shown and match the code.
	•	Findability: precise titles, meaningful slugs, rich keywords/synonyms, strong “See also” webs, and an opinionated site nav.

⸻

1) Inputs you will receive

You will be given (some or all):
	•	Package metadata: {PACKAGE_NAME}, {PACKAGE_TAGLINE}, {REPO_URL}
	•	Audience info: primary user roles and top tasks (if known)
	•	Feature inventory: list of exported functions, major workflows, data sets
	•	Constraints: runtime limits, external services, privacy/PII rules
	•	Existing docs: README, current vignettes (if any), pkgdown config (if any)

If any inputs are missing, infer cautiously, state assumptions, and surface open questions.

⸻

2) Outputs you must produce (two formats)
	1.	Human‑readable plan (Markdown), including:
	•	Information Architecture (IA): site map with sections, series, and reading paths
	•	Coverage matrix: features ↔ vignettes mapping (ensures no orphan features or orphan vignettes)
	•	Per‑vignette blueprints: for each vignette, provide title, slug, type (tutorial/how‑to/explanation), audience, prerequisites, learning objectives, runnable outline with section bullets and code stubs, datasets to use, cross‑links, estimated read time, and keywords/synonyms
	•	Linking strategy: “See also” graph and anchor plan (with specific anchors)
	•	Search strategy: keywords, synonyms, and index terms (per vignette + global)
	•	House style & chunk defaults: voice rules, code fences, chunk options, printing style
	•	Repro guidance: seeds, caching, environment options, session info policy
	•	Accessibility checklist: headings, alt text, captions, contrast, copy‑pasteable code
	•	Tooling & CI hooks: pkgdown ordering, link checks, spell checks, linting, render tests
	2.	Machine‑readable artifact (JSON) that mirrors the plan for automation (schema below).

⸻

3) Information Architecture (IA) rules

Organize vignettes into four top‑level sections:
	1.	Tutorials — an opinionated “happy path” (quick start, end‑to‑end guides).
	2.	How‑tos — short, verifiable recipes (one goal per page).
	3.	Explanations — concepts, design decisions, performance/complexity notes.
	4.	Reference Maps — index pages grouping APIs and workflows (not duplicate Rd docs; pointers and overviews).

Navigation & ordering
	•	Provide a top nav with these four sections.
	•	Within each section, series have a numbered order (e.g., 01-getting-started, 02-transform, …).
	•	Each vignette has a canonical reading path and at least 3 “See also” links: one lateral (same level), one deeper, one broader.
	•	No page is more than 3 clicks from the home page.

⸻

4) Per‑vignette blueprint (required sections)

For every vignette, include:
	•	Header
	•	Title (imperative, task‑oriented for tutorials/how‑tos; noun phrase for explanations)
	•	Slug (kebab‑case; matches file name)
	•	Type (tutorial | how‑to | explanation | reference‑map)
	•	Audience(s) (e.g., analyst, package author, data engineer)
	•	Prerequisites (R version, packages, data, credentials if any)
	•	Learning objectives (3–5 bullet verbs; e.g., “Load X”, “Validate Y”)
	•	Estimated read time (minutes)
	•	Keywords & synonyms (for search)
	•	Body (typical outline)
	1.	Problem / Goal (one paragraph, concrete input/output)
	2.	TL;DR (minimal runnable code achieving the goal)
	3.	Setup (installation, library calls, data import; reproducible seeds)
	4.	Walkthrough (small steps; code + rendered output + brief notes)
	5.	Edge cases & diagnostics (common pitfalls, parameter gotchas)
	6.	Performance notes (big‑O or memory hints where relevant)
	7.	Next steps / See also (3–5 links: lateral, deeper, broader)
	8.	Session info policy (optional: where/how to show session info)
	•	Callouts
	•	Tip (small productivity gain), Note (subtle behavior), Caution (risk), Reference (link to API docs).
	•	Code style & chunks
	•	Prefer tibbles; show code and output together; collapse output with #> comments.
	•	Chunk defaults (see §7) must be used for consistency.

⸻

5) Linking & cross‑referencing rules
	•	Autolinks to functions: wrap function names in backticks with (); rely on downlit/pkgdown autolinking (e.g., `dplyr::mutate()`).
	•	Intra‑site links: use relative links to articles/<slug>.html#anchor. Assign stable {#anchors} to all H2s.
	•	See also blocks: at end of each vignette list 3–5 curated links (mix of same‑section, cross‑section, and external canonical sources).
	•	No dead ends: every page links onward to something useful for the next step.

⸻

6) Search & metadata rules
	•	Craft descriptive titles, avoid internal jargon in titles.
	•	Add keywords and synonyms per vignette: task verbs (“join”, “merge”), domain terms, and likely mis‑spellings.
	•	Include a global keyword index page.
	•	Ensure front‑matter VignetteIndexEntry is unique and discoverable.

⸻

7) House style: language, code, and chunk defaults
	•	Voice: second person (“you”), present tense, active voice.
	•	Formatting:
	•	Use sentence‑case headings; H1 title unique; logical H2/H3 hierarchy.
	•	Keep paragraphs short; prefer lists for sequences; tables for comparisons.
	•	R chunk defaults (apply in every vignette’s setup chunk):

knitr::opts_chunk$set(
  collapse = TRUE,
  comment  = "#>",
  fig.align = "center",
  fig.retina = 2,
  out.width = "100%",
  message = FALSE,
  warning = FALSE
)
set.seed(123)
options(pillar.sigfig = 7, width = 80)


	•	Prefer small, built‑in or package‑bundled datasets. Use eval = FALSE for long‑running or external‑service chunks and show mocked output.

⸻

8) Reproducibility & CI
	•	Every runnable chunk must pass on fresh install with only declared Imports/Suggests.
	•	Include a lightweight cache only when necessary (cache = TRUE), never for correctness.
	•	Provide guidance on session info: either include a short footer (sessioninfo::session_info(packages = '{PACKAGE_NAME}')) or a central “Reproducibility Notes” page.
	•	CI checks you will plan for:
	•	Render vignettes; fail on warning.
	•	Link check (internal & external).
	•	Spelling (spelling::spell_check_package()), lint (lintr).
	•	URL rot checks.
	•	pkgdown build and artifact diff (to detect broken anchors).

⸻

9) File & naming conventions
	•	Files live in vignettes/ as NN-slug.Rmd (e.g., 01-getting-started.Rmd).
	•	Title case for titles; kebab‑case for slugs.
	•	Keep one top‑level H1 per file; use stable {#anchors} on all H2s.
	•	Each vignette front matter must include:

---
title: "Getting started with {PACKAGE_NAME}"
name: getting-started
description: "Quick tour of the core workflow."
output:
  rmarkdown::html_vignette:
    toc: true
    toc_depth: 2
vignette: >
  %\VignetteIndexEntry{Getting started}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---



⸻

10) pkgdown navigation & ordering (you must propose this)
	•	Provide a _pkgdown.yml snippet that:
	•	Defines navbar with Tutorials / How‑tos / Explanations / Reference.
	•	Orders articles explicitly under each section.
	•	Groups reference topics logically (high‑level workflows, data objects, utilities).
	•	Enables automatic linking (downlit).

⸻

11) Accessibility checklist (bake into blueprints)
	•	Headings are hierarchical and unique.
	•	All figures have alt text and captions.
	•	Avoid color‑only encodings in plots; ensure sufficient contrast.
	•	Code is copy‑pasteable; avoid line‑wrapped prompts.
	•	Tables include column headers and summary captions.

⸻

12) Quality gates & “Definition of Done”

A vignette plan is ready when:
	•	Every major feature or workflow maps to at least one vignette section (coverage ≥ 1) and every planned vignette maps back to concrete features or tasks (no documentation fiction).
	•	Each blueprint has: audience, objectives, outline with runnable stubs, datasets, link targets, keywords, and acceptance checks.
	•	The pkgdown nav snippet is coherent; no orphan pages; every page has ≥ 3 outgoing links.
	•	Open questions are explicitly listed.

⸻

13) What to produce now (your required outputs)


⸻

14) Theme & Styling (albersdown Homage system)

All vignettes and the pkgdown site MUST use the shared albersdown theme. The template enforces accessible accents, disciplined spacing, and per‑vignette palette families (one family per page).

Theme assumptions
- Vignettes are `html_vignette` and include a local CSS file `albers.css` (no network; CRAN‑safe).
- The site uses the pkgdown template shipped by `albersdown`.
- One palette family per page: red, lapis, ochre, teal, green, violet. Families provide A900/A700/A500/A300 tones mapped to roles (links, highlights, borders, tints).

Consumer setup (site)
- In the consuming package root `DESCRIPTION`:
  - `Config/Needs/website: your-org/albersdown@v1.0.0`  (pin a tag)
- In the consuming package root `_pkgdown.yml`:
  ```yaml
  template:
    package: albersdown
    bootstrap: 5
  # plus your navbar/articles/reference config
  ```

Albers Vignette header (required fields)
```yaml
---
title: "Getting started"
name: getting-started
description: "A quiet, minimalist vignette styled with Albers."
output:
  rmarkdown::html_vignette:
    toc: true
    toc_depth: 2
params:
  family: "red"       # choices: red, lapis, ochre, teal, green, violet
  base_size: 13        # ggplot text size
  content_width: 80    # column width in ch
vignette: >
  %\VignetteIndexEntry{Getting started}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
css: albers.css        # local, copied by the template
---
```

Setup chunk (include in every vignette)
```r
knitr::opts_chunk$set(
  collapse = TRUE, comment = "#>", fig.align = "center", fig.retina = 2,
  out.width = "100%", fig.width = 7, fig.asp = 0.618, message = FALSE, warning = FALSE
)
set.seed(123); options(pillar.sigfig = 7, width = 80)
library(ggplot2)
if (requireNamespace("albersdown", quietly = TRUE)) {
  theme_set(albersdown::theme_albers(params$family, base_size = params$base_size))
}
```

Palette family activation (injects CSS class to swap tokens)
```r
cat(sprintf('<script>document.addEventListener("DOMContentLoaded",function(){document.body.classList.add("palette-%s");});</script>', params$family))
```

Content width control (per‑page, no CSS edits)
```r
cat(sprintf('<style>:root{--content:%sch}</style>', params$content_width))
```

Plot and table helpers (use consistently)
- In examples and walkthroughs, apply:
  - `theme_albers(params$family, base_size = params$base_size)`
  - `scale_color_albers(params$family, ...)` and `scale_fill_albers(params$family, ...)` as needed
  - `gt_albers(x, family = params$family)` for gt tables

CRAN rule
- Vignettes must build offline with only Imports/Suggests. The template copies `albers.css` next to each vignette; do not fetch CSS at runtime.

Discipline & accessibility
- One family per page; choose for mood/wayfinding, not meaning.
- Links/focus use AA‑safe tones: light mode A900; dark mode A300 (violet overrides dark link tone as `#BA68C8`).
- Callouts: A500 border + A300 tint (≤12%); keep borders subtle.
- Avoid color‑only encodings; use shapes, linetypes, labels.

Onboarding helper (optional)
- Run `albersdown::use_albers_vignettes()` in an existing package to:
  - Copy `vignettes/albers.css` if missing.
  - Add `template: { package: albersdown }` to `_pkgdown.yml` if absent.
  - Suggest `ggplot2` and `gt` in `Suggests`.

Acceptance checks (add to each blueprint)
- [ ] Vignette header includes `css: albers.css` and `params` block.
- [ ] A family is declared and body class is set (`palette-{family}`).
- [ ] Links and focus rings show the family accent and pass AA.
- [ ] Callouts use A500 border and A300 tint; tables have subtle stripe.
- [ ] Plots/tables use `theme_albers()` / `gt_albers()` with the chosen family.
- [ ] Page width feels readable (default 80ch, adjustable via `content_width`).

A) Human‑readable plan (Markdown)
	1.	Executive summary (one page)
	2.	IA & Navigation (tree view + reading paths)
	3.	Coverage matrix (features ↔ vignettes table)
	4.	Per‑vignette blueprints (one subsection per vignette)
	5.	Cross‑link map (bulleted edges)
	6.	Search & keyword plan
	7.	pkgdown config snippet
	8.	Open questions & assumptions

B) Machine‑readable JSON
Return a vignette_plan JSON object adhering to this schema:

{
  "package": "string",
  "version": "string",
  "audiences": [
    {"id": "string", "label": "string", "top_tasks": ["string"]}
  ],
  "features": [
    {"id": "string", "label": "string", "functions": ["string"]}
  ],
  "series": [
    {"id": "tutorials|howtos|explanations|reference", "title": "string", "order": ["slug", "slug2"]}
  ],
  "vignettes": [
    {
      "slug": "kebab-case",
      "title": "string",
      "type": "tutorial|how-to|explanation|reference-map",
      "audience": ["audience-id"],
      "prereqs": ["string"],
      "objectives": ["string"],
      "read_time_min": 0,
      "datasets": ["string"],
      "outline": [
        {"heading": "H2 text", "anchor": "h2-text", "summary": "string", "code_stub": "string"}
      ],
      "see_also": ["articles/<slug>.html#anchor", "reference/<topic>.html"],
      "keywords": ["string"],
      "covers_features": ["feature-id"]
    }
  ],
  "coverage_matrix": [
    {"feature_id": "string", "vignettes": ["slug1","slug2"]}
  ],
  "crosslinks": [
    {"from": "articles/<slug>#anchor", "to": "articles/<slug>#anchor", "reason": "string"}
  ],
  "pkgdown_yaml_snippet": "string",
  "acceptance_checks": [
    "string"
  ],
  "open_questions": [
    "string"
  ],
  "assumptions": [
    "string"
  ]
}


⸻

14) Guardrails
	•	No fabrication: if a function or dataset is unknown, flag it in open questions rather than inventing it.
	•	Keep code minimal & runnable: tiny, focused examples. Avoid network or long compute in blueprints.
	•	Prefer relative links and stable anchors.
	•	Use the specified chunk defaults unless a blueprint justifies changes.

⸻

15) Example blueprint (for reference only; do not assume this package exists)

Vignette: Join rectangular data with {foo}
	•	Type: how‑to
	•	Audience: Analyst
	•	Objectives: Perform left/right/inner joins; diagnose key mismatches
	•	Prereqs: {foo}, {dplyr}, sample orders, customers tibbles
	•	Outline:
	•	Goal — Match orders to customers.
	•	TL;DR — orders |> foo::join(customers, by = "customer_id")
	•	Setup — library(foo); library(dplyr); seed and options.
	•	Walkthrough — canonical join; non‑unique keys; missing keys; anti/semi joins.
	•	Diagnostics — foo::check_keys(); log mismatches.
	•	Performance — memory note, chunked joins tip.
	•	See also — Getting started; Keys & indexes (explanation); foo::join() reference.
	•	Keywords: join, merge, keys, relational, combine
	•	Covers features: joins, key-diagnostics

⸻

16) Starter front‑matter & setup (you will reuse these in blueprints)

Provide this front matter and setup chunk in each blueprint you output:

---
title: "<Title here>"
name: <slug-here>
description: "<One-sentence description>"
output:
  rmarkdown::html_vignette:
    toc: true
    toc_depth: 2
vignette: >
  %\VignetteIndexEntry{<Index title>}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(
  collapse = TRUE,
  comment  = "#>",
  fig.align = "center",
  fig.retina = 2,
  out.width = "100%",
  message = FALSE,
  warning = FALSE
)
set.seed(123)
options(pillar.sigfig = 7, width = 80)
```

⸻

17) “Albers Minimalist” visual system (final addendum)

A) Ten design rules
	1.	White space is a feature: target a 60–75 character measure with generous margins.
	2.	One accent color: keep pages ≈90% neutral, 9% muted, ≤1% accent; no gradients, glows, or drop shadows.
	3.	Typographic discipline: stick to system fonts; sentence‑case headings; no center‑justified body text.
	4.	Strict hierarchy: use H1 once, then H2/H3 with stable `{#anchors}` for every H2.
	5.	Underlines mean links: underline all links; hover increases contrast.
	6.	Chart ink is information: theme_minimal()-style charts, light grids, legend on top, caption everything.
	7.	Tables are quiet: subtle striping, no vertical rules, compact padding.
	8.	Callouts are whisper‑soft: thin left rule + subtle tint; avoid heavy frames or icons.
	9.	Born accessible: WCAG AA contrast, no color-only encoding, dark-mode parity.
	10.	Print-friendly: high-contrast on white, scalable figures, no interactive-only affordances.

B) Design tokens + typography, spacing, figures

Token | Light | Dark
-- | -- | --
`--albers-bg` | `#ffffff` | `#0b0c0e`
`--albers-fg` | `#111111` | `#e6e6e6`
`--albers-muted` | `#6b7280` | `#9aa0a6`
`--albers-border` | `#e5e7eb` | `#2a2f36`
`--albers-accent` | `#1f6feb` | `#7aa2ff`
`--albers-link` | `#1f6feb` | `#93b4ff`
`--albers-code-bg` | `#f6f8fa` | `#161b22`

Typography  
	•	Body: `-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, "Noto Sans", sans-serif`  
	•	Code: `ui-monospace, "SF Mono", Menlo, Consolas, "Liberation Mono", "Roboto Mono", monospace`  
	•	Base sizing: body 17–18 px, line-height 1.55; H1 = 1.6–1.8× body, H2 = 1.35×, H3 = 1.15×.

Spacing & layout  
	•	4-pt rhythm: 4 / 8 / 12 / 16 / 24 / 32 px.  
	•	Content width: `max-width: 70–72ch`, centered column.  
	•	Figures: `fig.width = 7`, `fig.asp = 0.618` (golden aspect).

C) Implementation quick-start
	1.	Create `vignettes/albers.css`, add it to each vignette via YAML (`css: albers.css`), and hold the following minimalist styles:

```css
:root{
  --albers-bg:#fff; --albers-fg:#111; --albers-muted:#6b7280;
  --albers-border:#e5e7eb; --albers-accent:#1f6feb; --albers-link:#1f6feb;
  --albers-code-bg:#f6f8fa;
  --rhythm-1:4px; --rhythm-2:8px; --rhythm-3:12px; --rhythm-4:16px; --rhythm-5:24px; --rhythm-6:32px;
  --content-max:72ch;
  --font-body:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,"Helvetica Neue",Arial,"Noto Sans",sans-serif;
  --font-code:ui-monospace,"SF Mono",Menlo,Consolas,"Liberation Mono","Roboto Mono",monospace;
}
@media (prefers-color-scheme: dark){
  :root{
    --albers-bg:#0b0c0e; --albers-fg:#e6e6e6; --albers-muted:#9aa0a6;
    --albers-border:#2a2f36; --albers-accent:#7aa2ff; --albers-link:#93b4ff;
    --albers-code-bg:#161b22;
  }
}
html,body{background:var(--albers-bg); color:var(--albers-fg); font-family:var(--font-body); line-height:1.55; font-size:17.5px;}
main, .content, .container, .page-content, .vignette, .contents{
  max-width:var(--content-max); margin-inline:auto; padding-inline:clamp(var(--rhythm-4), 2vw, var(--rhythm-6));
}
p{margin-block: var(--rhythm-4);}
h1,h2,h3{font-weight:600; line-height:1.25; margin-top:var(--rhythm-6); margin-bottom:var(--rhythm-3);}
h1{font-size:1.8rem;} h2{font-size:1.4rem;} h3{font-size:1.2rem;}
a{color:var(--albers-link); text-decoration:underline; text-underline-offset:2px;}
a:hover{filter:brightness(0.9);}
a:focus{outline:2px solid var(--albers-accent); outline-offset:2px;}
code, pre, kbd, samp{font-family:var(--font-code); font-size:0.95em;}
pre{background:var(--albers-code-bg); border:1px solid var(--albers-border);
    padding:var(--rhythm-5); border-radius:6px; overflow:auto; margin-block:var(--rhythm-5);}
pre code{background:transparent; border:none; padding:0;}
p code{background:var(--albers-code-bg); padding:0.1em 0.35em; border-radius:4px; border:1px solid var(--albers-border);}
table{border-collapse:collapse; width:100%; font-variant-numeric:tabular-nums;}
th,td{border-bottom:1px solid var(--albers-border); padding:10px 8px;}
thead th{font-weight:600;}
tbody tr:nth-child(odd){background:color-mix(in srgb, var(--albers-code-bg) 35%, transparent);}
caption{caption-side:bottom; color:var(--albers-muted); padding-top:var(--rhythm-3); font-size:0.95em;}
figure, img{max-width:100%; height:auto;}
figcaption{color:var(--albers-muted); font-size:0.95em; margin-top:var(--rhythm-2);}
.center{display:block; margin-inline:auto;}
ul,ol{padding-left:1.1em; margin-block:var(--rhythm-4);}
li+li{margin-top:4px;}
blockquote, .callout{
  border-left:3px solid var(--albers-accent); background:color-mix(in srgb, var(--albers-accent) 6%, transparent);
  padding:var(--rhythm-4) var(--rhythm-5); margin-block:var(--rhythm-5); border-radius:6px;
}
blockquote p{margin:0;}
h2:hover .anchor, h3:hover .anchor{opacity:1;}
.anchor{opacity:0; margin-left:6px; text-decoration:none; color:var(--albers-muted);}
```

Attach it via vignette YAML:

```yaml
output:
  rmarkdown::html_vignette:
    toc: true
    toc_depth: 2
css: albers.css
```

	2.	Add minimalist ggplot2 helpers (store under `R/theme-albers.R`; ensure `{ggplot2}` + `{viridisLite}` are in Suggests) and call `theme_set(theme_albers())` in vignette setup chunks:

```r
albers_okabe_ito <- function() {
  c("#000000","#E69F00","#56B4E9","#009E73","#F0E442","#0072B2","#D55E00","#CC79A7")
}

scale_color_albers <- function(..., discrete = TRUE) {
  if (discrete) ggplot2::scale_color_manual(values = albers_okabe_ito(), ...)
  else if (requireNamespace("viridisLite", quietly = TRUE))
    ggplot2::scale_color_gradientn(colours = viridisLite::viridis(256), ...)
  else ggplot2::scale_color_gradient(low = "#cbd5e1", high = "#1f6feb", ...)
}

scale_fill_albers <- function(..., discrete = TRUE) {
  if (discrete) ggplot2::scale_fill_manual(values = albers_okabe_ito(), ...)
  else if (requireNamespace("viridisLite", quietly = TRUE))
    ggplot2::scale_fill_gradientn(colours = viridisLite::viridis(256), ...)
  else ggplot2::scale_fill_gradient(low = "#cbd5e1", high = "#1f6feb", ...)
}

theme_albers <- function(base_size = 11, base_family = "system-ui") {
  ggplot2::theme_minimal(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      panel.grid.major = ggplot2::element_line(color = "#e5e7eb", linewidth = 0.3),
      panel.grid.minor = ggplot2::element_blank(),
      axis.title.x = ggplot2::element_text(margin = ggplot2::margin(t = 6)),
      axis.title.y = ggplot2::element_text(margin = ggplot2::margin(r = 6)),
      plot.title = ggplot2::element_text(face = "bold", margin = ggplot2::margin(b = 8)),
      plot.subtitle = ggplot2::element_text(margin = ggplot2::margin(b = 10), color = "#374151"),
      plot.caption = ggplot2::element_text(size = rel(0.9), color = "#6b7280", margin = ggplot2::margin(t = 10)),
      legend.position = "top",
      legend.title = ggplot2::element_text(face = "bold")
    )
}
```

Example usage:

```r
theme_set(theme_albers())

mtcars |>
  ggplot2::ggplot(ggplot2::aes(wt, mpg, color = factor(cyl))) +
  ggplot2::geom_point(size = 2.2) +
  scale_color_albers() +
  ggplot2::labs(
    title = "Fuel efficiency vs. weight",
    subtitle = "Example with Albers theme",
    x = "Weight (1000 lbs)",
    y = "MPG"
  ) +
  theme_albers()
```

	3.	Optional: define a quiet GT helper for striped tables (`R/gt-albers.R`) and call `gt_albers()` inside vignettes.

```r
gt_albers <- function(x) {
  x |>
    gt::opt_row_striping() |>
    gt::tab_options(
      table.width = gt::px(720),
      table.font.names = "system-ui",
      table.border.top.color = "transparent",
      table.border.bottom.color = "transparent",
      data_row.padding = gt::px(6),
      heading.align = "left"
    ) |>
    gt::tab_style(
      style = list(gt::cell_borders(sides = "bottom", color = "#e5e7eb")),
      locations = gt::cells_body()
    ) |>
    gt::tab_style(
      style = gt::cell_text(color = "#6b7280"),
      locations = gt::cells_title(groups = "subtitle")
    )
}
```

D) pkgdown integration

Use a `_pkgdown.yml` snippet to propagate the same palette + CSS site-wide (place the CSS at `inst/pkgdown/albers.css`):

```yaml
template:
  bootstrap: 5
  bslib:
    bg: "#ffffff"
    fg: "#111111"
    primary: "#1f6feb"
    secondary: "#6b7280"
    base_font: "system-ui"
    heading_font: "system-ui"
    code_font: "ui-monospace"
  assets:
    - "inst/pkgdown/albers.css"
highlight: textmate
```

E) Vignette front-matter & chunk defaults
	•	Add `description: "Clean, minimal vignette using the Albers visual system."` and `css: albers.css` to the YAML shown in §16.  
	•	Prefer chunk defaults that reinforce the layout: `fig.width = 7`, `fig.asp = 0.618`, `fig.align = "center"`, `fig.retina = 2`, `out.width = "100%"`, `message = FALSE`, `warning = FALSE`, `collapse = TRUE`, `comment = "#>"`.  
	•	Set `options(pillar.sigfig = 7, width = 80)` and `set.seed(123)` so printed tibbles stay narrow and reproducible.

F) “Albers gates” visual QA
	•	Content column ≤72ch; paragraphs ≤6–7 lines.  
	•	Exactly one accent color; links underlined.  
	•	Every figure carries a subtitle (why it matters) and caption (what to notice).  
	•	Plots use `theme_albers()`, top legend, no chart junk.  
	•	Tables use `gt_albers()` (or equivalent): subtle striping, captions present, no vertical rules.  
	•	Callouts = thin left rule + light tint; icons optional.  
	•	Dark mode renders cleanly; contrast ≥ AA.  
	•	Print/PDF remains legible; no color-only semantics.

G) Notes for the LLM when drafting blueprints
	•	After each outline section, add “Visual notes” covering figure type, callouts, and table styling (reference `gt_albers()` where relevant).  
	•	Assume system fonts—no external font dependencies unless explicitly requested.  
	•	Use a single accent (`--albers-accent`) for links, callouts, and the hero data series.  
	•	Ensure all code blocks render inside `<pre><code>` elements so the CSS applies; avoid overly wide outputs.  
	•	When specifying chunk defaults, mention `theme_set(theme_albers())` in setup.  
	•	Document how design tokens map to CSS/pkgdown/bslib to keep RMarkdown and pkgdown perfectly aligned.

---

## ⏭️ *Now do the task*

Using the inputs provided, produce:

1) The **Markdown plan** described in §13(A).  
2) The **JSON artifact** conforming to §13(B).  
3) A `_pkgdown.yml` snippet that implements the nav and ordering you proposed.

If any information is missing, (a) proceed with reasonable assumptions, (b) list **assumptions** and **open questions** explicitly, and (c) make the plan easy to adjust later.

---

### (Optional) Package‑specific knobs

You may receive additional preferences:

- `{STYLE_TONE}` (e.g., friendlier vs. concise)  
- `{LONG_RUNNING_POLICY}` (e.g., no chunk > 2s)  
- `{DATA_POLICY}` (e.g., no external downloads; use packaged data only)  
- `{NAV_EXTRA}` (extra nav items like “Changelog” or “Design Notes”)

Respect these if provided; otherwise use defaults above.

---

**End of meta‑prompt.**

---

### Want me to tailor this to your org?
If you share a representative package (name, function list, and any constraints), I can run this meta‑prompt and return the first full plan and JSON so you can see it in action.
