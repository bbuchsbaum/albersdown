# Visual swatch of Albers palette families and presets

Draws a tile plot showing the four tones of each palette family,
optionally faceted by preset ground colors. Useful for quickly
previewing the design system in a notebook or presentation.

## Usage

``` r
albers_swatch(
  families = c("red", "lapis", "ochre", "teal", "green", "violet"),
  show_presets = FALSE
)
```

## Arguments

- families:

  Character vector of families to show. Defaults to all six.

- show_presets:

  If `TRUE`, add a row of preset ground colors below the palette tones.
  Defaults to `FALSE`.

## Value

A `ggplot` object.

## Examples

``` r
# \donttest{
if (requireNamespace("ggplot2", quietly = TRUE)) {
  albers_swatch()
}

# }
```
