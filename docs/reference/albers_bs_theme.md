# bs_theme for pkgdown (light/dark aware)

Convenience wrapper exposing core variables; most consumers won't need
this directly if they use `template: { package: albersdown }`.

## Usage

``` r
albers_bs_theme(
  family = "red",
  preset = c("homage", "study", "structural", "adobe", "midnight"),
  accent = NULL,
  bg = NULL,
  fg = NULL
)
```

## Arguments

- family:

  Palette family name (default `"red"`).

- preset:

  Visual preset (default `"homage"`). See
  [`albers_presets()`](https://bbuchsbaum.github.io/albersdown/reference/albers_presets.md).

- accent:

  Primary accent color (default A700 of the chosen family).

- bg:

  Background color (default derived from preset).

- fg:

  Foreground/text color (default derived from preset).
