#' Quiet, legible gt style with subtle stripe from A300
#'
#' @param x A `gt` table
#' @param family Palette family for subtle accents
#' @export
gt_albers <- function(x, family = "red") {
  pal <- albers_palette(family)
  stripe <- pal[["A300"]]
  x |>
    gt::opt_row_striping() |>
    gt::tab_options(
      table.width = gt::px(720),
      table.font.names = "system-ui",
      data_row.padding = gt::px(6),
      table.border.top.color = "transparent",
      table.border.bottom.color = "transparent",
      heading.align = "left"
    ) |>
    gt::tab_style(
      style = list(gt::cell_borders(sides = "bottom", color = "#e5e7eb")),
      locations = gt::cells_body()
    ) |>
    gt::tab_style(
      style = gt::cell_text(color = "#6b7280"),
      locations = gt::cells_title(groups = "subtitle")
    ) |>
    gt::tab_style(
      style = gt::cell_fill(color = stripe),
      locations = gt::cells_body(rows = gt::odd())
    )
}

