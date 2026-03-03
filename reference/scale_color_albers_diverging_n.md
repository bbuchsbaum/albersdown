# Diverging color scale with multiple stops (continuous)

Uses a 5-stop palette (low2, low1, neutral, high1, high2) for smoother
transitions around the midpoint.

## Usage

``` r
scale_color_albers_diverging_n(
  low_family = "red",
  high_family = albers_complement(low_family),
  neutral = "#e5e7eb",
  ...
)
```

## Arguments

- low_family, high_family:

  Homage families for the two sides

- neutral:

  hex color for the midpoint (default matches CSS border)

- ...:

  passed to ggplot2::scale_color_gradient2()

## Value

A `ggplot2` scale object.
