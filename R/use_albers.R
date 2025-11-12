#' Configure current package to use albersdown (back-compat wrapper)
#'
#' This wrapper preserves the old name and forwards to `use_albersdown()`.
#' @export
use_albers_vignettes <- function() {
  use_albersdown(apply_to = "new", dry_run = FALSE)
}
