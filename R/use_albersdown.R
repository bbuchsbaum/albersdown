#' One-shot setup for existing packages
#'
#' Adopt the albersdown theme in an existing package.
#'
#' With `method = "format"` (the default) each `vignettes/*.Rmd` whose first
#' output format is `html_vignette` is switched to [albers_vignette()], and
#' `_pkgdown.yml` is pointed at the albersdown template (it is created, and
#' added to `.Rbuildignore` with `docs/`, if missing). `DESCRIPTION` gains
#' `bbuchsbaum/albersdown` in `Config/Needs/website`. When at least one
#' vignette is on the format, it also gains `albersdown (>= <installed
#' version>)` in `Suggests` (or that bound where albersdown is already in
#' `Imports`/`Depends`), `knitr` and `rmarkdown`, and `VignetteBuilder: knitr`;
#' and, when the installed albersdown is a development version (not on CRAN),
#' `Remotes: bbuchsbaum/albersdown`, so that R CMD check and CI install the
#' version with `albers_vignette()` (`R CMD check --as-cran` notes that
#' field). Otherwise (no vignettes, none convertible, or `apply_to = "new"`
#' with none already on the format) the adoption is site-only and no field that
#' R CMD check reads is changed. Nothing is copied into
#' `vignettes/`. Edits are textual (other output formats, comments, key order
#' and line endings are kept) and each changed file is backed up to
#' `.albersdown.bak/`, which is added to `.Rbuildignore` and `.gitignore`.
#'
#' A package set up by albersdown 2.0 (the vendor setup) is migrated: the
#' setup-chunk lines and `params` (`family`, `preset`) that 2.0 added are
#' removed, as are its generated `pkgdown/extra.css` (an `@import` of the
#' theme) and `pkgdown/extra.js`, and its README note is rewritten. The copied
#' `albers.css`, `albers.js`, `albers-header.html` and fonts in `vignettes/` are
#' moved to `.albersdown.bak/` once no remaining vignette uses them.
#'
#' Quarto vignettes, flow-style `output: {...}` headers and pkgdown-only
#' articles in `vignettes/articles/` are listed but not changed: articles take the site default family unless you
#' set `output: albersdown::albers_vignette` in their YAML by hand.
#'
#' With `method = "vendor"` the stylesheet, script and fonts are copied into
#' `vignettes/` and each vignette keeps `rmarkdown::html_vignette` with the
#' theme's css and header include (the albersdown 2.0 setup).
#'
#' @param path Path to the package directory.  Must be supplied explicitly;
#'   there is no default so that the function never writes to an unexpected
#'   location.
#' @param family One of `"red"`, `"lapis"`, `"ochre"`, `"teal"`, `"green"`,
#'   `"violet"` (case-insensitive). If not given, the family the package
#'   already uses is kept: from its vignettes (a `family:` stated in their
#'   `albers_vignette()` entries, or albersdown 2.0's `params`; the most
#'   common if they differ), else from site defaults in `pkgdown/extra.js` or
#'   `_pkgdown.yml`, else `"red"`. With `apply_to = "new"` the site defaults
#'   come first. A message says which was kept and where it came from.
#' @param preset Direction, `"homage"` or `"interaction"` (legacy presets are
#'   accepted; case-insensitive). If not given, inferred like `family`, else
#'   `"homage"`. See [albers_presets()].
#' @param apply_to `"all"` to convert the vignettes as well (every `*.Rmd` in
#'   `vignettes/`; with `method = "vendor"` also `*.qmd`), or `"new"` to set up
#'   only `_pkgdown.yml`, the site defaults and `DESCRIPTION` (vignette
#'   dependencies only if a vignette is already on the format).
#' @param method `"format"` (default) or `"vendor"`; see Details.
#' @param readme If `TRUE`, add a short note about the theme to `README.Rmd`
#'   (re-knit it afterwards) or, when there is none, `README.md` (default
#'   `FALSE`), describing the setup `method` makes.
#' @param dry_run if TRUE, report the changes (including `.Rbuildignore` and
#'   `.gitignore` entries) without writing anything.
#' @param fallback_extra `method = "vendor"` only. Controls writing site-wide
#'   fallbacks into `pkgdown/`:
#'   - "auto": write `pkgdown/extra.css` and `pkgdown/extra.js` whenever
#'     site-wide defaults are needed.
#'   - "always": always write to `pkgdown/` (useful as a safety net or for custom setups).
#'   - "never": never copy site-wide fallbacks.
#'
#'   With `method = "format"`, only the site default family is written, to
#'   `pkgdown/extra.js`, and only when it is not red/homage (or was set before).
#' @param force_replace `method = "vendor"` only. If TRUE (default), overwrite
#'   existing albersdown assets and replace existing vignette CSS/header hooks
#'   so albersdown becomes the active theme.
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
  preset = c("homage", "interaction", "study", "structural", "adobe", "midnight"),
  apply_to = c("all", "new"),
  dry_run = FALSE,
  fallback_extra = c("auto", "always", "never"),
  force_replace = TRUE,
  method = c("format", "vendor"),
  readme = FALSE
) {
  apply_to <- match.arg(apply_to)
  fallback_extra <- match.arg(fallback_extra)
  method <- match.arg(method)
  infer <- c(family = missing(family), preset = missing(preset))
  family <- .albers_choice(family, .albers_families, "family", "use_albersdown")
  preset <- .albers_choice(preset, .albers_all_presets, "preset", "use_albersdown")
  if (!file.exists(file.path(path, "DESCRIPTION"))) {
    stop("`path` must be an R package (no DESCRIPTION in ", normalizePath(path, mustWork = FALSE), ").", call. = FALSE)
  }
  oldwd <- setwd(path)
  on.exit(setwd(oldwd), add = TRUE)
  if (requireNamespace("cli", quietly = TRUE)) cli::cli_h1("albersdown setup") else message("albersdown setup")

  # Not given: keep what the package already uses (a re-run, or a package
  # set up by albersdown 2.0) rather than resetting it to red/homage.
  if (any(infer)) {
    found <- .albers_infer_choice(names(infer)[infer], site_first = identical(apply_to, "new"))
    for (key in names(found)) {
      f <- found[[key]]
      if (identical(key, "family")) family <- f$value else preset <- f$value
      .albers_say(sprintf("Kept the package's %s: %s (from %s%s); pass `%s` to change it",
                          key, f$value, f$from, if (nzchar(f$note)) paste0("; ", f$note) else "", key),
                  if (nzchar(f$note)) "warning" else "info")
    }
  }

  if (identical(method, "format")) {
    changed <- .ensure_pkgdown_template_text(dry_run = dry_run)
    files <- c(Sys.glob("vignettes/*.Rmd"), Sys.glob("vignettes/*.rmd"))
    if (apply_to == "all") {
      status <- vapply(files, .patch_rmd_to_format, character(1), family = family, preset = preset, dry_run = dry_run)
      changed <- c(changed, status %in% c("converted", "updated"))
      qmd <- Sys.glob("vignettes/*.qmd")
      if (length(qmd)) {
        .albers_say(sprintf(
          "Not converted: %s (Quarto; albers_vignette() is an R Markdown format, so these keep their own theme)",
          paste(basename(qmd), collapse = ", ")), "warning")
      }
      articles <- c(Sys.glob("vignettes/articles/*.Rmd"), Sys.glob("vignettes/articles/*.qmd"))
      if (length(articles)) {
        .albers_say(sprintf(paste(
          "Not converted: %s in vignettes/articles/ (pkgdown-only articles take the site default family;",
          "to give one its own, set `output: albersdown::albers_vignette` with family/preset in its YAML by hand)"),
          paste(basename(articles), collapse = ", ")), "warning")
      }
      others <- c(files[status == "skipped"], qmd, articles)
      changed <- c(changed, .albers_retire_vendored(others, dry_run = dry_run))
      on_format <- any(status != "skipped")
    } else {
      on_format <- any(vapply(files, .albers_on_format, logical(1)))
    }
    # vignette dependencies (and Remotes) only for vignettes on the format: a
    # site-only adoption touches no field that R CMD check reads
    changed <- c(changed, .ensure_vignette_deps(dry_run = dry_run, vignettes = on_format))
    if (!on_format) {
      .albers_say(paste(
        "No vignettes on albersdown::albers_vignette(): DESCRIPTION gets only Config/Needs/website.",
        "Re-run use_albersdown() after switching a vignette to the format to add its dependencies."))
    }
    changed <- c(changed, .albers_retire_extra_css(dry_run = dry_run))
    # the site default follows the family, including a return to red/homage
    js <- file.path("pkgdown", "extra.js")
    js_lines <- if (file.exists(js)) readLines(js, warn = FALSE) else character()
    has_defaults <- any(grepl("^window\\.albersdownDefaults\\s*=", js_lines)) || .albers_legacy_extra_js(js_lines)
    if (has_defaults || !(identical(family, "red") && identical(preset, "homage"))) {
      changed <- c(changed, .albers_site_defaults(family = family, preset = preset, dry_run = dry_run))
    }
    # albersdown 2.0's README note describes the vendored setup: replace it
    # once the vignettes have moved to the format; while they have not, it
    # is still true of them
    vendor_note <- .albers_readme_has_vendor_note()
    if (isTRUE(readme) || (vendor_note && on_format)) {
      .write_readme_snippet(family = family, preset = preset, dry_run = dry_run, method = "format", on_format = on_format)
    } else if (vendor_note) {
      .albers_say("README note from albersdown 2.0 left as is: no vignette is on albersdown::albers_vignette() yet")
    }
    if (dir.exists(".albersdown.bak") || (dry_run && any(changed))) {
      .albers_build_ignore("^\\.albersdown\\.bak$", dry_run = dry_run)
      .albers_build_ignore(".albersdown.bak/", file = ".gitignore", dry_run = dry_run)
    }
    .albers_say(if (dry_run) "Dry run: no files were changed." else if (on_format)
      "Vignettes use albersdown::albers_vignette(); the theme is embedded when they render." else
      "The pkgdown site uses the albersdown template.")
    return(invisible(TRUE))
  }

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
  if (isTRUE(readme)) .write_readme_snippet(family = family, preset = preset, dry_run = dry_run)
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

  src_css_v_local <- file.path("inst", "pkgdown", "assets", "albers.css")
  src_header_local <- file.path("inst", "format", "albers-header.html")
  src_css_site_local <- file.path("inst", "pkgdown", "assets", "albers.css")
  src_js_local <- file.path("inst", "pkgdown", "assets", "albers.js")

  src_css_v <- if (file.exists(src_css_v_local)) src_css_v_local else system.file("pkgdown/assets/albers.css", package = "albersdown")
  src_header <- if (file.exists(src_header_local)) src_header_local else system.file("format/albers-header.html", package = "albersdown")
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

  # Web fonts (woff2) for the page @font-face. Copied next to albers.css so the
  # relative url(fonts/...) resolves and self-contained html_vignette embeds
  # them -- otherwise the typography falls back to system fonts on CRAN.
  src_fonts_local <- file.path("inst", "fonts")
  src_fonts <- if (dir.exists(src_fonts_local)) src_fonts_local else system.file("fonts", package = "albersdown")
  woff2 <- if (nzchar(src_fonts) && dir.exists(src_fonts)) {
    list.files(src_fonts, pattern = "\\.woff2$", full.names = TRUE)
  } else {
    character(0)
  }
  if (length(woff2) > 0L) {
    if (!dry_run) {
      dir.create(file.path("vignettes", "fonts"), showWarnings = FALSE, recursive = TRUE)
      copied <- 0L
      for (f in woff2) {
        dst <- file.path("vignettes", "fonts", basename(f))
        if (force_replace || !file.exists(dst)) {
          file.copy(f, dst, overwrite = TRUE)
          copied <- copied + 1L
        }
      }
      if (copied > 0L) {
        msg <- sprintf("Copied %d web font(s) to 'vignettes/fonts/'", copied)
        if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_success(msg) else message(msg)
      }
    }
  } else {
    msg <- "Packaged web fonts (woff2) not found; vignette @font-face will fall back to system fonts"
    if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_warning(msg) else message(msg)
  }

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
  # Vignettes already on the output format carry the theme themselves; leave
  # them exactly as they are.
  if (any(grepl("albersdown::albers_vignette", raw, fixed = TRUE))) {
    msg <- sprintf("%s already uses albersdown::albers_vignette(); left unchanged", basename(path))
    if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_info(msg) else message(msg)
    return(invisible(TRUE))
  }
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
    y$resources <- unique(c(resources, "albers.css", "albers.js", "fonts"))

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
    # `html_vignette: default` parses to a string
    if (!is.list(html_vignette)) html_vignette <- list()

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
    y$resource_files <- unique(c(resources, "albers.css", "albers.js", "albers-header.html", "fonts"))
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
      "    '<script>(function(){',",
      "    'document.body.classList.remove(\"palette-red\",\"palette-lapis\",\"palette-ochre\",\"palette-teal\",\"palette-green\",\"palette-violet\",\"preset-homage\",\"preset-interaction\",\"preset-study\",\"preset-structural\",\"preset-adobe\",\"preset-midnight\");',",
      "    'document.body.classList.add(\"palette-%s\",\"preset-%s\");',",
      "    '})();</script>'",
      "  ),",
      "  params$family,",
      "  params$preset",
      "))",
      "```"
    )

    append(lines, c("", inject), after = setup_end[1])
  }

  ensure_fonts <- function(lines) {
    inject <- c(
      "if (requireNamespace(\"ragg\", quietly = TRUE)) knitr::opts_chunk$set(dev = \"ragg_png\")",
      "if (",
      "  requireNamespace(\"systemfonts\", quietly = TRUE) &&",
      "  requireNamespace(\"albersdown\", quietly = TRUE) &&",
      "  \"albers_register_fonts\" %in% getNamespaceExports(\"albersdown\")",
      ") {",
      "  albersdown::albers_register_fonts()",
      "}"
    )

    old_call <- "^\\s*if \\(requireNamespace\\(\"systemfonts\", quietly = TRUE\\)\\) albersdown::albers_register_fonts\\(\\)\\s*$"
    if (any(grepl(old_call, lines))) {
      replacement <- if (any(grepl("knitr::opts_chunk\\$set\\(dev = \"ragg_png\"\\)", lines))) inject[-1] else inject
      out <- character()
      for (line in lines) {
        if (grepl(old_call, line)) out <- c(out, replacement) else out <- c(out, line)
      }
      return(out)
    }

    if (any(grepl("\"albers_register_fonts\" %in% getNamespaceExports(\"albersdown\")", lines, fixed = TRUE))) {
      return(lines)
    }

    if (any(grepl("albers_register_fonts", lines, fixed = TRUE))) return(lines)

    setup_chunk <- grep("^```\\{r[^}]*setup", lines)
    if (!length(setup_chunk)) return(lines)
    append(lines, inject, after = setup_chunk[1])
  }

  if (!dry_run) {
    patched <- readLines(path, warn = FALSE)
    patched <- ensure_theme(patched)
    patched <- ensure_fonts(patched)
    if (!is_qmd) patched <- ensure_runtime_classes(patched)
    writeLines(patched, path, useBytes = TRUE)
  }
  invisible(TRUE)
}

