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
  preset = c("homage", "interaction", "study", "structural", "adobe", "midnight"),
  base_size = 13,
  base_family = NULL,
  bg = NULL,
  fg = NULL
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

## Value

A `ggplot2` theme object.
