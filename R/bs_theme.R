#' bs_theme for pkgdown (light/dark aware)
#'
#' Convenience wrapper exposing core variables; most consumers won't need this
#' directly if they use `template: { package: albersdown }`.
#'
#' @param family Palette family name (default \code{"red"}).
#' @param preset Visual preset (default \code{"homage"}). See [albers_presets()].
#' @param accent Primary accent color (default A700 of the chosen family).
#' @param bg Background color (default derived from preset).
#' @param fg Foreground/text color (default derived from preset).
#' @export
albers_bs_theme <- function(
  family = "red",
  preset = c("homage", "study", "structural", "adobe", "midnight"),
  accent = NULL,
  bg = NULL,
  fg = NULL
) {
  preset <- match.arg(preset)
  pal <- albers_palette(family)
  colors <- .preset_colors(preset)

  accent <- accent %||% pal[["A700"]]
  bg <- bg %||% colors$bg
  fg <- fg %||% colors$fg

  bslib::bs_theme(
    version = 5,
    bg = bg,
    fg = fg,
    primary = accent,
    secondary = colors$muted,
    base_font = bslib::font_collection("Avenir Next", "Gill Sans", "system-ui"),
    heading_font = bslib::font_collection("Avenir Next", "Gill Sans", "system-ui"),
    code_font = bslib::font_collection(
      "ui-monospace", "SFMono-Regular", "Menlo", "Consolas", "monospace"
    ),
    `enable-rounded` = FALSE,
    `enable-shadows` = FALSE,
    `border-radius` = "0",
    `border-radius-sm` = "0",
    `border-radius-lg` = "0",
    `headings-font-weight` = 700,
    `font-size-base` = "1.05rem",
    `body-secondary-color` = colors$muted,
    `body-tertiary-bg` = colors$surface,
    `border-color` = colors$border,
    `code-bg` = colors$code_bg
  )
}
