#!/usr/bin/env Rscript

if (!requireNamespace("yaml", quietly = TRUE)) {
  stop("Package 'yaml' is required. Install it with install.packages('yaml').", call. = FALSE)
}

trim <- function(x) sub("^\\s+|\\s+$", "", x)

read_tokens <- function(path = "inst/tokens/albers-tokens.yml") {
  if (!file.exists(path)) stop("Token file not found: ", path, call. = FALSE)
  yaml::read_yaml(path)
}

marker_line <- function(marker, kind = c("START", "END")) {
  kind <- match.arg(kind)
  sprintf("/* %s_%s */", marker, kind)
}

replace_marker_block <- function(lines, marker, content_lines) {
  start_line <- marker_line(marker, "START")
  end_line <- marker_line(marker, "END")
  s <- which(trim(lines) == start_line)
  e <- which(trim(lines) == end_line)
  if (length(s) != 1 || length(e) != 1 || e <= s) {
    stop("Could not locate marker block: ", marker, call. = FALSE)
  }
  c(
    lines[seq_len(s)],
    content_lines,
    lines[e:length(lines)]
  )
}

render_family_block <- function(name, spec) {
  out <- c(sprintf(".palette-%s {", name))
  out <- c(out, sprintf("  --A900: %s;", spec$A900))
  out <- c(out, sprintf("  --A700: %s;", spec$A700))
  out <- c(out, sprintf("  --A500: %s;", spec$A500))
  out <- c(out, sprintf("  --A300: %s;", spec$A300))
  if (!is.null(spec$accent_ink_dark)) out <- c(out, sprintf("  --accent-ink-dark: %s;", spec$accent_ink_dark))
  out <- c(out, sprintf("  --accent-hover: %s;", spec$accent_hover))
  out <- c(out, sprintf("  --accent-tint: %s;", spec$accent_tint))
  out <- c(out, sprintf("  --accent-band: %s;", spec$accent_band))
  c(out, "}")
}

render_families <- function(tokens) {
  fams <- names(tokens$families)
  unlist(lapply(seq_along(fams), function(i) {
    blk <- render_family_block(fams[[i]], tokens$families[[fams[[i]]]])
    if (i < length(fams)) c(blk, "") else blk
  }))
}

render_preset_block <- function(name, spec, typography) {
  pretty <- paste(toupper(substring(name, 1, 1)), substring(name, 2), sep = "")
  out <- c(sprintf("/* %s preset */", pretty))
  out <- c(out, sprintf(".preset-%s {", name))
  keys <- c("bg", "surface", "surface_strong", "ink", "muted", "border", "code_bg", "shadow_soft", "shadow_card")
  css_names <- c(
    bg = "--bg", surface = "--surface", surface_strong = "--surface-strong",
    ink = "--ink", muted = "--muted", border = "--border", code_bg = "--code-bg",
    shadow_soft = "--shadow-soft", shadow_card = "--shadow-card"
  )
  for (k in keys) {
    v <- spec[[k]]
    if (!is.null(v)) out <- c(out, sprintf("  %s: %s;", css_names[[k]], v))
  }
  if (!is.null(typography$display)) out <- c(out, sprintf("  --font-display: %s;", typography$display))
  if (!is.null(typography$heading_weight)) out <- c(out, sprintf("  --heading-weight: %s;", typography$heading_weight))
  if (identical(name, "midnight")) {
    out <- c(
      out,
      "  --accent-ink: var(--accent-ink-dark);"
    )
  }
  c(out, "}")
}

render_presets <- function(tokens) {
  pnames <- names(tokens$presets)
  unlist(lapply(seq_along(pnames), function(i) {
    p <- pnames[[i]]
    typ <- tokens$preset_typography[[p]]
    blk <- render_preset_block(p, tokens$presets[[p]], typ)
    if (i < length(pnames)) c(blk, "") else blk
  }))
}

render_dark_families <- function(tokens) {
  fams <- names(tokens$families)

  bootstrap_blocks <- unlist(lapply(seq_along(fams), function(i) {
    name <- fams[[i]]
    dark <- tokens$families[[name]]$dark
    blk <- c(
      sprintf("body[data-bs-theme=\"dark\"].palette-%s,", name),
      sprintf("[data-bs-theme=\"dark\"] body.palette-%s {", name),
      sprintf("  --accent-ink: %s;", dark$accent_ink),
      sprintf("  --accent-hover: %s;", dark$accent_hover),
      sprintf("  --accent-tint: %s;", dark$accent_tint),
      sprintf("  --accent-band: %s;", dark$accent_band),
      "}"
    )
    if (i < length(fams)) c(blk, "") else blk
  }))

  media_blocks <- unlist(lapply(seq_along(fams), function(i) {
    name <- fams[[i]]
    dark <- tokens$families[[name]]$dark
    blk <- c(
      sprintf("  body.palette-%s {", name),
      sprintf("    --accent-ink: %s;", dark$accent_ink),
      sprintf("    --accent-hover: %s;", dark$accent_hover),
      sprintf("    --accent-tint: %s;", dark$accent_tint),
      sprintf("    --accent-band: %s;", dark$accent_band),
      "  }"
    )
    if (i < length(fams)) c(blk, "") else blk
  }))

  c(
    bootstrap_blocks,
    "",
    "@media (prefers-color-scheme: dark) {",
    media_blocks,
    "}"
  )
}

write_if_changed <- function(path, lines) {
  old <- if (file.exists(path)) readLines(path, warn = FALSE) else character()
  if (!identical(old, lines)) {
    writeLines(lines, path, useBytes = TRUE)
    message("Updated: ", path)
  } else {
    message("Unchanged: ", path)
  }
}

sync_css <- function() {
  tokens <- read_tokens()
  canonical <- "inst/pkgdown/assets/albers.css"
  lines <- readLines(canonical, warn = FALSE)
  lines <- replace_marker_block(lines, "ALBERS_TOKENS_FAMILIES", render_families(tokens))
  lines <- replace_marker_block(lines, "ALBERS_TOKENS_PRESETS", render_presets(tokens))
  lines <- replace_marker_block(lines, "ALBERS_TOKENS_DARK_FAMILIES", render_dark_families(tokens))
  write_if_changed(canonical, lines)

  targets <- c(
    "inst/rmarkdown/templates/albers_vignette/skeleton/albers.css",
    "vignettes/albers.css",
    "examples/albersdemo/vignettes/albers.css",
    "pkgdown/extra.css"
  )

  for (target in targets) write_if_changed(target, lines)

  js_source <- "inst/pkgdown/assets/albers.js"
  if (file.exists(js_source)) {
    js_lines <- readLines(js_source, warn = FALSE)
    for (target in c("vignettes/albers.js", "pkgdown/extra.js")) {
      write_if_changed(target, js_lines)
    }
  }
}

sync_css()
