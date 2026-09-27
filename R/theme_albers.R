#' Return four-tone Homage family by name
#'
#' @param family One of "red", "lapis", "ochre", "teal".
#' @return Named character vector of four hex colors (A900, A700, A500, A300).
#' @export
#' @examples
#' albers_palette("red")
#' albers_palette("lapis")
albers_palette <- function(family = c("red","lapis","ochre","teal","green","violet")) {
  family <- match.arg(family)
  switch(family,
    red    = c(A900 = "#760906", A700 = "#AE1703", A500 = "#D74A21", A300 = "#F7A885"),
    lapis  = c(A900 = "#213480", A700 = "#3154B9", A500 = "#507ADF", A300 = "#A2BEF5"),
    ochre  = c(A900 = "#513801", A700 = "#7A5604", A500 = "#A47807", A300 = "#DEB95C"),
    teal   = c(A900 = "#044746", A700 = "#0A6C69", A500 = "#2E918C", A300 = "#8DCCC5"),
    green  = c(A900 = "#204727", A700 = "#386B3A", A500 = "#5E904D", A300 = "#AEC98E"),
    violet = c(A900 = "#4E2B62", A700 = "#754590", A500 = "#956CB3", A300 = "#CAB2E1")
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
#'   \item{midnight}{The family's deepest tone mixed into ink, for dark-theme
#'     contexts.}
#' }
#'
#' @param preset One of the two 2.0 directions \code{"homage"} (warm cream,
#'   serif body) or \code{"interaction"} (cool grey, grotesk), or a legacy
#'   preset (\code{"study"}, \code{"structural"}, \code{"adobe"},
#'   \code{"midnight"}) retained for backward compatibility.
#' @param family Colour family name. Only midnight uses it: its grounds are
#'   tinted by the family (\code{NULL} or an unknown name gives red's).
#' @return Named list with bg, fg, surface, muted, grid, border, code_bg.
#' @keywords internal
.preset_colors <- function(preset = "homage", family = NULL) {
  if (identical(preset, "midnight")) return(.midnight_colors(family))
  switch(preset,
    homage = list(
      bg = "#efe7d6", fg = "#1f1b16", surface = "#fbf7ee",
      muted = "#6b6355", grid = "#e6ddca",
      border = "#d8cbae", code_bg = "#fbf7ee"
    ),
    interaction = list(
      bg = "#eceef1", fg = "#15181e", surface = "#ffffff",
      muted = "#5d6573", grid = "#e3e6eb",
      border = "#d6dbe3", code_bg = "#eef0f3"
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
    midnight = .midnight_colors(family)
  )
}

# Midnight's grounds are the family's deepest tone mixed into ink (albers.css
# computes them with color-mix(); these are the resolved values), so a red
# page's plots sit on the same red-black as the page.
.midnight_colors <- function(family = NULL) {
  grounds <- list(
    red    = c(bg = "#1e0d0e", surface = "#271416", border = "#40282a", code_bg = "#220c0e"),
    lapis  = c(bg = "#0c1223", surface = "#12192d", border = "#242e4a", code_bg = "#0b1229"),
    ochre  = c(bg = "#15120e", surface = "#1d1a16", border = "#332f2a", code_bg = "#17130e"),
    teal   = c(bg = "#0a1418", surface = "#101c21", border = "#223339", code_bg = "#08161b"),
    green  = c(bg = "#0d1512", surface = "#131c1b", border = "#253330", code_bg = "#0b1613"),
    violet = c(bg = "#15101d", surface = "#1c1727", border = "#322b41", code_bg = "#170f22")
  )
  key <- if (is.character(family) && length(family) == 1 && family %in% names(grounds)) family else "red"
  g <- grounds[[key]]
  list(
    bg = unname(g[["bg"]]), fg = "#e8e6e1", surface = unname(g[["surface"]]),
    muted = "#b6b4ae", grid = unname(g[["border"]]),
    border = unname(g[["border"]]), code_bg = unname(g[["code_bg"]])
  )
}

# Night grounds, matching html[data-albers-theme="dark"] in albers.css. Homage
# stays warm and Interaction cool; midnight is already dark.
.preset_colors_night <- function(preset = "homage", family = NULL) {
  if (identical(preset, "midnight")) return(.preset_colors("midnight", family))
  if (identical(preset, "interaction")) {
    return(list(
      bg = "#0d0f13", fg = "#e6e8ec", surface = "#14171c",
      muted = "#9aa3b2", grid = "#262b33",
      border = "#292e37", code_bg = "#090b0e"
    ))
  }
  list(
    bg = "#13110e", fg = "#ece5d6", surface = "#1b1814",
    muted = "#aaa190", grid = "#2f2a23",
    border = "#37312a", code_bg = "#12100d"
  )
}

#' List available Albers directions
#'
#' Returns the two 2.0 directions: \code{"homage"} (warm cream ground, serif
#' body, light code) and \code{"interaction"} (cool grey ground, grotesk, dark
#' code). The legacy presets \code{"study"}, \code{"structural"},
#' \code{"adobe"}, and \code{"midnight"} are still accepted by
#' \code{\link{theme_albers}()} for backward compatibility but are no longer
#' featured.
#'
#' @return Character vector of direction names.
#' @export
#' @examples
#' albers_presets()
albers_presets <- function() {
  c("homage", "interaction")
}

#' Minimal, legible plot theme inspired by Josef Albers
#'
#' @param family Palette family used by companion scales.
#' @param preset Visual direction: \code{"homage"} (warm cream ground) or
#'   \code{"interaction"} (cool grey ground). Legacy presets \code{"study"},
#'   \code{"structural"}, \code{"adobe"}, and \code{"midnight"} are still
#'   accepted for backward compatibility.
#' @param base_size Base font size.
#' @param base_family Base font family. Plots fall back to the system "sans"
#'   stack; install the matching typefaces (Familjen Grotesk / Space Grotesk,
#'   etc.) and pass e.g. \code{base_family = "Familjen Grotesk"} for full fidelity.
#' @param bg Override background color. Defaults to the preset's surface
#'   (the vignette sheet), so figures sit on the page rather than in a box.
#' @param fg Override foreground/text color (default derived from preset).
#' @param grid_color Override grid line color (default derived from preset).
#' @param mode \code{"light"} (default) or \code{"dark"}: the direction's night
#'   ground and ink, matching the page's dark mode. [albers_vignette()] uses it
#'   to render a dark twin of each plot.
#' @return A \code{ggplot2} theme object.
#' @export
#' @examples
#' \donttest{
#' if (requireNamespace("ggplot2", quietly = TRUE)) {
#'   ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) +
#'     ggplot2::geom_point() + theme_albers()
#' }
#' }
theme_albers <- function(
  family = getOption("albersdown.family", "red"),
  preset = getOption("albersdown.preset", c("homage", "interaction", "study", "structural", "adobe", "midnight")),
  base_size = 13,
  base_family = NULL,
  bg = NULL,
  fg = NULL,
  grid_color = NULL,
  mode = c("light", "dark")
) {
  preset <- match.arg(preset, c("homage", "interaction", "study", "structural", "adobe", "midnight"))
  mode <- match.arg(mode)
  # When base_family is unset, use the direction's display font if it has been
  # registered via albers_register_fonts(); otherwise fall back to "sans".
  base_family <- base_family %||% .albers_direction_font(preset)
  pal <- albers_palette(family)
  colors <- if (identical(mode, "dark")) .preset_colors_night(preset, family) else .preset_colors(preset, family)

  bg <- bg %||% colors$surface
  fg <- fg %||% colors$fg
  grid_color <- grid_color %||% colors$grid
  muted <- colors$muted
  surface <- colors$surface
  strip_alpha <- if (preset == "midnight" || identical(mode, "dark")) 0.18 else 0.11
  strip_fill <- grDevices::adjustcolor(pal[["A300"]], alpha.f = strip_alpha)

  ggplot2::theme_minimal(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      plot.background = ggplot2::element_rect(fill = bg, colour = NA),
      panel.background = ggplot2::element_rect(fill = bg, colour = NA),
      panel.border = ggplot2::element_blank(),
      panel.grid.major = ggplot2::element_line(color = grid_color, linewidth = 0.35),
      panel.grid.minor = ggplot2::element_blank(),
      panel.spacing = grid::unit(14, "pt"),
      axis.line.x = ggplot2::element_line(color = fg, linewidth = 0.35),
      axis.line.y = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank(),
      axis.ticks.length = grid::unit(0, "pt"),
      plot.title = ggplot2::element_text(
        face = "bold", color = fg, size = ggplot2::rel(1.15),
        lineheight = 1.04,
        margin = ggplot2::margin(b = 4)
      ),
      plot.title.position = "plot",
      plot.subtitle = ggplot2::element_text(
        color = muted,
        lineheight = 1.2,
        margin = ggplot2::margin(b = 12)
      ),
      plot.caption = ggplot2::element_text(
        color = muted, hjust = 0, size = ggplot2::rel(0.85),
        margin = ggplot2::margin(t = 10)
      ),
      plot.caption.position = "plot",
      legend.position = "top",
      legend.justification = "left",
      legend.title = ggplot2::element_text(color = muted, size = ggplot2::rel(0.85)),
      legend.text = ggplot2::element_text(color = fg, size = ggplot2::rel(0.9)),
      legend.background = ggplot2::element_blank(),
      legend.box.background = ggplot2::element_blank(),
      legend.key = ggplot2::element_blank(),
      legend.key.width = grid::unit(12, "pt"),
      legend.key.height = grid::unit(12, "pt"),
      legend.margin = ggplot2::margin(0, 0, 4, 0),
      axis.title = ggplot2::element_text(color = muted, size = ggplot2::rel(0.9)),
      axis.title.x = ggplot2::element_text(margin = ggplot2::margin(t = 8)),
      axis.title.y = ggplot2::element_text(margin = ggplot2::margin(r = 8)),
      axis.text = ggplot2::element_text(color = muted, size = ggplot2::rel(0.9)),
      strip.background = ggplot2::element_rect(fill = strip_fill, colour = NA),
      strip.text = ggplot2::element_text(
        face = "bold",
        color = fg,
        hjust = 0,
        margin = ggplot2::margin(4, 6, 4, 6)
      ),
      plot.margin = ggplot2::margin(10, 14, 10, 6)
    ) +
    .albers_geom_defaults(ink = fg, paper = bg, accent = pal[["A700"]])
}

# ggplot2 >= 4.0 lets a theme set geom defaults: unmapped lines, points and
# text then use the page's ink and the family accent instead of pure black.
.albers_geom_defaults <- function(ink, paper, accent) {
  ns <- asNamespace("ggplot2")
  if (!exists("element_geom", envir = ns, inherits = FALSE)) return(NULL)
  ggplot2::theme(geom = get("element_geom", envir = ns)(ink = ink, paper = paper, accent = accent))
}

# Each family's "interaction" complement (see inst/tokens/albers-tokens.yml):
# `comp` for fills and marks, `comp_ink` / `comp_light` for text.
.albers_comp <- function(family) {
  switch(family,
    red    = c(comp = "#DE9D16", comp_ink = "#745004", comp_light = "#E5B568"),
    lapis  = c(comp = "#E69825", comp_ink = "#7A4D04", comp_light = "#EBB16C"),
    ochre  = c(comp = "#BA93FB", comp_ink = "#634590", comp_light = "#C8AEFA"),
    teal   = c(comp = "#F9875E", comp_ink = "#8E3B1C", comp_light = "#FBA587"),
    green  = c(comp = "#E28DAE", comp_ink = "#863A5B", comp_light = "#F6A0C1"),
    violet = c(comp = "#C9A90C", comp_ink = "#695701", comp_light = "#D4BD67")
  )
}

#' Discrete colours for a family
#'
#' The \code{"contrast"} set leads with the family's own tone and its
#' interaction complement -- the two colours of the title plate (red and gold
#' for the red family) -- then the complementary family (blue), the family at
#' another lightness, the complementary family at another lightness, and a
#' warm neutral. With \code{mode = "dark"} each slot keeps its hue (only its
#' lightness changes), so a category keeps its colour when the page switches
#' theme.
#' Adjacent levels differ in hue, so a two-group comparison is always legible. The \code{"family"} set is the single-hue A900-A300 ramp.
#'
#' @param family Palette family.
#' @param type \code{"contrast"} (default) or \code{"family"}.
#' @param mode \code{"light"} (default) or \code{"dark"}: lighter tones that
#'   hold up on the night ground (used for the dark twins of figures).
#' @return Character vector of hex colours.
#' @export
#' @examples
#' albers_discrete("red")
#' albers_discrete("teal", type = "family")
albers_discrete <- function(family = getOption("albersdown.family", "red"),
                            type = c("contrast", "family"),
                            mode = c("light", "dark")) {
  type <- match.arg(type)
  mode <- match.arg(mode)
  pal <- albers_palette(family)
  comp <- albers_palette(albers_complement(family))
  # Slot k has the same hue in light and dark, so a category keeps its colour
  # when the page switches theme: family, interaction complement, complement
  # family, family (other lightness), complement family (other lightness),
  # neutral.
  if (identical(mode, "dark")) {
    if (type == "family") return(unname(pal[c("A300", "A500", "A700", "A900")]))
    return(unname(c(
      pal[["A500"]], .albers_comp(family)[["comp"]], comp[["A300"]],
      .albers_tint(pal[["A300"]], 0.45), comp[["A500"]], "#B5AD9C"
    )))
  }
  if (type == "family") return(unname(pal[c("A900", "A700", "A500", "A300")]))
  unname(c(
    pal[["A700"]],
    .albers_mark_contrast(.albers_comp(family)[["comp"]]),
    comp[["A700"]],
    pal[["A900"]],
    comp[["A500"]],
    "#8C8474"
  ))
}

#' Scales that use the family's tones (discrete/continuous)
#'
#' Discrete scales use \code{\link{albers_discrete}()}: by default the
#' family's tone is paired with its Albers complement and ochre so adjacent
#' groups stay distinguishable. Use \code{type = "family"} for the single-hue
#' ramp. Continuous scales run from a light tint to the family's A900.
#'
#' @param family Palette family. Defaults to the `albersdown.family` option
#'   (set by [albers_vignette()] while a vignette renders), else `"red"`.
#' @param discrete Whether to use a discrete palette; if FALSE, uses a gradient.
#' @param type Discrete colour set, \code{"contrast"} (default) or
#'   \code{"family"}; see \code{\link{albers_discrete}()}.
#' @param ... Passed to underlying `ggplot2` scale.
#' @return A \code{ggplot2} scale object.
#' @export
#' @examples
#' \donttest{
#' if (requireNamespace("ggplot2", quietly = TRUE)) {
#'   ggplot2::ggplot(iris, ggplot2::aes(Sepal.Length, Sepal.Width,
#'     color = Species)) + ggplot2::geom_point() + scale_color_albers()
#' }
#' }
scale_color_albers <- function(family = getOption("albersdown.family", "red"), discrete = TRUE, type = c("contrast", "family"), ...) {
  type <- match.arg(type)
  pal <- albers_palette(family)
  sc <- if (discrete) ggplot2::scale_color_manual(values = albers_discrete(family, type), ...)
  else ggplot2::scale_color_gradient(low = .albers_tint(pal[["A300"]], 0.55), high = pal[["A900"]], ...)
  .albers_tag_scale(sc, family, type, discrete)
}

#' @rdname scale_color_albers
#' @export
scale_fill_albers <- function(family = getOption("albersdown.family", "red"), discrete = TRUE, type = c("contrast", "family"), ...) {
  type <- match.arg(type)
  pal <- albers_palette(family)
  sc <- if (discrete) ggplot2::scale_fill_manual(values = albers_discrete(family, type), ...)
  else ggplot2::scale_fill_gradient(low = .albers_tint(pal[["A300"]], 0.55), high = pal[["A900"]], ...)
  .albers_tag_scale(sc, family, type, discrete)
}

# Remember how an albersdown scale was made, so the dark twin of a figure can
# redraw it with night tones (see .albers_dark_twin()).
.albers_tag_scale <- function(sc, family, type, discrete) {
  tryCatch(sc$albers <- list(family = family, type = type, discrete = discrete), error = function(e) NULL)
  sc
}

# Palette function for the night version of a tagged scale.
.albers_night_palette <- function(tag) {
  if (isTRUE(tag$discrete)) {
    vals <- albers_discrete(tag$family, tag$type, mode = "dark")
    return(function(n) vals)
  }
  pal <- albers_palette(tag$family)
  ramp <- grDevices::colorRamp(c(grDevices::colorRampPalette(c(pal[["A900"]], "#1b1814"))(3)[2], pal[["A300"]]))
  function(x) {
    out <- rep(NA_character_, length(x))
    ok <- !is.na(x)
    if (any(ok)) {
      m <- ramp(pmin(pmax(x[ok], 0), 1))
      out[ok] <- grDevices::rgb(m[, 1], m[, 2], m[, 3], maxColorValue = 255)
    }
    out
  }
}

# Darken a colour in CIELAB lightness (hue and chroma kept) until it has at
# least `min` contrast against every light plot ground, the WCAG 1.4.11 level
# for graphical marks.
.albers_mark_contrast <- function(col, grounds = c("#fbf7ee", "#ffffff"), min = 3.2) {
  lum <- function(h) {
    v <- grDevices::col2rgb(h)[, 1] / 255
    v <- ifelse(v <= 0.04045, v / 12.92, ((v + 0.055) / 1.055)^2.4)
    sum(c(0.2126, 0.7152, 0.0722) * v)
  }
  ok <- function(h) all(vapply(grounds, function(g) {
    l <- sort(c(lum(h), lum(g)), decreasing = TRUE)
    (l[1] + 0.05) / (l[2] + 0.05) >= min
  }, logical(1)))
  lab <- grDevices::convertColor(t(grDevices::col2rgb(col) / 255), "sRGB", "Lab")
  while (!ok(col) && lab[1, 1] > 5) {
    lab[1, 1] <- lab[1, 1] - 1
    rgb <- pmin(pmax(grDevices::convertColor(lab, "Lab", "sRGB"), 0), 1)
    col <- grDevices::rgb(rgb[1, 1], rgb[1, 2], rgb[1, 3])
  }
  col
}

.albers_tint <- function(col, amount) {
  grDevices::colorRampPalette(c(col, "#ffffff"))(101)[round(amount * 100) + 1]
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
#' @return A \code{ggplot2} scale object.
#' @export
#' @examples
#' \donttest{
#' if (requireNamespace("ggplot2", quietly = TRUE)) {
#'   df <- data.frame(x = 1:6, y = 1:6, g = paste0("G", 1:6))
#'   ggplot2::ggplot(df, ggplot2::aes(x, y, color = g)) +
#'     ggplot2::geom_point() + scale_color_albers_distinct()
#' }
#' }
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
#' @return A \code{ggplot2} scale object.
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
#' @return A \code{ggplot2} scale object.
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
#' @return A \code{ggplot2} scale object.
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
#' @return A \code{ggplot2} scale object.
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
#' @return A \code{ggplot2} scale object.
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
#' @return A \code{ggplot2} scale object.
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
#' @return A \code{ggplot2} scale object.
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
#' @return A \code{ggplot2} scale object.
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
#' @return A \code{ggplot2} scale object.
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
#' @return A \code{ggplot2} theme object.
#' @export
theme_albers_void <- function(
  family = "red",
  preset = c("homage", "interaction", "study", "structural", "adobe", "midnight"),
  base_size = 13,
  base_family = NULL,
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
#' @examples
#' albers_ramp("lapis", n = 5)
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
#' @examples
#' \donttest{
#' if (requireNamespace("ggplot2", quietly = TRUE)) {
#'   albers_swatch()
#' }
#' }
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
