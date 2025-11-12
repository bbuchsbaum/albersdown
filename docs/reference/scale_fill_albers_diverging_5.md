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

- labels:

  Optional labels for the five classes (low2, low1, mid, high1, high2)
