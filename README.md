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
theme_set(albersdown::theme_albers())

Helpers
-------

- theme_albers(family = "red")
- scale_color_albers(family = "red", discrete = TRUE, ...)
- scale_fill_albers(family = "red", discrete = TRUE, ...)
- gt_albers(x, family = "red")

Notes
-----

- Keep vignette CSS local to satisfy CRAN’s no-network rule.
- Pin a release tag in Config/Needs/website for deterministic site builds.

