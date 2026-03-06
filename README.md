albersdown
===============================

<!-- badges: start -->
[![R-CMD-check](https://github.com/bbuchsbaum/albersdown/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/bbuchsbaum/albersdown/actions/workflows/R-CMD-check.yaml)
[![pkgdown](https://github.com/bbuchsbaum/albersdown/actions/workflows/pkgdown.yaml/badge.svg)](https://bbuchsbaum.github.io/albersdown/)
<!-- badges: end -->

Minimalist theme and vignette kit for pkgdown and R Markdown.

- One line to theme pkgdown sites via a template package.
- Vignettes ship with local CSS for CRAN-friendly offline builds.
- Helper functions for ggplot2 and gt align plots/tables with the house style.

Install (template package)
-------------------------

This package is meant to live on GitHub and be pinned by consumers.

Install with pak:

```r
pak::pak("bbuchsbaum/albersdown")
```

Use in a consuming package
-------------------------

1) pkgdown site theme

_pkgdown.yml:

```yaml
template:
  package: albersdown
```

DESCRIPTION:

```yaml
Config/Needs/website: bbuchsbaum/albersdown
```

2) Vignettes (offline & styled)

Create a new vignette using the "Albers Vignette" template (or run `albersdown::use_albers_vignettes()`). The skeleton includes:

```yaml
output: rmarkdown::html_vignette
css: albers.css
```

In the setup chunk:

```r
library(ggplot2)
ggplot2::theme_set(albersdown::theme_albers(
  family = params$family,
  preset = params$preset,
  base_size = 13
))
```

3) Retrofit an existing package (replace prior theming)

```r
albersdown::use_albersdown(
  family = "red",
  preset = "homage",
  apply_to = "all",
  force_replace = TRUE
)
```

Team one-liner (same defaults as above):

```r
albersdown::migrate_albersdown()
```

Migration also exposes the Albers theme surface directly:

```r
albersdown::migrate_albersdown(family = "teal", preset = "midnight")
```

Helpers
-------

- theme_albers(family = "red", preset = "homage")
- scale_color_albers(family = "red", discrete = TRUE, ...)
- scale_fill_albers(family = "red", discrete = TRUE, ...)
- scale_color_albers_highlight(family = "red", tone = "A700", other = "#9aa0a6")
- scale_fill_albers_highlight(family = "red", tone = "A700", other = "#9aa0a6")
- gt_albers(x, family = "red", preset = "homage")

Design tooling
--------------

- Vignettes: `getting-started`, `design-notes`, `theme-lab`, `theme-showcase`.
- Theme Lab article: interactive family/preset/style/content-width preview.
- Theme Showcase article: dark preset + non-red accent family gallery.
- Token source of truth: `inst/tokens/albers-tokens.yml`.
- Token sync script: `Rscript tools/sync_albers_assets.R`.
- Homepage blueprint: `inst/pkgdown/templates/homepage-blueprint.md`.
- Visual regression scaffold: `tests/visual-regression/` plus workflow `visual-regression.yaml`.

Notes
-----

- Keep vignette CSS local to satisfy CRAN’s no-network rule.
- Pin a release tag in Config/Needs/website for deterministic site builds.

Choosing a palette family per page
----------------------------------

- Families: red, lapis, ochre, teal, green, violet.
- Presets: homage, study, structural, adobe, midnight.
- In YAML, add:
  `params: { family: "red", preset: "study" }`
- In setup, call:
  `ggplot2::theme_set(albersdown::theme_albers(family = params$family, preset = params$preset))`
- If plot text feels small, increase `base_size` (e.g., 13–14):
  `ggplot2::theme_set(albersdown::theme_albers(family = params$family, preset = params$preset, base_size = 14))`
- Add body class so CSS tokens switch by family:
  cat(sprintf('<script>document.addEventListener("DOMContentLoaded",function(){document.body.classList.add("palette-%s");});</script>', params$family))
- Add body class so CSS preset styles switch by preset:
  `cat(sprintf('<script>document.addEventListener("DOMContentLoaded",function(){document.body.classList.add("preset-%s");});</script>', params$preset))`

<!-- albersdown:theme-note:start -->
## Albers theme
This package uses the albersdown theme. Existing vignette theme hooks are replaced so `albers.css` and local `albers.js` render consistently on CRAN and GitHub Pages. The defaults are configured via `params$family` and `params$preset` (family = 'red', preset = 'homage'). The pkgdown site uses `template: { package: albersdown }`.
<!-- albersdown:theme-note:end -->
