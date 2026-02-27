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

#' Color values for named Albers presets
#'
#' Each preset captures ground, surface, ink, and accent-role colours
#' inspired by Bauhaus, Le Corbusier, and Josef Albers.
#'
#' \describe{
#'   \item{homage}{Cool gallery white, the Bauhaus exhibition wall.}
#'   \item{study}{Pure analytical white from \emph{Interaction of Color} plates.}
#'   \item{structural}{Cool concrete (b\enc{é}{e}ton brut), shadowless precision.}
#'   \item{adobe}{Warm architectural grey, Le Corbusier b\enc{é}{e}ton.}
#'   \item{midnight}{Deep indigo-black for dark-theme contexts.}
#' }
#'
#' @param preset One of \code{"homage"}, \code{"study"}, \code{"structural"},
#'   \code{"adobe"}, \code{"midnight"}.
#' @return Named list with bg, fg, surface, muted, grid, border, code_bg.
#' @keywords internal
.preset_colors <- function(preset = "homage") {
  switch(preset,
    homage = list(
      bg = "#f3f5f7", fg = "#17181a", surface = "#ffffff",
      muted = "#636b76", grid = "#dde2e8",
      border = "#d5dae1", code_bg = "#ecf0f4"
    ),
    study = list(
      bg = "#f7f9fb", fg = "#17181a", surface = "#ffffff",
      muted = "#68717d", grid = "#e5e9ef",
      border = "#dde2e8", code_bg = "#f1f4f8"
    ),
    structural = list(
      bg = "#e6e9ed", fg = "#101214", surface = "#f1f3f6",
      muted = "#4b5360", grid = "#ccd3db",
      border = "#c1c8d0", code_bg = "#e0e5ea"
    ),
    adobe = list(
      bg = "#ece9e7", fg = "#1f1c19", surface = "#f3f1ef",
      muted = "#66615d", grid = "#d4cfcb",
      border = "#ccc7c3", code_bg = "#e3dfdc"
    ),
    midnight = list(
      bg = "#0d1117", fg = "#e8e6e1", surface = "#151b24",
      muted = "#9aa2b0", grid = "#303745",
      border = "#2c3342", code_bg = "#111722"
    )
  )
}

#' List available Albers presets
#'
#' Returns the names of the five built-in presets, each inspired by a
#' different period or series in Josef Albers' work.
#'
#' @return Character vector of preset names.
#' @export
albers_presets <- function() {
  c("homage", "study", "structural", "adobe", "midnight")
}

