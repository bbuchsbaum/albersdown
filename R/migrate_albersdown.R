#' One-command migration to latest albersdown
#'
#' Convenience helper for existing packages that already use albersdown and
#' need to replace older vignette/site wiring with the latest defaults while
#' choosing an Albers accent family and preset.
#'
#' @param family one of: "red","lapis","ochre","teal","green","violet"
#' @param preset Visual preset (default \code{"homage"}). See [albers_presets()].
#' @param dry_run if TRUE, report changes without writing files.
#' @return \code{TRUE} invisibly.
#' @export
#' @examples
#' \donttest{
#' if (interactive()) {
#'   migrate_albersdown(family = "teal", preset = "midnight", dry_run = TRUE)
#' }
#' }
migrate_albersdown <- function(
  family = "red",
  preset = c("homage", "study", "structural", "adobe", "midnight"),
  dry_run = FALSE
) {
  use_albersdown(
    family = family,
    preset = preset,
    apply_to = "all",
    dry_run = dry_run,
    fallback_extra = "always",
    force_replace = TRUE
  )
}
