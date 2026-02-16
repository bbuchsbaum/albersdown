# One-shot setup for existing packages

Turn-key retrofit to adopt the albersdown theme in an existing package.
Copies local assets for CRAN-safe vignettes, ensures pkgdown template,
optionally patches all vignettes, writes a README note, and prints a
doctor report.

## Usage

``` r
use_albersdown(
  family = "red",
  preset = c("homage", "study", "structural", "adobe", "midnight"),
  apply_to = c("all", "new"),
  dry_run = FALSE,
  fallback_extra = c("auto", "always", "never"),
  force_replace = TRUE
)
```

## Arguments

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

  Controls copying site-wide fallbacks into `pkgdown/`:

  - "auto": copy `pkgdown/extra.css` and `pkgdown/extra.js` only when
    the consuming package does not use
    `template: { package: albersdown }` in `_pkgdown.yml`.

  - "always": always copy to `pkgdown/` (useful as a safety net or for
    custom setups).

  - "never": never copy site-wide fallbacks.

- force_replace:

  if TRUE (default), overwrite existing albersdown assets and replace
  existing vignette CSS/header hooks so albersdown becomes the active
  theme.
