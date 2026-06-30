# Quiet, legible gt style with subtle stripe from A300

Quiet, legible gt style with subtle stripe from A300

## Usage

``` r
gt_albers(
  x,
  family = "red",
  preset = c("homage", "interaction", "study", "structural", "adobe", "midnight"),
  base_size = 14,
  width = 720,
  bg = NULL,
  fg = NULL
)
```

## Arguments

- x:

  A `gt` table

- family:

  Palette family for subtle accents

- preset:

  Visual preset (default `"homage"`). See
  [`albers_presets()`](https://bbuchsbaum.github.io/albersdown/reference/albers_presets.md).

- base_size:

  Base font size in pixels (default 14).

- width:

  Table width in pixels (default 720). Use `NULL` for auto.

- bg:

  Override background color (default derived from preset).

- fg:

  Override text color (default derived from preset).

## Value

A styled `gt` table object.

## Examples

``` r
# \donttest{
if (requireNamespace("gt", quietly = TRUE)) {
  tbl <- gt::gt(head(mtcars))
  gt_albers(tbl)
}


  

mpg
```
