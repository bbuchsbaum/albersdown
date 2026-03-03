# Scales that use the family's tones (discrete/continuous)

Scales that use the family's tones (discrete/continuous)

## Usage

``` r
scale_color_albers(family = "red", discrete = TRUE, ...)

scale_fill_albers(family = "red", discrete = TRUE, ...)
```

## Arguments

- family:

  Palette family.

- discrete:

  Whether to use a discrete palette; if FALSE, uses a gradient.

- ...:

  Passed to underlying `ggplot2` scale.

## Value

A `ggplot2` scale object.

## Examples

``` r
# \donttest{
if (requireNamespace("ggplot2", quietly = TRUE)) {
  ggplot2::ggplot(iris, ggplot2::aes(Sepal.Length, Sepal.Width,
    color = Species)) + ggplot2::geom_point() + scale_color_albers()
}

# }
```
