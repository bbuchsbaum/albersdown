# albersdown (development version)

* Definition lists (including the pkgdown reference index) no longer let one
  long term squeeze every description to a sliver. The term column now fits
  its content up to 45% of the row, and long terms wrap between calls; a
  call is split only when it is wider than the column itself. In 2.1.0 the
  column grew to its widest term, so a reference entry listing many S3
  methods pushed descriptions down to one character per line.

* `use_albersdown()` now retires the stylesheet and script that albersdown
  1.x copied into `pkgdown/extra.css` and `pkgdown/extra.js`. pkgdown loads
  `extra.css` after the theme, so an old copy overrode 2.x on every page
  (uppercase headings, section numbers run into the heading text). A file is
  retired, with a backup, only when its text matches a version albersdown
  shipped. A family or preset the old script set carries over to the
  defaults line; otherwise the vignettes' choice is used. An
  edited copy is kept with a warning, and the doctor flags it.

* `use_albersdown()` appends to `.Rbuildignore` and `.gitignore` instead of
  rewriting them, so a file that mixes CRLF and LF line endings keeps every
  existing byte.

* On pkgdown sites, a plot now sits 2rem below the code that made it, not
  3.5rem. Bootstrap styles knitr's `div.figure` as `inline-block`, whose
  margins add to the code block's instead of collapsing; the theme now sets
  it to `block`.

# albersdown 2.1.0

## A vignette format

* New output format `albersdown::albers_vignette()`: one line of YAML themes a
  CRAN vignette, with nothing copied into `vignettes/`. It embeds the installed
  stylesheet, the page script and only the chosen direction's fonts, sets the
  family and direction before the page draws (no restyle on load), sets knitr
  defaults, and uses `theme_albers()` for the render. Scales and themes called
  without a family follow the vignette's family (`albersdown.family` option).
  Packages using it should declare `albersdown (>= 2.1.0)`.
* Dark figures: each auto-printed ggplot is also rendered with
  `theme_albers(mode = "dark")` (and night tones for albersdown scales), shown
  in dark mode instead of a light plot on a dark page (`dark_figures = FALSE`
  turns this off). Chunks with `fig.show = "hold"`, `"animate"` or `"hide"`
  get no dark version.
* Phone figures: each plot (ggplot2, grid or base graphics) is also drawn at
  phone width (3.6 in), shown while the figure is displayed narrower than about
  470 px, so axis text on a 390 px phone is about 15 px instead of 8 px. Print
  and the enlarged view keep the full figure. This adds about 66 KB per simple
  ggplot (light and dark); `phone_figures = FALSE` turns it off.
* `albers_vignette()` writes equations as MathML by default
  (`math_method = "mathml"`), so pages with math need no CDN, and gives
  base-graphics plots the page's ground, ink, font and family palette.
* The R Markdown template uses the format and renders out of the box.
* pkgdown sites are themed by `template: package: albersdown` alone: the
  template's `in-header.html` links the stylesheet and script on every page.
  Articles on `albers_vignette()` keep their own family and direction on the
  site; `pkgdown/extra.js` (written by `use_albersdown()`) only sets the site
  defaults. A site's own `pkgdown/extra.css` loads after the theme, so it can
  override it.

## Design

* Family ramps rebuilt in OKLCH with even lightness steps; green and violet are
  now pigment-like. Each family has its own complement (red/gold, lapis/orange,
  ochre/lavender, teal/coral, green/rose, violet/olive), used by the title
  plate, the sheet band, code strings and the discrete scales.
* A "Homage to the Square" title plate beside every vignette and article
  title; numbered sections; a margin column with sidenotes on wide screens;
  opt-in `.wide` blocks; a colophon; callouts as typed Albers objects.
* Code output is set as one block per run of `#>` lines, with messages,
  warnings and errors marked; the copy button copies source without output.
  On phones, long source lines wrap at ranked break points with a hanging
  indent that follows the author's own alignment.
