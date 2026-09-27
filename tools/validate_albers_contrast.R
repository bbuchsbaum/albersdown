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

# Night grounds are defined in albers.css (html[data-albers-theme="dark"]).
night <- list(
  homage = list(surface = "#1b1814", surface_strong = "#221e19", code_bg = "#12100d",
                ink = "#ece5d6", muted = "#aaa190"),
  interaction = list(surface = "#14171c", surface_strong = "#1a1e24", code_bg = "#090b0e",
                     ink = "#e6e8ec", muted = "#9aa3b2")
)

rows <- list()
add <- function(check, fg, bg) {
  if (is.null(fg) || is.null(bg)) return(invisible())
  rows[[length(rows) + 1L]] <<- data.frame(check = check, fg = fg, bg = bg,
    ratio = contrast_ratio(fg, bg), stringsAsFactors = FALSE)
}

light <- setdiff(names(tokens$presets), "midnight")
grounds <- c("surface", "surface_strong")

# Token values may reference the family (var(--A700), var(--comp-ink)) or mix
# it into a ground (color-mix(in oklab, var(--A900) 24%, #101217)). Resolve
# them per family; mixes are approximated in sRGB.
resolve <- function(value, fam) {
  if (is.null(value)) return(NULL)
  v <- trimws(value)
  m <- regmatches(v, regexec("^var\\(--([A-Za-z0-9-]+)\\)$", v))[[1]]
  if (length(m) == 2) return(fam[[gsub("-", "_", m[2])]])
  m <- regmatches(v, regexec("^color-mix\\(in [a-z]+, *(.+?) +([0-9.]+)%, *(#[0-9A-Fa-f]{6})\\)$", v))[[1]]
  if (length(m) == 4) {
    a <- hex_to_rgb(resolve(m[2], fam)); b <- hex_to_rgb(m[4]); w <- as.numeric(m[3]) / 100
    if (is.null(a) || is.null(b)) return(NULL)
    mix <- w * a + (1 - w) * b
    return(grDevices::rgb(mix[1], mix[2], mix[3]))
  }
  v
}

# Text on the sheet, per preset (midnight's grounds mix in the family's A900,
# so they are checked per family)
for (p in names(tokens$presets)) {
  sp <- tokens$presets[[p]]
  for (f in names(tokens$families)) {
    fam <- tokens$families[[f]]
    for (g in grounds) {
      bg <- resolve(sp[[g]], fam)
      add(paste0("ink-", p, "-", f, "-", g), sp$ink, bg)
      add(paste0("muted-", p, "-", f, "-", g), sp$muted, bg)
    }
  }
}

# Syntax tokens and output on each code ground, for every family
tok_keys <- c("code_fg", "code_out", "tok_fun", "tok_str", "tok_num", "tok_com", "tok_kw", "tok_arg", "code_warn", "code_err")
for (p in names(tokens$presets)) {
  sp <- tokens$presets[[p]]
  for (f in names(tokens$families)) {
    fam <- tokens$families[[f]]
    bg <- resolve(sp$code_bg, fam)
    for (k in intersect(tok_keys, names(sp))) add(paste0(k, "-", p, "-", f), resolve(sp[[k]], fam), bg)
  }
}

# Diagnostics on light code grounds (presets without their own code_warn /
# code_err use the page's --warn #7a5300 and --danger #b3261e)
for (p in names(tokens$presets)) {
  sp <- tokens$presets[[p]]
  if (is.null(sp$code_bg) || !is.null(sp$code_warn) || identical(p, "midnight")) next
  add(paste0("warn-on-code-", p), "#7a5300", sp$code_bg)
  add(paste0("danger-on-code-", p), "#b3261e", sp$code_bg)
}
# Night: --warn #f0b429 and --danger #ff8a73 on the night code grounds
for (n in names(night)) {
  add(paste0("night-warn-", n), "#f0b429", night[[n]]$code_bg)
  add(paste0("night-danger-", n), "#ff8a73", night[[n]]$code_bg)
}
# Midnight's own code plate, per family
for (f in names(tokens$families)) {
  bg <- resolve(tokens$presets$midnight$code_bg, tokens$families[[f]])
  add(paste0("midnight-warn-", f), "#f0b429", bg)
  add(paste0("midnight-danger-", f), "#ff8a73", bg)
}

