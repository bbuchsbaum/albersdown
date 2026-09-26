# albersdown 2.1.0: outstanding design issues, then release

Decisions (2026-09-26):
- The version is 2.1.0, reaching `main` by PR from `redesign/hill-climb`.
- The CRAN submission comes after the five design issues below.

## Phase A: design issues (hill-climb round v25, with critics)

Each item is verified by a harness check that is first shown to fail on v24.

1. **One phone indent model** (the critics' top item for four rounds).
   Rule, at 620 px and narrower:
   - author lines keep their indentation at full width;
   - a wrapped continuation hangs at the line's indent + 2ch;
   - if the author aligned the next line under an open bracket, and at least 20 columns remain beside it, continuations take that column, so siblings share one column;
   - a child is never left of its parent;
   - a wrapped `name = value` continues 2ch right of the name.

   Gate: a sibling-column and child-not-left-of-parent check at 320, 360 and 390.
2. **Print identity.**
   - The first printed page carries the title plate and the four-segment bar.
   - The code ground is tinted by the family, and the syntax keeps the family's colours.

   Gate: printcheck asserts the plate and the bar on page 1 of the vignette and site PDFs.
3. **Figure text on phones.** Axis text renders at about 5 px at 390. Measure the options (a smaller default `fig.width` on narrow screens via `srcset`, a larger `theme_albers()` base size in the format, or both) and pick by rendered text height ≥ 9 px at 390 without hurting desktop.

   Gate: rendered axis-label height at 390.
4. **Site title and pkgdown card edges.**
   - The site title is no more than 2 lines at 1720 and 768.
   - Prose, code, `hr` and callouts in the article card end at one or two deliberate right edges, not three.
   - The wide table uses the card's margin instead of scrolling a few px.

   Gate: an edges probe on site pages.
5. **Echo-free output + message block.** Output followed by a message in a chunk with `echo = FALSE` gets the same banding, spacing and message hang as the echo-on case.

   Gate: a fixture plus a band/hang check.

Also fold in whatever the v24 critics confirm.

## Phase B: release 2.1.0

1. `DESCRIPTION` Version: 2.1.0. Update the version-specific text in README, getting-started and `R/albers_vignette.R`. Measure the README page-weight figures and state them.
2. NEWS: the heading becomes `# albersdown 2.1.0`. Ship NEWS.md (remove it from `.Rbuildignore`), as CRAN packages conventionally do.
3. Rewrite `cran-comments.md` for 2.1.0. Justify or trim the installed size (5.7 MB; `doc` is 3.9 MB), for example by making the proof and theme-lab vignettes pkgdown-only.
4. Evidence beyond this Mac: GitHub Actions R-CMD-check (Linux/Windows/macOS), win-builder devel and release, a reverse-dependency check, and a pkgdown deploy of the branch.
5. Open a PR from `redesign/hill-climb` to `main`. Merge after hosted CI passes, then tag. Adopters' `albersdown (>= 2.0.0.9000)` pin resolves from `main`.
6. Submit to CRAN (the user submits, or approves the submission).
