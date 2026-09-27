# Minimal, legible plot theme inspired by Josef Albers

Minimal, legible plot theme inspired by Josef Albers

## Usage

``` r
theme_albers(
  family = getOption("albersdown.family", "red"),
  preset = getOption("albersdown.preset", c("homage", "interaction", "study",
    "structural", "adobe", "midnight")),
  base_size = 13,
  base_family = NULL,
  bg = NULL,
  fg = NULL,
  grid_color = NULL,
  mode = c("light", "dark")
)
```

## Arguments

- family:

  Palette family used by companion scales.

- preset:

  Visual direction: `"homage"` (warm cream ground) or `"interaction"`
  (cool grey ground). Legacy presets `"study"`, `"structural"`,
  `"adobe"`, and `"midnight"` are still accepted for backward
  compatibility.

- base_size:

  Base font size.

- base_family:

  Base font family. Plots fall back to the system "sans" stack; install
  the matching typefaces (Familjen Grotesk / Space Grotesk, etc.) and
  pass e.g. `base_family = "Familjen Grotesk"` for full fidelity.

- bg:

  Override background color. Defaults to the preset's surface (the
  vignette sheet), so figures sit on the page rather than in a box.

- fg:

  Override foreground/text color (default derived from preset).

- grid_color:

  Override grid line color (default derived from preset).

- mode:

  `"light"` (default) or `"dark"`: the direction's night ground and ink,
  matching the page's dark mode.
  [`albers_vignette()`](https://bbuchsbaum.github.io/albersdown/reference/albers_vignette.md)
  uses it to render a dark twin of each plot.

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
