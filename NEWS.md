# albersdown (development version)

## A vignette format

* New output format `albersdown::albers_vignette()`: one line of YAML themes a
  CRAN vignette, with nothing copied into `vignettes/`. It embeds the installed
  stylesheet, the page script and only the chosen direction's fonts, stamps the
  family and direction before the page draws (no restyle on load), sets knitr
  defaults, and sets `theme_albers()` for the render. Scales and themes called
  without a family follow the vignette's family (`albersdown.family` option).
* Plots have dark twins: each auto-printed ggplot is also rendered with
  `theme_albers(mode = "dark")` (and night tones for albersdown scales), and the
  page shows it in dark mode instead of a light plot on a dark page
  (`dark_figures = FALSE` turns this off). Plots in chunks with
  `fig.show = "hold"`, `"animate"` or `"hide"` get no twin and stay light.
* The R Markdown template now uses the format and renders out of the box.
* pkgdown sites are themed by `template: package: albersdown` alone: the
  template's `in-header.html` links the stylesheet and script on every page.
  Articles on `albers_vignette()` keep their own family and direction on the
  site. `pkgdown/extra.js` (written by `use_albersdown()`) now only sets the site
  defaults.

## Design

* Family ramps rebuilt in OKLCH with even lightness steps; green and violet are
  now pigment-like. Each family has its own "interaction" complement
  (red/gold, lapis/orange, ochre/lavender, teal/coral, green/rose,
  violet/olive), used by the title plate, the sheet band, code strings and the
  discrete scales.
* A "Homage to the Square" title plate beside every vignette and article
  title; numbered sections; a margin column with sidenotes on wide screens;
  opt-in `.wide` blocks; a colophon; callouts as typed Albers objects.
* Code output is set as one block per run of `#>` lines, with warnings and
  errors marked; the copy button copies source without output.
* Tables are booktabs with numbered captions; figures are numbered and sit on
  the page (`theme_albers()` now uses the sheet colour, with no panel box).
* Real dark mode for both directions (warm and cool nights), resolved before
  first paint, with a three-state control (follow system / light / dark).
* Syntax colours follow the family and direction everywhere: numbers take their
  own hue, dark homage is warm and dark interaction cool, and printed code keeps
  the family's colours.
* The legacy `midnight` preset now sits on the family's deepest tone mixed into
  ink, not a fixed navy, with its own syntax colours. `theme_albers()`,
  `gt_albers()`, `albers_bs_theme()` and base-graphics chunks use the same
  family-tinted ground, so midnight plots match the page.
* Bundled fonts trimmed to the axis ranges the theme uses, and Newsreader's
  optical size fixed at its text size: each homage vignette is about 120 KB
  smaller.

## Accessibility and function

* Visible keyboard focus; headings are their own permalinks; a contents list
  that tracks the reader; skip link; keyboard-scrollable wide code and tables;
  light printing from dark mode with page margins and expanded `<details>`;
  `prefers-contrast` and `prefers-reduced-motion` honoured.
* `tools/validate_albers_contrast.R` (in the source repository) checks every
  text role against every ground for every family and direction (362 pairs,
  all at least 4.5:1).

## Other changes

* `use_albersdown()` now moves a package onto the format by default
  (`method = "format"`): each vignette's `output:` is switched to
  `albersdown::albers_vignette`, `DESCRIPTION` gains `albersdown`, `knitr` and
  `rmarkdown` in `Suggests` (and `VignetteBuilder: knitr`), and `_pkgdown.yml`
  points at the template. Edits are textual, so other output formats, comments
  and key order are kept; changed files are backed up to `.albersdown.bak/`.
  `method = "vendor"` keeps the 2.0 behaviour (copying the assets into
  `vignettes/`), which `migrate_albersdown()` and `use_albers_vignettes()` still
  use. The README note is now opt-in (`readme = TRUE`), and `pkgdown/` is added
  to `.Rbuildignore`. For vignettes already on the format, a re-run only
  updates their family and direction.
* The retrofit keeps a vignette's own `css:` and `includes:` (only albersdown's
  old `albers.css`/`albers-header.html` hooks are removed), leaves vignettes on
  other formats (e.g. bookdown) or with another format listed first unchanged,
  never overwrites a file's first backup, validates `family`, refuses a
  directory that is not a package, and on a re-run updates the family and
  direction of vignettes already on the format.
