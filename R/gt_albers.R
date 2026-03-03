#' Quiet, legible gt style with subtle stripe from A300
#'
#' @param x A `gt` table
#' @param family Palette family for subtle accents
#' @param preset Visual preset (default \code{"homage"}). See [albers_presets()].
#' @param base_size Base font size in pixels (default 14).
#' @param width Table width in pixels (default 720). Use \code{NULL} for auto.
#' @param bg Override background color (default derived from preset).
#' @param fg Override text color (default derived from preset).
#' @return A styled \code{gt} table object.
#' @export
#' @examples
#' \donttest{
#' if (requireNamespace("gt", quietly = TRUE)) {
#'   tbl <- gt::gt(head(mtcars))
#'   gt_albers(tbl)
#' }
#' }
gt_albers <- function(
  x,
  family = "red",
  preset = c("homage", "study", "structural", "adobe", "midnight"),
  base_size = 14,
  width = 720,
  bg = NULL,
  fg = NULL
) {

  if (!requireNamespace("gt", quietly = TRUE)) {
    stop("Package 'gt' is required for gt_albers(). ",
         "Install it with install.packages(\"gt\").", call. = FALSE)
  }

  preset <- match.arg(preset)
  pal <- albers_palette(family)
  colors <- .preset_colors(preset)
  bg <- bg %||% colors$bg
  fg <- fg %||% colors$fg
  stripe <- grDevices::adjustcolor(pal[["A300"]], alpha.f = 0.08)
  header_accent <- pal[["A500"]]
  tbl_width <- if (!is.null(width)) gt::px(width) else NULL
  x |>
    gt::opt_row_striping() |>
    gt::tab_options(
      table.width = tbl_width,
      table.font.names = "system-ui",
      table.font.size = gt::px(base_size),
      data_row.padding = gt::px(6),
      table.border.top.color = "transparent",
      table.border.bottom.color = "transparent",
      table.background.color = bg,
      heading.align = "left"
    ) |>
    gt::tab_style(
      style = list(gt::cell_borders(sides = "bottom", color = colors$border)),
      locations = gt::cells_body()
    ) |>
    gt::tab_style(
      style = gt::cell_text(color = fg),
      locations = gt::cells_body()
    ) |>
    gt::tab_style(
      style = gt::cell_text(color = colors$muted),
      locations = gt::cells_title(groups = "subtitle")
    ) |>
    gt::tab_options(
      row.striping.background_color = stripe
    ) |>
    gt::tab_style(
      style = list(gt::cell_borders(
        sides = "bottom", color = header_accent, weight = gt::px(2)
      )),
      locations = gt::cells_column_labels()
    )
}

