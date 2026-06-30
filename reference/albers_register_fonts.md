# Register the bundled Albers display fonts for R graphics

albersdown ships static TTF builds of Familjen Grotesk (the Homage
display face) and Space Grotesk (the Interaction display face) so that
ggplot2 plots can use the same typefaces as the rendered HTML pages.
Call this once per session – for example in a vignette setup chunk –
before
[`theme_albers()`](https://bbuchsbaum.github.io/albersdown/reference/theme_albers.md).
Once the fonts are registered,
[`theme_albers()`](https://bbuchsbaum.github.io/albersdown/reference/theme_albers.md)
picks the direction's display font automatically (Homage -\> Familjen
Grotesk, Interaction -\> Space Grotesk).

## Usage

``` r
albers_register_fonts()
```

## Value

Invisibly, a character vector of the font families that were registered
(empty if systemfonts is unavailable or the files are missing).

## Details

Requires the systemfonts package and a font-aware graphics device such
as ragg (e.g. `knitr::opts_chunk$set(dev = "ragg_png")`). Without those,
plots fall back to the system `"sans"` family, so package examples and
CRAN checks never depend on the bundled fonts.

## Examples

``` r
# Registers the bundled display fonts for the current session. Plot with a
# font-aware device (e.g. ragg); the default pdf/postscript device cannot
# render registered fonts. Wrapped in \dontrun because it mutates the
# session-wide font registry.
if (FALSE) { # \dontrun{
albers_register_fonts()
} # }
```
