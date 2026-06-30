# Color values for named Albers presets

Each preset captures ground, surface, ink, and accent-role colours
inspired by Bauhaus, Le Corbusier, and Josef Albers.

## Usage

``` r
.preset_colors(preset = "homage")
```

## Arguments

- preset:

  One of the two 2.0 directions `"homage"` (warm cream, serif body) or
  `"interaction"` (cool grey, grotesk), or a legacy preset (`"study"`,
  `"structural"`, `"adobe"`, `"midnight"`) retained for backward
  compatibility.

## Value

Named list with bg, fg, surface, muted, grid, border, code_bg.

## Details

- homage:

  Cool gallery white, the Bauhaus exhibition wall.

- study:

  Pure analytical white from *Interaction of Color* plates.

- structural:

  Cool concrete (béton brut), shadowless precision.

- adobe:

  Warm architectural grey, Le Corbusier béton.

- midnight:

  Deep indigo-black for dark-theme contexts.
