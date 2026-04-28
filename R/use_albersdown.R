#' One-shot setup for existing packages
#'
#' Turn-key retrofit to adopt the albersdown theme in an existing package.
#' Copies local assets for CRAN-safe vignettes, ensures pkgdown template,
#' optionally patches all vignettes, writes a README note, and prints a doctor report.
#'
#' @param path Path to the package directory.  Must be supplied explicitly;
#'   there is no default so that the function never writes to an unexpected
#'   location.
#' @param family one of: "red","lapis","ochre","teal","green","violet"
#' @param preset Visual preset (default \code{"homage"}). See [albers_presets()].
#' @param apply_to "all" to patch every *.Rmd/*.qmd in vignettes/, or "new" to only add the template and assets
#' @param dry_run if TRUE, show changes without writing
#' @param fallback_extra Controls writing site-wide fallbacks into `pkgdown/`:
#'   - "auto": write `pkgdown/extra.css` and `pkgdown/extra.js` whenever
#'     site-wide defaults are needed, including the standard
#'     `template: { package: albersdown }` setup where pkgdown template
#'     assets are copied but not linked automatically.
#'   - "always": always write to `pkgdown/` (useful as a safety net or for custom setups).
#'   - "never": never copy site-wide fallbacks.
#' @param force_replace if TRUE (default), overwrite existing albersdown assets and
#'   replace existing vignette CSS/header hooks so albersdown becomes the active theme.
#' @return \code{TRUE} invisibly.
#' @export
#' @examples
#' \donttest{
#' if (interactive()) {
#'   use_albersdown(path = ".", dry_run = TRUE)
#' }
#' }
use_albersdown <- function(
  path,
  family = "red",
  preset = c("homage", "study", "structural", "adobe", "midnight"),
  apply_to = c("all", "new"),
  dry_run = FALSE,
  fallback_extra = c("auto", "always", "never"),
  force_replace = TRUE
) {
  apply_to <- match.arg(apply_to)
  preset <- match.arg(preset)
  fallback_extra <- match.arg(fallback_extra)
  oldwd <- setwd(path)
  on.exit(setwd(oldwd), add = TRUE)
  if (requireNamespace("cli", quietly = TRUE)) cli::cli_h1("albersdown setup") else message("albersdown setup")
  .ensure_pkgdown_template(dry_run = dry_run)
  .add_website_dep(dry_run = dry_run)
  .copy_resources(
    family = family,
    preset = preset,
    dry_run = dry_run,
    fallback_extra = fallback_extra,
    force_replace = force_replace
  )
  if (apply_to == "all") .patch_all_rmds(family = family, preset = preset, dry_run = dry_run, force_replace = force_replace)
  .write_readme_snippet(family = family, preset = preset, dry_run = dry_run)
  .doctor(family = family)
  invisible(TRUE)
}

.ensure_pkgdown_template <- function(dry_run = FALSE) {
  yml <- "_pkgdown.yml"
  if (!requireNamespace("yaml", quietly = TRUE)) {
    if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_warning("Package {.pkg yaml} not installed; cannot parse {.file _pkgdown.yml}") else message("yaml not installed; cannot parse _pkgdown.yml")
    return(invisible(FALSE))
  }
  cfg <- if (file.exists(yml)) tryCatch(yaml::read_yaml(yml), error = function(e) list()) else list()
  if (is.null(cfg) || isTRUE(is.na(cfg))) cfg <- list()
  tpl <- cfg$template %||% list()
  tpl$package <- "albersdown"
  tpl$bootstrap <- tpl$bootstrap %||% 5
  cfg$template <- tpl
  if (dry_run) {
    if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_info("Would write/update {.file _pkgdown.yml} with template: {.code package: albersdown}, {.code bootstrap: 5}") else message("Would write/update _pkgdown.yml with template")
  } else {
    yaml::write_yaml(cfg, yml)
    if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_success("Ensured {.file _pkgdown.yml} uses albersdown template") else message("Ensured _pkgdown.yml uses albersdown template")
  }
  invisible(TRUE)
}

