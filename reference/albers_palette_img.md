# Image-derived Homage palettes (A900 -\> A300)

Four-tone families distilled from the uploaded grid; order is darkest to
lightest (A900, A700, A500, A300).

## Usage

``` r
albers_palette_img(family = c("red", "lapis", "ochre", "teal", "green"))
```

## Arguments

- family:

  One of "red","lapis","ochre","teal","green"

## Value

Named character vector of four hex colors (A900, A700, A500, A300).

## Examples

``` r
albers_palette_img("red")
#>      A900      A700      A500      A300 
#> "#52140A" "#9D2E46" "#A52B22" "#C53926" 
```
