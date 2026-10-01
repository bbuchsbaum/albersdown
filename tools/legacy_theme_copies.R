# Regenerate inst/legacy/theme-copies.txt: the fingerprints of every theme
# stylesheet and script albersdown has shipped, so use_albersdown() can
# recognise an old copy in a package's pkgdown/extra.css or extra.js and
# retire it. Run from the package root after a release that changes
# albers.css or albers.js:
#
#   Rscript tools/legacy_theme_copies.R

source("R/use_albersdown_format.R", local = (env <- new.env()))
fingerprint <- env$.albers_theme_fingerprint

objects <- system2("git", c("rev-list", "--all", "--objects"), stdout = TRUE)
objects <- strsplit(objects, " ", fixed = TRUE)
objects <- Filter(function(o) length(o) == 2, objects)
theme_files <- c("albers.css", "albers.js", "extra.css", "extra.js")
blobs <- unique(vapply(Filter(function(o) basename(o[2]) %in% theme_files, objects), `[`, "", 1))

prints <- vapply(blobs, function(sha) {
  lines <- system2("git", c("cat-file", "blob", sha), stdout = TRUE)
  # short files (a defaults line, the 2.0 @import) are handled by name, and a
  # fingerprint of a near-empty file could match a user's own
  if (length(lines) < 20) NA_character_ else fingerprint(lines)
}, "")
prints <- sort(unique(prints[!is.na(prints)]))

dir.create("inst/legacy", showWarnings = FALSE)
writeLines(prints, "inst/legacy/theme-copies.txt")
message(sprintf("%d fingerprints from %d theme blobs", length(prints), length(blobs)))
