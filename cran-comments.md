## R CMD check results

0 errors | 0 warnings | 1 note

The remaining note is from CRAN incoming feasibility:

* Source tarball size: 5,688,876 bytes.

The package bundles web fonts and rendered vignettes so the supplied pkgdown and
R Markdown templates render consistently offline and on CRAN.

## Release summary

This is a major release after 1.0.0. In this version I have:

* Added the new `interaction` visual direction alongside `homage`.
* Updated the pkgdown and R Markdown assets for the 2.0 visual system.
* Bundled the required web fonts under their upstream open font licenses.
* Updated `use_albersdown()` and `migrate_albersdown()` so setup and migration
  helpers accept the current `interaction` direction and remove stale
  `preset-interaction` classes before applying page-specific classes.
* Added regression tests for setup and migration of the `interaction` direction.

## Test environments

* local macOS Sonoma 14.3 (aarch64-apple-darwin20), R 4.5.1
  `R CMD check --as-cran --no-manual`

## Package documentation

Online documentation is available at: https://bbuchsbaum.github.io/albersdown/

## Downstream dependencies

There are no CRAN reverse dependencies for `albersdown` according to
`available.packages(repos = "https://cloud.r-project.org")` on 2026-07-04.
