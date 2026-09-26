#!/usr/bin/env Rscript
# Syntax colour separation: for every family x direction x mode, the four code
# roles a reader has to tell apart at a glance -- plain text, functions,
# strings, numbers -- must sit at least `min_de` CIEDE2000 apart, and each must
# clear 4.5:1 on its code ground. Prints the per-variant minimum pair.
# Variants: light and dark per direction, midnight, and print (on the paper
# code ground and on bare white). Also reports, per family and role, how far
# dark Homage (warm) sits from dark Interaction (cool), and requires:
# - midnight to have its own set: at least two of fun/str/num per family sit
#   `min_midnight_de` or more from dark Interaction;
# - a calm luminance band in every dark variant: no syntax role's contrast
#   exceeds the functions' by more than `max_spread` (functions lead).

if (!requireNamespace("yaml", quietly = TRUE)) {
  stop("Package 'yaml' is required. Install it with install.packages('yaml').", call. = FALSE)
}

min_de <- 15
min_ratio <- 4.5
min_midnight_de <- 10
max_spread <- 1.5
dark_variants <- c("homage-dark", "interaction-dark", "midnight")

hex_rgb <- function(h) as.numeric(grDevices::col2rgb(h)) / 255
srgb_lin <- function(u) ifelse(u <= 0.04045, u / 12.92, ((u + 0.055) / 1.055)^2.4)
mix <- function(a, w, b) grDevices::rgb(t(w * hex_rgb(a) + (1 - w) * hex_rgb(b)))

luminance <- function(h) sum(c(0.2126, 0.7152, 0.0722) * srgb_lin(hex_rgb(h)))
contrast <- function(a, b) {
  l <- c(luminance(a), luminance(b))
  (max(l) + 0.05) / (min(l) + 0.05)
}

lab <- function(h) {
  m <- matrix(c(0.4124564, 0.3575761, 0.1804375,
                0.2126729, 0.7151522, 0.0721750,
                0.0193339, 0.1191920, 0.9503041), 3, byrow = TRUE)
  xyz <- as.numeric(m %*% srgb_lin(hex_rgb(h))) / c(0.95047, 1, 1.08883)
  f <- ifelse(xyz > 216 / 24389, xyz^(1 / 3), (24389 / 27 * xyz + 16) / 116)
  c(116 * f[2] - 16, 500 * (f[1] - f[2]), 200 * (f[2] - f[3]))
}

de2000 <- function(x, y) {
  p <- lab(x); q <- lab(y)
  rad <- pi / 180
  cb <- (sqrt(p[2]^2 + p[3]^2) + sqrt(q[2]^2 + q[3]^2)) / 2
  g <- 0.5 * (1 - sqrt(cb^7 / (cb^7 + 25^7)))
  a1 <- (1 + g) * p[2]; a2 <- (1 + g) * q[2]
  c1 <- sqrt(a1^2 + p[3]^2); c2 <- sqrt(a2^2 + q[3]^2)
  h1 <- (atan2(p[3], a1) / rad) %% 360; h2 <- (atan2(q[3], a2) / rad) %% 360
  dh <- if (c1 * c2 == 0) 0 else {
    d <- h2 - h1
    if (d > 180) d - 360 else if (d < -180) d + 360 else d
  }
  dl <- q[1] - p[1]; dc <- c2 - c1
  dhh <- 2 * sqrt(c1 * c2) * sin(dh * rad / 2)
  lb <- (p[1] + q[1]) / 2; cbp <- (c1 + c2) / 2
  hb <- if (c1 * c2 == 0) h1 + h2 else if (abs(h1 - h2) <= 180) (h1 + h2) / 2 else if (h1 + h2 < 360) (h1 + h2 + 360) / 2 else (h1 + h2 - 360) / 2
  tt <- 1 - 0.17 * cos((hb - 30) * rad) + 0.24 * cos(2 * hb * rad) +
    0.32 * cos((3 * hb + 6) * rad) - 0.20 * cos((4 * hb - 63) * rad)
  dth <- 30 * exp(-((hb - 275) / 25)^2)
  rc <- 2 * sqrt(cbp^7 / (cbp^7 + 25^7))
  sl <- 1 + 0.015 * (lb - 50)^2 / sqrt(20 + (lb - 50)^2)
  sc <- 1 + 0.045 * cbp
  sh <- 1 + 0.015 * cbp * tt
  rt <- -sin(2 * dth * rad) * rc
  sqrt((dl / sl)^2 + (dc / sc)^2 + (dhh / sh)^2 + rt * (dc / sc) * (dhh / sh))
}

tokens <- yaml::read_yaml("inst/tokens/albers-tokens.yml")
pr <- tokens$presets

# Resolve a token value against a family: plain hex, var(--x), or the
# interaction code ground's color-mix(in oklab, var(--A900) N%, #hex)
# (approximated in sRGB, as tools/validate_albers_contrast.R does).
resolve <- function(v, fam) {
  v <- trimws(v)
  m <- regmatches(v, regexec("^var\\(--([A-Za-z0-9-]+)\\)$", v))[[1]]
  if (length(m) == 2) return(fam[[gsub("-", "_", m[2])]])
  m <- regmatches(v, regexec("^color-mix\\(in [a-z]+, *(.+?) +([0-9.]+)%, *(#[0-9A-Fa-f]{6})\\)$", v))[[1]]
  if (length(m) == 4) return(mix(resolve(m[2], fam), as.numeric(m[3]) / 100, m[4]))
  v
}

