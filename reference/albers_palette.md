# Return four-tone Homage family by name

Return four-tone Homage family by name

## Usage

``` r
albers_palette(family = c("red", "lapis", "ochre", "teal", "green", "violet"))
```

## Arguments

- family:

  One of "red", "lapis", "ochre", "teal".

## Value

Named character vector of four hex colors (A900, A700, A500, A300).

## Examples

``` r
albers_palette("red")
#>      A900      A700      A500      A300 
#> "#760906" "#AE1703" "#D74A21" "#F7A885" 
albers_palette("lapis")
#>      A900      A700      A500      A300 
#> "#213480" "#3154B9" "#507ADF" "#A2BEF5" 
```