* Tables are booktabs with numbered captions; figures are numbered and sit on
  the page (`theme_albers()` uses the sheet colour, with no panel box).
* Real dark mode for both directions (warm and cool nights), resolved before
  first paint, with a three-state control (follow system / light / dark).
* Syntax colours follow the family and direction everywhere: numbers take their
  own hue, dark homage is warm and dark interaction cool.
* Print keeps the page's identity: the first printed page carries the title
  plate and the family bar, the code ground keeps a light wash of the family,
  and the syntax keeps the family's colours. Dark mode prints light, with page
  margins and expanded `<details>`.
* The legacy `midnight` preset sits on the family's deepest tone mixed into
  ink, not a fixed navy, with its own syntax colours. `theme_albers()`,
  `gt_albers()`, `albers_bs_theme()` and base-graphics chunks use the same
  family-tinted ground, so midnight plots match the page.
* Bundled fonts are trimmed to the axis ranges the theme uses, with
  Newsreader's optical size fixed at its text size.
* `scale_color_albers()`/`scale_fill_albers()` gain `type = c("contrast",
  "family")`; the default pairs the family with its complement. New
  `albers_discrete()`.

## Reading and accessibility

* Long pages keep the reader's place: the page is prepared lazily in chunks
  without moving what is on screen or losing a text selection, and the place
  is restored on reload and Back.
* No layout shift on load (metric-matched font fallbacks).
* Visible keyboard focus; headings are their own permalinks; a contents list
  that tracks the reader; skip link; keyboard-scrollable wide code and tables;
  `prefers-contrast` and `prefers-reduced-motion` honoured.
* `tools/validate_albers_contrast.R` (in the source repository) checks every
  text role against every ground for every family and direction (362 pairs,
  all at least 4.5:1).

## Setup helpers

* `use_albersdown()` moves a package onto the format by default
  (`method = "format"`): each `html_vignette` vignette's `output:` is switched
  to `albersdown::albers_vignette`, `DESCRIPTION` gains
  `albersdown (>= <installed version>)` (in `Suggests`, or where albersdown is
  already in `Imports`/`Depends`), `knitr`, `rmarkdown` and
  `VignetteBuilder: knitr`, and `_pkgdown.yml` points at the template. When the
  installed albersdown is a development version it also adds
  `Remotes: bbuchsbaum/albersdown` and says so. `method = "vendor"` keeps the
  2.0 behaviour (copying the assets into `vignettes/`).
* Vignette dependencies are added only when a vignette is on the format;
  otherwise (no vignettes, none convertible, or `apply_to = "new"`) only
  `_pkgdown.yml` and `Config/Needs/website` change, a site-only adoption that
  R CMD check does not see.
* Edits are textual: other output formats, a vignette's own `css:` and
  `includes:`, comments, key order, CRLF line endings and a byte-order mark are
  kept; vignettes on other formats, Quarto vignettes, flow-style
  `output: {...}` headers and `vignettes/articles/` are reported and left
  alone. Changed files are backed up to `.albersdown.bak/` (a first backup is
  never overwritten); `_pkgdown.yml`, `pkgdown/` and `.albersdown.bak/` are
  added to `.Rbuildignore`. `dry_run = TRUE` lists every change.
* A package set up by albersdown 2.0 is migrated: the setup-chunk lines and
  `family`/`preset` params 2.0 added, its `pkgdown/extra.css` and
  `pkgdown/extra.js`, and its README note are removed or rewritten, and the
  copied assets are moved from `vignettes/` to `.albersdown.bak/`.
* `use_albersdown()` and `migrate_albersdown()` called without `family` or
  `preset` keep the package's current choice (read from its vignettes or site
  defaults) and say where they found it; previously a 2.0 migration without
  `family` switched the package to red.
* `family`, `preset` and `style` are matched case-insensitively, and a bad
  value gives an error naming the function and the argument.
* The README note is opt-in (`readme = TRUE`) and goes in `README.Rmd` when
  there is one.

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