# Per-family semantic colours (albers.css: red danger, ochre caution)
for (g in c("#fbf7ee", "#f4eedf", "#ffffff", "#f5f6f8", "#f6f0e3")) {
  add(paste0("red-danger-on-", g), "#9a1d63", g)
  add(paste0("ochre-warn-on-", g), "#9c470d", g)
}
for (g in c(night$homage$surface, night$interaction$surface, "#15181e", night$homage$code_bg)) {
  add(paste0("red-danger-night-on-", g), "#f18db5", g)
  add(paste0("ochre-warn-night-on-", g), "#f2a26a", g)
}

# Night code grounds (albers.css): Homage uses the warm night set (richer
# family functions, deep-complement strings, muted third-hue numbers);
# Interaction keeps its slab's family A300, light string tone and light
# third-hue numbers.
for (f in names(tokens$families)) {
  fam <- tokens$families[[f]]
  add(paste0("night-fun-", f), fam$code_fun_warm, night$homage$code_bg)
  add(paste0("night-str-", f), fam$code_str_warm, night$homage$code_bg)
  add(paste0("night-num-", f), fam$code_num_warm, night$homage$code_bg)
  slab <- resolve("color-mix(in oklab, var(--A900) 18%, #07080b)", fam)
  add(paste0("night-int-fun-", f), fam$A300, slab)
  add(paste0("night-int-str-", f), fam$code_str_light, slab)
  add(paste0("night-int-num-", f), fam$code_num_light, slab)
}

# Print (albers.css @media print): the light-day family triad on white paper
# and on the #f5f5f3 code ground
for (f in names(tokens$families)) {
  fam <- tokens$families[[f]]
  for (g in c("#ffffff", "#f5f5f3")) {
    add(paste0("print-fun-", f, "-", g), fam$A700, g)
    add(paste0("print-str-", f, "-", g), fam$comp_ink, g)
    add(paste0("print-num-", f, "-", g), fam$code_num, g)
  }
}

# Interaction section numerals: one numeral colour (the sheet) reversed out of
# chips that step through A900 / A700 / comp-ink; at night the night sheet on
# A300 / comp-light / a mix of A500 into A300.
for (f in names(tokens$families)) {
  fam <- tokens$families[[f]]
  for (chip in c("A900", "A700", "comp_deep")) add(paste0("int-num-", f, "-", chip), tokens$presets$interaction$surface, fam[[chip]])
  for (chip in c("--A300", "--comp-light")) {
    ground <- resolve(sprintf("color-mix(in oklab, var(%s) 85%%, %s)", chip, night$interaction$surface), fam)
    add(paste0("int-num-night-", f, chip), night$interaction$surface, ground)
  }
  a <- hex_to_rgb(fam$A500); b <- hex_to_rgb(fam$A300)
  mid <- grDevices::rgb(t(0.45 * a + 0.55 * b))
  ground <- resolve(sprintf("color-mix(in oklab, %s 85%%, %s)", mid, night$interaction$surface), fam)
  add(paste0("int-num-night-", f, "-deep"), night$interaction$surface, ground)
}

# Links: light mode uses A700; dark mode and midnight use the dark accent ink
for (f in names(tokens$families)) {
  fam <- tokens$families[[f]]
  for (p in light) for (g in grounds) add(paste0("link-", f, "-", p, "-", g), fam$A700, tokens$presets[[p]][[g]])
  for (g in grounds) add(paste0("link-", f, "-midnight-", g), fam$dark$accent_ink, resolve(tokens$presets$midnight[[g]], fam))
  for (n in names(night)) for (g in grounds) add(paste0("link-dark-", f, "-", n, "-", g), fam$dark$accent_ink, night[[n]][[g]])
}

for (n in names(night)) {
  for (g in grounds) {
    add(paste0("ink-night-", n, "-", g), night[[n]]$ink, night[[n]][[g]])
    add(paste0("muted-night-", n, "-", g), night[[n]]$muted, night[[n]][[g]])
  }
}

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