.copy_resources <- function(
  family = "red",
  preset = "homage",
  dry_run = FALSE,
  fallback_extra = c("auto", "always", "never"),
  force_replace = TRUE
) {
  fallback_extra <- match.arg(fallback_extra)
  dir.create("vignettes", showWarnings = FALSE)

  src_css_v_local <- file.path("inst", "rmarkdown", "templates", "albers_vignette", "skeleton", "albers.css")
  src_header_local <- file.path("inst", "rmarkdown", "templates", "albers_vignette", "skeleton", "albers-header.html")
  src_css_site_local <- file.path("inst", "pkgdown", "assets", "albers.css")
  src_js_local <- file.path("inst", "pkgdown", "assets", "albers.js")

  src_css_v <- if (file.exists(src_css_v_local)) src_css_v_local else system.file("rmarkdown/templates/albers_vignette/skeleton/albers.css", package = "albersdown")
  src_header <- if (file.exists(src_header_local)) src_header_local else system.file("rmarkdown/templates/albers_vignette/skeleton/albers-header.html", package = "albersdown")
  src_css_site <- if (file.exists(src_css_site_local)) src_css_site_local else system.file("pkgdown/assets/albers.css", package = "albersdown")
  src_js <- if (file.exists(src_js_local)) src_js_local else system.file("pkgdown/assets/albers.js", package = "albersdown")

  .copy_with_policy(
    src = src_css_v,
    dst = file.path("vignettes", "albers.css"),
    dry_run = dry_run,
    force_replace = force_replace,
    context = "vignette"
  )
  .copy_with_policy(
    src = src_js,
    dst = file.path("vignettes", "albers.js"),
    dry_run = dry_run,
    force_replace = force_replace,
    context = "vignette"
  )
  .copy_with_policy(
    src = src_header,
    dst = file.path("vignettes", "albers-header.html"),
    dry_run = dry_run,
    force_replace = force_replace,
    context = "vignette"
  )

  if ((!nzchar(src_css_v) || !file.exists(src_css_v)) && !file.exists(file.path("vignettes", "albers.css"))) {
    msg <- "Packaged vignette CSS not found and vignettes/albers.css is missing; vignette styling will be absent"
    if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_warning(msg) else message(msg)
  }
  if ((!nzchar(src_js) || !file.exists(src_js)) && !file.exists(file.path("vignettes", "albers.js"))) {
    msg <- "Packaged vignette JS not found and vignettes/albers.js is missing; copy buttons/anchors may be absent"
    if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_warning(msg) else message(msg)
  }
  if ((!nzchar(src_header) || !file.exists(src_header)) && !file.exists(file.path("vignettes", "albers-header.html"))) {
    msg <- "Packaged vignette header include not found and vignettes/albers-header.html is missing; html_vignette head hooks will be absent"
    if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_warning(msg) else message(msg)
  }

  if (identical(fallback_extra, "always") || identical(fallback_extra, "auto")) {
    dir.create("pkgdown", showWarnings = FALSE)
    .write_pkgdown_extra(
      family = family,
      preset = preset,
      dry_run = dry_run,
      force_replace = force_replace
    )
  }

  invisible(TRUE)
}

.patch_all_rmds <- function(family, preset = "homage", dry_run = FALSE, force_replace = TRUE) {
  files <- c(Sys.glob("vignettes/*.Rmd"), Sys.glob("vignettes/*.qmd"))
  if (!length(files)) {
    if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_info("No vignettes found to patch") else message("No vignettes found to patch")
    return(invisible(TRUE))
  }
  for (path in files) .patch_one_rmd(path = path, family = family, preset = preset, dry_run = dry_run, force_replace = force_replace)
  invisible(TRUE)
}

