#!/usr/bin/env Rscript
# Draws man/figures/README-plates.png: the title plate of every family in both
# directions, as the stylesheet draws it (four nested squares at 100/80/60/40%,
# each inner square's top margin three times its bottom margin).
# Run from the package root: Rscript tools/make_readme_plates.R

pkgload::load_all(quiet = TRUE)

families <- c("red", "lapis", "ochre", "teal", "green", "violet")
plate_cols <- function(family, preset) {
  pal <- albers_palette(family)
  comp <- .albers_comp(family)[["comp"]]
  if (identical(preset, "homage")) {
    c(comp, pal[["A300"]], pal[["A500"]], pal[["A900"]])
  } else {
    c(pal[["A900"]], pal[["A700"]], pal[["A500"]], comp)
  }
}

draw_plate <- function(x, y, size, cols) {
  for (k in seq_along(cols)) {
    s <- size * c(1, 0.8, 0.6, 0.4)[k]
    free <- size - s
    # centred horizontally; vertical free space split 3:1 (top:bottom)
    grid::grid.rect(
      x = x + (size - s) / 2, y = y + free / 4, width = s, height = s,
      just = c("left", "bottom"), default.units = "in",
      gp = grid::gpar(fill = cols[k], col = NA)
    )
  }
}

have_fonts <- requireNamespace("systemfonts", quietly = TRUE) && isTRUE(try(albers_register_fonts(), silent = TRUE))
font <- if (have_fonts) "Familjen Grotesk" else "sans"

dir.create("man/figures", showWarnings = FALSE, recursive = TRUE)
out <- "man/figures/README-plates.png"
size <- 1.05; gap <- 0.3; left <- 1.9; top <- 0.3; label_h <- 0.5
width <- left + 6 * size + 5 * gap + 0.3
height <- top + 2 * (size + label_h) + 0.25 + 0.2
dev <- if (requireNamespace("ragg", quietly = TRUE)) ragg::agg_png else grDevices::png
dev(out, width = width, height = height, units = "in", res = 200, background = "#fbf7ee")
grid::grid.newpage()
ink <- "#1f1b16"; muted <- "#6b6357"
for (r in 1:2) {
  preset <- c("homage", "interaction")[r]
  y <- height - top - r * size - (r - 1) * (label_h + 0.25)
  grid::grid.text(preset, x = 0.3, y = y + size / 2, just = "left", default.units = "in",
                  gp = grid::gpar(fontfamily = font, fontsize = 20, col = ink, fontface = "bold"))
  for (i in seq_along(families)) {
    x <- left + (i - 1) * (size + gap)
    draw_plate(x, y, size, plate_cols(families[i], preset))
    if (r == 2) {
      grid::grid.text(families[i], x = x, y = y - 0.26, just = "left", default.units = "in",
                      gp = grid::gpar(fontfamily = font, fontsize = 17, col = muted))
    }
  }
}
invisible(grDevices::dev.off())
message("Wrote ", out)
