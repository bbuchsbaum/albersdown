# Scales that use the family's tones (discrete/continuous)

Discrete scales use
[`albers_discrete()`](https://bbuchsbaum.github.io/albersdown/reference/albers_discrete.md):
by default the family's tone is paired with its Albers complement and
ochre so adjacent groups stay distinguishable. Use `type = "family"` for
the single-hue ramp. Continuous scales run from a light tint to the
family's A900.

## Usage

``` r
scale_color_albers(
  family = getOption("albersdown.family", "red"),
  discrete = TRUE,
  type = c("contrast", "family"),
  ...
)

scale_fill_albers(
  family = getOption("albersdown.family", "red"),
  discrete = TRUE,
  type = c("contrast", "family"),
  ...
)
```

## Arguments

- family:

  Palette family. Defaults to the `albersdown.family` option (set by
  [`albers_vignette()`](https://bbuchsbaum.github.io/albersdown/reference/albers_vignette.md)
  while a vignette renders), else `"red"`.

- discrete:

  Whether to use a discrete palette; if FALSE, uses a gradient.

- type:

  Discrete colour set, `"contrast"` (default) or `"family"`; see
  [`albers_discrete()`](https://bbuchsbaum.github.io/albersdown/reference/albers_discrete.md).

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
