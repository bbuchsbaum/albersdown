# Color values for named Albers presets

Each preset captures ground, surface, ink, and accent-role colours
inspired by different periods of Josef Albers' body of work.

## Usage

``` r
.preset_colors(preset = "homage")
```

## Arguments

- preset:

  One of `"homage"`, `"study"`, `"structural"`, `"adobe"`, `"midnight"`.

## Value

Named list with bg, fg, surface, muted, grid, border, code_bg.

## Details

- homage:

  Warm cream ground evoking the raw linen of *Homage to the Square*.

- study:

  Clean near-white, the analytical plates of *Interaction of Color*.

- structural:

  Stark cool grey, the precision of *Structural Constellations*.

- adobe:

  Warm sand, Albers' studies of Mexican adobe architecture.

- midnight:

  Deep indigo-black for dark-theme contexts.
