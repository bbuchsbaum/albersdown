# Distinct, colorblind-friendly fill palette across families

Uses one high-contrast tone (default A700) from different families to
maximize separation between filled regions. Fill counterpart of
[`scale_color_albers_distinct`](https://bbuchsbaum.github.io/albersdown/reference/scale_color_albers_distinct.md).

## Usage

``` r
scale_fill_albers_distinct(n = NULL, tone = c("A700", "A900", "A500"), ...)
```

## Arguments

- n:

  Number of colors needed; defaults to length of available families (6).

- tone:

  One of "A700", "A900", or "A500".

- ...:

  Passed to
  [`ggplot2::scale_fill_manual()`](https://ggplot2.tidyverse.org/reference/scale_manual.html).
