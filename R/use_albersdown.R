#' One-shot setup for existing packages
#'
#' Turn-key retrofit to adopt the albersdown theme in an existing package.
#' Copies local assets for CRAN-safe vignettes, ensures pkgdown template,
#' optionally patches all vignettes, writes a README note, and prints a doctor report.
#'
#' @param family one of: "red","lapis","ochre","teal","green","violet"
#' @param apply_to "all" to patch every *.Rmd/*.qmd in vignettes/, or "new" to only add the template and assets
#' @param dry_run if TRUE, show changes without writing
#' @param fallback_extra Controls copying site-wide fallbacks into `pkgdown/`:
#'   - "auto": copy `pkgdown/extra.css` and `pkgdown/extra.js` only when the consuming
#'     package does not use `template: { package: albersdown }` in `_pkgdown.yml`.
#'   - "always": always copy to `pkgdown/` (useful as a safety net or for custom setups).
#'   - "never": never copy site-wide fallbacks.
#' @param fallback_extra Controls copying site-wide fallbacks into `pkgdown/`:
#'   - "auto": copy `pkgdown/extra.css` and `pkgdown/extra.js` only when the consuming
#'     package does not use `template: { package: albersdown }` in `_pkgdown.yml`.
#'   - "always": always copy to `pkgdown/` (useful as a safety net or for custom setups).
#'   - "never": never copy site-wide fallbacks.
#' @export
use_albersdown <- function(
  family = "red",
  apply_to = c("all","new"),
  dry_run = FALSE,
  fallback_extra = c("auto","always","never")
) {
  apply_to <- match.arg(apply_to)
  fallback_extra <- match.arg(fallback_extra)
  if (requireNamespace("cli", quietly = TRUE)) cli::cli_h1("albersdown setup") else message("albersdown setup")
  .ensure_pkgdown_template(dry_run = dry_run)
  .add_website_dep(dry_run = dry_run)
  .copy_resources(dry_run = dry_run, fallback_extra = fallback_extra)
  if (apply_to == "all") .patch_all_rmds(family, dry_run)
  .write_readme_snippet(family, dry_run)
  .doctor(family)
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
  # Ensure template points to this package without clobbering other template fields
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

.copy_resources <- function(dry_run = FALSE, fallback_extra = c("auto","always","never")) {
  fallback_extra <- match.arg(fallback_extra)
  dir.create("vignettes", showWarnings = FALSE)
  # CSS for vignettes (skeleton) ensures offline/CRAN builds
  src_css_v <- system.file("rmarkdown/templates/albers_vignette/skeleton/albers.css", package = "albersdown")
  # Site CSS/JS from pkgdown assets (anchors + copy buttons)
  src_css_site <- system.file("pkgdown/assets/albers.css", package = "albersdown")
  src_js  <- system.file("pkgdown/assets/albers.js", package = "albersdown")
  dst_css <- file.path("vignettes", "albers.css")
  dst_js  <- file.path("vignettes", "albers.js")
  for (pair in list(c(src_css_v, dst_css), c(src_js, dst_js))) {
    if (!nzchar(pair[1]) || !file.exists(pair[1])) next
    src <- pair[1]; dst <- pair[2]
    if (!file.exists(dst)) {
      if (dry_run) {
        if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_info("Would copy {.file %s}", dst) else message(sprintf("Would copy %s", dst))
      } else {
        file.copy(src, dst, overwrite = FALSE)
        if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_success("Copied {.file %s}", dst) else message(sprintf("Copied %s", dst))
      }
    } else {
      # checksum-based drift detection
      h_src <- .md5(src); h_dst <- .md5(dst)
      if (!is.na(h_src) && !is.na(h_dst) && identical(h_src, h_dst)) {
        if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_info("{.file %s} already exists and is up-to-date", dst) else message(sprintf("%s already exists and is up-to-date", dst))
      } else {
        if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_warning("{.file %s} differs from packaged copy; keeping local file", dst) else message(sprintf("%s differs from packaged copy; keeping local file", dst))
      }
    }
  }
  # Warn loudly if packaged sources are missing and no local files exist
  if ((!nzchar(src_css_v) || !file.exists(src_css_v)) && !file.exists(dst_css)) {
    msg <- "Packaged vignette CSS not found and vignettes/albers.css is missing; vignette styling will be absent"
    if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_warning(msg) else message(msg)
  }
  if ((!nzchar(src_js) || !file.exists(src_js)) && !file.exists(dst_js)) {
    msg <- "Packaged vignette JS not found and vignettes/albers.js is missing; copy buttons/anchors may be absent"
    if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_warning(msg) else message(msg)
  }

  # Fallback for pkgdown sites that are not using the albersdown template:
  # copy site-wide assets to pkgdown/extra.css and pkgdown/extra.js so pkgdown
  # auto-includes them. This is only done when the template is absent to avoid
  # interfering with other templates.
  if (identical(fallback_extra, "always") || (identical(fallback_extra, "auto") && !.uses_albers_template())) {
    dir.create("pkgdown", showWarnings = FALSE)
    site_pairs <- list(
      c(src_css_site, file.path("pkgdown", "extra.css")),
      c(src_js,  file.path("pkgdown", "extra.js"))
    )
    for (pair in site_pairs) {
      if (!nzchar(pair[1]) || !file.exists(pair[1])) next
      src <- pair[1]; dst <- pair[2]
      if (!file.exists(dst)) {
        if (dry_run) {
          if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_info("Would copy {.file %s}", dst) else message(sprintf("Would copy %s", dst))
        } else {
          file.copy(src, dst, overwrite = FALSE)
          if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_success("Copied {.file %s} (pkgdown fallback)", dst) else message(sprintf("Copied %s (pkgdown fallback)", dst))
        }
      } else {
        h_src <- .md5(src); h_dst <- .md5(dst)
        if (!is.na(h_src) && !is.na(h_dst) && identical(h_src, h_dst)) {
          if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_info("{.file %s} already exists and is up-to-date", dst) else message(sprintf("%s already exists and is up-to-date", dst))
        } else {
          if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_warning("{.file %s} differs from packaged copy; keeping local file", dst) else message(sprintf("%s differs from packaged copy; keeping local file", dst))
        }
      }
    }
  }
  invisible(TRUE)
}

.patch_all_rmds <- function(family, dry_run = FALSE) {
  files <- c(Sys.glob("vignettes/*.Rmd"), Sys.glob("vignettes/*.qmd"))
  if (!length(files)) {
    if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_info("No vignettes found to patch") else message("No vignettes found to patch")
    return(invisible(TRUE))
  }
  for (f in files) .patch_one_rmd(f, family, dry_run)
  invisible(TRUE)
}

.patch_one_rmd <- function(path, family, dry_run = FALSE) {
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
  head <- raw[(fence[1]+1):(fence[2]-1)]
  body <- raw[(fence[2]+1):length(raw)]
  y <- tryCatch(yaml::yaml.load(paste(head, collapse = "\n")), error = function(e) NULL)
  if (is.null(y)) {
    if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_warning("Could not parse YAML in {.file {basename(path)}}; skipping") else message(sprintf("Could not parse YAML in %s; skipping", basename(path)))
    return(invisible(FALSE))
  }

  # Ensure params and family
  y$params <- .modify_list(list(family = family), y$params %||% list())

  is_qmd <- grepl("\\.qmd$", basename(path), ignore.case = TRUE)
  if (is_qmd) {
    # Quarto: use format.html keys and resources
    y$format <- y$format %||% list(html = list())
    if (is.null(y$format$html)) y$format$html <- list()
    # css array
    css_cur <- y$format$html$css %||% NULL
    y$format$html$css <- unique(c(as.character(css_cur), "albers.css"))
    # include-in-header referencing our JS file
    inc_hdr <- y$format$html[["include-in-header"]] %||% NULL
    y$format$html[["include-in-header"]] <- unique(c(as.character(inc_hdr), "albers.js"))
    # resources ensure copying
    res <- y$resources %||% NULL
    y$resources <- unique(c(as.character(res), "albers.css", "albers.js"))
  } else {
    # R Markdown: ensure output, css, includes, resource_files
    y$output <- y$output %||% list(`rmarkdown::html_vignette` = list(toc = TRUE, toc_depth = 2))
    if (is.null(y$css)) {
      y$css <- "albers.css"
    } else if (is.character(y$css)) {
      if (!"albers.css" %in% y$css) y$css <- unique(c(y$css, "albers.css"))
    }
    # resource_files guarantees file copying
    rf <- y$resource_files %||% NULL
    y$resource_files <- unique(c(as.character(rf), "albers.css", "albers.js"))
    # header include for local JS and palette family script
    inject_palette <- sprintf(
      "<script>document.addEventListener('DOMContentLoaded',()=>document.body.classList.add('palette-%s'));</script>",
      family
    )
    inc <- y$includes %||% list()
    in_header <- inc$in_header %||% ""
    if (!grepl("albers\\.js", in_header, fixed = FALSE)) {
      in_header <- paste0(in_header, if (nzchar(in_header)) "\n" else "", "<script src=\"albers.js\"></script>")
    }
    if (!grepl("palette-", in_header, fixed = TRUE)) {
      in_header <- paste0(in_header, if (nzchar(in_header)) "\n" else "", inject_palette)
    }
    inc$in_header <- in_header
    y$includes <- inc
  }

  new_head <- yaml::as.yaml(y)
  out <- c("---", new_head, "---", body)
  if (!dry_run) {
    dir.create(".albersdown.bak", showWarnings = FALSE)
    file.copy(path, file.path(".albersdown.bak", basename(path)), overwrite = TRUE)
    writeLines(out, path, useBytes = TRUE)
  }
  if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_success("Updated YAML in {.file {basename(path)}}") else message(sprintf("Updated YAML in %s", basename(path)))

  # ensure setup chunk sets theme (idempotent). Prefer ggplot2::theme_set.
  ensure_theme <- function(lines) {
    has_qualified <- any(grepl("ggplot2::theme_set\\(albersdown::theme_albers\\(", lines, fixed = TRUE))
    if (has_qualified) return(lines)
    # If an unqualified theme_set() exists, upgrade it in place
    unqual_idx <- grep("(^|[^:])theme_set\\(albersdown::theme_albers\\(", lines)
    if (length(unqual_idx)) {
      lines[unqual_idx] <- sub(
        pattern = "theme_set\\(albersdown::theme_albers\\(",
        replacement = "ggplot2::theme_set(albersdown::theme_albers(",
        x = lines[unqual_idx]
      )
      return(lines)
    }
    # Otherwise, inject into existing setup chunk if present
    pos <- grep("^```\\{r.*setup", lines)
    if (!length(pos)) return(lines)  # no setup chunk; don't invent one
    inject <- "if (requireNamespace(\"ggplot2\", quietly = TRUE) && requireNamespace(\"albersdown\", quietly = TRUE)) ggplot2::theme_set(albersdown::theme_albers(params$family))"
    lines <- append(lines, inject, after = pos[1])
    lines
  }
  if (!dry_run) writeLines(ensure_theme(readLines(path, warn = FALSE)), path, useBytes = TRUE)
  invisible(TRUE)
}

.write_readme_snippet <- function(family, dry_run = FALSE) {
  tip <- paste0(
    "\n\n## Albers theme\n",
    "This package uses the albersdown theme. Vignettes are styled with `vignettes/albers.css` and a local `vignettes/albers.js`; the palette family is provided via `params$family` (default '",
    family, "'). The pkgdown site uses `template: { package: albersdown }`.\n"
  )
  if (file.exists("README.md")) {
    if (dry_run) {
      if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_info("Would append Albers note to {.file README.md}") else message("Would append Albers note to README.md")
    } else {
      cat(tip, file = "README.md", append = TRUE)
      if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_success("Appended Albers note to {.file README.md}") else message("Appended Albers note to README.md")
    }
  }
  invisible(TRUE)
}

.doctor <- function(family) {
  if (requireNamespace("cli", quietly = TRUE)) cli::cli_h2("Doctor") else message("Doctor")
  ok_css <- file.exists("vignettes/albers.css")
  ok_js  <- file.exists("vignettes/albers.js")
  if (requireNamespace("cli", quietly = TRUE)) {
    cli::cli_alert_success("CSS present: {ok_css}")
    cli::cli_alert_success("JS present:  {ok_js}")
  } else {
    message(sprintf("CSS present: %s", ok_css))
    message(sprintf("JS present: %s", ok_js))
  }
  # drift report
  src_css <- system.file("rmarkdown/templates/albers_vignette/skeleton/albers.css", package = "albersdown")
  src_js  <- system.file("pkgdown/assets/albers.js", package = "albersdown")
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
  v <- c(Sys.glob("vignettes/*.Rmd"), Sys.glob("vignettes/*.qmd"))
  if (length(v)) {
    missing_css <- v[!vapply(v, function(p) any(grepl("css:\\s*.*albers\\.css", readLines(p))), logical(1))]
    if (length(missing_css)) {
      if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_warning("These vignettes do not include albers.css: {missing_css}") else message(sprintf("These vignettes do not include albers.css: %s", paste(basename(missing_css), collapse = ", ")))
    }
    missing_js <- v[!vapply(v, function(p) any(grepl("albers\\.js", readLines(p))), logical(1))]
    if (length(missing_js)) {
      if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_warning("These vignettes do not include albers.js: {missing_js}") else message(sprintf("These vignettes do not include albers.js: %s", paste(basename(missing_js), collapse = ", ")))
    }
    fams <- vapply(v, function(p) {
      any(grepl(sprintf("palette-%s", family), readLines(p)))
    }, logical(1))
    if (!all(fams)) {
      if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_info("Some vignettes omit the palette script; they will default to 'red'") else message("Some vignettes omit the palette script; they will default to 'red'")
    }
  }
  # Check pkgdown/extra.css includes anchor hover rules if present
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
  for (nm in names(val)) x[[nm]] <- val[[nm]]
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
    i <- grep("^Config/Needs/website\\s*:", lines)[1]
    cur <- sub("^Config/Needs/website\\s*:\\s*", "", lines[i])
    vals <- unique(strsplit(cur, "\\s*,\\s*")[[1]])
    if (!entry %in% vals) {
      lines[i] <- sprintf("%s %s, %s", fld, cur, entry)
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