* The format retrofit writes `albersdown (>= <installed version>)` in
  `Suggests`, since CRAN albersdown 2.0.0 has no `albers_vignette()`; while
  that version is a development version it also adds
  `Remotes: bbuchsbaum/albersdown` and says so. A bare `albersdown` in
  `Config/Needs/website` is folded into `bbuchsbaum/albersdown`.
* The retrofit migrates a package set up by albersdown 2.0: it removes the
  setup-chunk lines 2.0 added (`ragg`, font registration, and the
  `theme_set(... params$family ...)` line that re-themed plots in the old
  family), the `family`/`preset` params when nothing else reads them, 2.0's
  `pkgdown/extra.css` (an `@import` of the theme) and `pkgdown/extra.js` (an
  old copy of `albers.js`), rewrites its README note, and moves the copied
  `albers.css`, `albers.js`, `albers-header.html` and fonts from `vignettes/`
  to `.albersdown.bak/`.
* The retrofit adds vignette dependencies (`albersdown` with its bound,
  `knitr`, `rmarkdown`, `VignetteBuilder`, `Remotes`) only when a vignette is on
  the format; otherwise (no vignettes, none convertible, or `apply_to = "new"`)
  it changes only `_pkgdown.yml` and `Config/Needs/website`, a site-only
  adoption that R CMD check does not see. An albersdown already in `Imports` or
  `Depends` gets the bound there instead of a second listing in `Suggests`; a
  pinned or `github::` website reference is not duplicated.
* `use_albersdown()` and `migrate_albersdown()` called without `family` or
  `preset` keep the package's current choice, read from its vignettes
  (`albers_vignette()` entries or albersdown 2.0's `params`, the most common
  if they differ; a vignette that leaves `family` out is not counted) or its
  site defaults (`pkgdown/extra.js`, `_pkgdown.yml`; these come first with
  `apply_to = "new"`, which only sets up the site), and say so; they fall back to red/homage only when nothing is found.
  Previously a 2.0 migration without `family` switched the package to red.
* `family` and `preset` in `use_albersdown()`, and `family`, `preset` and
  `style` in `albers_vignette()`, are matched case-insensitively (`"Teal"`
  works), and a bad value gives an error naming the function and the argument.
* The retrofit removes albersdown 2.0's `family`/`preset` params only from files
  2.0 set up, so a vignette's own `family` parameter is kept.
* With `readme = TRUE` the note goes in `README.Rmd` when there is one, and on
  the site-only route it describes only the site; a README note from
  albersdown 2.0 is rewritten only once the vignettes are on the format.
  Flow-style `output: {...}` headers are reported as such, and file names or
  YAML containing braces no longer break the helper's messages.
* The retrofit adds `_pkgdown.yml` (and, when it creates the file, `docs/`) to
  `.Rbuildignore`, so it no longer causes an R CMD check NOTE.
* The retrofit finds YAML headers as rmarkdown does (trailing blanks on the
  fences, a closing `...`), keeps CRLF line endings and a byte-order mark,
  writes a README note that describes the format with `readme = TRUE`, lists
  `.Rbuildignore`/`.gitignore` edits in a dry run, and says why Quarto
  vignettes and `vignettes/articles/` are not converted.
* `albers_vignette()` gives base-graphics plots the page's ground, ink, font and
  family palette.
* `albers_vignette()` writes equations as MathML by default
  (`math_method = "mathml"`), so pages with math need no CDN.
* A site's own `pkgdown/extra.css` loads after the theme again, so it can
  override it.
* `scale_color_albers()`/`scale_fill_albers()` gain `type = c("contrast",
  "family")`; the default pairs the family with its complement. New
  `albers_discrete()`.

# albersdown 2.0.0

albersdown 2.0.0 is a visual redesign organised around two curated
**directions** — **homage** (warm cream ground, Newsreader serif body, light
code blocks) and **interaction** (cool grey ground, all-grotesk type, dark code
blocks) — each pairing with the six accent families. Pages and plots now share
the same grounds and bundled typefaces, and the signature heading marker is a
nested "Homage to the Square".

## Breaking changes

* The featured visual directions are now `homage` and `interaction`:
  `albers_presets()` returns `c("homage", "interaction")`. The `homage` preset
  has been redefined from gallery white to a warm cream ground. The legacy
  presets `study`, `structural`, `adobe`, and `midnight` are still accepted by
  `theme_albers()`, `gt_albers()`, and `albers_bs_theme()` for backward
  compatibility, but are no longer featured.
