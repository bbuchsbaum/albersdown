# Stripped theme for maps, brain surfaces, and abstract compositions

Extends
[`theme_albers`](https://bbuchsbaum.github.io/albersdown/reference/theme_albers.md)
by removing axes, grid lines, ticks, and panel border – leaving only the
plot background, titles, and legend. Useful for spatial visualizations
where coordinate axes are meaningless.

## Usage

``` r
theme_albers_void(
  family = "red",
  preset = c("homage", "study", "structural", "adobe", "midnight"),
  base_size = 13,
  base_family = "sans",
  bg = NULL,
  fg = NULL
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

## Value

A `ggplot2` theme object.
