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
