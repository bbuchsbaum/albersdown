# Diverging fill scale (continuous)

Diverging fill scale (continuous)

## Usage

``` r
scale_fill_albers_diverging(
  low_family = "red",
  high_family = albers_complement(low_family),
  midpoint = 0,
  neutral = "#e5e7eb",
  ...
)
```

## Arguments

- low_family, high_family:

  Homage families for the two sides

- midpoint:

  numeric midpoint for the diverging scale (default 0)

- neutral:

  hex color for the midpoint (default matches CSS border)

- ...:

  passed to ggplot2::scale_color_gradient2()
