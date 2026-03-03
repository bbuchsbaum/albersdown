# Configure current package to use albersdown (back-compat wrapper)

This wrapper preserves the old name and forwards to
[`use_albersdown()`](https://bbuchsbaum.github.io/albersdown/reference/use_albersdown.md).

## Usage

``` r
use_albers_vignettes()
```

## Value

`TRUE` invisibly.

## Examples

``` r
# \donttest{
if (interactive()) {
  use_albers_vignettes()
}
# }
```
