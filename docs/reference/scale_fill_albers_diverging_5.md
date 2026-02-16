# 5-class diverging (discrete)

Useful for binned choropleths or sliced residuals. The middle class uses
the neutral color.

## Usage

``` r
scale_fill_albers_diverging_5(
  low_family = "red",
  high_family = albers_complement(low_family),
  neutral = "#e5e7eb",
  labels = ggplot2::waiver(),
  ...
)

scale_color_albers_diverging_5(
  low_family = "red",
  high_family = albers_complement(low_family),
  neutral = "#e5e7eb",
  labels = ggplot2::waiver(),
  ...
)
```

## Arguments

- low_family, high_family:

  Homage families for the two sides

- neutral:

  hex color for the midpoint (default matches CSS border)

- labels:

  Optional labels for the five classes (low2, low1, mid, high1, high2)

- ...:

  Passed to
  [`ggplot2::scale_fill_manual()`](https://ggplot2.tidyverse.org/reference/scale_manual.html)
  or
  [`ggplot2::scale_color_manual()`](https://ggplot2.tidyverse.org/reference/scale_manual.html).
