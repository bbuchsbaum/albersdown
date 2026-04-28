#' Configure current package to use albersdown (back-compat wrapper)
#'
#' This wrapper preserves the old name and forwards to `use_albersdown()`.
#' @param path Path to the package directory. Defaults to the current working
#'   directory to preserve the original wrapper behavior.
#' @param ... Additional arguments passed to [use_albersdown()].
#' @return \code{TRUE} invisibly.
#' @export
#' @examples
#' \donttest{
#' if (interactive()) {
#'   use_albers_vignettes()
#' }
#' }
use_albers_vignettes <- function(path = ".", ...) {
  args <- list(...)
  if (is.null(args$apply_to)) args$apply_to <- "new"
  if (is.null(args$dry_run)) args$dry_run <- FALSE
  do.call(use_albersdown, c(list(path = path), args))
}
