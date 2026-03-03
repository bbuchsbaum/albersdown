#' Configure current package to use albersdown (back-compat wrapper)
#'
#' This wrapper preserves the old name and forwards to `use_albersdown()`.
#' @return \code{TRUE} invisibly.
#' @export
#' @examples
#' \donttest{
#' if (interactive()) {
#'   use_albers_vignettes()
#' }
#' }
use_albers_vignettes <- function() {
  use_albersdown(apply_to = "new", dry_run = FALSE)
}
