# albersdown development

* `migrate_albersdown()` now exposes the full Albers family/preset choices and
  migrated vignettes now apply both `params$family` and `params$preset` in the
  injected `theme_albers()` call.
* `use_albersdown()` and `migrate_albersdown()` now write `html_vignette`
  metadata in the form that `rmarkdown` actually honors: vignette CSS is placed
  under `output: rmarkdown::html_vignette`, `includes: in_header` points at a
  real `albers-header.html` file, and migrated vignettes get a single
  idempotent runtime class hook for `palette-*` and `preset-*`.
* Re-running `migrate_albersdown()` no longer duplicates the marked Albers note
  in `README.md` or the vignette class-injection block.
* Added two proof vignettes, `proof-teal-study` and
  `proof-ochre-structural`, so users can inspect full-page non-red family /
  preset combinations directly.

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