# Dark-mode code grounds and plain text live in albers.css
# (html[data-albers-theme="dark"] body...); keep in step with it.
night <- list(
  homage = list(code_bg = "#12100d", code_fg = "#e4dccb",
                tok_fun = "var(--code-fun-warm)", tok_str = "var(--code-str-warm)", tok_num = "var(--code-num-warm)"),
  interaction = list(code_bg = "color-mix(in oklab, var(--A900) 18%, #07080b)", code_fg = "#d3d8e1",
                     tok_fun = "var(--A300)", tok_str = "var(--code-str-light)", tok_num = "var(--code-num-light)")
)
# Print (@media print in albers.css): one light token set on white paper,
# with the family's light-day triad for syntax. Checked on both the #f5f5f3
# code ground and bare white.
paper <- list(code_fg = "#222", tok_fun = "var(--A700)", tok_str = "var(--comp-ink)", tok_num = "var(--code-num)")
specs <- list(
  "homage-light" = pr$homage, "homage-dark" = night$homage,
  "interaction-light" = pr$interaction, "interaction-dark" = night$interaction,
  "midnight" = pr$midnight,
  "print" = c(paper, code_bg = "#f5f5f3"), "print-white" = c(paper, code_bg = "#ffffff")
)
roles <- c(plain = "code_fg", fun = "tok_fun", str = "tok_str", num = "tok_num")
pairs <- utils::combn(names(roles), 2)

rows <- list()
for (f in names(tokens$families)) {
  fam <- tokens$families[[f]]
  for (v in names(specs)) {
    sp <- specs[[v]]
    bg <- resolve(sp$code_bg, fam)
    col <- vapply(roles, function(k) resolve(sp[[k]], fam), character(1))
    de <- apply(pairs, 2, function(p) de2000(col[[p[1]]], col[[p[2]]]))
    ratio <- vapply(col, contrast, numeric(1), b = bg)
    syn <- ratio[c("fun", "str", "num")]
    i <- which.min(de)
    rows[[length(rows) + 1L]] <- data.frame(
      family = f, variant = v,
      plain = col[["plain"]], fun = col[["fun"]], str = col[["str"]], num = col[["num"]],
      min_de = round(de[i], 1), pair = paste(pairs[, i], collapse = "/"),
      min_ratio = round(min(ratio), 2),
      cr_fun = round(syn[["fun"]], 2), cr_str = round(syn[["str"]], 2), cr_num = round(syn[["num"]], 2),
      spread = round(max(syn) / syn[["fun"]], 2), stringsAsFactors = FALSE
    )
  }
}
report <- do.call(rbind, rows)
print(report, row.names = FALSE)
cat(sprintf("\nMinimum dE2000 between syntax roles: %.1f (%s, %s)\n",
            min(report$min_de), report$pair[which.min(report$min_de)],
            paste(report[which.min(report$min_de), c("family", "variant")], collapse = " ")))
cat(sprintf("Minimum contrast on the code ground: %.2f\n", min(report$min_ratio)))

# Direction character at night: the same role and family must read
# differently in dark Homage (warm) and dark Interaction (cool).
cross <- do.call(rbind, lapply(names(tokens$families), function(f) {
  fam <- tokens$families[[f]]
  de <- vapply(roles, function(k) de2000(resolve(night$homage[[k]], fam), resolve(night$interaction[[k]], fam)), numeric(1))
  data.frame(family = f, t(round(de, 1)), stringsAsFactors = FALSE)
}))
cat("\nDark Homage vs dark Interaction, dE2000 per role:\n")
print(cross, row.names = FALSE)

# Midnight's own character: the same role and family must not repeat dark
# Interaction on a different ground.
syn_roles <- roles[c("fun", "str", "num")]
mid <- do.call(rbind, lapply(names(tokens$families), function(f) {
  fam <- tokens$families[[f]]
  de <- vapply(syn_roles, function(k) de2000(resolve(pr$midnight[[k]], fam), resolve(night$interaction[[k]], fam)), numeric(1))
  data.frame(family = f, t(round(de, 1)), n_distinct = sum(de >= min_midnight_de), stringsAsFactors = FALSE)
}))
cat(sprintf("\nMidnight vs dark Interaction, dE2000 per role (need >= %g in 2 of 3):\n", min_midnight_de))
print(mid, row.names = FALSE)

dark <- report[report$variant %in% dark_variants, c("family", "variant", "cr_fun", "cr_str", "cr_num", "spread")]
cat(sprintf("\nDark luminance band, contrast per role (brightest / functions <= %g):\n", max_spread))
print(dark, row.names = FALSE)
cat(sprintf("Maximum spread: %.2f\n", max(dark$spread)))

fail <- FALSE
bad <- report[report$min_de < min_de | report$min_ratio < min_ratio, , drop = FALSE]
if (nrow(bad)) {
  cat(sprintf("\nFailures (dE2000 < %g or ratio < %g):\n", min_de, min_ratio))
  print(bad, row.names = FALSE)
  fail <- TRUE
}
if (any(mid$n_distinct < 2)) {
  cat(sprintf("\nFailures (midnight within dE2000 %g of dark Interaction in 2+ roles):\n", min_midnight_de))
  print(mid[mid$n_distinct < 2, ], row.names = FALSE)
  fail <- TRUE
}
if (any(dark$spread > max_spread)) {
  cat(sprintf("\nFailures (a role out-shines functions by more than %g):\n", max_spread))
  print(dark[dark$spread > max_spread, ], row.names = FALSE)
  fail <- TRUE
}
if (fail) quit(status = 1)
cat("All syntax separation checks passed.\n")
