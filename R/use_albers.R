#' Configure current package to use albersdown
#'
#' - Copies vignette CSS if missing
#' - Suggests helper packages
#' - Adds pkgdown template stanza to `_pkgdown.yml`
#' @export
use_albers_vignettes <- function() {
  if (requireNamespace("usethis", quietly = TRUE)) {
    usethis::use_package("ggplot2", type = "Suggests")
    usethis::use_package("gt", type = "Suggests")
  }

  dir.create("vignettes", showWarnings = FALSE)
  css_src <- system.file(
    "rmarkdown/templates/albers_vignette/skeleton/albers.css",
    package = "albersdown"
  )
  css_dst <- file.path("vignettes", "albers.css")
  if (file.exists(css_src) && !file.exists(css_dst)) {
    file.copy(css_src, css_dst, overwrite = FALSE)
    message("✓ Copied vignettes/albers.css")
  }

  yml_path <- "_pkgdown.yml"
  if (file.exists(yml_path)) {
    y <- readLines(yml_path, warn = FALSE)
    if (!any(grepl("^template:\\s*$", y))) {
      cat("\n# Albers theme\n", file = yml_path, append = TRUE)
      cat("template:\n  package: albersdown\n", file = yml_path, append = TRUE)
      message("✓ Added pkgdown template stanza")
    } else if (!any(grepl("package:\\s*albersdown", y))) {
      cat("\n  package: albersdown\n", file = yml_path, append = TRUE)
      message("✓ Appended albersdown package to template stanza")
    } else {
      message("i _pkgdown.yml already references albersdown; no change.")
    }
  } else {
    writeLines("template:\n  package: albersdown\n", yml_path)
    message("✓ Created _pkgdown.yml with template stanza")
  }

  invisible(TRUE)
}
