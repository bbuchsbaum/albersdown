# Configure current package to use albersdown (back-compat wrapper)

This wrapper preserves the old name and forwards to
[`use_albersdown()`](https://bbuchsbaum.github.io/albersdown/reference/use_albersdown.md).

## Usage

``` r
use_albers_vignettes(path = ".", ...)
```

## Arguments

- path:

  Path to the package directory. Defaults to the current working
  directory to preserve the original wrapper behavior.

- ...:

  Additional arguments passed to
  [`use_albersdown()`](https://bbuchsbaum.github.io/albersdown/reference/use_albersdown.md).

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
