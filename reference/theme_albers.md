# Minimal, legible plot theme inspired by Josef Albers

Minimal, legible plot theme inspired by Josef Albers

## Usage

``` r
theme_albers(
  family = "red",
  preset = c("homage", "study", "structural", "adobe", "midnight"),
  base_size = 13,
  base_family = "sans",
  bg = NULL,
  fg = NULL,
  grid_color = NULL
)
```

## Arguments

- family:

  Palette family used by companion scales.

- preset:

  Visual preset: `"homage"` (gallery white), `"study"` (analytical
  white), `"structural"` (concrete), `"adobe"` (warm architectural
  grey), `"midnight"` (dark).

- base_size:

  Base font size.

- base_family:

  Base font family.

- bg:

  Override background color (default derived from preset).

- fg:

  Override foreground/text color (default derived from preset).

- grid_color:

  Override grid line color (default derived from preset).

## Value

A `ggplot2` theme object.

## Examples

``` r
# \donttest{
if (requireNamespace("ggplot2", quietly = TRUE)) {
  ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) +
    ggplot2::geom_point() + theme_albers()
}

# }
```
