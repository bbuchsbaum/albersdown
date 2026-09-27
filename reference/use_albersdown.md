# One-shot setup for existing packages

Adopt the albersdown theme in an existing package.

## Usage

``` r
use_albersdown(
  path,
  family = "red",
  preset = c("homage", "interaction", "study", "structural", "adobe", "midnight"),
  apply_to = c("all", "new"),
  dry_run = FALSE,
  fallback_extra = c("auto", "always", "never"),
  force_replace = TRUE,
  method = c("format", "vendor"),
  readme = FALSE
)
```

## Arguments

- path:

  Path to the package directory. Must be supplied explicitly; there is
  no default so that the function never writes to an unexpected
  location.

- family:

  One of `"red"`, `"lapis"`, `"ochre"`, `"teal"`, `"green"`, `"violet"`
  (case-insensitive). If not given, the family the package already uses
  is kept: from its vignettes (a `family:` stated in their
  [`albers_vignette()`](https://bbuchsbaum.github.io/albersdown/reference/albers_vignette.md)
  entries, or albersdown 2.0's `params`; the most common if they
  differ), else from site defaults in `pkgdown/extra.js` or
  `_pkgdown.yml`, else `"red"`. With `apply_to = "new"` the site
  defaults come first. A message says which was kept and where it came
  from.

- preset:

  Direction, `"homage"` or `"interaction"` (legacy presets are accepted;
  case-insensitive). If not given, inferred like `family`, else
  `"homage"`. See
  [`albers_presets()`](https://bbuchsbaum.github.io/albersdown/reference/albers_presets.md).

- apply_to:

  `"all"` to convert the vignettes as well (every `*.Rmd` in
  `vignettes/`; with `method = "vendor"` also `*.qmd`), or `"new"` to
  set up only `_pkgdown.yml`, the site defaults and `DESCRIPTION`
  (vignette dependencies only if a vignette is already on the format).

- dry_run:

  if TRUE, report the changes (including `.Rbuildignore` and
  `.gitignore` entries) without writing anything.

- fallback_extra:

  `method = "vendor"` only. Controls writing site-wide fallbacks into
  `pkgdown/`:

  - "auto": write `pkgdown/extra.css` and `pkgdown/extra.js` whenever
    site-wide defaults are needed.

  - "always": always write to `pkgdown/` (useful as a safety net or for
    custom setups).

  - "never": never copy site-wide fallbacks.

  With `method = "format"`, only the site default family is written, to
  `pkgdown/extra.js`, and only when it is not red/homage (or was set
  before).

- force_replace:

  `method = "vendor"` only. If TRUE (default), overwrite existing
  albersdown assets and replace existing vignette CSS/header hooks so
  albersdown becomes the active theme.

- method:

  `"format"` (default) or `"vendor"`; see Details.

- readme:

  If `TRUE`, add a short note about the theme to `README.Rmd` (re-knit
  it afterwards) or, when there is none, `README.md` (default `FALSE`),
  describing the setup `method` makes.

## Value

`TRUE` invisibly.

## Details

With `method = "format"` (the default) each `vignettes/*.Rmd` whose
first output format is `html_vignette` is switched to
[`albers_vignette()`](https://bbuchsbaum.github.io/albersdown/reference/albers_vignette.md),
and `_pkgdown.yml` is pointed at the albersdown template (it is created,
and added to `.Rbuildignore` with `docs/`, if missing). `DESCRIPTION`
gains `bbuchsbaum/albersdown` in `Config/Needs/website`. When at least
one vignette is on the format, it also gains
`albersdown (>= <installed version>)` in `Suggests` (or that bound where
albersdown is already in `Imports`/`Depends`), `knitr` and `rmarkdown`,
and `VignetteBuilder: knitr`; and, when the installed albersdown is a
development version (not on CRAN), `Remotes: bbuchsbaum/albersdown`, so
that R CMD check and CI install the version with
[`albers_vignette()`](https://bbuchsbaum.github.io/albersdown/reference/albers_vignette.md)
(`R CMD check --as-cran` notes that field). Otherwise (no vignettes,
none convertible, or `apply_to = "new"` with none already on the format)
the adoption is site-only and no field that R CMD check reads is
changed. Nothing is copied into `vignettes/`. Edits are textual (other
output formats, comments, key order and line endings are kept) and each
changed file is backed up to `.albersdown.bak/`, which is added to
`.Rbuildignore` and `.gitignore`.

A package set up by albersdown 2.0 (the vendor setup) is migrated: the
setup-chunk lines and `params` (`family`, `preset`) that 2.0 added are
removed, as are its generated `pkgdown/extra.css` (an `@import` of the
theme) and `pkgdown/extra.js`, and its README note is rewritten. The
copied `albers.css`, `albers.js`, `albers-header.html` and fonts in
`vignettes/` are moved to `.albersdown.bak/` once no remaining vignette
uses them.

Quarto vignettes, flow-style `output: {...}` headers and pkgdown-only
articles in `vignettes/articles/` are listed but not changed: articles
take the site default family unless you set
`output: albersdown::albers_vignette` in their YAML by hand.

With `method = "vendor"` the stylesheet, script and fonts are copied
into `vignettes/` and each vignette keeps
[`rmarkdown::html_vignette`](https://pkgs.rstudio.com/rmarkdown/reference/html_vignette.html)
with the theme's css and header include (the albersdown 2.0 setup).

## Examples

``` r
# \donttest{
if (interactive()) {
  use_albersdown(path = ".", dry_run = TRUE)
}
# }
```
