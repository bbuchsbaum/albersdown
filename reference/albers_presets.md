# List available Albers directions

Returns the two 2.0 directions: `"homage"` (warm cream ground, serif
body, light code) and `"interaction"` (cool grey ground, grotesk, dark
code). The legacy presets `"study"`, `"structural"`, `"adobe"`, and
`"midnight"` are still accepted by
[`theme_albers()`](https://bbuchsbaum.github.io/albersdown/reference/theme_albers.md)
for backward compatibility but are no longer featured.

## Usage

``` r
albers_presets()
```

## Value

Character vector of direction names.

## Examples

``` r
albers_presets()
#> [1] "homage"      "interaction"
```