.patch_one_rmd <- function(path, family, preset = "homage", dry_run = FALSE, force_replace = TRUE) {
  if (!requireNamespace("yaml", quietly = TRUE)) {
    if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_warning("Package {.pkg yaml} not installed; skipping {.file {basename(path)}}") else message(sprintf("yaml not installed; skipping %s", basename(path)))
    return(invisible(FALSE))
  }

  raw <- readLines(path, warn = FALSE)
  if (length(raw) < 3 || raw[1] != "---") {
    if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_warning("No YAML header in {.file {basename(path)}}; skipping") else message(sprintf("No YAML header in %s; skipping", basename(path)))
    return(invisible(FALSE))
  }
  fence <- which(raw == "---")
  if (length(fence) < 2) {
    if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_warning("Malformed YAML in {.file {basename(path)}}; skipping") else message(sprintf("Malformed YAML in %s; skipping", basename(path)))
    return(invisible(FALSE))
  }

  head <- raw[(fence[1] + 1):(fence[2] - 1)]
  body <- raw[(fence[2] + 1):length(raw)]
  y <- tryCatch(yaml::yaml.load(paste(head, collapse = "\n")), error = function(e) NULL)
  if (is.null(y)) {
    if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_warning("Could not parse YAML in {.file {basename(path)}}; skipping") else message(sprintf("Could not parse YAML in %s; skipping", basename(path)))
    return(invisible(FALSE))
  }

  # Explicit function arguments should override pre-existing YAML params.
  y$params <- .modify_list(y$params %||% list(), list(family = family, preset = preset))

  is_qmd <- grepl("\\.qmd$", basename(path), ignore.case = TRUE)
  if (is_qmd) {
    y$format <- y$format %||% list(html = list())
    if (is.null(y$format$html)) y$format$html <- list()

    css_cur <- .as_char_vec(y$format$html$css)
    y$format$html$css <- if (force_replace) "albers.css" else unique(c(css_cur, "albers.css"))

    resources <- .as_char_vec(y$resources)
    y$resources <- unique(c(resources, "albers.css", "albers.js"))

    y[["header-includes"]] <- .upsert_header_includes(
      values = y[["header-includes"]],
      family = family,
      preset = preset,
      force_replace = force_replace
    )
  } else {
    output_cur <- y$output
    html_vignette <- if (is.character(output_cur) && length(output_cur) == 1L) {
      list()
    } else if (is.list(output_cur)) {
      output_cur[["rmarkdown::html_vignette"]] %||% list()
    } else {
      list()
    }

    if (is.null(html_vignette$toc)) html_vignette$toc <- TRUE
    if (is.null(html_vignette$toc_depth)) html_vignette$toc_depth <- 2

    css_cur <- .as_char_vec(html_vignette$css %||% y$css)
    html_vignette$css <- if (force_replace) "albers.css" else unique(c(css_cur, "albers.css"))

    includes_top <- if (is.list(y$includes)) y$includes else list()
    includes_cur <- .modify_list(includes_top, html_vignette$includes %||% list())
    includes_cur$in_header <- .upsert_in_header_path(
      value = includes_cur$in_header,
      force_replace = force_replace,
      target = "albers-header.html"
    )
    html_vignette$includes <- includes_cur

    y$output <- list(`rmarkdown::html_vignette` = html_vignette)
    y$css <- NULL
    y$includes <- NULL

    resources <- .as_char_vec(y$resource_files)
    y$resource_files <- unique(c(resources, "albers.css", "albers.js", "albers-header.html"))
  }

  new_head <- .yaml_with_literal_vignette(y)
  out <- c("---", new_head, "---", body)
  if (!dry_run) {
    dir.create(".albersdown.bak", showWarnings = FALSE)
    file.copy(path, file.path(".albersdown.bak", basename(path)), overwrite = TRUE)
    writeLines(out, path, useBytes = TRUE)
  }
  if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_success("Updated YAML in {.file {basename(path)}}") else message(sprintf("Updated YAML in %s", basename(path)))

  ensure_theme <- function(lines) {
    lines <- sub(
      pattern = "(^\\s*)theme_set\\(albersdown::theme_albers\\(",
      replacement = "\\1ggplot2::theme_set(albersdown::theme_albers(",
      x = lines,
      perl = TRUE
    )

    canonical <- function(indent = "") {
      paste0(
        indent,
        "if (requireNamespace(\"ggplot2\", quietly = TRUE) && requireNamespace(\"albersdown\", quietly = TRUE)) ",
        "ggplot2::theme_set(albersdown::theme_albers(family = params$family, preset = params$preset))"
      )
    }

    target <- "ggplot2::theme_set\\(albersdown::theme_albers\\("
    idx <- grep(target, lines, perl = TRUE)
    if (length(idx)) {
      keep <- rep(TRUE, length(lines))
      for (k in seq_along(idx)) {
        i <- idx[[k]]
        original <- lines[[i]]
        indent <- sub("^(\\s*).*", "\\1", lines[[i]], perl = TRUE)
        if (k == 1L) lines[[i]] <- canonical(indent) else keep[[i]] <- FALSE

        # Collapse any older multi-line theme_albers() call to the canonical one-liner.
        if (!grepl("\\)\\)\\s*$", original, perl = TRUE)) {
          j <- i + 1L
          while (j <= length(lines)) {
            if (grepl("^\\s*```", lines[[j]]) ||
                grepl("^\\s*if\\s*\\(", lines[[j]]) ||
                grepl("^\\s*}\\s*$", lines[[j]])) {
              break
            }
            keep[[j]] <- FALSE
            if (grepl("^\\s*\\)\\)\\s*$", lines[[j]], perl = TRUE)) break
            j <- j + 1L
          }
        }
      }

      return(lines[keep])
    }

    setup_chunk <- grep("^```\\{r[^}]*setup", lines)
    if (!length(setup_chunk)) return(lines)

    inject <- canonical()
    append(lines, inject, after = setup_chunk[1])
  }

  ensure_runtime_classes <- function(lines) {
    lines <- .drop_named_chunks(lines, c("albers-family", "albers-preset", "albers-classes"))

    setup_chunk <- grep("^```\\{r[^}]*setup", lines)
    if (!length(setup_chunk)) return(lines)

    setup_end <- which(seq_along(lines) > setup_chunk[1] & grepl("^```\\s*$", lines))
    if (!length(setup_end)) return(lines)

    inject <- c(
      "```{r albers-classes, echo=FALSE, results='asis'}",
      "cat(sprintf(",
      "  paste0(",
      "    '<script>document.addEventListener(\"DOMContentLoaded\",function(){',",
      "    'document.body.classList.remove(\"palette-red\",\"palette-lapis\",\"palette-ochre\",\"palette-teal\",\"palette-green\",\"palette-violet\",\"preset-homage\",\"preset-study\",\"preset-structural\",\"preset-adobe\",\"preset-midnight\");',",
      "    'document.body.classList.add(\"palette-%s\",\"preset-%s\");',",
      "    '});</script>'",
      "  ),",
      "  params$family,",
      "  params$preset",
      "))",
      "```"
    )

    append(lines, c("", inject), after = setup_end[1])
  }

  if (!dry_run) {
    patched <- readLines(path, warn = FALSE)
    patched <- ensure_theme(patched)
    if (!is_qmd) patched <- ensure_runtime_classes(patched)
    writeLines(patched, path, useBytes = TRUE)
  }
  invisible(TRUE)
}

