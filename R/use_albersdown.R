#' One-shot setup for existing packages
#'
#' Turn-key retrofit to adopt the albersdown theme in an existing package.
#' Copies local assets for CRAN-safe vignettes, ensures pkgdown template,
#' optionally patches all vignettes, writes a README note, and prints a doctor report.
#'
#' @param family one of: "red","lapis","ochre","teal","green","violet"
#' @param preset Visual preset (default \code{"homage"}). See [albers_presets()].
#' @param apply_to "all" to patch every *.Rmd/*.qmd in vignettes/, or "new" to only add the template and assets
#' @param dry_run if TRUE, show changes without writing
#' @param fallback_extra Controls copying site-wide fallbacks into `pkgdown/`:
#'   - "auto": copy `pkgdown/extra.css` and `pkgdown/extra.js` only when the consuming
#'     package does not use `template: { package: albersdown }` in `_pkgdown.yml`.
#'   - "always": always copy to `pkgdown/` (useful as a safety net or for custom setups).
#'   - "never": never copy site-wide fallbacks.
#' @param force_replace if TRUE (default), overwrite existing albersdown assets and
#'   replace existing vignette CSS/header hooks so albersdown becomes the active theme.
#' @export
use_albersdown <- function(
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
  if (requireNamespace("cli", quietly = TRUE)) cli::cli_h1("albersdown setup") else message("albersdown setup")
  .ensure_pkgdown_template(dry_run = dry_run)
  .add_website_dep(dry_run = dry_run)
  .copy_resources(dry_run = dry_run, fallback_extra = fallback_extra, force_replace = force_replace)
  if (apply_to == "all") .patch_all_rmds(family = family, preset = preset, dry_run = dry_run, force_replace = force_replace)
  .write_readme_snippet(family = family, dry_run = dry_run)
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

.copy_resources <- function(dry_run = FALSE, fallback_extra = c("auto", "always", "never"), force_replace = TRUE) {
  fallback_extra <- match.arg(fallback_extra)
  dir.create("vignettes", showWarnings = FALSE)

  src_css_v_local <- file.path("inst", "rmarkdown", "templates", "albers_vignette", "skeleton", "albers.css")
  src_css_site_local <- file.path("inst", "pkgdown", "assets", "albers.css")
  src_js_local <- file.path("inst", "pkgdown", "assets", "albers.js")

  src_css_v <- if (file.exists(src_css_v_local)) src_css_v_local else system.file("rmarkdown/templates/albers_vignette/skeleton/albers.css", package = "albersdown")
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

  if ((!nzchar(src_css_v) || !file.exists(src_css_v)) && !file.exists(file.path("vignettes", "albers.css"))) {
    msg <- "Packaged vignette CSS not found and vignettes/albers.css is missing; vignette styling will be absent"
    if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_warning(msg) else message(msg)
  }
  if ((!nzchar(src_js) || !file.exists(src_js)) && !file.exists(file.path("vignettes", "albers.js"))) {
    msg <- "Packaged vignette JS not found and vignettes/albers.js is missing; copy buttons/anchors may be absent"
    if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_warning(msg) else message(msg)
  }

  if (identical(fallback_extra, "always") || (identical(fallback_extra, "auto") && !.uses_albers_template())) {
    dir.create("pkgdown", showWarnings = FALSE)
    .copy_with_policy(
      src = src_css_site,
      dst = file.path("pkgdown", "extra.css"),
      dry_run = dry_run,
      force_replace = force_replace,
      context = "pkgdown fallback"
    )
    .copy_with_policy(
      src = src_js,
      dst = file.path("pkgdown", "extra.js"),
      dry_run = dry_run,
      force_replace = force_replace,
      context = "pkgdown fallback"
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

  y$params <- .modify_list(list(family = family, preset = preset), y$params %||% list())

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
    y$output <- y$output %||% list(`rmarkdown::html_vignette` = list(toc = TRUE, toc_depth = 2))

    css_cur <- .as_char_vec(y$css)
    y$css <- if (force_replace) "albers.css" else unique(c(css_cur, "albers.css"))

    resources <- .as_char_vec(y$resource_files)
    y$resource_files <- unique(c(resources, "albers.css", "albers.js"))

    includes <- y$includes %||% list()
    includes$in_header <- .upsert_in_header_block(
      value = includes$in_header,
      family = family,
      preset = preset,
      force_replace = force_replace
    )
    y$includes <- includes
  }

  new_head <- yaml::as.yaml(y)
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

    target <- "ggplot2::theme_set\\(albersdown::theme_albers\\("
    idx <- grep(target, lines, perl = TRUE)
    if (length(idx) > 1) lines <- lines[-idx[-length(idx)]]
    if (length(idx) >= 1) return(lines)

    setup_chunk <- grep("^```\\{r[^}]*setup", lines)
    if (!length(setup_chunk)) return(lines)

    inject <- "if (requireNamespace(\"ggplot2\", quietly = TRUE) && requireNamespace(\"albersdown\", quietly = TRUE)) ggplot2::theme_set(albersdown::theme_albers(params$family))"
    append(lines, inject, after = setup_chunk[1])
  }

  if (!dry_run) writeLines(ensure_theme(readLines(path, warn = FALSE)), path, useBytes = TRUE)
  invisible(TRUE)
}

.write_readme_snippet <- function(family, dry_run = FALSE) {
  if (!file.exists("README.md")) return(invisible(TRUE))

  start_tag <- "<!-- albersdown:theme-note:start -->"
  end_tag <- "<!-- albersdown:theme-note:end -->"
  block <- c(
    start_tag,
    "## Albers theme",
    paste0(
      "This package uses the albersdown theme. Existing vignette theme hooks are replaced so `albers.css` and local `albers.js` render consistently on CRAN and GitHub Pages. The palette family is provided via `params$family` (default '",
      family,
      "'). The pkgdown site uses `template: { package: albersdown }`."
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

  ok_css <- file.exists("vignettes/albers.css")
  ok_js <- file.exists("vignettes/albers.js")
  if (requireNamespace("cli", quietly = TRUE)) {
    cli::cli_alert_success("CSS present: {ok_css}")
    cli::cli_alert_success("JS present:  {ok_js}")
  } else {
    message(sprintf("CSS present: %s", ok_css))
    message(sprintf("JS present: %s", ok_js))
  }

  src_css_local <- file.path("inst", "rmarkdown", "templates", "albers_vignette", "skeleton", "albers.css")
  src_css <- if (file.exists(src_css_local)) src_css_local else system.file("rmarkdown/templates/albers_vignette/skeleton/albers.css", package = "albersdown")
  src_js_local <- file.path("inst", "pkgdown", "assets", "albers.js")
  src_js <- if (file.exists(src_js_local)) src_js_local else system.file("pkgdown/assets/albers.js", package = "albersdown")
  if (ok_css && nzchar(src_css) && file.exists(src_css)) {
    if (!identical(.md5(src_css), .md5("vignettes/albers.css"))) {
      if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_warning("vignettes/albers.css is not the packaged version (drift detected)") else message("vignettes/albers.css drift detected")
    }
  }
  if (ok_js && nzchar(src_js) && file.exists(src_js)) {
    if (!identical(.md5(src_js), .md5("vignettes/albers.js"))) {
      if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_warning("vignettes/albers.js is not the packaged version (drift detected)") else message("vignettes/albers.js drift detected")
    }
  }

  if (file.exists("_pkgdown.yml") && requireNamespace("yaml", quietly = TRUE)) {
    cfg <- tryCatch(yaml::read_yaml("_pkgdown.yml"), error = function(e) NULL)
    tpl <- if (is.list(cfg)) (cfg$template %||% list()) else list()
    if (!identical(tpl$package, "albersdown")) {
      msg <- "_pkgdown.yml template does not point at albersdown; pkgdown theme replacement is incomplete"
      if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_warning(msg) else message(msg)
    }
  }

  v <- c(Sys.glob("vignettes/*.Rmd"), Sys.glob("vignettes/*.qmd"))
  if (length(v)) {
    missing_css <- v[!vapply(v, function(path) any(grepl("albers\\.css", readLines(path, warn = FALSE))), logical(1))]
    if (length(missing_css)) {
      if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_warning("These vignettes do not reference albers.css: {missing_css}") else message(sprintf("These vignettes do not reference albers.css: %s", paste(basename(missing_css), collapse = ", ")))
    }

    missing_js <- v[!vapply(v, function(path) any(grepl("albers\\.js", readLines(path, warn = FALSE))), logical(1))]
    if (length(missing_js)) {
      if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_warning("These vignettes do not reference albers.js: {missing_js}") else message(sprintf("These vignettes do not reference albers.js: %s", paste(basename(missing_js), collapse = ", ")))
    }

    family_ok <- vapply(v, function(path) any(grepl("palette-", readLines(path, warn = FALSE))), logical(1))
    if (!all(family_ok)) {
      if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_info("Some vignettes omit any palette script; they may fall back to default tokens") else message("Some vignettes omit any palette script; they may fall back to default tokens")
    }

    dup_theme <- v[vapply(v, function(path) sum(grepl("ggplot2::theme_set\\(albersdown::theme_albers\\(", readLines(path, warn = FALSE), perl = TRUE)) > 1, logical(1))]
    if (length(dup_theme)) {
      if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_warning("These vignettes define albers theme_set multiple times: {dup_theme}") else message(sprintf("These vignettes define albers theme_set multiple times: %s", paste(basename(dup_theme), collapse = ", ")))
    }
  }

  if (file.exists("pkgdown/extra.css")) {
    css <- readLines("pkgdown/extra.css", warn = FALSE)
    has_anchor <- any(grepl("\\.anchor\\s*\\{", css))
    has_hover <- any(grepl("h2:hover \\.anchor|h3:hover \\.anchor", css))
    if (has_anchor && !has_hover) {
      msg <- "pkgdown/extra.css defines .anchor but misses hover/focus rules; anchors may always show"
      if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_warning(msg) else message(msg)
    }
  }

  invisible(TRUE)
}

`%||%` <- function(a, b) if (is.null(a)) b else a

.modify_list <- function(x, val) {
  if (is.null(val)) return(x)
  for (name in names(val)) x[[name]] <- val[[name]]
  x
}

.md5 <- function(path) {
  if (!file.exists(path)) return(NA_character_)
  as.character(utils::head(tools::md5sum(path), 1L))
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
  lines <- lines[!grepl("palette-", lines)]
  lines <- lines[!grepl("preset-", lines)]
  lines
}

.upsert_in_header_block <- function(value, family, preset = "homage", force_replace = TRUE) {
  lines <- if (is.null(value) || !nzchar(value)) character() else strsplit(as.character(value), "\\n", fixed = FALSE)[[1]]
  if (force_replace) {
    lines <- .strip_albers_lines(lines)
    lines <- c(lines, .albers_js_tag(), .palette_script(family, preset))
  } else {
    if (!any(grepl("albers\\.js", lines))) lines <- c(lines, .albers_js_tag())
    if (!any(grepl("palette-", lines))) lines <- c(lines, .palette_script(family, preset))
  }
  lines <- unique(lines)
  lines <- lines[nzchar(trimws(lines))]
  paste(lines, collapse = "\n")
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
