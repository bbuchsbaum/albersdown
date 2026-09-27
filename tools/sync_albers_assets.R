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
  # the family's "interaction" complement: plate/band colour, and text-weight
  # versions for code strings on light and dark grounds
  if (!is.null(spec$comp)) out <- c(out, sprintf("  --comp: %s;", spec$comp))
  if (!is.null(spec$comp_ink)) out <- c(out, sprintf("  --comp-ink: %s;", spec$comp_ink))
  if (!is.null(spec$comp_light)) out <- c(out, sprintf("  --comp-light: %s;", spec$comp_light))
  if (!is.null(spec$comp_deep)) out <- c(out, sprintf("  --comp-deep: %s;", spec$comp_deep))
  # code literals: numbers on the third hue (opposite the family/complement
  # pair), for light and dark code grounds; strings on dark grounds
  if (!is.null(spec$code_num)) out <- c(out, sprintf("  --code-num: %s;", spec$code_num))
  if (!is.null(spec$code_num_light)) out <- c(out, sprintf("  --code-num-light: %s;", spec$code_num_light))
  if (!is.null(spec$code_str_light)) out <- c(out, sprintf("  --code-str-light: %s;", spec$code_str_light))
  # Homage at night (warm, lamplit): functions a warm family tone and the
  # brightest role, strings the deep complement, numbers the third hue muted
  # beneath the functions, where Interaction's cool slab keeps pale tints
  if (!is.null(spec$code_fun_warm)) out <- c(out, sprintf("  --code-fun-warm: %s;", spec$code_fun_warm))
  if (!is.null(spec$code_str_warm)) out <- c(out, sprintf("  --code-str-warm: %s;", spec$code_str_warm))
  if (!is.null(spec$code_num_warm)) out <- c(out, sprintf("  --code-num-warm: %s;", spec$code_num_warm))
  # Midnight: the chord of the family's own plate on its ink ground --
  # functions the light family ring, numbers the deeper family ring (a
  # lightness step, not a third hue), strings the complement
  if (!is.null(spec$code_fun_night)) out <- c(out, sprintf("  --code-fun-night: %s;", spec$code_fun_night))
  if (!is.null(spec$code_str_night)) out <- c(out, sprintf("  --code-str-night: %s;", spec$code_str_night))
  if (!is.null(spec$code_num_night)) out <- c(out, sprintf("  --code-num-night: %s;", spec$code_num_night))
  c(out, "}")
}

render_families <- function(tokens) {
  fams <- names(tokens$families)
  unlist(lapply(seq_along(fams), function(i) {
    blk <- render_family_block(fams[[i]], tokens$families[[fams[[i]]]])
    if (i < length(fams)) c(blk, "") else blk
  }))
}

# Every key in a preset spec becomes a custom property: snake_case -> --kebab-case.
# `comment` becomes the block's leading comment; `color_scheme` maps to the
# `color-scheme` property (not a custom property).
render_preset_block <- function(name, spec) {
  pretty <- paste(toupper(substring(name, 1, 1)), substring(name, 2), sep = "")
  comment <- spec$comment %||% sprintf("%s preset", pretty)
  out <- c(sprintf("/* %s */", comment), sprintf(".preset-%s {", name))
  for (k in setdiff(names(spec), "comment")) {
    v <- spec[[k]]
    prop <- if (identical(k, "color_scheme")) "color-scheme" else paste0("--", gsub("_", "-", k))
    out <- c(out, sprintf("  %s: %s;", prop, v))
  }
  c(out, "}")
}

`%||%` <- function(a, b) if (is.null(a)) b else a

render_presets <- function(tokens) {
  pnames <- names(tokens$presets)
  unlist(lapply(seq_along(pnames), function(i) {
    p <- pnames[[i]]
    blk <- render_preset_block(p, tokens$presets[[p]])
    if (i < length(pnames)) c(blk, "") else blk
  }))
}

# Mix a token value that is color-mix(in oklab, var(--A900) N%, #hex) for one
# family, in OKLab as the browser does; a plain hex passes through.
oklab_mix <- function(value, fam) {
  m <- regmatches(value, regexec("^color-mix\\(in oklab, *var\\(--(A[0-9]+)\\) +([0-9.]+)%, *(#[0-9A-Fa-f]{6})\\)$", trimws(value)))[[1]]
  if (length(m) != 4) return(value)
  lin <- function(u) ifelse(u <= 0.04045, u / 12.92, ((u + 0.055) / 1.055)^2.4)
  gam <- function(u) ifelse(u <= 0.0031308, 12.92 * u, 1.055 * u^(1 / 2.4) - 0.055)
  m1 <- matrix(c(0.4122214708, 0.5363325363, 0.0514459929,
                 0.2119034982, 0.6806995451, 0.1073969566,
                 0.0883024619, 0.2817188376, 0.6299787005), 3, byrow = TRUE)
  m2 <- matrix(c(0.2104542553, 0.7936177850, -0.0040720468,
                 1.9779984951, -2.4285922050, 0.4505937099,
                 0.0259040371, 0.7827717662, -0.8086757660), 3, byrow = TRUE)
  ok <- function(h) as.numeric(m2 %*% (m1 %*% lin(as.numeric(grDevices::col2rgb(h)) / 255))^(1 / 3))
  w <- as.numeric(m[3]) / 100
  lab <- w * ok(fam[[m[2]]]) + (1 - w) * ok(m[4])
  rgb <- as.numeric(solve(m1) %*% (solve(m2) %*% lab)^3)
  tolower(grDevices::rgb(t(gam(pmin(pmax(rgb, 0), 1)))))
}