.write_readme_snippet <- function(family, preset = "homage", dry_run = FALSE) {
  if (!file.exists("README.md")) return(invisible(TRUE))

  start_tag <- "<!-- albersdown:theme-note:start -->"
  end_tag <- "<!-- albersdown:theme-note:end -->"
  block <- c(
    start_tag,
    "## Albers theme",
    paste0(
      "This package uses the albersdown theme. Existing vignette theme hooks are replaced so `albers.css` and local `albers.js` render consistently on CRAN and GitHub Pages. The defaults are configured via `params$family` and `params$preset` (family = '",
      family,
      "', preset = '",
      preset,
      "'). The pkgdown site uses `template: { package: albersdown }` together with generated `pkgdown/extra.css` and `pkgdown/extra.js` so the theme is linked and activated on site pages."
    ),
    end_tag
  )

  lines <- readLines("README.md", warn = FALSE)
  updated <- .replace_or_append_marked_block(lines, block, start_tag, end_tag)

  if (identical(lines, updated)) {
    if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_info("README.md already contains an up-to-date Albers note") else message("README.md already contains an up-to-date Albers note")
    return(invisible(TRUE))
  }

  if (dry_run) {
    if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_info("Would write/update marked Albers note in {.file README.md}") else message("Would write/update marked Albers note in README.md")
  } else {
    writeLines(updated, "README.md", useBytes = TRUE)
    if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_success("Updated marked Albers note in {.file README.md}") else message("Updated marked Albers note in README.md")
  }

  invisible(TRUE)
}

.doctor <- function(family) {
  if (requireNamespace("cli", quietly = TRUE)) cli::cli_h2("Doctor") else message("Doctor")

  score <- 100
  issues <- character()
  penalize <- function(points, msg, level = c("warning", "info")) {
    level <- match.arg(level)
    score <<- max(0, score - points)
    issues <<- c(issues, sprintf("-%d %s", points, msg))
    if (requireNamespace("cli", quietly = TRUE)) {
      if (level == "warning") cli::cli_alert_warning(msg) else cli::cli_alert_info(msg)
    } else {
      message(msg)
    }
  }

  ok_css <- file.exists("vignettes/albers.css")
  ok_js <- file.exists("vignettes/albers.js")
  ok_header <- file.exists("vignettes/albers-header.html")
  if (ok_css) {
    if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_success("CSS present: {ok_css}") else message(sprintf("CSS present: %s", ok_css))
  } else {
    penalize(25, "Missing vignettes/albers.css; themed vignettes will not render as intended")
  }
  if (ok_js) {
    if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_success("JS present:  {ok_js}") else message(sprintf("JS present: %s", ok_js))
  } else {
    penalize(15, "Missing vignettes/albers.js; anchors/copy/composition behaviors will be absent")
  }
  if (ok_header) {
    if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_success("Header include present: {ok_header}") else message(sprintf("Header include present: %s", ok_header))
  } else {
    penalize(12, "Missing vignettes/albers-header.html; html_vignette will ignore custom head hooks")
  }

  src_css_local <- file.path("inst", "rmarkdown", "templates", "albers_vignette", "skeleton", "albers.css")
  src_css <- if (file.exists(src_css_local)) src_css_local else system.file("rmarkdown/templates/albers_vignette/skeleton/albers.css", package = "albersdown")
  src_js_local <- file.path("inst", "pkgdown", "assets", "albers.js")
  src_js <- if (file.exists(src_js_local)) src_js_local else system.file("pkgdown/assets/albers.js", package = "albersdown")
  src_header_local <- file.path("inst", "rmarkdown", "templates", "albers_vignette", "skeleton", "albers-header.html")
  src_header <- if (file.exists(src_header_local)) src_header_local else system.file("rmarkdown/templates/albers_vignette/skeleton/albers-header.html", package = "albersdown")
  if (ok_css && nzchar(src_css) && file.exists(src_css)) {
    if (!identical(.md5(src_css), .md5("vignettes/albers.css"))) {
      penalize(8, "vignettes/albers.css is not the packaged version (drift detected)")
    }
  }
  if (ok_js && nzchar(src_js) && file.exists(src_js)) {
    if (!identical(.md5(src_js), .md5("vignettes/albers.js"))) {
      penalize(5, "vignettes/albers.js is not the packaged version (drift detected)")
    }
  }
  if (ok_header && nzchar(src_header) && file.exists(src_header)) {
    if (!identical(.md5(src_header), .md5("vignettes/albers-header.html"))) {
      penalize(5, "vignettes/albers-header.html is not the packaged version (drift detected)")
    }
  }

  if (file.exists("_pkgdown.yml") && requireNamespace("yaml", quietly = TRUE)) {
    cfg <- tryCatch(yaml::read_yaml("_pkgdown.yml"), error = function(e) NULL)
    tpl <- if (is.list(cfg)) (cfg$template %||% list()) else list()
    if (!identical(tpl$package, "albersdown")) {
      penalize(18, "_pkgdown.yml template does not point at albersdown; pkgdown theme replacement is incomplete")
    }
  }

  v <- c(Sys.glob("vignettes/*.Rmd"), Sys.glob("vignettes/*.qmd"))
  if (length(v)) {
    missing_css <- v[!vapply(v, function(path) any(grepl("albers\\.css", readLines(path, warn = FALSE))), logical(1))]
    if (length(missing_css)) {
      penalize(min(18, 6 * length(missing_css)), sprintf(
        "These vignettes do not reference albers.css: %s",
        paste(basename(missing_css), collapse = ", ")
      ))
    }

    missing_js <- v[!vapply(v, function(path) any(grepl("albers\\.js|albers-header\\.html", readLines(path, warn = FALSE))), logical(1))]
    if (length(missing_js)) {
      penalize(min(15, 5 * length(missing_js)), sprintf(
        "These vignettes do not reference albers.js or albers-header.html: %s",
        paste(basename(missing_js), collapse = ", ")
      ))
    }

    yaml_status <- lapply(v, .inspect_vignette_theme_yaml)
    names(yaml_status) <- basename(v)
    yaml_status <- yaml_status[!vapply(yaml_status, is.null, logical(1))]
    if (length(yaml_status)) {
      legacy_hooks <- names(yaml_status)[vapply(yaml_status, function(x) isTRUE(x$legacy_css) || isTRUE(x$legacy_header), logical(1))]
      if (length(legacy_hooks)) {
        penalize(min(18, 6 * length(legacy_hooks)), sprintf(
          "These vignettes still use legacy top-level css/includes hooks that html_vignette may ignore on CRAN: %s",
          paste(legacy_hooks, collapse = ", ")
        ))
      }

      missing_nested_css <- names(yaml_status)[!vapply(yaml_status, function(x) isTRUE(x$nested_css), logical(1))]
      if (length(missing_nested_css)) {
        penalize(min(18, 6 * length(missing_nested_css)), sprintf(
          "These vignettes do not configure albers.css inside their HTML output format: %s",
          paste(missing_nested_css, collapse = ", ")
        ))
      }

      missing_nested_header <- names(yaml_status)[!vapply(yaml_status, function(x) isTRUE(x$nested_header), logical(1))]
      if (length(missing_nested_header)) {
        penalize(min(15, 5 * length(missing_nested_header)), sprintf(
          "These vignettes do not configure albers-header.html/albers.js inside their HTML output format: %s",
          paste(missing_nested_header, collapse = ", ")
        ))
      }

      missing_resources <- names(yaml_status)[!vapply(yaml_status, function(x) isTRUE(x$resources), logical(1))]
      if (length(missing_resources)) {
        penalize(min(12, 4 * length(missing_resources)), sprintf(
          "These vignettes do not list all local Albers resources for package builds: %s",
          paste(missing_resources, collapse = ", ")
        ))
      }
    }

    family_ok <- vapply(v, function(path) any(grepl("palette-", readLines(path, warn = FALSE))), logical(1))
    if (!all(family_ok)) {
      penalize(8, "Some vignettes omit any palette script; they may fall back to default tokens", level = "info")
    }

    dup_theme <- v[vapply(v, function(path) sum(grepl("ggplot2::theme_set\\(albersdown::theme_albers\\(", readLines(path, warn = FALSE), perl = TRUE)) > 1, logical(1))]
    if (length(dup_theme)) {
      penalize(6, sprintf(
        "These vignettes define albers theme_set multiple times: %s",
        paste(basename(dup_theme), collapse = ", ")
      ))
    }
  }

  if (file.exists("pkgdown/extra.css")) {
    css <- readLines("pkgdown/extra.css", warn = FALSE)
    has_anchor <- any(grepl("\\.anchor\\s*\\{", css))
    has_hover <- any(grepl("h2:hover \\.anchor|h3:hover \\.anchor", css))
    if (has_anchor && !has_hover) {
      penalize(5, "pkgdown/extra.css defines .anchor but misses hover/focus rules; anchors may always show")
    }
  }

  contrast <- .doctor_contrast_report()
  if (isFALSE(contrast$ok)) {
    penalize(20, sprintf(
      "Contrast checks found %d failing combinations (minimum ratio %.2f)",
      length(contrast$failures),
      contrast$min_ratio
    ))
  } else if (isTRUE(contrast$ok)) {
    if (requireNamespace("cli", quietly = TRUE)) {
      cli::cli_alert_success("Contrast checks passed across palette/preset matrix (minimum ratio {format(round(contrast$min_ratio, 2), nsmall = 2)})")
    } else {
      message(sprintf("Contrast checks passed (minimum ratio %.2f)", contrast$min_ratio))
    }
  } else {
    penalize(4, "Contrast checks skipped (token file or yaml package unavailable)", level = "info")
  }

  grade <- if (score >= 92) "A" else if (score >= 84) "B" else if (score >= 72) "C" else if (score >= 60) "D" else "F"
  if (requireNamespace("cli", quietly = TRUE)) {
    cli::cli_alert_info("Design quality score: {score}/100 ({grade})")
  } else {
    message(sprintf("Design quality score: %d/100 (%s)", score, grade))
  }

  invisible(list(score = score, grade = grade, issues = issues, contrast = contrast))
}

