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

  Visual preset: `"homage"` (warm cream), `"study"` (clean white),
  `"structural"` (stark), `"adobe"` (earth tones), `"midnight"` (dark).

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
