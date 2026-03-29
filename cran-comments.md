## R CMD check results

0 errors | 0 warnings | 0 notes

## Resubmission

This is a resubmission. In this version I have:

* Added a reference to the Description field in DESCRIPTION:
  Albers (1963, ISBN:978-0-300-17935-4) "Interaction of Color"

* `use_albersdown()` and `migrate_albersdown()` now require an explicit
  `path` argument so that they never write to an unexpected location.
  The working directory is restored via `on.exit()`.

* Vignettes (`getting-started.Rmd`, `design-notes.Rmd`) now save and
  restore `options()` and the ggplot2 theme via cleanup chunks.

## Test environments

* local macOS (aarch64-apple-darwin), R 4.5.x
* GitHub Actions: ubuntu-latest (release), macOS-latest (release),
  windows-latest (release)

## Package documentation

Online documentation is available at: https://bbuchsbaum.github.io/albersdown/

## Downstream dependencies

This is a new submission; there are no reverse dependencies.
