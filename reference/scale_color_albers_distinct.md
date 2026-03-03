# Distinct, colorblind-friendly line palette across families

Uses one high-contrast tone (default A700) from different families to
maximize separation between lines. This departs from the single-family
aesthetic but improves readability for multi-series lines.

## Usage

``` r
scale_color_albers_distinct(n = NULL, tone = c("A700", "A900", "A500"), ...)
```

## Arguments

- n:

  Number of colors needed; defaults to length of available families (6).

- tone:

  One of "A700", "A900", or "A500".

- ...:

  Passed to
  [`ggplot2::scale_color_manual()`](https://ggplot2.tidyverse.org/reference/scale_manual.html).

## Value

A `ggplot2` scale object.

## Examples

``` r
# \donttest{
if (requireNamespace("ggplot2", quietly = TRUE)) {
  df <- data.frame(x = 1:6, y = 1:6, g = paste0("G", 1:6))
  ggplot2::ggplot(df, ggplot2::aes(x, y, color = g)) +
    ggplot2::geom_point() + scale_color_albers_distinct()
}

# }
```
