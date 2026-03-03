# Image-derived sequential color scale

Image-derived sequential color scale

## Usage

``` r
scale_color_albers_img(family = "red", discrete = TRUE, ...)

scale_fill_albers_img(family = "red", discrete = TRUE, ...)
```

## Arguments

- family:

  One of "red","lapis","ochre","teal","green"

- discrete:

  Whether to use discrete palette; if FALSE uses a gradient.

- ...:

  Passed to underlying ggplot2 scale.

## Value

A `ggplot2` scale object.
