# Minimal, legible plot theme inspired by Josef Albers

Minimal, legible plot theme inspired by Josef Albers

## Usage

``` r
theme_albers(
  family = "red",
  preset = c("homage", "interaction", "study", "structural", "adobe", "midnight"),
  base_size = 13,
  base_family = NULL,
  bg = NULL,
  fg = NULL,
  grid_color = NULL
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
