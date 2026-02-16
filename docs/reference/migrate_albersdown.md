# One-command migration to latest albersdown

Convenience helper for existing packages that already use albersdown and
need to replace older vignette/site wiring with the latest defaults.

## Usage

``` r
migrate_albersdown(family = "red", dry_run = FALSE)
```

## Arguments

- family:

  one of: "red","lapis","ochre","teal","green","violet"

- dry_run:

  if TRUE, report changes without writing files.
