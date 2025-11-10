#' bs_theme for pkgdown (light/dark aware)
#'
#' Convenience wrapper exposing core variables; most consumers won't need this
#' directly if they use `template: { package: albersdown }`.
#' @export
albers_bs_theme <- function(accent = "#1f6feb", bg = "#ffffff", fg = "#111111") {
  bslib::bs_theme(
    version = 5,
    bg = bg, fg = fg, primary = accent, secondary = "#6b7280",
    base_font = bslib::font_collection("system-ui"),
    heading_font = bslib::font_collection("system-ui"),
    code_font = bslib::font_collection("ui-monospace")
  )
}

