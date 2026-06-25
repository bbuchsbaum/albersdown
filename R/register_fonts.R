#' Register the bundled Albers display fonts for R graphics
#'
#' albersdown ships static TTF builds of Familjen Grotesk (the Homage display
#' face) and Space Grotesk (the Interaction display face) so that ggplot2 plots
#' can use the same typefaces as the rendered HTML pages. Call this once per
#' session -- for example in a vignette setup chunk -- before [theme_albers()].
#' Once the fonts are registered, `theme_albers()` picks the direction's display
#' font automatically (Homage -> Familjen Grotesk, Interaction -> Space Grotesk).
#'
#' Requires the \pkg{systemfonts} package and a font-aware graphics device such
#' as \pkg{ragg} (e.g. `knitr::opts_chunk$set(dev = "ragg_png")`). Without those,
#' plots fall back to the system `"sans"` family, so package examples and CRAN
#' checks never depend on the bundled fonts.
#'
#' @return Invisibly, a character vector of the font families that were
#'   registered (empty if \pkg{systemfonts} is unavailable or the files are
#'   missing).
#' @export
#' @examples
#' \donttest{
#' if (requireNamespace("systemfonts", quietly = TRUE)) {
#'   albers_register_fonts()
#' }
#' }
albers_register_fonts <- function() {
  if (!requireNamespace("systemfonts", quietly = TRUE)) {
    return(invisible(character(0)))
  }
  specs <- list(
    "Familjen Grotesk" = c("FamiljenGrotesk-Regular.ttf", "FamiljenGrotesk-Bold.ttf"),
    "Space Grotesk" = c("SpaceGrotesk-Regular.ttf", "SpaceGrotesk-Bold.ttf")
  )
  registered <- character(0)
  for (fam in names(specs)) {
    files <- specs[[fam]]
    plain <- .albers_font_path(files[[1]])
    bold <- .albers_font_path(files[[2]])
    if (!nzchar(plain) || !file.exists(plain)) next
    systemfonts::register_font(
      name = fam,
      plain = plain,
      bold = if (nzchar(bold) && file.exists(bold)) bold else plain
    )
    registered <- c(registered, fam)
  }
  invisible(registered)
}

#' @keywords internal
.albers_font_path <- function(file) {
  local <- file.path("inst", "fonts", "ttf", file)
  if (file.exists(local)) {
    return(local)
  }
  system.file("fonts", "ttf", file, package = "albersdown")
}

#' Is a font family available to R graphics (registered or system-installed)?
#' @keywords internal
.albers_font_available <- function(family) {
  if (!requireNamespace("systemfonts", quietly = TRUE)) {
    return(FALSE)
  }
  reg <- tryCatch(systemfonts::registry_fonts()$family, error = function(e) NULL)
  sys <- tryCatch(systemfonts::system_fonts()$family, error = function(e) NULL)
  family %in% c(reg, sys)
}

#' Display font for a direction, falling back to "sans" when not registered.
#' @keywords internal
.albers_direction_font <- function(preset) {
  want <- switch(preset,
    homage = "Familjen Grotesk",
    interaction = "Space Grotesk",
    "Space Grotesk"
  )
  if (.albers_font_available(want)) want else "sans"
}
