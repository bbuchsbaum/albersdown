# Changelog

## albersdown 1.0.1

- [`migrate_albersdown()`](https://bbuchsbaum.github.io/albersdown/reference/migrate_albersdown.md)
  now exposes the full Albers family/preset choices and migrated
  vignettes now apply both `params$family` and `params$preset` in the
  injected
  [`theme_albers()`](https://bbuchsbaum.github.io/albersdown/reference/theme_albers.md)
  call.
- [`use_albersdown()`](https://bbuchsbaum.github.io/albersdown/reference/use_albersdown.md)
  and
  [`migrate_albersdown()`](https://bbuchsbaum.github.io/albersdown/reference/migrate_albersdown.md)
  now write `html_vignette` metadata in the form that `rmarkdown`
  actually honors: vignette CSS is placed under
  `output: rmarkdown::html_vignette`, `includes: in_header` points at a
  real `albers-header.html` file, and migrated vignettes get a single
  idempotent runtime class hook for `palette-*` and `preset-*`.
- Re-running
  [`migrate_albersdown()`](https://bbuchsbaum.github.io/albersdown/reference/migrate_albersdown.md)
  no longer duplicates the marked Albers note in `README.md` or the
  vignette class-injection block.
- [`use_albers_vignettes()`](https://bbuchsbaum.github.io/albersdown/reference/use_albers_vignettes.md)
  once again works as a current-directory wrapper and forwards
  additional setup arguments to
  [`use_albersdown()`](https://bbuchsbaum.github.io/albersdown/reference/use_albersdown.md).
- The setup doctor now warns about legacy top-level vignette CSS/header
  hooks that
  [`rmarkdown::html_vignette()`](https://pkgs.rstudio.com/rmarkdown/reference/html_vignette.html)
  can ignore during CRAN builds.
- Added two proof vignettes, `proof-teal-study` and
  `proof-ochre-structural`, so users can inspect full-page non-red
  family / preset combinations directly.

## albersdown 1.0.0

CRAN release: 2026-04-01

- Initial CRAN release.
- [`theme_albers()`](https://bbuchsbaum.github.io/albersdown/reference/theme_albers.md)
  and
  [`theme_albers_void()`](https://bbuchsbaum.github.io/albersdown/reference/theme_albers_void.md):
  minimalist ggplot2 themes with configurable palette presets and
  typographic defaults.
- Colour scales for continuous, diverging, discrete, and highlight
  palettes
  ([`scale_color_albers()`](https://bbuchsbaum.github.io/albersdown/reference/scale_color_albers.md),
  [`scale_fill_albers_diverging()`](https://bbuchsbaum.github.io/albersdown/reference/scale_fill_albers_diverging.md),
  [`scale_color_albers_distinct()`](https://bbuchsbaum.github.io/albersdown/reference/scale_color_albers_distinct.md),
  [`scale_color_albers_highlight()`](https://bbuchsbaum.github.io/albersdown/reference/scale_color_albers_highlight.md),
  and image-derived variants).
- [`albers_palette()`](https://bbuchsbaum.github.io/albersdown/reference/albers_palette.md),
  [`albers_ramp()`](https://bbuchsbaum.github.io/albersdown/reference/albers_ramp.md),
  and
  [`albers_swatch()`](https://bbuchsbaum.github.io/albersdown/reference/albers_swatch.md)
  for working with the built-in colour system.
- [`gt_albers()`](https://bbuchsbaum.github.io/albersdown/reference/gt_albers.md):
  apply Albers styling to gt tables.
- [`albers_bs_theme()`](https://bbuchsbaum.github.io/albersdown/reference/albers_bs_theme.md):
  bslib Bootstrap 5 theme for pkgdown sites.
- [`use_albersdown()`](https://bbuchsbaum.github.io/albersdown/reference/use_albersdown.md)
  and
  [`use_albers_vignettes()`](https://bbuchsbaum.github.io/albersdown/reference/use_albers_vignettes.md):
  one-command setup helpers to adopt Albers theming across an entire R
  package.
- [`migrate_albersdown()`](https://bbuchsbaum.github.io/albersdown/reference/migrate_albersdown.md):
  migrate assets from an older albersdown layout.
- Two vignettes: “Getting Started” and “Design Notes”.
