# Discrete colours for a family

The `"contrast"` set leads with the family's own tone and its
interaction complement – the two colours of the title plate (red and
gold for the red family) – then the complementary family (blue), the
family at another lightness, the complementary family at another
lightness, and a warm neutral. With `mode = "dark"` each slot keeps its
hue (only its lightness changes), so a category keeps its colour when
the page switches theme. Adjacent levels differ in hue, so a two-group
comparison is always legible. The `"family"` set is the single-hue
A900-A300 ramp.

## Usage

``` r
albers_discrete(
  family = getOption("albersdown.family", "red"),
  type = c("contrast", "family"),
  mode = c("light", "dark")
)
```

## Arguments

- family:

  Palette family.

- type:

  `"contrast"` (default) or `"family"`.

- mode:

  `"light"` (default) or `"dark"`: lighter tones that hold up on the
  night ground (used for the dark twins of figures).

## Value

Character vector of hex colours.

## Examples

``` r
albers_discrete("red")
#> [1] "#AE1703" "#B97E00" "#3154B9" "#760906" "#507ADF" "#8C8474"
albers_discrete("teal", type = "family")
#> [1] "#044746" "#0A6C69" "#2E918C" "#8DCCC5"
```