`%||%` <- function(a, b) if (is.null(a)) b else a

.modify_list <- function(x, val) {
  if (is.null(val)) return(x)
  for (name in names(val)) x[[name]] <- val[[name]]
  x
}

.yaml_with_literal_vignette <- function(x) {
  vignette_value <- x$vignette
  x$vignette <- NULL

  yml <- yaml::as.yaml(x)
  if (is.null(vignette_value)) {
    return(yml)
  }

  vignette_lines <- trimws(strsplit(as.character(vignette_value), "\n", fixed = TRUE)[[1]])
  vignette_lines <- vignette_lines[nzchar(vignette_lines)]

  c(yml, "vignette: |", paste0("  ", vignette_lines))
}

.render_pkgdown_extra_css <- function() {
  c(
    "@import url(\"albers.css\");",
    ""
  )
}

.render_pkgdown_extra_js <- function(family = "red", preset = "homage") {
  c(
    "(function () {",
    "  var FAMILY_CLASSES = [\"red\", \"lapis\", \"ochre\", \"teal\", \"green\", \"violet\"];",
    "  var PRESET_CLASSES = [\"homage\", \"study\", \"structural\", \"adobe\", \"midnight\"];",
    "  var STYLE_CLASSES = [\"minimal\", \"assertive\"];",
    "",
    "  function removeClasses(values, prefix) {",
    "    values.forEach(function (value) {",
    "      document.body.classList.remove(prefix + value);",
    "    });",
    "  }",
    "",
    "  function applyDefaults() {",
    "    if (!document.body) return;",
    "",
    "    removeClasses(FAMILY_CLASSES, \"palette-\");",
    "    removeClasses(PRESET_CLASSES, \"preset-\");",
    "    removeClasses(STYLE_CLASSES, \"style-\");",
    "",
    sprintf("    document.body.classList.add(\"palette-%s\", \"preset-%s\", \"style-minimal\");", family, preset),
    "",
    "    var theme = document.body.classList.contains(\"preset-midnight\") ? \"dark\" : \"light\";",
    "    document.documentElement.setAttribute(\"data-bs-theme\", theme);",
    "    document.body.setAttribute(\"data-bs-theme\", theme);",
    "",
    "    var nav = document.querySelector(\"nav.navbar\");",
    "    if (nav) nav.setAttribute(\"data-bs-theme\", theme);",
    "  }",
    "",
    "  if (document.readyState === \"loading\") {",
    "    document.addEventListener(\"DOMContentLoaded\", applyDefaults);",
    "  } else {",
    "    applyDefaults();",
    "  }",
    "})();",
    ""
  )
}

