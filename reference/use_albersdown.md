# One-shot setup for existing packages

Turn-key retrofit to adopt the albersdown theme in an existing package.
Copies local assets for CRAN-safe vignettes, ensures pkgdown template,
optionally patches all vignettes, writes a README note, and prints a
doctor report.

## Usage

``` r
use_albersdown(
  path,
  family = "red",
  preset = c("homage", "study", "structural", "adobe", "midnight"),
  apply_to = c("all", "new"),
  dry_run = FALSE,
  fallback_extra = c("auto", "always", "never"),
  force_replace = TRUE
)
```

## Arguments

- path:

  Path to the package directory. Must be supplied explicitly; there is
  no default so that the function never writes to an unexpected
  location.

- family:

  one of: "red","lapis","ochre","teal","green","violet"

- preset:

  Visual preset (default `"homage"`). See
  [`albers_presets()`](https://bbuchsbaum.github.io/albersdown/reference/albers_presets.md).

- apply_to:

  "all" to patch every *.Rmd/*.qmd in vignettes/, or "new" to only add
  the template and assets

- dry_run:

  if TRUE, show changes without writing

- fallback_extra:

  Controls writing site-wide fallbacks into `pkgdown/`:

  - "auto": write `pkgdown/extra.css` and `pkgdown/extra.js` whenever
    site-wide defaults are needed, including the standard
    `template: { package: albersdown }` setup where pkgdown template
    assets are copied but not linked automatically.

  - "always": always write to `pkgdown/` (useful as a safety net or for
    custom setups).

  - "never": never copy site-wide fallbacks.

- force_replace:

  if TRUE (default), overwrite existing albersdown assets and replace
  existing vignette CSS/header hooks so albersdown becomes the active
  theme.

## Value

`TRUE` invisibly.

## Examples

``` r
# \donttest{
if (interactive()) {
  use_albersdown(path = ".", dry_run = TRUE)
}
# }
```
