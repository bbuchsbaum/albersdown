#' One-command migration to latest albersdown
#'
#' Convenience helper for existing packages that already use albersdown and
#' need to replace older vignette/site wiring with the latest defaults.
#'
#' @param family one of: "red","lapis","ochre","teal","green","violet"
#' @param dry_run if TRUE, report changes without writing files.
#' @export
migrate_albersdown <- function(family = "red", dry_run = FALSE) {
  use_albersdown(
    family = family,
    apply_to = "all",
    dry_run = dry_run,
    fallback_extra = "always",
    force_replace = TRUE
  )
}
