# One-command migration to latest albersdown

Convenience helper for existing packages that already use the vendored
albersdown setup (copied `albers.css`/`albers.js` in `vignettes/`) and
need to refresh it with the latest assets while choosing an Albers
accent family and preset. To move to the output format instead, use
`use_albersdown(path, method = "format")`.

## Usage

``` r
migrate_albersdown(
  path,
  family = "red",
  preset = c("homage", "interaction", "study", "structural", "adobe", "midnight"),
  dry_run = FALSE
)
```

## Arguments

- path:

  Path to the package directory. Must be supplied explicitly; there is
  no default so that the function never writes to an unexpected
  location.

- family, preset:

  As in
  [`use_albersdown()`](https://bbuchsbaum.github.io/albersdown/reference/use_albersdown.md):
  if not given, the package's current family and direction are kept.

- dry_run:

  if TRUE, report changes without writing files.

## Value

`TRUE` invisibly.

## Examples

``` r
# \donttest{
if (interactive()) {
  migrate_albersdown(path = ".", family = "teal", preset = "midnight", dry_run = TRUE)
}
# }
```
