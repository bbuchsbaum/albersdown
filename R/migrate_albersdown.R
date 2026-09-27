#' One-command migration to latest albersdown
#'
#' Convenience helper for existing packages that already use the vendored
#' albersdown setup (copied `albers.css`/`albers.js` in `vignettes/`) and need
#' to refresh it with the latest assets while choosing an Albers accent family
#' and preset. To move to the output format instead, use
#' `use_albersdown(path, method = "format")`.
#'
#' @param path Path to the package directory.  Must be supplied explicitly;
#'   there is no default so that the function never writes to an unexpected
#'   location.
#' @param family,preset As in [use_albersdown()]: if not given, the package's
#'   current family and direction are kept.
#' @param dry_run if TRUE, report changes without writing files.
#' @return \code{TRUE} invisibly.
#' @export
#' @examples
#' \donttest{
#' if (interactive()) {
#'   migrate_albersdown(path = ".", family = "teal", preset = "midnight", dry_run = TRUE)
#' }
#' }
migrate_albersdown <- function(
  path,
  family = "red",
  preset = c("homage", "interaction", "study", "structural", "adobe", "midnight"),
  dry_run = FALSE
) {
  args <- list(
    path = path,
    apply_to = "all",
    dry_run = dry_run,
    fallback_extra = "always",
    force_replace = TRUE,
    method = "vendor",
    readme = TRUE
  )
  # family/preset not given: use_albersdown() keeps the package's own
  if (!missing(family)) args$family <- family
  if (!missing(preset)) args$preset <- preset
  do.call(use_albersdown, args)
}
