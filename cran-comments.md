## R CMD check results

0 errors | 0 warnings | 2 notes

The two local notes are environment-related:

* `unable to verify current time` from the local `--as-cran` check.
* HTML validation skipped because the local `tidy` binary is not recent enough.

## Resubmission

This is a patch release after 1.0.0. In this version I have:

* Fixed CRAN vignette rendering by ensuring `albers.css` and
  `albers-header.html` are configured inside
  `output: rmarkdown::html_vignette`, where `rmarkdown` actually honors them.
* Updated `use_albersdown()` and `migrate_albersdown()` to migrate legacy
  top-level vignette `css`/`includes` hooks to the CRAN-safe form.
* Restored `use_albers_vignettes()` as a current-directory wrapper around
  `use_albersdown()`.
* Added regression tests that render a legacy CRAN-shaped vignette and verify
  that the Albers CSS and JavaScript hooks are embedded in the HTML.

## Test environments

* local macOS (aarch64-apple-darwin), R 4.5.x
* GitHub Actions: ubuntu-latest (release), macOS-latest (release),
  windows-latest (release)

## Package documentation

Online documentation is available at: https://bbuchsbaum.github.io/albersdown/

## Downstream dependencies

There are no known reverse dependency breakages from this vignette/setup patch.
