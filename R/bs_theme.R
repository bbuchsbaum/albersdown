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
#' @return A \code{bslib::bs_theme} object.
#' @export
#' @examples
#' \donttest{
#' if (requireNamespace("bslib", quietly = TRUE)) {
#'   albers_bs_theme()
#' }
#' }
albers_bs_theme <- function(
  family = "red",
  preset = c("homage", "interaction", "study", "structural", "adobe", "midnight"),
  accent = NULL,
  bg = NULL,
  fg = NULL
) {

  if (!requireNamespace("bslib", quietly = TRUE)) {
    stop("Package 'bslib' is required for albers_bs_theme(). ",
         "Install it with install.packages(\"bslib\").", call. = FALSE)
  }

  preset <- match.arg(preset)
  pal <- albers_palette(family)
  colors <- .preset_colors(preset, family)

  accent <- accent %||% pal[["A700"]]
  bg <- bg %||% colors$bg
  fg <- fg %||% colors$fg

  # Per-direction type pairing. The actual webfonts are delivered offline by
  # albers.css (@font-face); these collections just name the families so bslib
  # wires them, with system fallbacks when the fonts are unavailable.
  fonts <- if (identical(preset, "interaction")) {
    list(
      base = c("Hanken Grotesk", "system-ui", "-apple-system", "sans-serif"),
      head = c("Space Grotesk", "system-ui", "sans-serif"),
      code = c("JetBrains Mono", "ui-monospace", "SFMono-Regular", "Menlo", "monospace")
    )
  } else {
    list(
      base = c("Newsreader", "Georgia", "Times New Roman", "serif"),
      head = c("Familjen Grotesk", "system-ui", "-apple-system", "sans-serif"),
      code = c("Spline Sans Mono", "ui-monospace", "SFMono-Regular", "Menlo", "monospace")
    )
  }

  bslib::bs_theme(
    version = 5,
    bg = bg,
    fg = fg,
    primary = accent,
    secondary = colors$muted,
    base_font = do.call(bslib::font_collection, as.list(fonts$base)),
    heading_font = do.call(bslib::font_collection, as.list(fonts$head)),
    code_font = do.call(bslib::font_collection, as.list(fonts$code)),
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
