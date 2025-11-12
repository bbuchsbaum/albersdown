# Convenience scale: highlight vs other (color)

Returns a manual color scale mapping a single highlighted group to a
family tone (default A700) and all other points to a neutral gray.

## Usage

``` r
scale_color_albers_highlight(
  family = "red",
  tone = c("A700", "A900", "A500", "A300"),
  other = "#9aa0a6",
  highlight = "highlight",
  other_name = "other",
  ...
)
```

## Arguments

- family:

  Palette family name.

- tone:

  One of A900, A700, A500, A300 used for the highlight color.

- other:

  Hex color used for non-highlight values.

- highlight:

  Name of the value that should receive the highlight color.

- other_name:

  Name of the value that should receive the neutral color.

- ...:

  Passed to
  [`ggplot2::scale_color_manual()`](https://ggplot2.tidyverse.org/reference/scale_manual.html).
