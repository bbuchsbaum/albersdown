# One-command migration to latest albersdown

Convenience helper for existing packages that already use albersdown and
need to replace older vignette/site wiring with the latest defaults
while choosing an Albers accent family and preset.

## Usage

``` r
migrate_albersdown(
  family = "red",
  preset = c("homage", "study", "structural", "adobe", "midnight"),
  dry_run = FALSE
)
```

## Arguments

- family:

  one of: "red","lapis","ochre","teal","green","violet"

- preset:

  Visual preset (default `"homage"`). See
  [`albers_presets()`](https://bbuchsbaum.github.io/albersdown/reference/albers_presets.md).

- dry_run:

  if TRUE, report changes without writing files.

## Value

`TRUE` invisibly.

## Examples

``` r
# \donttest{
if (interactive()) {
  migrate_albersdown(family = "teal", preset = "midnight", dry_run = TRUE)
}
# }
```
