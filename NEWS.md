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
