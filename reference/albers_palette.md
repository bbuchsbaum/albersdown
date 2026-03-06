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
#> "#C22B23" "#DC3925" "#E44926" "#E35B2D" 
albers_palette("lapis")
#>      A900      A700      A500      A300 
#> "#1B2A74" "#20399C" "#2C4FCC" "#4968D6" 
```
