albersdown
===============================

Minimalist theme and vignette kit for pkgdown and R Markdown.

- One line to theme pkgdown sites via a template package.
- Vignettes ship with local CSS for CRAN-friendly offline builds.
- Helper functions for ggplot2 and gt align plots/tables with the house style.

Install (template package)
-------------------------

This package is meant to live on GitHub and be pinned by consumers.

Install with pak: pak::pak("your-org/albersdown@v1.0.0").

Use in a consuming package
-------------------------

1) pkgdown site theme

_pkgdown.yml:

template:
  package: albersdown

DESCRIPTION:

Config/Needs/website: your-org/albersdown@v1.0.0

2) Vignettes (offline & styled)

Create a new vignette using the "Albers Vignette" template (or run albersdown::use_albers_vignettes()). The skeleton includes:

output: rmarkdown::html_vignette
css: albers.css

In the setup chunk:

library(ggplot2)
theme_set(albersdown::theme_albers(params$family, base_size = 13))

Helpers
-------

- theme_albers(family = "red")
- scale_color_albers(family = "red", discrete = TRUE, ...)
- scale_fill_albers(family = "red", discrete = TRUE, ...)
- scale_color_albers_highlight(family = "red", tone = "A700", other = "#9aa0a6")
- scale_fill_albers_highlight(family = "red", tone = "A700", other = "#9aa0a6")
- gt_albers(x, family = "red")

Notes
-----

- Keep vignette CSS local to satisfy CRAN’s no-network rule.
- Pin a release tag in Config/Needs/website for deterministic site builds.

Choosing a palette family per page
----------------------------------

- Families: red, lapis, ochre, teal, green, violet.
- In YAML, add: params: family: "red"
- In setup, call: theme_set(albersdown::theme_albers(params$family))
- If plot text feels small, increase `base_size` (e.g., 13–14):
  `theme_set(albersdown::theme_albers(params$family, base_size = 14))`
- Add body class so CSS tokens switch by family:
  cat(sprintf('<script>document.addEventListener("DOMContentLoaded",function(){document.body.classList.add("palette-%s");});</script>', params$family))


## Albers theme
This package uses the albersdown theme. Vignettes are styled with `vignettes/albers.css` and a local `vignettes/albers.js`; the palette family is provided via `params$family` (default 'red'). The pkgdown site uses `template: { package: albersdown }`.


## Albers theme
This package uses the albersdown theme. Vignettes are styled with `vignettes/albers.css` and a local `vignettes/albers.js`; the palette family is provided via `params$family` (default 'red'). The pkgdown site uses `template: { package: albersdown }`.


## Albers theme
This package uses the albersdown theme. Vignettes are styled with `vignettes/albers.css` and a local `vignettes/albers.js`; the palette family is provided via `params$family` (default 'red'). The pkgdown site uses `template: { package: albersdown }`.