.write_readme_snippet <- function(family, preset = "homage", dry_run = FALSE, method = c("vendor", "format"),
                                  on_format = TRUE) {
  method <- match.arg(method)
  # README.md knitted from README.Rmd: the note goes in the source
  readme <- if (file.exists("README.Rmd")) "README.Rmd" else "README.md"
  if (!file.exists(readme)) return(invisible(TRUE))

  start_tag <- "<!-- albersdown:theme-note:start -->"
  end_tag <- "<!-- albersdown:theme-note:end -->"
  text <- if (identical(method, "format") && !isTRUE(on_format)) {
    # site-only adoption: the vignettes were not changed
    paste0(
      "This package's pkgdown site uses the albersdown theme (`template: package: albersdown`, site default family = '",
      family,
      "', preset = '",
      preset,
      "'). Its vignettes keep their own output format."
    )
  } else if (identical(method, "format")) {
    paste0(
      "This package uses the albersdown theme. Its vignettes use the `albersdown::albers_vignette()` output format (family = '",
      family,
      "', preset = '",
      preset,
      "', set in each vignette's YAML), which embeds the stylesheet, script and fonts when a vignette renders. The pkgdown site uses `template: package: albersdown`."
    )
  } else {
    paste0(
      "This package uses the albersdown theme. Existing vignette theme hooks are replaced so `albers.css` and local `albers.js` render consistently on CRAN and GitHub Pages. The defaults are configured via `params$family` and `params$preset` (family = '",
      family,
      "', preset = '",
      preset,
      "'). The pkgdown site uses `template: { package: albersdown }` together with generated `pkgdown/extra.css` and `pkgdown/extra.js` so the theme is linked and activated on site pages."
    )
  }
  block <- c(start_tag, "## Albers theme", text, end_tag)

  lines <- readLines(readme, warn = FALSE)
  updated <- .replace_or_append_marked_block(lines, block, start_tag, end_tag)

  if (identical(lines, updated)) {
    .albers_say(sprintf("%s already contains an up-to-date Albers note", readme))
    return(invisible(TRUE))
  }
  reknit <- if (identical(readme, "README.Rmd")) "; re-knit it (devtools::build_readme()) to update README.md" else ""
  if (dry_run) {
    .albers_say(sprintf("Would write/update marked Albers note in %s%s", readme, reknit))
  } else {
    .albers_write_lines(updated, readme)
    .albers_say(sprintf("Updated marked Albers note in %s%s", readme, reknit), "success")
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

  src_css_local <- file.path("inst", "pkgdown", "assets", "albers.css")
  src_css <- if (file.exists(src_css_local)) src_css_local else system.file("pkgdown/assets/albers.css", package = "albersdown")
  src_js_local <- file.path("inst", "pkgdown", "assets", "albers.js")
  src_js <- if (file.exists(src_js_local)) src_js_local else system.file("pkgdown/assets/albers.js", package = "albersdown")
  src_header_local <- file.path("inst", "format", "albers-header.html")
  src_header <- if (file.exists(src_header_local)) src_header_local else system.file("format/albers-header.html", package = "albersdown")
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
    if (.albers_is_theme_copy(css) || .albers_theme_copy_header(css)) {
      penalize(15, "pkgdown/extra.css is a copy of the albersdown 1.x stylesheet; it loads after the theme and overrides it (use_albersdown() retires an unedited copy)")
    }
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

  vignette_text <- paste(as.character(vignette_value), collapse = "\n")
  vignette_text <- gsub("\r\n?", "\n", vignette_text)
  vignette_text <- gsub("\\s+(%\\\\Vignette[A-Za-z]+\\{)", "\n\\1", vignette_text, perl = TRUE)
  vignette_lines <- trimws(strsplit(vignette_text, "\n", fixed = TRUE)[[1]])
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
  # Site default classes. albers.js applies them the moment <body> exists
  # ("add only if none present"), so bare site pages (home, reference) pick up
  # the configured direction without a late restyle, and each article's inline
  # hook can still replace them.
  defaults <- c(
    sprintf(
      "window.albersdownDefaults = { family: \"%s\", preset: \"%s\", style: \"minimal\" };",
      family, preset
    ),
    ""
  )

  # The template (inst/pkgdown/templates/in-header.html) links albers.css and
  # albers.js on every page; extra.js only has to carry the site defaults.
  c(
    "/* albersdown pkgdown/extra.js: site default family and direction. */",
    defaults
  )
}

# Keep a path out of the package tarball (as usethis::use_build_ignore()).
.albers_build_ignore <- function(pattern, file = ".Rbuildignore", dry_run = FALSE) {
  lines <- if (file.exists(file)) readLines(file, warn = FALSE) else character()
  if (pattern %in% lines) return(invisible(FALSE))
  if (dry_run) {
    .albers_say(sprintf("Would add %s to %s", pattern, file))
    return(invisible(TRUE))
  }
  .albers_append_line(pattern, file)
  .albers_say(sprintf("Added %s to %s", pattern, file), "success")
  invisible(TRUE)
}

# The README note albersdown 2.0 wrote (it describes the vendored setup).
.albers_readme_has_vendor_note <- function() {
  for (f in intersect(c("README.Rmd", "README.md"), list.files("."))) {
    lines <- readLines(f, warn = FALSE)
    s <- which(lines == "<!-- albersdown:theme-note:start -->")[1]
    e <- which(lines == "<!-- albersdown:theme-note:end -->")[1]
    if (!is.na(s) && !is.na(e) && e > s && any(grepl("params$family", lines[s:e], fixed = TRUE))) return(TRUE)
  }
  FALSE
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

  if (!dry_run) {
    dir.create("pkgdown", showWarnings = FALSE)
    .albers_build_ignore("^pkgdown$")
  }

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

  # the grounds the theme itself uses (midnight's are tinted per family)
  preset_names <- c("homage", "interaction", "study", "structural", "adobe", "midnight")
  ground <- function(preset_name, family = NULL) {
    cols <- .preset_colors(preset_name, family)
    list(bg = cols$bg, ink = cols$fg)
  }

  checks <- list()

  for (preset_name in setdiff(preset_names, "midnight")) {
    g <- ground(preset_name)
    checks[[paste0("body-light-", preset_name)]] <- .contrast_ratio(g$ink, g$bg)
  }

  for (family_name in names(tokens$families)) {
    fam <- tokens$families[[family_name]]
    g <- ground("midnight", family_name)
    checks[[paste0("body-midnight-", family_name)]] <- .contrast_ratio(g$ink, g$bg)
    for (preset_name in preset_names) {
      g <- ground(preset_name, family_name)
      link_fg <- if (identical(preset_name, "midnight") && !is.null(fam$dark$accent_ink)) fam$dark$accent_ink else fam$A900
      checks[[paste0("link-light-", family_name, "-", preset_name)]] <- .contrast_ratio(link_fg, g$bg)
    }
    if (!is.null(fam$dark$accent_ink)) {
      # on both night grounds the theme uses (warm homage, cool interaction)
      for (dir in c("homage", "interaction")) {
        checks[[paste0("link-dark-", family_name, "-", dir)]] <- .contrast_ratio(
          fam$dark$accent_ink, .preset_colors_night(dir)$bg
        )
      }
    }
  }

  for (dir in c("homage", "interaction")) {
    night <- .preset_colors_night(dir)
    checks[[paste0("body-dark-", dir)]] <- .contrast_ratio(night$fg, night$bg)
  }
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
    "<script>(function(){document.body.classList.add(%s);})();</script>",
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