.write_pkgdown_extra <- function(
  family = "red",
  preset = "homage",
  dry_run = FALSE,
  force_replace = TRUE
) {
  targets <- list(
    list(
      path = file.path("pkgdown", "extra.css"),
      lines = .render_pkgdown_extra_css()
    ),
    list(
      path = file.path("pkgdown", "extra.js"),
      lines = .render_pkgdown_extra_js(family = family, preset = preset)
    )
  )

  for (target in targets) {
    exists <- file.exists(target$path)
    if (dry_run) {
      if (requireNamespace("cli", quietly = TRUE)) {
        cli::cli_alert_info("Would write/update {.file {target$path}}")
      } else {
        message(sprintf("Would write/update %s", target$path))
      }
      next
    }

    if (exists && !force_replace) next
    writeLines(target$lines, target$path, useBytes = TRUE)
    if (requireNamespace("cli", quietly = TRUE)) {
      cli::cli_alert_success("Wrote {.file {target$path}}")
    } else {
      message(sprintf("Wrote %s", target$path))
    }
  }

  invisible(TRUE)
}

.md5 <- function(path) {
  if (!file.exists(path)) return(NA_character_)
  as.character(utils::head(tools::md5sum(path), 1L))
}

.load_albers_tokens <- function() {
  if (!requireNamespace("yaml", quietly = TRUE)) return(NULL)
  local_tokens <- file.path("inst", "tokens", "albers-tokens.yml")
  pkg_tokens <- system.file("tokens", "albers-tokens.yml", package = "albersdown")
  token_path <- if (file.exists(local_tokens)) local_tokens else pkg_tokens
  if (!nzchar(token_path) || !file.exists(token_path)) return(NULL)
  tryCatch(yaml::read_yaml(token_path), error = function(e) NULL)
}

.hex_to_rgb <- function(hex) {
  if (!is.character(hex) || length(hex) != 1L || !nzchar(hex)) return(NULL)
  x <- trimws(hex)
  if (grepl("^#[0-9A-Fa-f]{3}$", x)) {
    x <- paste0("#", paste(rep(substring(x, 2, 4), each = 2), collapse = ""))
  }
  if (!grepl("^#[0-9A-Fa-f]{6}$", x)) return(NULL)
  as.numeric(grDevices::col2rgb(x)) / 255
}

.linear_channel <- function(u) ifelse(u <= 0.03928, u / 12.92, ((u + 0.055) / 1.055)^2.4)

.relative_luminance <- function(hex) {
  rgb <- .hex_to_rgb(hex)
  if (is.null(rgb)) return(NA_real_)
  lin <- .linear_channel(rgb)
  0.2126 * lin[1] + 0.7152 * lin[2] + 0.0722 * lin[3]
}

.contrast_ratio <- function(fg, bg) {
  lf <- .relative_luminance(fg)
  lb <- .relative_luminance(bg)
  if (any(is.na(c(lf, lb)))) return(NA_real_)
  l1 <- max(lf, lb)
  l2 <- min(lf, lb)
  (l1 + 0.05) / (l2 + 0.05)
}