# Dark accents follow the resolved theme (html[data-albers-theme], stamped by
# albers.js, or pkgdown's html[data-bs-theme]) and the always-dark midnight preset.
# <html> cannot see the family class, so each family also mirrors its midnight
# ground onto it (resolved here, since var(--A900) on <html> is the default red).
render_dark_families <- function(tokens) {
  fams <- names(tokens$families)
  midnight_bg <- tokens$presets$midnight$bg
  unlist(lapply(seq_along(fams), function(i) {
    name <- fams[[i]]
    dark <- tokens$families[[name]]$dark
    mirror <- if (is.null(midnight_bg)) character() else
      sprintf("html:has(body.preset-midnight.palette-%s) { --bg: %s; }", name, oklab_mix(midnight_bg, tokens$families[[name]]))
    blk <- c(mirror,
      sprintf("html[data-albers-theme=\"dark\"] body.palette-%s,", name),
      sprintf("html[data-bs-theme=\"dark\"] body.palette-%s,", name),
      sprintf("body.preset-midnight.palette-%s {", name),
      sprintf("  --accent-ink: %s;", dark$accent_ink),
      sprintf("  --accent-hover: %s;", dark$accent_hover),
      sprintf("  --accent-tint: %s;", dark$accent_tint),
      sprintf("  --accent-band: %s;", dark$accent_band),
      "}"
    )
    if (i < length(fams)) c(blk, "") else blk
  }))
}

write_if_changed <- function(path, lines) {
  old <- if (file.exists(path)) readLines(path, warn = FALSE) else character()
  # compare as text: generated blocks may hold several lines in one element
  if (!identical(paste(old, collapse = "\n"), paste(lines, collapse = "\n"))) {
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
    "examples/albersdemo/vignettes/albers.css"
  )
  for (target in targets) write_if_changed(target, lines)

  # albers_vignette() assets: the stylesheet without @font-face, plus one
  # font file per direction so a vignette embeds only the faces it uses.
  dir.create("inst/format", showWarnings = FALSE)
  is_face <- grepl("^@font-face", lines)
  # the core (no @font-face) is only an intermediate: the format ships the
  # minified copy
  core <- lines[!is_face]
  faces <- sub('url\\("fonts/', 'url("../fonts/', lines[is_face])
  # (each direction's web faces and their metric-matched local fallbacks)
  homage <- c("Newsreader", "Newsreader Fallback", "Familjen Grotesk", "Familjen Grotesk Fallback", "Spline Sans Mono")
  interaction <- c("Hanken Grotesk", "Hanken Grotesk Fallback", "Space Grotesk", "Space Grotesk Fallback", "JetBrains Mono")
  pick <- function(fams) faces[vapply(faces, function(f) any(vapply(fams, function(x) grepl(sprintf('"%s"', x), f, fixed = TRUE), logical(1))), logical(1))]
  write_if_changed("inst/format/albers-fonts-homage.css", pick(homage))
  write_if_changed("inst/format/albers-fonts-interaction.css", pick(interaction))

  # Minified copies for albers_vignette(), which embeds them in every page:
  # CSS comments and runs of whitespace go; the JS loses full-line comments
  # and indentation (string contents are untouched).
  css <- paste(core, collapse = "\n")
  css <- gsub("(?s)/\\*.*?\\*/", "", css, perl = TRUE)
  css <- gsub("\\s+", " ", css, perl = TRUE)
  css <- gsub("\\s*([{};,>])\\s*", "\\1", css, perl = TRUE)
  css <- gsub(";}", "}", css, fixed = TRUE)
  write_if_changed("inst/format/albers-core.min.css", css)

  js_source <- "inst/pkgdown/assets/albers.js"
  if (file.exists(js_source)) {
    js_lines <- readLines(js_source, warn = FALSE)
    js_min <- js_lines
    in_block <- FALSE
    keep <- logical(length(js_min))
    for (i in seq_along(js_min)) {
      ln <- trimws(js_min[i])
      if (in_block) { keep[i] <- FALSE; if (grepl("\\*/\\s*$", ln)) in_block <- FALSE; next }
      if (grepl("^/\\*", ln)) { keep[i] <- FALSE; in_block <- !grepl("\\*/\\s*$", ln); next }
      keep[i] <- nzchar(ln) && !grepl("^//", ln)
    }
    write_if_changed("inst/format/albers.min.js", trimws(js_min[keep]))
    # Same shape as use_albersdown()'s generated pkgdown/extra.js.
    write_if_changed("pkgdown/extra.js", c(
      "/* albersdown pkgdown/extra.js: site default family and direction. */",
      "window.albersdownDefaults = { family: \"red\", preset: \"homage\", style: \"minimal\" };",
      ""
    ))
  }
}

sync_css()
