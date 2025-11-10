#' Return four-tone Homage family by name
#'
#' @param family One of "red", "lapis", "ochre", "teal".
#' @export
albers_palette <- function(family = c("red","lapis","ochre","teal")) {
  family <- match.arg(family)
  switch(family,
    red   = c(A900 = "#CD2D26", A700 = "#DC3925", A500 = "#E44926", A300 = "#E35B2D"),
    lapis = c(A900 = "#1B2A74", A700 = "#20399C", A500 = "#2C4FCC", A300 = "#4968D6"),
    ochre = c(A900 = "#6F5200", A700 = "#8B6700", A500 = "#B48900", A300 = "#D7A700"),
    teal  = c(A900 = "#0D4A4A", A700 = "#0F5E5E", A500 = "#127373", A300 = "#2F8C8C")
  )
}

#' Minimal, legible plot theme (uses family tones for accents)
#'
#' @param family Palette family used by companion scales.
#' @param base_size Base font size.
#' @param base_family Base font family.
#' @export
theme_albers <- function(family = "red", base_size = 11, base_family = "system-ui") {
  pal <- albers_palette(family)
  ggplot2::theme_minimal(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      panel.grid.major = ggplot2::element_line(color = "#e5e7eb", linewidth = 0.3),
      panel.grid.minor = ggplot2::element_blank(),
      plot.title = ggplot2::element_text(face = "bold", margin = ggplot2::margin(b = 8)),
      plot.subtitle = ggplot2::element_text(color = "#374151", margin = ggplot2::margin(b = 10)),
      plot.caption = ggplot2::element_text(color = "#6b7280", margin = ggplot2::margin(t = 10)),
      legend.position = "top",
      legend.title = ggplot2::element_text(face = "bold"),
      axis.title.x = ggplot2::element_text(margin = ggplot2::margin(t = 6)),
      axis.title.y = ggplot2::element_text(margin = ggplot2::margin(r = 6)),
      plot.background = ggplot2::element_rect(fill = NA, colour = NA)
    )
}

#' Scales that use the family's tones (discrete/continuous)
#'
#' @param family Palette family.
#' @param discrete Whether to use a discrete palette; if FALSE, uses a gradient.
#' @param ... Passed to underlying `ggplot2` scale.
#' @export
scale_color_albers <- function(family = "red", discrete = TRUE, ...) {
  pal <- albers_palette(family)
  if (discrete) ggplot2::scale_color_manual(values = unname(pal[c("A900","A700","A500","A300")]), ...)
  else ggplot2::scale_color_gradient(low = pal[["A300"]], high = pal[["A900"]], ...)
}

#' @export
scale_fill_albers <- function(family = "red", discrete = TRUE, ...) {
  pal <- albers_palette(family)
  if (discrete) ggplot2::scale_fill_manual(values = unname(pal[c("A900","A700","A500","A300")]), ...)
  else ggplot2::scale_fill_gradient(low = pal[["A300"]], high = pal[["A900"]], ...)
}

