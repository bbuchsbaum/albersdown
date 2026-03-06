#!/usr/bin/env Rscript

if (!requireNamespace("yaml", quietly = TRUE)) {
  stop("Package 'yaml' is required. Install it with install.packages('yaml').", call. = FALSE)
}

hex_to_rgb <- function(hex) {
  x <- trimws(hex)
  if (grepl("^#[0-9A-Fa-f]{3}$", x)) x <- paste0("#", paste(rep(substring(x, 2, 4), each = 2), collapse = ""))
  if (!grepl("^#[0-9A-Fa-f]{6}$", x)) return(NULL)
  as.numeric(grDevices::col2rgb(x)) / 255
}

linear_channel <- function(u) ifelse(u <= 0.03928, u / 12.92, ((u + 0.055) / 1.055)^2.4)

relative_luminance <- function(hex) {
  rgb <- hex_to_rgb(hex)
  if (is.null(rgb)) return(NA_real_)
  lin <- linear_channel(rgb)
  0.2126 * lin[1] + 0.7152 * lin[2] + 0.0722 * lin[3]
}

contrast_ratio <- function(fg, bg) {
  lf <- relative_luminance(fg)
  lb <- relative_luminance(bg)
  if (any(is.na(c(lf, lb)))) return(NA_real_)
  l1 <- max(lf, lb)
  l2 <- min(lf, lb)
  (l1 + 0.05) / (l2 + 0.05)
}

tokens <- yaml::read_yaml("inst/tokens/albers-tokens.yml")
min_ratio <- 4.5

presets <- list(
  homage = list(bg = "#f3f5f7", ink = "#17181a"),
  study = list(bg = "#f7f9fb", ink = "#17181a"),
  structural = list(bg = "#e6e9ed", ink = "#101214"),
  adobe = list(bg = "#ece9e7", ink = "#1f1c19"),
  midnight = list(bg = "#0d1117", ink = "#e8e6e1")
)

rows <- list()

for (p in names(presets)) {
  rows[[length(rows) + 1L]] <- data.frame(
    check = paste0("body-light-", p),
    ratio = contrast_ratio(presets[[p]]$ink, presets[[p]]$bg),
    stringsAsFactors = FALSE
  )
}

for (f in names(tokens$families)) {
  fam <- tokens$families[[f]]
  for (p in names(presets)) {
    link_fg <- if (identical(p, "midnight")) fam$dark$accent_ink else fam$A900
    rows[[length(rows) + 1L]] <- data.frame(
      check = paste0("link-light-", f, "-", p),
      ratio = contrast_ratio(link_fg, presets[[p]]$bg),
      stringsAsFactors = FALSE
    )
  }

  rows[[length(rows) + 1L]] <- data.frame(
    check = paste0("link-dark-", f),
    ratio = contrast_ratio(fam$dark$accent_ink, "#111315"),
    stringsAsFactors = FALSE
  )
}

rows[[length(rows) + 1L]] <- data.frame(
  check = "body-dark-default",
  ratio = contrast_ratio("#ece8de", "#111315"),
  stringsAsFactors = FALSE
)

report <- do.call(rbind, rows)
report$pass <- !is.na(report$ratio) & report$ratio >= min_ratio

cat(sprintf("Checked %d contrast combinations\n", nrow(report)))
cat(sprintf("Minimum ratio: %.2f\n", min(report$ratio, na.rm = TRUE)))

fails <- report[!report$pass, , drop = FALSE]
if (nrow(fails)) {
  cat("\nFailures (ratio < 4.5):\n")
  print(fails, row.names = FALSE)
  quit(status = 1)
}

cat("All checks passed.\n")