.doctor_contrast_report <- function(min_ratio = 4.5) {
  tokens <- .load_albers_tokens()
  if (is.null(tokens) || is.null(tokens$families)) {
    return(list(ok = NA, min_ratio = NA_real_, failures = character(), checked = integer()))
  }

  presets <- list(
    homage = list(bg = "#f3f5f7", ink = "#17181a"),
    study = list(bg = "#f7f9fb", ink = "#17181a"),
    structural = list(bg = "#e6e9ed", ink = "#101214"),
    adobe = list(bg = "#ece9e7", ink = "#1f1c19"),
    midnight = list(bg = "#0d1117", ink = "#e8e6e1")
  )

  checks <- list()

  for (preset_name in names(presets)) {
    checks[[paste0("body-light-", preset_name)]] <- .contrast_ratio(
      presets[[preset_name]]$ink,
      presets[[preset_name]]$bg
    )
  }

  for (family_name in names(tokens$families)) {
    fam <- tokens$families[[family_name]]
    for (preset_name in names(presets)) {
      link_fg <- if (identical(preset_name, "midnight") && !is.null(fam$dark$accent_ink)) fam$dark$accent_ink else fam$A900
      checks[[paste0("link-light-", family_name, "-", preset_name)]] <- .contrast_ratio(
        link_fg,
        presets[[preset_name]]$bg
      )
    }
    if (!is.null(fam$dark$accent_ink)) {
      checks[[paste0("link-dark-", family_name)]] <- .contrast_ratio(fam$dark$accent_ink, "#111315")
    }
  }

  checks[["body-dark-default"]] <- .contrast_ratio("#ece8de", "#111315")
  vals <- unlist(checks, use.names = TRUE)
  vals <- vals[!is.na(vals)]
  failing <- names(vals[vals < min_ratio])

  list(
    ok = length(failing) == 0,
    min_ratio = if (length(vals)) min(vals) else NA_real_,
    failures = failing,
    checked = names(vals)
  )
}

.inspect_vignette_theme_yaml <- function(path) {
  if (!requireNamespace("yaml", quietly = TRUE)) return(NULL)

  raw <- readLines(path, warn = FALSE)
  if (length(raw) < 3 || raw[[1]] != "---") return(NULL)
  fence <- which(raw == "---")
  if (length(fence) < 2) return(NULL)

  head <- raw[(fence[[1]] + 1):(fence[[2]] - 1)]
  y <- tryCatch(yaml::yaml.load(paste(head, collapse = "\n")), error = function(e) NULL)
  if (!is.list(y)) return(NULL)

  is_qmd <- grepl("\\.qmd$", basename(path), ignore.case = TRUE)
  if (is_qmd) {
    html <- list()
    if (is.list(y$format) && is.list(y$format$html)) html <- y$format$html
    resources <- .as_char_vec(y$resources)
    return(list(
      nested_css = any(grepl("albers\\.css", .as_char_vec(html$css))),
      nested_header = any(grepl("albers\\.js", .as_char_vec(y[["header-includes"]]))),
      legacy_css = FALSE,
      legacy_header = FALSE,
      resources = all(c("albers.css", "albers.js") %in% resources)
    ))
  }

  output_cur <- y$output
  html_vignette <- if (is.character(output_cur) && length(output_cur) == 1L && identical(output_cur, "rmarkdown::html_vignette")) {
    list()
  } else if (is.list(output_cur)) {
    output_cur[["rmarkdown::html_vignette"]] %||% list()
  } else {
    list()
  }
  includes <- if (is.list(html_vignette$includes)) html_vignette$includes else list()
  resources <- .as_char_vec(y$resource_files)

  list(
    nested_css = any(grepl("albers\\.css", .as_char_vec(html_vignette$css))),
    nested_header = any(grepl("albers-header\\.html|albers\\.js", .as_char_vec(includes$in_header))),
    legacy_css = any(grepl("albers\\.css", .as_char_vec(y$css))),
    legacy_header = any(grepl("albers-header\\.html|albers\\.js", .as_char_vec(y$includes))),
    resources = all(c("albers.css", "albers.js", "albers-header.html") %in% resources)
  )
}

.uses_albers_template <- function() {
  yml <- "_pkgdown.yml"
  if (!file.exists(yml) || !requireNamespace("yaml", quietly = TRUE)) return(FALSE)
  cfg <- tryCatch(yaml::read_yaml(yml), error = function(e) NULL)
  if (is.null(cfg) || isTRUE(is.na(cfg))) return(FALSE)
  tpl <- cfg$template %||% list()
  isTRUE(identical(tpl$package, "albersdown"))
}

.add_website_dep <- function(pkg = "albersdown", dry_run = FALSE) {
  desc <- "DESCRIPTION"
  if (!file.exists(desc)) return(invisible(FALSE))

  lines <- readLines(desc, warn = FALSE)
  fld <- "Config/Needs/website:"
  entry <- pkg

  if (any(grepl("^Config/Needs/website\\s*:", lines))) {
    idx <- grep("^Config/Needs/website\\s*:", lines)[1]
    cur <- sub("^Config/Needs/website\\s*:\\s*", "", lines[idx])
    vals <- unique(strsplit(cur, "\\s*,\\s*")[[1]])
    if (!entry %in% vals) {
      lines[idx] <- sprintf("%s %s, %s", fld, cur, entry)
      if (dry_run) {
        if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_info("Would append {.pkg albersdown} to DESCRIPTION {.code Config/Needs/website}") else message("Would append albersdown to Config/Needs/website")
      } else {
        writeLines(lines, desc, useBytes = TRUE)
        if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_success("Ensured DESCRIPTION has {.code Config/Needs/website}: includes {.pkg albersdown}") else message("Ensured DESCRIPTION has Config/Needs/website: includes albersdown")
      }
    }
  } else {
    lines <- c(lines, sprintf("%s %s", fld, entry))
    if (dry_run) {
      if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_info("Would add DESCRIPTION field {.code Config/Needs/website: albersdown}") else message("Would add Config/Needs/website: albersdown")
    } else {
      writeLines(lines, desc, useBytes = TRUE)
      if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_success("Added DESCRIPTION field {.code Config/Needs/website: albersdown}") else message("Added Config/Needs/website: albersdown")
    }
  }

  invisible(TRUE)
}

