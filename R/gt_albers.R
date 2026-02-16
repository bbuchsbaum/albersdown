#' Quiet, legible gt style with subtle stripe from A300
#'
#' @param x A `gt` table
#' @param family Palette family for subtle accents
#' @param preset Visual preset (default \code{"homage"}). See [albers_presets()].
#' @export
gt_albers <- function(
  x,
  family = "red",
  preset = c("homage", "study", "structural", "adobe", "midnight")
) {
  preset <- match.arg(preset)
  pal <- albers_palette(family)
  colors <- .preset_colors(preset)
  stripe <- pal[["A300"]]
  x |>
    gt::opt_row_striping() |>
    gt::tab_options(
      table.width = gt::px(720),
      table.font.names = "system-ui",
      data_row.padding = gt::px(6),
      table.border.top.color = "transparent",
      table.border.bottom.color = "transparent",
      table.background.color = colors$bg,
      heading.align = "left"
    ) |>
    gt::tab_style(
      style = list(gt::cell_borders(sides = "bottom", color = colors$border)),
      locations = gt::cells_body()
    ) |>
    gt::tab_style(
      style = gt::cell_text(color = colors$muted),
      locations = gt::cells_title(groups = "subtitle")
    ) |>
    gt::tab_style(
      style = gt::cell_fill(color = stripe),
      locations = gt::cells_body(rows = gt::odd())
    )
}

