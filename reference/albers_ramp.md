# Interpolate n colors along a palette family gradient

Uses [`colorRampPalette`](https://rdrr.io/r/grDevices/colorRamp.html) to
interpolate between the four tones of a family (A900 → A300), producing
an arbitrary number of evenly spaced colors.

## Usage

``` r
albers_ramp(family = "red", n = 9, reverse = FALSE)
```

## Arguments

- family:

  Palette family name.

- n:

  Number of colors to return.

- reverse:

  If `TRUE`, return colors from light to dark.

## Value

Character vector of `n` hex colors.

## Examples

``` r
albers_ramp("lapis", n = 5)
#> [1] "#213480" "#2D4CAA" "#4067CC" "#648BE4" "#A2BEF5"
```