* Typography moved from a system-font stack (Avenir Next, etc.) to bundled web
  fonts: Familjen Grotesk + Newsreader (homage) and Space Grotesk + Hanken
  Grotesk (interaction), with Spline Sans Mono / JetBrains Mono for code. The
  fonts ship in `inst/fonts/` under the SIL Open Font License.
* The em-dash heading marker is replaced by a nested-square marker whose inner
  squares follow the active family and whose outer ring is the direction's
  signature hue.
* `theme_albers()` and `theme_albers_void()`: `base_family` now defaults to
  `NULL`. When unset, the theme uses the direction's display font if it has been
  registered with `albers_register_fonts()`, otherwise the system `"sans"`
  family.

## New features

* `albers_register_fonts()`: register the bundled display fonts (Familjen
  Grotesk, Space Grotesk) for R graphics so plot text matches the HTML
  typography. Requires `systemfonts` and a font-aware device such as `ragg`;
  falls back silently to system fonts otherwise.
* The **interaction** direction renders code blocks on a dark ground with light
  syntax tokens; **homage** keeps light code. Inline code stays a light chip in
  both directions.
* The `style` intensity (`minimal` / `balanced` / `assertive`) now visibly
  scales the nested-square marker and structural rule weights.
* The interactive **Theme Lab** now works on the pkgdown site, with live family
  / direction / style / width controls, coloured palette chips, and a
  composition preview.

## Bug fixes

* `rmarkdown::html_vignette` output now lays out correctly on CRAN: the reading
  column is constrained and drawn as an Albers surface card, with a sticky
  sidebar table of contents on wide viewports (collapsing to a styled card on
  narrow screens). The previous rules only matched the pkgdown DOM, so
  CRAN-hosted vignettes rendered full-bleed with the contents stacked on top.
* Non-default directions no longer appear to switch background colour partway
  down a page: the active ground is mirrored onto `<html>`, so a short body
  never reveals the default ground.
* The pkgdown site now loads the full `albers.js`, so the Theme Lab and other
  interactive behaviours work on rendered articles (previously only the
  standalone vignette did).
* ggplot2 plots now sit on the same ground as their page — warm cream for
  homage, cool grey for interaction.

## Setup and migration

* `use_albersdown()` and `migrate_albersdown()` default to `preset = "homage"`,
  copy the bundled web fonts into `vignettes/fonts/`, inject
  the `ragg` device and a guarded `albers_register_fonts()` call into vignette
  setup chunks, and add `fonts` to `resource_files`. The generated
  `pkgdown/extra.js` now carries the full `albers.js` so consumer sites get the
  complete behaviour.
* Setup and migration helpers now accept both featured directions, `homage` and
  `interaction`, and generated class hooks clear `preset-interaction` before
  applying page-specific direction classes.
* `gt_albers()` and `albers_bs_theme()` use the per-direction type pairings.
* Setup writes `html_vignette` metadata in the form `rmarkdown` honours, with a
  single idempotent runtime class hook; re-running no longer duplicates the
  marked README note or the vignette class-injection block.

## Vignettes

* New **Interaction** vignette demonstrating the cool direction end to end.
* **Theme Showcase** reworked into a directions × families gallery: palette
  swatches, per-family plots, and side-by-side warm/cool example plots.
* The two proof vignettes now render real non-default combinations
  (Homage + teal, Interaction + ochre).

# albersdown 1.0.0

* Initial CRAN release.
* `theme_albers()` and `theme_albers_void()`: minimalist ggplot2 themes with
  configurable palette presets and typographic defaults.
* Colour scales for continuous, diverging, discrete, and highlight palettes
  (`scale_color_albers()`, `scale_fill_albers_diverging()`,
  `scale_color_albers_distinct()`, `scale_color_albers_highlight()`, and
  image-derived variants).
* `albers_palette()`, `albers_ramp()`, and `albers_swatch()` for working with
  the built-in colour system.
* `gt_albers()`: apply Albers styling to gt tables.
* `albers_bs_theme()`: bslib Bootstrap 5 theme for pkgdown sites.
* `use_albersdown()` and `use_albers_vignettes()`: one-command setup helpers
  to adopt Albers theming across an entire R package.
* `migrate_albersdown()`: migrate assets from an older albersdown layout.
* Two vignettes: "Getting Started" and "Design Notes".
