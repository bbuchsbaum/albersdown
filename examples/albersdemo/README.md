albersdemo
===============================

Minimal demo package that consumes the `albersdown` theme.

What it shows
-------------

- pkgdown site themed via `template: { package: albersdown }`.
- A vignette that includes local `albers.css` for offline/CRAN-friendly builds.
- ggplot2 setup with `theme_albers()`.

How to try it
-------------

1) Install the template package (from your tagged release):

   pak::pak("your-org/albersdown@v1.0.0")

2) Build the demo vignette locally (from the `examples/albersdemo` directory):

   rmarkdown::render("vignettes/getting-started.Rmd")

3) Build the pkgdown site (ensure pkgdown is installed):

   pkgdown::build_site()

The site should include copy-code buttons on code blocks, subtle anchors on H2/H3, and the clean Albers layout.