#' Minimal, legible plot theme inspired by Josef Albers
#'
#' @param family Palette family used by companion scales.
#' @param preset Visual preset: \code{"homage"} (gallery white), \code{"study"}
#'   (analytical white), \code{"structural"} (concrete), \code{"adobe"}
#'   (warm architectural grey), \code{"midnight"} (dark).
#' @param base_size Base font size.
#' @param base_family Base font family.
#' @param bg Override background color (default derived from preset).
#' @param fg Override foreground/text color (default derived from preset).
#' @param grid_color Override grid line color (default derived from preset).
#' @export
theme_albers <- function(
  family = "red",
  preset = c("homage", "study", "structural", "adobe", "midnight"),
  base_size = 13,
  base_family = "sans",
  bg = NULL,
  fg = NULL,
  grid_color = NULL
) {
  preset <- match.arg(preset)
  pal <- albers_palette(family)
  colors <- .preset_colors(preset)

  bg <- bg %||% colors$bg
  fg <- fg %||% colors$fg
  grid_color <- grid_color %||% colors$grid
  muted <- colors$muted
  surface <- colors$surface
  border <- colors$border
  strip_alpha <- if (preset == "midnight") 0.18 else 0.11
  strip_fill <- grDevices::adjustcolor(pal[["A300"]], alpha.f = strip_alpha)
  legend_bg <- grDevices::adjustcolor(surface, alpha.f = 0.97)

  ggplot2::theme_minimal(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      plot.background = ggplot2::element_rect(fill = bg, colour = NA),
      panel.background = ggplot2::element_rect(fill = surface, colour = NA),
      panel.border = ggplot2::element_rect(fill = NA, colour = border, linewidth = 0.33),
      panel.grid.major = ggplot2::element_line(color = grid_color, linewidth = 0.3),
      panel.grid.minor = ggplot2::element_blank(),
      panel.spacing = grid::unit(10, "pt"),
      axis.line = ggplot2::element_line(color = border, linewidth = 0.24),
      axis.ticks = ggplot2::element_line(color = border, linewidth = 0.24),
      axis.ticks.length = grid::unit(2.5, "pt"),
      plot.title = ggplot2::element_text(
        face = "bold", color = fg,
        lineheight = 1.04,
        margin = ggplot2::margin(b = 6)
      ),
      plot.title.position = "plot",
      plot.subtitle = ggplot2::element_text(
        color = muted,
        lineheight = 1.2,
        margin = ggplot2::margin(b = 10)
      ),
      plot.caption = ggplot2::element_text(
        color = muted, hjust = 0, size = ggplot2::rel(0.9),
        margin = ggplot2::margin(t = 10)
      ),
      plot.caption.position = "plot",
      legend.position = "top",
      legend.title = ggplot2::element_text(face = "bold", color = fg),
      legend.text = ggplot2::element_text(color = muted),
      legend.background = ggplot2::element_rect(fill = legend_bg, colour = border, linewidth = 0.3),
      legend.box.background = ggplot2::element_rect(fill = legend_bg, colour = border, linewidth = 0.3),
      legend.key = ggplot2::element_rect(fill = legend_bg, colour = NA),
      legend.key.width = grid::unit(14, "pt"),
      legend.key.height = grid::unit(8, "pt"),
      axis.title = ggplot2::element_text(color = fg),
      axis.title.x = ggplot2::element_text(margin = ggplot2::margin(t = 8)),
      axis.title.y = ggplot2::element_text(margin = ggplot2::margin(r = 8)),
      axis.text = ggplot2::element_text(color = muted),
      strip.background = ggplot2::element_rect(fill = strip_fill, colour = border, linewidth = 0.3),
      strip.text = ggplot2::element_text(
        face = "bold",
        color = fg,
        margin = ggplot2::margin(4, 4, 4, 4)
      ),
      plot.margin = ggplot2::margin(12, 12, 12, 12)
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

#' @rdname scale_color_albers
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
#' @inheritParams scale_color_albers_diverging
#' @param labels Optional labels for the five classes (low2, low1, mid, high1, high2)
#' @param ... Passed to `ggplot2::scale_fill_manual()` or `ggplot2::scale_color_manual()`.
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

#' Distinct, colorblind-friendly fill palette across families
#'
#' Uses one high-contrast tone (default A700) from different families
#' to maximize separation between filled regions. Fill counterpart of
#' \code{\link{scale_color_albers_distinct}}.
#'
#' @inheritParams scale_color_albers_distinct
#' @param ... Passed to \code{ggplot2::scale_fill_manual()}.
#' @export
scale_fill_albers_distinct <- function(n = NULL, tone = c("A700", "A900", "A500"), ...) {
  tone <- match.arg(tone)
  families <- c("red", "teal", "lapis", "ochre", "green", "violet")
  cols <- vapply(families, function(f) albers_palette(f)[[tone]], character(1))
  if (is.null(n)) n <- length(cols)
  ggplot2::scale_fill_manual(values = unname(cols[seq_len(min(n, length(cols)))]), ...)
}

#' Stripped theme for maps, brain surfaces, and abstract compositions
#'
#' Extends \code{\link{theme_albers}} by removing axes, grid lines, ticks,
#' and panel border -- leaving only the plot background, titles, and legend.
#' Useful for spatial visualizations where coordinate axes are meaningless.
#'
#' @inheritParams theme_albers
#' @export
theme_albers_void <- function(
  family = "red",
  preset = c("homage", "study", "structural", "adobe", "midnight"),
  base_size = 13,
  base_family = "sans",
  bg = NULL,
  fg = NULL
) {
  theme_albers(
    family = family, preset = preset,
    base_size = base_size, base_family = base_family,
    bg = bg, fg = fg
  ) +
    ggplot2::theme(
      axis.line        = ggplot2::element_blank(),
      axis.text        = ggplot2::element_blank(),
      axis.ticks       = ggplot2::element_blank(),
      axis.title       = ggplot2::element_blank(),
      panel.border     = ggplot2::element_blank(),
      panel.grid.major = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank()
    )
}

#' Interpolate n colors along a palette family gradient
#'
#' Uses \code{\link[grDevices]{colorRampPalette}} to interpolate between the
#' four tones of a family (A900 \enc{→}{->} A300), producing an arbitrary
#' number of evenly spaced colors.
#'
#' @param family Palette family name.
#' @param n Number of colors to return.
#' @param reverse If \code{TRUE}, return colors from light to dark.
#' @return Character vector of \code{n} hex colors.
#' @export
albers_ramp <- function(family = "red", n = 9, reverse = FALSE) {
  pal <- albers_palette(family)
  ramp <- grDevices::colorRampPalette(unname(pal))
  cols <- ramp(n)
  if (reverse) rev(cols) else cols
}

#' Visual swatch of Albers palette families and presets
#'
#' Draws a tile plot showing the four tones of each palette family, optionally
#' faceted by preset ground colors. Useful for quickly previewing the design
#' system in a notebook or presentation.
#'
#' @param families Character vector of families to show.
#'   Defaults to all six.
#' @param show_presets If \code{TRUE}, add a row of preset ground colors
#'   below the palette tones. Defaults to \code{FALSE}.
#' @return A \code{ggplot} object.
#' @export
albers_swatch <- function(
  families = c("red", "lapis", "ochre", "teal", "green", "violet"),
  show_presets = FALSE
) {
  tones <- c("A900", "A700", "A500", "A300")

  rows <- do.call(rbind, lapply(families, function(fam) {
    pal <- albers_palette(fam)
    data.frame(
      family = fam,
      tone   = factor(tones, levels = tones),
      hex    = unname(pal[tones]),
      type   = "palette",
      stringsAsFactors = FALSE
    )
  }))

  if (show_presets) {
    preset_rows <- do.call(rbind, lapply(albers_presets(), function(p) {
      cols <- .preset_colors(p)
      data.frame(
        family = p,
        tone   = factor(c("bg", "surface", "border", "muted"),
                        levels = c("bg", "surface", "border", "muted")),
        hex    = c(cols$bg, cols$surface, cols$border, cols$muted),
        type   = "preset",
        stringsAsFactors = FALSE
      )
    }))
    rows <- rbind(rows, preset_rows)
  }

  rows$family <- factor(rows$family, levels = unique(rows$family))

  # avoid R CMD check NOTEs for NSE column references
  tone <- family <- hex <- NULL

  ggplot2::ggplot(rows, ggplot2::aes(x = tone, y = family, fill = hex)) +
    ggplot2::geom_tile(color = "white", linewidth = 1.5) +
    ggplot2::scale_fill_identity() +
    ggplot2::geom_text(
      ggplot2::aes(label = hex),
      size = 2.8, color = ifelse(
        grDevices::col2rgb(rows$hex)[1, ] * 0.299 +
        grDevices::col2rgb(rows$hex)[2, ] * 0.587 +
        grDevices::col2rgb(rows$hex)[3, ] * 0.114 > 150,
        "#17181a", "#f3f5f7"
      )
    ) +
    ggplot2::coord_equal() +
    theme_albers_void(preset = "study") +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(color = "#636b76", size = 9),
      axis.text.y = ggplot2::element_text(color = "#17181a", size = 10, face = "bold", hjust = 1)
    ) +
    ggplot2::labs(x = NULL, y = NULL)
}
