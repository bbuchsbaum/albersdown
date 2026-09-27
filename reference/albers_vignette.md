# Albers vignette output format

A drop-in replacement for
[`rmarkdown::html_vignette()`](https://pkgs.rstudio.com/rmarkdown/reference/html_vignette.html)
that applies the albersdown theme with no files to copy into
`vignettes/`. The stylesheet, the fonts for the chosen direction, and
the page script are taken from the installed package and embedded in the
self-contained HTML, so the result is CRAN-safe (no network requests).

## Usage

``` r
albers_vignette(
  family = "red",
  preset = "homage",
  style = c("minimal", "balanced", "assertive"),
  toc = TRUE,
  toc_depth = 3,
  fig_width = 6.6,
  fig_height = 4.1,
  plot_theme = TRUE,
  dark_figures = TRUE,
  phone_figures = TRUE,
  math_method = "mathml",
  fonts = c("direction", "both"),
  css = NULL,
  includes = NULL,
  ...
)
```

## Arguments

- family:

  Accent family: one of `"red"`, `"lapis"`, `"ochre"`, `"teal"`,
  `"green"`, `"violet"`. While the vignette renders, the
  `albersdown.family` and `albersdown.preset` options are set, so
  [`scale_color_albers()`](https://bbuchsbaum.github.io/albersdown/reference/scale_color_albers.md),
  [`scale_fill_albers()`](https://bbuchsbaum.github.io/albersdown/reference/scale_color_albers.md)
  and
  [`theme_albers()`](https://bbuchsbaum.github.io/albersdown/reference/theme_albers.md)
  follow it without repeating the family.

- preset:

  Direction: `"homage"` (warm, serif body) or `"interaction"` (cool,
  grotesk, dark code). Legacy presets are accepted.

- style:

  Weight of the structural marks: `"minimal"` (default), `"balanced"` or
  `"assertive"`.

- toc, toc_depth:

  Table of contents, passed to
  [`rmarkdown::html_vignette()`](https://pkgs.rstudio.com/rmarkdown/reference/html_vignette.html).

- fig_width, fig_height:

  Default figure size in inches.

- plot_theme:

  If `TRUE`, set
  [`theme_albers()`](https://bbuchsbaum.github.io/albersdown/reference/theme_albers.md)
  (matching `family` and `preset`) as the ggplot2 theme while the
  vignette renders.

- dark_figures:

  If `TRUE` (and `plot_theme` is on), each auto-printed ggplot is also
  rendered with `theme_albers(mode = "dark")`; the page shows that
  version in dark mode instead of a light plot on a dark page. This adds
  one image per plot to the HTML. Plots in chunks with
  `fig.show = "hold"`, `"animate"` or `"hide"` get no dark version and
  stay light in dark mode.

- phone_figures:

  If `TRUE`, each plot (ggplot2, grid or base graphics) is also drawn at
  phone width (3.6 in, the same aspect ratio), so its text is legible in
  a phone's column; the page shows that drawing while the figure is
  displayed narrower than about 470 CSS px, in light and dark mode alike
  (the dark version is drawn when `dark_figures` is on). Printing and
  the enlarged view use the full figure. Figures narrower than 4.5 in,
  figures whose `out.width` is not a percentage, animations and non-PNG
  devices are left as they are.

- math_method:

  How equations are rendered. The default `"mathml"` has pandoc write
  native MathML, which browsers display without any download, so
  vignettes with math stay offline. Use `"mathjax"` (fetched from a CDN
  when the page is read) for heavier TeX.

- fonts:

  Which bundled typefaces to embed: `"direction"` (default) embeds only
  the chosen direction's faces; `"both"` embeds homage's and
  interaction's, for a page that previews both (about 130 KB more).

- css:

  Additional stylesheets, applied after the theme.

- includes:

  Additional
  [`rmarkdown::includes()`](https://pkgs.rstudio.com/rmarkdown/reference/includes.html);
  combined with the theme's own head and body includes.

- ...:

  Further arguments passed to
  [`rmarkdown::html_vignette()`](https://pkgs.rstudio.com/rmarkdown/reference/html_vignette.html).

## Value

An R Markdown output format.

## Details

Use it in a vignette's YAML header:

    output:
      albersdown::albers_vignette:
        family: teal
        preset: interaction

The format sets the page's family and direction before any content is
drawn (no restyle on load), sets knitr defaults suited to the theme
(`collapse = TRUE`, `comment = "#>"`, retina figures at full column
width, the `ragg` device when available), and, when `plot_theme = TRUE`
and ggplot2 is installed, sets
[`theme_albers()`](https://bbuchsbaum.github.io/albersdown/reference/theme_albers.md)
as the ggplot2 theme for the duration of the render.

`albers_vignette()` is new in albersdown 2.1.0. A package whose
vignettes use it should declare `albersdown (>= 2.1.0)` in `Suggests`
(as
[`use_albersdown()`](https://bbuchsbaum.github.io/albersdown/reference/use_albersdown.md)
writes). If building a vignette fails with
`'albers_vignette' is not an exported object from 'namespace:albersdown'`,
the albersdown installed is 2.0.0 or older: update it.

## Examples

``` r
if (FALSE) { # \dontrun{
rmarkdown::render("my-vignette.Rmd",
  output_format = albersdown::albers_vignette(family = "teal"))
} # }
```
