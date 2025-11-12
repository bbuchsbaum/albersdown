# Image-derived diverging color scale (gradientn)

Image-derived diverging color scale (gradientn)

## Usage

``` r
scale_color_albers_img_diverging(
  low_family,
  high_family,
  neutral = "#E4E0D9",
  ...
)
```

## Arguments

- low_family:

  Family for the low side (left)

- high_family:

  Family for the high side (right)

- neutral:

  Hex color for the midpoint (default derived from image)

- ...:

  Passed to ggplot2::scale_color_gradientn