.copy_with_policy <- function(src, dst, dry_run = FALSE, force_replace = TRUE, context = "asset") {
  if (!nzchar(src) || !file.exists(src)) return(invisible(FALSE))

  dst_exists <- file.exists(dst)
  same_file <- dst_exists && identical(.md5(src), .md5(dst))

  if (!dst_exists) {
    if (dry_run) {
      if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_info("Would copy {.file {dst}} ({context})") else message(sprintf("Would copy %s (%s)", dst, context))
    } else {
      file.copy(src, dst, overwrite = FALSE)
      if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_success("Copied {.file {dst}} ({context})") else message(sprintf("Copied %s (%s)", dst, context))
    }
    return(invisible(TRUE))
  }

  if (same_file) {
    if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_info("{.file {dst}} already exists and is up-to-date") else message(sprintf("%s already exists and is up-to-date", dst))
    return(invisible(TRUE))
  }

  if (!force_replace) {
    if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_warning("{.file {dst}} differs from packaged copy; keeping local file") else message(sprintf("%s differs from packaged copy; keeping local file", dst))
    return(invisible(TRUE))
  }

  if (dry_run) {
    if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_info("Would replace {.file {dst}} with packaged copy") else message(sprintf("Would replace %s with packaged copy", dst))
  } else {
    file.copy(src, dst, overwrite = TRUE)
    if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_success("Replaced {.file {dst}} with packaged copy") else message(sprintf("Replaced %s with packaged copy", dst))
  }

  invisible(TRUE)
}

.as_char_vec <- function(x) {
  if (is.null(x)) return(character())
  if (is.list(x) && !is.data.frame(x)) return(unlist(lapply(x, as.character), use.names = FALSE))
  as.character(x)
}

.albers_js_tag <- function() '<script src="albers.js"></script>'

.palette_script <- function(family, preset = "homage") {
  classes <- sprintf("'palette-%s'", family)
  if (preset != "homage") classes <- paste0(classes, sprintf(",'preset-%s'", preset))
  sprintf(
    "<script>document.addEventListener('DOMContentLoaded',function(){document.body.classList.add(%s);});</script>",
    classes
  )
}

.strip_albers_lines <- function(lines) {
  lines <- lines[!grepl("albers\\.js", lines)]
  lines <- lines[!grepl("albers-header\\.html", lines)]
  lines <- lines[!grepl("palette-", lines)]
  lines <- lines[!grepl("preset-", lines)]
  lines
}

.drop_named_chunks <- function(lines, labels) {
  if (!length(labels)) return(lines)

  keep <- rep(TRUE, length(lines))
  pattern <- paste0("^```\\{r[^}]*\\b(", paste(labels, collapse = "|"), ")\\b")

  i <- 1L
  while (i <= length(lines)) {
    if (grepl(pattern, lines[[i]], perl = TRUE)) {
      keep[[i]] <- FALSE
      i <- i + 1L
      while (i <= length(lines)) {
        keep[[i]] <- FALSE
        if (grepl("^```\\s*$", lines[[i]], perl = TRUE)) {
          i <- i + 1L
          break
        }
        i <- i + 1L
      }
      next
    }
    i <- i + 1L
  }

  lines[keep]
}

.upsert_in_header_path <- function(value, force_replace = TRUE, target = "albers-header.html") {
  lines <- .as_char_vec(value)
  lines <- lines[nzchar(trimws(lines))]
  if (force_replace) lines <- .strip_albers_lines(lines)
  if (any(grepl("albers-header\\.html", lines))) return(unique(lines))
  unique(c(lines, target))
}

.upsert_header_includes <- function(values, family, preset = "homage", force_replace = TRUE) {
  lines <- .as_char_vec(values)
  lines <- lines[nzchar(trimws(lines))]
  if (force_replace) {
    lines <- .strip_albers_lines(lines)
    lines <- c(lines, .albers_js_tag(), .palette_script(family, preset))
  } else {
    if (!any(grepl("albers\\.js", lines))) lines <- c(lines, .albers_js_tag())
    if (!any(grepl("palette-", lines))) lines <- c(lines, .palette_script(family, preset))
  }
  unique(lines)
}

.replace_or_append_marked_block <- function(lines, block, start_tag, end_tag) {
  start_idx <- which(lines == start_tag)
  end_idx <- which(lines == end_tag)

  if (length(start_idx) && length(end_idx)) {
    start_idx <- start_idx[1]
    end_idx <- end_idx[end_idx > start_idx][1]
    if (!is.na(end_idx)) {
      before <- if (start_idx > 1) lines[seq_len(start_idx - 1)] else character()
      after <- if (end_idx < length(lines)) lines[(end_idx + 1):length(lines)] else character()
      return(c(before, block, after))
    }
  }

  c(lines, "", block)
}
