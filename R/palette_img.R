# Image-derived palettes and scales (opt-in)

#' Image-derived Homage palettes (A900 -> A300)
#'
#' Four-tone families distilled from the uploaded grid; order is
#' darkest to lightest (A900, A700, A500, A300).
#'
#' @param family One of "red","lapis","ochre","teal","green"
#' @export
albers_palette_img <- function(family = c("red","lapis","ochre","teal","green")) {
  family <- match.arg(family)
  switch(
    family,
    red   = c(A900 = "#52140A", A700 = "#9D2E46", A500 = "#A52B22", A300 = "#C53926"),
    lapis = c(A900 = "#132E5C", A700 = "#104A77", A500 = "#1056A8", A300 = "#1675E5"),
    ochre = c(A900 = "#8F603B", A700 = "#D17937", A500 = "#EDD9A9", A300 = "#F8EDBB"),
    teal  = c(A900 = "#286D66", A700 = "#49AF9E", A500 = "#73AEBE", A300 = "#98E6FB"),
    green = c(A900 = "#2D5544", A700 = "#366E5B", A500 = "#3B796C", A300 = "#59B6A3")
  )
}

#' Image-derived sequential color scale
#'
#' @inheritParams albers_palette_img
#' @param discrete Whether to use discrete palette; if FALSE uses a gradient.
#' @param ... Passed to underlying ggplot2 scale.
#' @export
scale_color_albers_img <- function(family = "red", discrete = TRUE, ...) {
  pal <- albers_palette_img(family)
  if (discrete) ggplot2::scale_color_manual(values = unname(pal[c("A900","A700","A500","A300")]), ...)
  else ggplot2::scale_color_gradient(low = pal[["A300"]], high = pal[["A900"]], ...)
}

#' @rdname scale_color_albers_img
#' @export
scale_fill_albers_img <- function(family = "red", discrete = TRUE, ...) {
  pal <- albers_palette_img(family)
  if (discrete) ggplot2::scale_fill_manual(values = unname(pal[c("A900","A700","A500","A300")]), ...)
  else ggplot2::scale_fill_gradient(low = pal[["A300"]], high = pal[["A900"]], ...)
}

#' Build 5-stop diverging spec from image-derived families
#'
#' @param low_family  Family for the low side (left)
#' @param high_family Family for the high side (right)
#' @param neutral     Hex color for the midpoint (default derived from image)
#' @return list(colours, values)
#' @keywords internal
albers_diverging_img <- function(low_family, high_family, neutral = "#E4E0D9") {
  low  <- albers_palette_img(low_family)
  high <- albers_palette_img(high_family)
  cols <- c(low[["A900"]], low[["A500"]], neutral, high[["A500"]], high[["A900"]])
  list(colours = unname(cols), values = c(0, 0.45, 0.50, 0.55, 1.00))
}

#' Image-derived diverging color scale (gradientn)
#'
#' @inheritParams albers_diverging_img
#' @param ... Passed to ggplot2::scale_color_gradientn
#' @export
scale_color_albers_img_diverging <- function(low_family, high_family, neutral = "#E4E0D9", ...) {
  sp <- albers_diverging_img(low_family, high_family, neutral)
  ggplot2::scale_color_gradientn(colours = sp$colours, values = sp$values, ...)
}

#' Image-derived diverging fill scale (gradientn)
#'
#' @inheritParams scale_color_albers_img_diverging
#' @param ... Passed to ggplot2::scale_fill_gradientn
#' @export
scale_fill_albers_img_diverging <- function(low_family, high_family, neutral = "#E4E0D9", ...) {
  sp <- albers_diverging_img(low_family, high_family, neutral)
  ggplot2::scale_fill_gradientn(colours = sp$colours, values = sp$values, ...)
}

#' Pre-canned image-derived diverging pairs
#'
#' @param neutral Midpoint color (default from image); use "#e5e7eb" to match site CSS
#' @param ... Passed to the underlying gradientn scale
#' @export
scale_color_albers_img_red_teal <- function(neutral = "#E4E0D9", ...) {
  scale_color_albers_img_diverging("red", "teal", neutral, ...)
}

#' @rdname scale_color_albers_img_red_teal
#' @export
scale_color_albers_img_lapis_ochre <- function(neutral = "#E4E0D9", ...) {
  scale_color_albers_img_diverging("lapis", "ochre", neutral, ...)
}

#' @rdname scale_color_albers_img_red_teal
#' @export
scale_color_albers_img_green_red <- function(neutral = "#E4E0D9", ...) {
  scale_color_albers_img_diverging("green", "red", neutral, ...)
}

#' @rdname scale_color_albers_img_red_teal
#' @export
scale_fill_albers_img_red_teal <- function(neutral = "#E4E0D9", ...) {
  scale_fill_albers_img_diverging("red", "teal", neutral, ...)
}

#' @rdname scale_color_albers_img_red_teal
#' @export
scale_fill_albers_img_lapis_ochre <- function(neutral = "#E4E0D9", ...) {
  scale_fill_albers_img_diverging("lapis", "ochre", neutral, ...)
}

#' @rdname scale_color_albers_img_red_teal
#' @export
scale_fill_albers_img_green_red <- function(neutral = "#E4E0D9", ...) {
  scale_fill_albers_img_diverging("green", "red", neutral, ...)
}

