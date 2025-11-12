#' Return four-tone Homage family by name
#'
#' @param family One of "red", "lapis", "ochre", "teal".
#' @export
albers_palette <- function(family = c("red","lapis","ochre","teal","green","violet")) {
  family <- match.arg(family)
  switch(family,
    red    = c(A900 = "#CD2D26", A700 = "#DC3925", A500 = "#E44926", A300 = "#E35B2D"),
    lapis  = c(A900 = "#1B2A74", A700 = "#20399C", A500 = "#2C4FCC", A300 = "#4968D6"),
    ochre  = c(A900 = "#6F5200", A700 = "#8B6700", A500 = "#B48900", A300 = "#D7A700"),
    teal   = c(A900 = "#0D4A4A", A700 = "#0F5E5E", A500 = "#127373", A300 = "#2F8C8C"),
    green  = c(A900 = "#1B5E20", A700 = "#2E7D32", A500 = "#388E3C", A300 = "#66BB6A"),
    violet = c(A900 = "#4A148C", A700 = "#6A1B9A", A500 = "#8E24AA", A300 = "#BA68C8")
  )
}

#' Minimal, legible plot theme (uses family tones for accents)
#'
#' @param family Palette family used by companion scales.
#' @param base_size Base font size.
#' @param base_family Base font family.
#' @export
theme_albers <- function(family = "red", base_size = 13, base_family = "system-ui") {
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

#' Distinct, colorblind-friendly line palette across families
#'
#' Uses one high-contrast tone (default A700) from different families
#' to maximize separation between lines. This departs from the
#' single-family aesthetic but improves readability for multi-series lines.
#'
#' @param n Number of colors needed; defaults to length of available families (6).
#' @param tone One of "A700", "A900", or "A500".
#' @param ... Passed to `ggplot2::scale_color_manual()`.
#' @export
scale_color_albers_distinct <- function(n = NULL, tone = c("A700", "A900", "A500"), ...) {
  tone <- match.arg(tone)
  families <- c("red","teal","lapis","ochre","green","violet")
  cols <- vapply(families, function(f) albers_palette(f)[[tone]], character(1))
  if (is.null(n)) n <- length(cols)
  ggplot2::scale_color_manual(values = unname(cols[seq_len(min(n, length(cols)))]), ...)
}

#' Discrete linetype scale to pair with Albers colors
#'
#' Provides a sensible set of linetypes for multi-series line charts.
#' @param ... Passed to `ggplot2::scale_linetype_manual()`.
#' @export
scale_linetype_albers <- function(...) {
  ggplot2::scale_linetype_manual(values = c("solid","dashed","dotdash","dotted","longdash","twodash"), ...)
}

#' Return a complementary family for diverging palettes
#'
#' Pairs warm/cool and related families to produce balanced diverging
#' combinations that align with the Homage system.
#'
#' @param family One of "red","lapis","ochre","teal","green","violet"
#' @keywords internal
albers_complement <- function(family = c("red","lapis","ochre","teal","green","violet")) {
  family <- match.arg(family)
  switch(
    family,
    red    = "lapis",
    lapis  = "red",
    ochre  = "teal",
    teal   = "ochre",
    violet = "green",
    green  = "violet"
  )
}

#' Build a 5-stop diverging spec from two families
#'
#' @param low_family  family driving the low side
#' @param high_family family driving the high side
#' @param neutral     hex color at the midpoint (defaults to CSS border tone)
#' @return list(colours, values)
#' @keywords internal
albers_diverging_spec <- function(
  low_family  = "red",
  high_family = albers_complement(low_family),
  neutral     = "#e5e7eb"
) {
  low  <- albers_palette(low_family)
  high <- albers_palette(high_family)
  cols <- c(low[["A900"]], low[["A500"]], neutral, high[["A500"]], high[["A900"]])
  vals <- c(0,               0.45,         0.50,     0.55,            1.00)
  list(colours = unname(cols), values = vals)
}

#' Diverging color scale (continuous)
#'
#' @param low_family,high_family Homage families for the two sides
#' @param midpoint numeric midpoint for the diverging scale (default 0)
#' @param neutral hex color for the midpoint (default matches CSS border)
#' @param ... passed to ggplot2::scale_color_gradient2()
#' @export
scale_color_albers_diverging <- function(
  low_family  = "red",
  high_family = albers_complement(low_family),
  midpoint = 0,
  neutral = "#e5e7eb",
  ...
) {
  low  <- albers_palette(low_family)
  high <- albers_palette(high_family)
  ggplot2::scale_color_gradient2(
    low = low[["A700"]], mid = neutral, high = high[["A700"]],
    midpoint = midpoint, ...
  )
}

#' Diverging fill scale (continuous)
#'
#' @inheritParams scale_color_albers_diverging
#' @export
scale_fill_albers_diverging <- function(
  low_family  = "red",
  high_family = albers_complement(low_family),
  midpoint = 0,
  neutral = "#e5e7eb",
  ...
) {
  low  <- albers_palette(low_family)
  high <- albers_palette(high_family)
  ggplot2::scale_fill_gradient2(
    low = low[["A700"]], mid = neutral, high = high[["A700"]],
    midpoint = midpoint, ...
  )
}

#' Diverging color scale with multiple stops (continuous)
#'
#' Uses a 5-stop palette (low2, low1, neutral, high1, high2) for smoother
#' transitions around the midpoint.
#'
#' @inheritParams scale_color_albers_diverging
#' @export
scale_color_albers_diverging_n <- function(
  low_family  = "red",
  high_family = albers_complement(low_family),
  neutral = "#e5e7eb",
  ...
) {
  spec <- albers_diverging_spec(low_family, high_family, neutral)
  ggplot2::scale_color_gradientn(colours = spec$colours, values = spec$values, ...)
}

#' Diverging fill scale with multiple stops (continuous)
#'
#' @inheritParams scale_color_albers_diverging_n
#' @export
scale_fill_albers_diverging_n <- function(
  low_family  = "red",
  high_family = albers_complement(low_family),
  neutral = "#e5e7eb",
  ...
) {
  spec <- albers_diverging_spec(low_family, high_family, neutral)
  ggplot2::scale_fill_gradientn(colours = spec$colours, values = spec$values, ...)
}

#' 5-class diverging (discrete)
#'
#' Useful for binned choropleths or sliced residuals. The middle class uses
#' the neutral color.
#'
#' @param labels Optional labels for the five classes (low2, low1, mid, high1, high2)
#' @export
scale_fill_albers_diverging_5 <- function(
  low_family  = "red",
  high_family = albers_complement(low_family),
  neutral = "#e5e7eb",
  labels = ggplot2::waiver(),
  ...
) {
  low  <- albers_palette(low_family)
  high <- albers_palette(high_family)
  vals <- c(low[["A900"]], low[["A500"]], neutral, high[["A500"]], high[["A900"]])
  ggplot2::scale_fill_manual(values = unname(vals), labels = labels, ...)
}

#' @rdname scale_fill_albers_diverging_5
#' @export
scale_color_albers_diverging_5 <- function(
  low_family  = "red",
  high_family = albers_complement(low_family),
  neutral = "#e5e7eb",
  labels = ggplot2::waiver(),
  ...
) {
  low  <- albers_palette(low_family)
  high <- albers_palette(high_family)
  vals <- c(low[["A900"]], low[["A500"]], neutral, high[["A500"]], high[["A900"]])
  ggplot2::scale_color_manual(values = unname(vals), labels = labels, ...)
}

#' Convenience scale: highlight vs other (color)
#'
#' Returns a manual color scale mapping a single highlighted group to a
#' family tone (default A700) and all other points to a neutral gray.
#' 
#' @param family Palette family name.
#' @param tone One of A900, A700, A500, A300 used for the highlight color.
#' @param other Hex color used for non-highlight values.
#' @param highlight Name of the value that should receive the highlight color.
#' @param other_name Name of the value that should receive the neutral color.
#' @param ... Passed to `ggplot2::scale_color_manual()`.
#' @export
scale_color_albers_highlight <- function(
  family = "red",
  tone = c("A700", "A900", "A500", "A300"),
  other = "#9aa0a6",
  highlight = "highlight",
  other_name = "other",
  ...
) {
  tone <- match.arg(tone)
  pal <- albers_palette(family)
  vals <- stats::setNames(c(pal[[tone]], other), c(highlight, other_name))
  ggplot2::scale_color_manual(values = vals, ...)
}

#' Convenience scale: highlight vs other (fill)
#'
#' @inheritParams scale_color_albers_highlight
#' @export
scale_fill_albers_highlight <- function(
  family = "red",
  tone = c("A700", "A900", "A500", "A300"),
  other = "#9aa0a6",
  highlight = "highlight",
  other_name = "other",
  ...
) {
  tone <- match.arg(tone)
  pal <- albers_palette(family)
  vals <- stats::setNames(c(pal[[tone]], other), c(highlight, other_name))
  ggplot2::scale_fill_manual(values = vals, ...)
}
