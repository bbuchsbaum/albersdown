## Release summary

This is a minor release (2.0.0 -> 2.1.0). In this version I have:

* Added the output format `albers_vignette()`, which themes a vignette with one
  line of YAML and embeds the stylesheet, script and fonts in the
  self-contained HTML, so the page makes no network requests.
* Added dark and phone-width versions of plots in vignettes, a print style,
  and reading and accessibility improvements to the pkgdown and vignette
  assets.
* Updated `use_albersdown()` to move packages onto the new format.
* Moved the design showcase and proof pages from vignettes to website-only
  articles, which reduces the installed size from 7.1 MB to 2.8 MB.
* Shipped NEWS.md.

## R CMD check results

0 errors | 0 warnings | 0 notes

## Test environments

* local macOS Sonoma 14.3 (aarch64-apple-darwin20), R 4.5.1:
  `R CMD check --as-cran --no-manual`, Status: OK.
* win-builder, R-devel: [TODO: result]
* win-builder, R-release: [TODO: result]
* GitHub Actions, ubuntu-latest (R-devel, R-release, R-oldrel-1): Status: OK.
* GitHub Actions, windows-latest (R-release): Status: OK.
* GitHub Actions, macos-latest (R-release): Status: OK.

## Package documentation

Online documentation is available at: https://bbuchsbaum.github.io/albersdown/

## Downstream dependencies

`tools::package_dependencies("albersdown", reverse = TRUE, which = "all")`
against CRAN on 2026-09-26 lists three reverse dependencies, all of which
suggest albersdown: bidser, genpca and neuroim2. I checked each (current CRAN
version) with albersdown 2.1.0 installed:

* bidser 0.5.0: Status OK.
* genpca 0.2.1: vignettes rebuilt and tests passed; 1 WARNING from the local
  compiler (Homebrew clang 20 reports an unknown warning group in R's
  `R_ext/Boolean.h`), which is unrelated to albersdown.
* neuroim2 0.13.0: Status OK.

(`R CMD check --no-manual` on local macOS, R 4.5.1.)
