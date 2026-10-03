# use_albersdown(method = "format"): move vignettes onto the
# albersdown::albers_vignette() output format. All edits are textual so other
# output formats, comments, key order and line endings in the user's files
# survive; files are backed up to .albersdown.bak/ before they are changed.

.albers_say <- function(msg, type = c("info", "success", "warning")) {
  type <- match.arg(type)
  if (requireNamespace("cli", quietly = TRUE)) {
    # "{msg}": the text is inserted literally, so braces in it (file names,
    # YAML like `{toc: true}`) are not read as cli markup
    switch(type,
      info = cli::cli_alert_info("{msg}"),
      success = cli::cli_alert_success("{msg}"),
      warning = cli::cli_alert_warning("{msg}")
    )
  } else {
    message(msg)
  }
}

# A free name in .albersdown.bak/ for `rel`: the first backup is the original;
# later ones get a timestamped name, so no backup is ever overwritten.
.albers_backup_dest <- function(rel) {
  dest <- file.path(".albersdown.bak", rel)
  dir.create(dirname(dest), showWarnings = FALSE, recursive = TRUE)
  if (file.exists(dest)) dest <- paste0(dest, ".", format(Sys.time(), "%Y%m%d-%H%M%OS3"))
  dest
}

.albers_backup <- function(path) {
  file.copy(path, .albers_backup_dest(basename(path)), overwrite = FALSE)
}

# Line ending and byte-order mark of an existing file, so a rewrite keeps them.
.albers_file_style <- function(path) {
  style <- list(eol = "\n", bom = FALSE)
  if (!file.exists(path)) return(style)
  n <- file.info(path)$size
  if (is.na(n) || n == 0) return(style)
  b <- readBin(path, "raw", n)
  style$bom <- n >= 3 && identical(b[1:3], as.raw(c(0xef, 0xbb, 0xbf)))
  lf <- which(b == as.raw(10L))
  if (length(lf) && lf[1] > 1 && b[lf[1] - 1L] == as.raw(13L)) style$eol <- "\r\n"
  style
}

.albers_write_lines <- function(lines, path) {
  style <- .albers_file_style(path)
  con <- file(path, open = "wb")
  on.exit(close(con), add = TRUE)
  if (style$bom) writeBin(as.raw(c(0xef, 0xbb, 0xbf)), con)
  writeLines(lines, con, sep = style$eol, useBytes = TRUE)
}

# Add one line to the end of a file without rewriting what is there: an ignore
# file may mix CRLF and LF lines, and every existing byte is kept. The new
# line takes the ending of the line above it.
.albers_append_line <- function(line, path) {
  old <- if (file.exists(path)) readBin(path, "raw", file.info(path)$size) else raw()
  lf <- which(old == as.raw(10L))
  eol <- if (length(lf) && lf[length(lf)] > 1 && old[lf[length(lf)] - 1L] == as.raw(13L)) "\r\n" else "\n"
  # a last line without its newline gets one first
  if (length(old) && old[length(old)] != as.raw(10L)) old <- c(old, charToRaw(eol))
  con <- file(path, open = "wb")
  on.exit(close(con), add = TRUE)
  writeBin(c(old, charToRaw(paste0(line, eol))), con)
}

# The YAML front matter delimiters, as rmarkdown finds them: an opening `---`
# (after blank lines only) and a closing `---` or `...`, trailing blanks
# allowed. Returns the two line numbers, or NULL.
.albers_fences <- function(raw) {
  delims <- grep("^(---|\\.\\.\\.)\\s*$", raw)
  if (length(delims) < 2 || delims[2] - delims[1] <= 1 || !grepl("^---\\s*$", raw[delims[1]])) return(NULL)
  if (delims[1] > 1 && !all(grepl("^\\s*$", raw[seq_len(delims[1] - 1)]))) return(NULL)
  delims[1:2]
}

# Does this vignette's front matter already use albers_vignette()?
.albers_on_format <- function(path) {
  raw <- readLines(path, warn = FALSE)
  fence <- .albers_fences(raw)
  !is.null(fence) && any(grepl("albersdown::albers_vignette", raw[fence[1]:fence[2]], fixed = TRUE))
}

# Lines of the top-level YAML block that starts at `start` (its indented
# continuation lines, plus blank lines between them).
.yaml_block_end <- function(lines, start) {
  i <- start + 1L
  last <- start
  while (i <= length(lines)) {
    if (grepl("^\\s*$", lines[i])) {
      i <- i + 1L
      next
    }
    if (!grepl("^\\s", lines[i])) break
    last <- i
    i <- i + 1L
  }
  last
}

.albers_format_entry <- function(family, preset, keep = character(), indent = "  ",
                                  child = paste0(indent, indent), comment = "") {
  keep <- keep[!grepl("^\\s+(family|preset)\\s*:", keep)]
  c(
    paste0(indent, "albersdown::albers_vignette:", if (nzchar(comment)) paste0(" ", comment) else ""),
    sprintf("%sfamily: %s", child, family),
    sprintf("%spreset: %s", child, preset),
    keep
  )
}

# Rewrite the `output:` field of one front matter (character vector without
# the --- fences). Returns the new front matter.
.albers_output_to_format <- function(head, family, preset) {
  idx <- grep("^output\\s*:", head)
  if (!length(idx)) {
    return(c(head, "output:", .albers_format_entry(family, preset)))
  }
  idx <- idx[1]
  end <- .yaml_block_end(head, idx)
  first <- sub("^output\\s*:\\s*", "", head[idx])
  first <- trimws(sub("\\s+#.*$", "", first))

  # output: {rmarkdown::html_vignette: ...}   (flow-style map)
  if (grepl("^\\{", first)) {
    return(if (grepl("^\\{\\s*['\"]?(rmarkdown::)?html_vignette['\"]?\\s*(:|,|\\})", first)) "flow" else NULL)
  }
  # output: rmarkdown::html_vignette   (scalar)
  if (nzchar(first)) {
    if (grepl("^['\"]?(rmarkdown::)?html_vignette['\"]?$", first)) {
      return(c(head[seq_len(idx - 1)], "output:", .albers_format_entry(family, preset), head[-seq_len(end)]))
    }
    # some other single format (e.g. bookdown::html_vignette2): not ours to change
    return(NULL)
  }

  block <- if (end > idx) head[(idx + 1):end] else character()
  # the output block's own indentation (2, 4, ... spaces)
  first_line <- block[grepl("\\S", block)][1]
  indent <- if (is.na(first_line)) "  " else sub("^(\\s*).*$", "\\1", first_line)
  entry_re <- paste0("^", indent, "['\"]?(rmarkdown::)?html_vignette['\"]?\\s*:")
  entry_start <- grep(entry_re, block)
  if (!length(entry_start)) return(NULL)
  s <- entry_start[1]
  entries <- grep(paste0("^", indent, "[^[:space:]#]"), block)  # comment lines are not formats
  if (length(entries) && entries[1] != s) return("not-first")
  deeper <- paste0("^", indent, "\\s")
  e <- s
  while (e + 1 <= length(block) && (grepl(deeper, block[e + 1]) || grepl("^\\s*$", block[e + 1]))) e <- e + 1
  # blank lines after the entry belong to what follows it
  while (e > s && grepl("^\\s*$", block[e])) e <- e - 1
  args <- if (e > s) block[(s + 1):e] else character()
  child <- if (length(args) && any(grepl("\\S", args))) sub("^(\\s*).*$", "\\1", args[grepl("\\S", args)][1]) else paste0(indent, indent)
  comment <- if (grepl("\\s#", block[s])) sub("^.*?(\\s#.*)$", "\\1", block[s], perl = TRUE) else ""
  comment <- trimws(comment)
  keep <- .albers_strip_vendored_args(args[grepl("\\S", args)])
  new_block <- c(block[seq_len(s - 1)], .albers_format_entry(family, preset, keep, indent = indent, child = child, comment = comment), block[-seq_len(e)])
  c(head[seq_len(idx)], new_block, head[-seq_len(end)])
}

# Lines albersdown 2.0's use_albersdown() injected into a vignette's setup
# chunk. The format now does all of this itself (ragg device, fonts, and
# theme_albers() in the vignette's family), and a leftover theme_set() line
# would re-theme every plot in the old family after the format has set it.
.albers_legacy_line_re <- c(
  "^\\s*if \\(requireNamespace\\(\"ragg\", quietly = TRUE\\)\\) knitr::opts_chunk\\$set\\(dev = \"ragg_png\"\\)\\s*$",
  "^\\s*if \\(requireNamespace\\(\"systemfonts\", quietly = TRUE\\)\\) albersdown::albers_register_fonts\\(\\)\\s*$",
  "^\\s*(if \\(requireNamespace\\(\"ggplot2\", quietly = TRUE\\) && requireNamespace\\(\"albersdown\", quietly = TRUE\\)\\) )?(ggplot2::)?theme_set\\(albersdown::theme_albers\\(family = params\\$family, preset = params\\$preset\\)\\)\\s*$"
)
.albers_legacy_font_guard <- c(
  "if (",
  "requireNamespace(\"systemfonts\", quietly = TRUE) &&",
  "requireNamespace(\"albersdown\", quietly = TRUE) &&",
  "\"albers_register_fonts\" %in% getNamespaceExports(\"albersdown\")",
  ") {",
  "albersdown::albers_register_fonts()",
  "}"
)

.albers_legacy_chunks <- c("albers-family", "albers-preset", "albers-classes", "albers-style")

# Did albersdown 2.0 set up this file? (its theme_set(params$...) line, its
# class chunk, or its vendored css/header in the front matter)
.albers_legacy_fingerprint <- function(head, body) {
  chunk <- paste0("^```\\{r[^}]*\\b(", paste(.albers_legacy_chunks, collapse = "|"), ")\\b")
  any(grepl(.albers_legacy_line_re[3], body)) || any(grepl(chunk, body, perl = TRUE)) ||
    any(grepl("albers\\.css|albers-header\\.html", head))
}

.albers_drop_legacy_setup <- function(body) {
  # a removed chunk takes one of the blank lines around it with it
  chunk <- paste0("^```\\{r[^}]*\\b(", paste(.albers_legacy_chunks, collapse = "|"), ")\\b")
  for (i in rev(grep(chunk, body, perl = TRUE))) {
    close <- which(seq_along(body) > i & grepl("^```\\s*$", body))[1]
    if (is.na(close)) close <- length(body)
    if (i > 1 && close < length(body) && grepl("^\\s*$", body[i - 1]) && grepl("^\\s*$", body[close + 1])) close <- close + 1
    body <- body[-(i:close)]
  }
  drop <- Reduce(`|`, lapply(.albers_legacy_line_re, grepl, x = body), rep(FALSE, length(body)))
  n <- length(.albers_legacy_font_guard)
  for (i in which(trimws(body) == .albers_legacy_font_guard[1])) {
    if (i + n - 1 <= length(body) && identical(trimws(body[i:(i + n - 1)]), .albers_legacy_font_guard)) {
      drop[i:(i + n - 1)] <- TRUE
    }
  }
  # 2.0's vignettes wrapped the theme_set() line in `if (...) {` / `}`: a
  # block left empty by the removal goes too (repeatedly, for nested blocks)
  repeat {
    found <- FALSE
    for (i in which(drop)) {
      kept <- which(!drop)
      j <- max(c(0L, kept[kept < i]))
      k <- min(c(length(body) + 1L, kept[kept > i]))
      if (j < 1 || k > length(body)) next
      if (grepl("^\\s*if\\s*\\(.*\\)\\s*\\{\\s*$", body[j]) && grepl("^\\s*\\}\\s*$", body[k])) {
        drop[j:k] <- TRUE
        found <- TRUE
        break
      }
    }
    if (!found) break
  }
  body[!drop]
}

# Drop the params albersdown 2.0 added (family, preset) once nothing in the
# body reads them; a `params:` block left empty goes too.
.albers_drop_legacy_params <- function(head, body) {
  p <- grep("^params\\s*:\\s*$", head)
  if (!length(p)) return(head)
  p <- p[1]
  end <- .yaml_block_end(head, p)
  if (end == p) return(head)
  values <- list(family = c("red", "lapis", "ochre", "teal", "green", "violet"), preset = c("homage", "interaction", "study", "structural", "adobe", "midnight"))
  drop <- integer()
  for (key in names(values)) {
    used <- sprintf("params\\s*(\\$\\s*%s\\b|\\[\\[?\\s*['\"]%s['\"])", key, key)
    if (any(grepl(used, body, perl = TRUE))) next
    k <- (p + 1):end
    k <- k[grepl(sprintf("^\\s+%s\\s*:\\s*['\"]?(%s)['\"]?\\s*(#.*)?$", key, paste(values[[key]], collapse = "|")), head[k])]
    drop <- c(drop, k)
  }
  if (!length(drop)) return(head)
  head <- head[-drop]
  end <- end - length(drop)
  if (end == p || all(grepl("^\\s*$", head[(p + 1):end]))) head <- head[-(p:end)]
  head
}

# Returns "converted", "updated", "unchanged" (already on the format) or
# "skipped".
.patch_rmd_to_format <- function(path, family, preset, dry_run = FALSE) {
  raw <- readLines(path, warn = FALSE)
  fence <- .albers_fences(raw)
  if (is.null(fence)) {
    .albers_say(sprintf(
      "Could not find the YAML header delimiters (--- ... --- or ...) in %s; skipped", basename(path)), "warning")
    return(invisible("skipped"))
  }
  pre <- raw[seq_len(fence[1])]
  head <- raw[(fence[1] + 1):(fence[2] - 1)]
  close <- raw[fence[2]]
  body <- if (fence[2] < length(raw)) raw[(fence[2] + 1):length(raw)] else character()

  on_format <- any(grepl("albersdown::albers_vignette", head, fixed = TRUE))
  if (on_format) {
    new_head <- .albers_update_format_args(head, family, preset)
  } else {
    new_head <- .albers_output_to_format(head, family, preset)
    if (identical(new_head, "flow")) {
      .albers_say(sprintf(paste(
        "%s has a flow-style `output: {...}` map; not converted. Rewrite it as a block",
        "(`output:` then `  rmarkdown::html_vignette: ...` on its own line) and re-run, or set",
        "`albersdown::albers_vignette` by hand"), basename(path)), "warning")
      return(invisible("skipped"))
    }
    if (identical(new_head, "not-first")) {
      .albers_say(sprintf(
        "%s lists another output format before html_vignette, and R CMD build uses the first one; left unchanged (move html_vignette first, then re-run)",
        basename(path)), "warning")
      return(invisible("skipped"))
    }
    if (is.null(new_head)) {
      .albers_say(sprintf("%s uses an output format other than html_vignette; left unchanged", basename(path)), "warning")
      return(invisible("skipped"))
    }
  }
  # vendored resources are no longer needed
  vend <- "^\\s*-\\s*['\"]?(albers\\.css|albers\\.js|albers-header\\.html|fonts)['\"]?\\s*$"
  new_head <- new_head[!grepl(vend, new_head)]
  rf <- grep("^resource_files\\s*:\\s*$", new_head)
  if (length(rf) && .yaml_block_end(new_head, rf[1]) == rf[1]) new_head <- new_head[-rf[1]]
  # what albersdown 2.0 put in the setup chunk and params (only in a file
  # that carries 2.0's fingerprint: a user's own `family` param stays)
  legacy <- .albers_legacy_fingerprint(head, body)
  new_body <- body
  if (legacy) {
    new_body <- .albers_drop_legacy_setup(body)
    new_head <- .albers_drop_legacy_params(new_head, c(new_head, new_body))
  }
  if (identical(new_head, head) && identical(new_body, body)) {
    .albers_say(sprintf("%s already uses albersdown::albers_vignette (%s, %s)", basename(path), family, preset))
    return(invisible("unchanged"))
  }
  legacy_note <- if (legacy && (!identical(new_body, body) || !identical(.albers_drop_legacy_params(head, c(head, new_body)), head))) {
    " and removed albersdown 2.0's setup lines/params"
  } else {
    ""
  }
  if (dry_run) {
    .albers_say(sprintf(
      if (on_format) "Would set %s to %s / %s%s" else "Would switch %s to albersdown::albers_vignette (%s, %s)%s",
      basename(path), family, preset, sub("^ and removed", " and remove", legacy_note)))
    return(invisible(if (on_format) "updated" else "converted"))
  }
  .albers_backup(path)
  .albers_write_lines(c(pre, new_head, close, new_body), path)
  .albers_say(sprintf(
    if (on_format) "Set %s to %s / %s%s" else "Switched %s to albersdown::albers_vignette (%s, %s)%s",
    basename(path), family, preset, legacy_note), "success")
  invisible(if (on_format) "updated" else "converted")
}

# The DESCRIPTION field `field` as line numbers (the field line and its
# continuation lines), or NULL.
.albers_desc_range <- function(lines, field) {
  start <- grep(sprintf("^%s\\s*:", field), lines)
  if (!length(start)) return(NULL)
  start <- start[1]
  end <- start
  while (end + 1 <= length(lines) && grepl("^\\s", lines[end + 1])) end <- end + 1
  start:end
}

.albers_desc_items <- function(lines, field) {
  rng <- .albers_desc_range(lines, field)
  if (is.null(rng)) return(character())
  text <- paste(lines[rng], collapse = " ")
  items <- trimws(strsplit(sub(sprintf("^%s\\s*:", field), "", text), ",")[[1]])
  items[nzchar(items)]
}

# A dependency or remote reference reduced to its name: `github::a/b@ref (>= 1)`
# is `a/b`.
.albers_ref_name <- function(x) {
  trimws(sub("[@#].*$", "", sub("^[A-Za-z]+::", "", trimws(sub("\\(.*$", "", x)))))
}

# Add packages to a DESCRIPTION dependency field without reflowing the file.
.albers_desc_add <- function(lines, field, pkgs) {
  rng <- .albers_desc_range(lines, field)
  if (is.null(rng)) {
    return(c(lines, sprintf("%s:", field), paste0("    ", pkgs, c(rep(",", length(pkgs) - 1), ""))))
  }
  end <- max(rng)
  add <- setdiff(.albers_ref_name(pkgs), .albers_ref_name(.albers_desc_items(lines, field)))
  add <- pkgs[.albers_ref_name(pkgs) %in% add]
  if (!length(add)) return(lines)
  last <- sub("\\s+$", "", lines[end])
  if (!grepl(":\\s*$", last)) last <- paste0(last, ",")
  new <- c(last, paste0("    ", add, c(rep(",", length(add) - 1), "")))
  c(lines[seq_len(end - 1)], new, if (end < length(lines)) lines[(end + 1):length(lines)])
}

# Remove one package from a DESCRIPTION list field, textually.
.albers_desc_drop <- function(lines, field, pkg) {
  rng <- .albers_desc_range(lines, field)
  if (is.null(rng)) return(lines)
  item <- sprintf("(?<![[:alnum:]./_-])%s\\s*(\\([^)]*\\))?", pkg)
  for (i in rng) {
    followed <- sprintf("%s\\s*,\\s*", item)
    if (grepl(followed, lines[i], perl = TRUE)) {
      lines[i] <- sub(followed, "", lines[i], perl = TRUE)
      break
    }
    last <- sprintf("\\s*,?\\s*%s\\s*$", item)
    if (grepl(last, lines[i], perl = TRUE)) {
      lines[i] <- sub(last, "", lines[i], perl = TRUE)
      # the item was last: the comma before it (maybe on an earlier line) goes
      k <- rev(rng[rng <= i & grepl("\\S", sub(sprintf("^%s\\s*:", field), "", lines[rng]))])
      if (length(k)) lines[k[1]] <- sub(",\\s*$", "", lines[k[1]])
      break
    }
  }
  empty <- rng[rng != rng[1] & grepl("^\\s*$", lines[rng])]
  if (length(empty)) lines <- lines[-empty]
  lines[rng[1]] <- sub("\\s+$", "", lines[rng[1]])
  lines
}

# Give the `pkg` entry of `field` a lower bound of `version` (unless a bound
# at least as high is there).
.albers_desc_bound <- function(lines, field, pkg, version) {
  rng <- .albers_desc_range(lines, field)
  if (is.null(rng)) return(lines)
  re <- sprintf("(?<![[:alnum:]./_-])%s(\\s*\\(([^)]*)\\))?(?=\\s*(,|$))", pkg)
  for (i in rng) {
    m <- regmatches(lines[i], regexec(re, lines[i], perl = TRUE))[[1]]
    if (!length(m)) next
    bound <- m[3]
    have <- sub("^\\s*>=?\\s*", "", bound)
    if (grepl("^\\s*>", bound) && !is.na(v <- suppressWarnings(package_version(have, strict = FALSE))) && v >= version) {
      return(lines)
    }
    lines[i] <- sub(re, sprintf("%s (>= %s)", pkg, version), lines[i], perl = TRUE)
    return(lines)
  }
  lines
}

.albers_is_dev_version <- function(version) {
  v <- unlist(package_version(version))
  length(v) >= 4 && v[4] >= 9000
}

# DESCRIPTION for vignettes on the format (`vignettes = TRUE`): albersdown
# with a lower bound of the installed version (in Suggests, or where it is
# already listed in Depends/Imports), knitr, rmarkdown, VignetteBuilder, and
# Remotes while that version is not on CRAN. For a site-only adoption
# (`vignettes = FALSE`) only Config/Needs/website, which R CMD check ignores.
.ensure_vignette_deps <- function(dry_run = FALSE, version = utils::packageVersion("albersdown"), vignettes = TRUE) {
  desc <- "DESCRIPTION"
  if (!file.exists(desc)) return(invisible(FALSE))
  version <- package_version(version)
  lines <- readLines(desc, warn = FALSE)
  done <- character()
  note <- function(new, old, what) if (!identical(new, old)) done <<- c(done, what)

  new <- lines
  remotes <- FALSE
  if (vignettes) {
    dep <- Filter(function(f) "albersdown" %in% .albers_ref_name(.albers_desc_items(lines, f)), c("Depends", "Imports"))
    if (length(dep)) {
      # already a hard dependency: a Suggests entry too would be a check NOTE
      new <- .albers_desc_bound(new, dep[1], "albersdown", version)
      note(new, lines, sprintf("%s: albersdown (>= %s)", dep[1], version))
      old <- new
      new <- .albers_desc_add(new, "Suggests", c("knitr", "rmarkdown"))
      note(new, old, "Suggests: knitr, rmarkdown")
    } else {
      new <- .albers_desc_add(new, "Suggests", c("albersdown", "knitr", "rmarkdown"))
      new <- .albers_desc_bound(new, "Suggests", "albersdown", version)
      note(new, lines, sprintf("Suggests: albersdown (>= %s), knitr, rmarkdown", version))
    }
    old <- new
    if (!any(grepl("^VignetteBuilder\\s*:", new))) new <- c(new, "VignetteBuilder: knitr")
    note(new, old, "VignetteBuilder: knitr")
    if (.albers_is_dev_version(version) && !"bbuchsbaum/albersdown" %in% .albers_ref_name(.albers_desc_items(new, "Remotes"))) {
      new <- .albers_desc_add(new, "Remotes", "bbuchsbaum/albersdown")
      remotes <- TRUE
      done <- c(done, "Remotes: bbuchsbaum/albersdown")
    }
  }
  old <- new
  new <- .albers_desc_add(new, "Config/Needs/website", "bbuchsbaum/albersdown")
  # albersdown 2.0 wrote a bare `albersdown`, which resolves to CRAN
  new <- .albers_desc_drop(new, "Config/Needs/website", "albersdown")
  note(new, old, "Config/Needs/website: bbuchsbaum/albersdown")
  if (identical(new, lines)) return(invisible(FALSE))
  if (dry_run) {
    .albers_say(paste0("Would update DESCRIPTION: ", paste(done, collapse = "; ")))
  } else {
    .albers_backup(desc)  # only files that change are backed up
    .albers_write_lines(new, desc)
    .albers_say(paste0("DESCRIPTION: ", paste(done, collapse = "; ")), "success")
  }
  if (remotes) {
    .albers_say(sprintf(paste(
      "albers_vignette() needs albersdown >= %s, a development version that is not on CRAN, so",
      "`Remotes: bbuchsbaum/albersdown` %s DESCRIPTION for R CMD check and CI to install it from GitHub.",
      "`R CMD check --as-cran` notes the Remotes field; remove it once that release is on CRAN."),
      version, if (dry_run) "would be added to" else "was added to"), "warning")
  }
  invisible(TRUE)
}

# Is `path` (relative to the package root) excluded by .Rbuildignore?
.albers_build_ignored <- function(path) {
  if (!file.exists(".Rbuildignore")) return(FALSE)
  pats <- readLines(".Rbuildignore", warn = FALSE)
  pats <- pats[nzchar(trimws(pats))]
  any(vapply(pats, function(p) isTRUE(tryCatch(grepl(p, path, perl = TRUE, ignore.case = TRUE), error = function(e) FALSE)), logical(1)))
}

# Point pkgdown at the template without rewriting the rest of _pkgdown.yml.
.ensure_pkgdown_template_text <- function(dry_run = FALSE) {
  yml <- "_pkgdown.yml"
  created <- !file.exists(yml)
  lines <- if (!created) readLines(yml, warn = FALSE) else character()
  t_idx <- grep("^template\\s*:", lines)
  new <- lines
  if (length(t_idx)) {
    end <- .yaml_block_end(lines, t_idx[1])
    block <- if (end > t_idx[1]) lines[(t_idx[1] + 1):end] else character()
    if (!any(grepl("^\\s+package\\s*:\\s*['\"]?albersdown", block))) {
      block <- block[!grepl("^\\s+package\\s*:", block)]
      add <- "  package: albersdown"
      if (!any(grepl("^\\s+bootstrap\\s*:", block))) add <- c(add, "  bootstrap: 5")
      new <- c(lines[seq_len(t_idx[1])], add, block, if (end < length(lines)) lines[(end + 1):length(lines)])
    }
  } else {
    new <- c(lines, "template:", "  package: albersdown", "  bootstrap: 5")
  }
  changed <- !identical(new, lines)
  if (changed) {
    if (dry_run) {
      .albers_say(sprintf("Would %s _pkgdown.yml with template: package: albersdown", if (created) "create" else "set"))
    } else {
      if (!created) .albers_backup(yml)
      .albers_write_lines(new, yml)
      .albers_say(if (created) "Created _pkgdown.yml with the albersdown template" else "_pkgdown.yml uses the albersdown template", "success")
    }
  }
  # keep the site's files out of the package tarball (R CMD check notes them)
  if (!.albers_build_ignored("_pkgdown.yml")) .albers_build_ignore("^_pkgdown\\.yml$", dry_run = dry_run)
  if (created && !.albers_build_ignored("docs")) .albers_build_ignore("^docs$", dry_run = dry_run)
  invisible(changed)
}

# Site-wide defaults for pkgdown (format method): only pkgdown/extra.js, with
# the defaults line added to (not replacing) any existing script. The
# extra.js albersdown 2.0 wrote (an old copy of albers.js, which would run
# beside the template's) is replaced.
.albers_site_defaults <- function(family, preset, dry_run = FALSE) {
  path <- file.path("pkgdown", "extra.js")
  line <- sprintf('window.albersdownDefaults = { family: "%s", preset: "%s", style: "minimal" };', family, preset)
  old <- if (file.exists(path)) readLines(path, warn = FALSE) else character()
  legacy <- .albers_legacy_extra_js(old)
  new <- c(line, if (!legacy) old[!grepl("^window\\.albersdownDefaults\\s*=", old)])
  if (identical(new, old)) return(invisible(FALSE))
  if (dry_run) {
    .albers_say(sprintf("Would set the site default to %s / %s in %s%s", family, preset, path,
                        if (legacy) " (replacing the old albersdown script copied there)" else ""))
    if (!.albers_build_ignored("pkgdown")) .albers_build_ignore("^pkgdown$", dry_run = TRUE)
    return(invisible(TRUE))
  }
  dir.create("pkgdown", showWarnings = FALSE)
  if (file.exists(path)) .albers_backup(path)
  .albers_write_lines(new, path)
  if (!.albers_build_ignored("pkgdown")) .albers_build_ignore("^pkgdown$")
  .albers_say(sprintf("Site default: %s / %s (%s%s)", family, preset, path,
                      if (legacy) "; replaced the old albersdown script copied there" else ""), "success")
  invisible(TRUE)
}

.albers_legacy_extra_js <- function(lines) {
  if (!length(lines)) return(FALSE)
  identical(trimws(lines[1]), "/* albersdown pkgdown/extra.js: site default classes + full albers.js. */") ||
    .albers_is_theme_copy(lines)
}

# albersdown 1.x copied its whole stylesheet into pkgdown/extra.css and a
# class-setting script into pkgdown/extra.js. pkgdown loads extra.css after
# the template's albers.css, so an old copy silently overrides the current
# theme. A file is recognised as such a copy by its fingerprint: the MD5 of
# its text with trailing whitespace and the filled-in family/preset names
# taken out, looked up in inst/legacy/theme-copies.txt (every stylesheet and
# script albersdown has shipped; regenerate with tools/legacy_theme_copies.R).
.albers_theme_fingerprint <- function(lines) {
  # bytes, not characters: a stray latin-1 byte must not make sub() fail
  lines <- sub("[ \t\r]+$", "", lines, useBytes = TRUE)
  while (length(lines) && !nzchar(lines[length(lines)])) lines <- lines[-length(lines)]
  lines <- gsub("(['\"])(palette|preset)-[a-z]+\\1", "\\1\\2-*\\1", lines, perl = TRUE, useBytes = TRUE)
  tmp <- tempfile()
  on.exit(unlink(tmp))
  writeBin(charToRaw(paste0(paste(lines, collapse = "\n"), "\n")), tmp)
  unname(tools::md5sum(tmp))
}

.albers_is_theme_copy <- function(lines) {
  known <- system.file("legacy", "theme-copies.txt", package = "albersdown")
  if (!nzchar(known) || !length(lines)) return(FALSE)
  .albers_theme_fingerprint(lines) %in% readLines(known, warn = FALSE)
}

# The first line of each 1.x stylesheet: an edited copy still carries it.
.albers_theme_copy_header <- function(lines) {
  length(lines) > 0 &&
    grepl("^\\s*/\\* -+ (Albersdown: (Bauhaus geometric|geometric modernist) system|Homage family: default = Homage-Red) -+ \\*/\\s*$",
          lines[1], useBytes = TRUE)
}

# albersdown 2.0's pkgdown/extra.css was only this import, a second load of
# the theme now that the template links it; 1.x's was a full copy of the old
# stylesheet, which loads after the template's and overrides it. Both are
# removed. A user's own extra.css is kept, and so is an edited 1.x copy, with
# a warning, since it may hold the user's rules.
.albers_retire_extra_css <- function(dry_run = FALSE) {
  path <- file.path("pkgdown", "extra.css")
  if (!file.exists(path)) return(invisible(FALSE))
  lines <- readLines(path, warn = FALSE)
  content <- gsub("^[ \t\r\n]+|[ \t\r\n]+$", "", lines, useBytes = TRUE)
  why <- if (identical(content[nzchar(content)], "@import url(\"albers.css\");")) {
    "albersdown 2.0's @import of albers.css; the template links the theme"
  } else if (.albers_is_theme_copy(lines)) {
    "a copy of the albersdown 1.x stylesheet, which overrode the current theme"
  }
  if (is.null(why)) {
    if (.albers_theme_copy_header(lines)) {
      .albers_say(sprintf(paste(
        "%s starts as a copy of the albersdown 1.x stylesheet but has been edited, so it was kept.",
        "pkgdown loads it after the theme, so it overrides albersdown: keep only your own rules in it."), path), "warning")
    }
    return(invisible(FALSE))
  }
  if (dry_run) {
    .albers_say(sprintf("Would remove %s (%s)", path, why))
    return(invisible(TRUE))
  }
  if (!isTRUE(.albers_backup(path))) {
    .albers_say(sprintf("Kept %s (%s): it could not be backed up to .albersdown.bak/", path, why), "warning")
    return(invisible(FALSE))
  }
  file.remove(path)
  .albers_say(sprintf("Removed %s (%s; backed up)", path, why), "success")
  invisible(TRUE)
}

.albers_font_files <- function() {
  shipped <- list.files(system.file("fonts", package = "albersdown"), pattern = "\\.woff2$")
  unique(c(shipped, "familjen-grotesk.woff2", "hanken-grotesk.woff2", "hanken-grotesk-italic.woff2",
           "jetbrains-mono.woff2", "newsreader-italic.woff2", "newsreader.woff2",
           "space-grotesk.woff2", "spline-sans-mono.woff2"))
}

# The stylesheet, script, header and fonts that the vendor setup (albersdown
# 2.0) copied into vignettes/. Once every vignette that used them is on the
# format they are dead weight in the tarball; they are moved to
# .albersdown.bak/ (never overwriting an earlier backup).
# `others`: vignette sources not on the format, which may still use them.
.albers_retire_vendored <- function(others = character(), dry_run = FALSE) {
  assets <- file.path("vignettes", c("albers.css", "albers.js", "albers-header.html"))
  assets <- assets[file.exists(assets)]
  fonts <- file.path("vignettes", "fonts", .albers_font_files())
  fonts <- fonts[file.exists(fonts)]
  found <- c(assets, fonts)
  if (!length(found)) return(invisible(FALSE))
  shown <- c(basename(assets), if (length(fonts)) sprintf("fonts/ (%d woff2)", length(fonts)))
  shown <- paste0("vignettes/", shown, collapse = ", ")
  users <- others[vapply(others, function(f) {
    any(grepl("albers\\.css|albers\\.js|albers-header\\.html", readLines(f, warn = FALSE)))
  }, logical(1))]
  if (length(users)) {
    .albers_say(sprintf("%s left in place: still used by %s, which is not on the format",
                        shown, paste(basename(users), collapse = ", ")), "warning")
    return(invisible(FALSE))
  }
  kb <- round(sum(file.size(found)) / 1024)
  if (dry_run) {
    .albers_say(sprintf("Would move %s (%d KB, no longer used: the format embeds the theme) to .albersdown.bak/", shown, kb))
    return(invisible(TRUE))
  }
  for (f in found) file.rename(f, .albers_backup_dest(sub("^vignettes/", "", f)))
  fdir <- file.path("vignettes", "fonts")
  if (dir.exists(fdir) && !length(list.files(fdir, all.files = TRUE, no.. = TRUE))) unlink(fdir, recursive = TRUE)
  .albers_say(sprintf("Moved %s (%d KB, no longer used: the format embeds the theme) to .albersdown.bak/", shown, kb), "success")
  invisible(TRUE)
}

# From an html_vignette's option lines, remove only albersdown's own vendored
# hooks (albers.css, albers-header.html); a user's own css/includes stay.
.albers_strip_vendored_args <- function(args) {
  ours <- "albers\\.css|albers-header\\.html"
  ind <- nchar(sub("^(\\s*).*$", "\\1", args))
  out <- character()
  i <- 1L
  while (i <= length(args)) {
    ln <- args[i]
    key <- sub("^\\s*([A-Za-z_]+)\\s*:.*$", "\\1", ln)
    j <- i
    while (j + 1 <= length(args) && ind[j + 1] > ind[i]) j <- j + 1
    kids <- if (j > i) args[(i + 1):j] else character()
    if (key %in% c("css", "includes", "in_header")) {
      value <- sub("^[^:]*:\\s*", "", ln)
      if (nzchar(value)) {
        # inline value: drop our file from it
        items <- trimws(strsplit(gsub("^\\[|\\]$", "", value), ",")[[1]])
        items <- items[!grepl(ours, items)]
        if (length(items) && any(nzchar(items))) {
          out <- c(out, sub(":.*$", paste0(": ", if (length(items) > 1) paste0("[", paste(items, collapse = ", "), "]") else items), ln))
        }
      } else {
        kept <- .albers_strip_vendored_args(kids[!grepl(paste0("^\\s*-\\s*['\"]?(", ours, ")['\"]?\\s*$"), kids)])
        if (length(kept)) out <- c(out, ln, kept)
      }
    } else {
      out <- c(out, ln, kids)
    }
    i <- j + 1L
  }
  out
}

# Re-run on a vignette already on the format: set its family/preset in the
# front matter `head` (without the fences). Returns the new front matter.
.albers_update_format_args <- function(head, family, preset) {
  entry <- grep("albersdown::albers_vignette", head, fixed = TRUE)[1]
  defaults <- c(family = "red", preset = "homage")
  # `output: albersdown::albers_vignette` (scalar) takes arguments only as a map
  if (grepl("^output\\s*:\\s*['\"]?albersdown::albers_vignette['\"]?\\s*(#.*)?$", head[entry])) {
    if (identical(family, defaults[["family"]]) && identical(preset, defaults[["preset"]])) return(head)
    head <- c(head[seq_len(entry - 1)], "output:", "  albersdown::albers_vignette:", head[-seq_len(entry)])
    entry <- entry + 1L
  }
  ind <- nchar(sub("^(\\s*).*$", "\\1", head[entry]))
  j <- entry
  while (j + 1 <= length(head) && nchar(sub("^(\\s*).*$", "\\1", head[j + 1])) > ind) j <- j + 1
  new <- head
  child <- if (j > entry) sub("^(\\s*).*$", "\\1", head[entry + 1]) else strrep(" ", ind + 2)
  set_arg <- function(lines, key, value) {
    k <- which(seq_along(lines) > entry & seq_along(lines) <= j & grepl(sprintf("^\\s+%s\\s*:", key), lines))
    if (length(k)) {
      lines[k[1]] <- sub(sprintf("(%s\\s*:\\s*)[^#]*?(\\s*(#.*)?)$", key), sprintf("\\1%s\\2", value), lines[k[1]], perl = TRUE)
      lines
    } else if (identical(value, defaults[[key]])) {
      lines  # absent and equal to the format's default: nothing to write
    } else {
      append(lines, sprintf("%s%s: %s", child, key, value), after = entry)
    }
  }
  if (grepl("albers_vignette\\s*$|albers_vignette\\s*:\\s*default\\s*$", head[entry]) &&
      !(identical(family, defaults[["family"]]) && identical(preset, defaults[["preset"]]))) {
    new[entry] <- sub("\\s*:?\\s*default\\s*$", ":", sub("albers_vignette\\s*$", "albers_vignette:", head[entry]))
  }
  new <- set_arg(new, "preset", preset)
  new <- set_arg(new, "family", family)
  new
}

.albers_families <- c("red", "lapis", "ochre", "teal", "green", "violet")
.albers_all_presets <- c("homage", "interaction", "study", "structural", "adobe", "midnight")

# Validate one choice argument: case-insensitive, unique prefixes allowed (as
# match.arg), and an error that names the function and the argument. The
# full `choices` vector (an untouched default) gives its first element.
.albers_choice <- function(x, choices, arg, fun) {
  if (identical(x, choices)) return(choices[1])
  ok <- is.character(x) && length(x) == 1 && !is.na(x) && nzchar(trimws(x))
  hit <- if (ok) pmatch(tolower(trimws(x)), choices) else NA
  if (is.na(hit)) {
    got <- if (is.character(x) && length(x) == 1) sprintf("'%s'", x) else paste(deparse(x), collapse = " ")
    stop(sprintf("%s(): `%s` must be one of %s; got %s.", fun, arg,
                 paste(sprintf('"%s"', choices), collapse = ", "), got), call. = FALSE)
  }
  choices[hit]
}

# The family and preset a vignette states: its albers_vignette() entry (NA for
# an argument it leaves out), or the params albersdown 2.0 wrote. NULL when it
# has neither.
.albers_vignette_choice <- function(path) {
  raw <- readLines(path, warn = FALSE)
  fence <- .albers_fences(raw)
  if (is.null(fence) || fence[2] - fence[1] < 2) return(NULL)
  head <- raw[(fence[1] + 1):(fence[2] - 1)]
  body <- if (fence[2] < length(raw)) raw[(fence[2] + 1):length(raw)] else character()
  block_after <- function(i) {
    ind <- nchar(sub("^(\\s*).*$", "\\1", head[i]))
    j <- i
    while (j + 1 <= length(head) && nchar(sub("^(\\s*).*$", "\\1", head[j + 1])) > ind) j <- j + 1
    if (j > i) head[(i + 1):j] else character()
  }
  get <- function(lines, key, choices) {
    v <- grep(sprintf("^\\s+%s\\s*:", key), lines, value = TRUE)[1]
    if (is.na(v)) return(NA_character_)
    v <- tolower(sub(sprintf("^\\s+%s\\s*:\\s*['\"]?([A-Za-z]+)['\"]?\\s*(#.*)?$", key), "\\1", v))
    if (v %in% choices) v else NA_character_
  }
  entry <- grep("albersdown::albers_vignette", head, fixed = TRUE)[1]
  if (!is.na(entry)) {
    block <- block_after(entry)
    # an absent argument is the format's default, not a choice: not evidence
    return(list(family = get(block, "family", .albers_families), preset = get(block, "preset", .albers_all_presets)))
  }
  p <- grep("^params\\s*:\\s*$", head)[1]
  if (!is.na(p) && .albers_legacy_fingerprint(head, body)) {
    block <- block_after(p)
    return(list(family = get(block, "family", .albers_families), preset = get(block, "preset", .albers_all_presets)))
  }
  NULL
}

# Site defaults already written: `window.albersdownDefaults = {...}` (in
# pkgdown/extra.js or _pkgdown.yml) or albersdown 2.0's extra.js class adds.
.albers_site_choice <- function(path) {
  if (!file.exists(path)) return(NULL)
  text <- paste(readLines(path, warn = FALSE), collapse = "\n")
  pick <- function(re, choices) {
    m <- regmatches(text, regexec(re, text, perl = TRUE))[[1]]
    if (length(m) == 2 && tolower(m[2]) %in% choices) tolower(m[2]) else NA_character_
  }
  fam <- pick("albersdownDefaults\\s*=\\s*\\{[^}]*family\\s*:\\s*['\"]([A-Za-z]+)['\"]", .albers_families)
  pre <- pick("albersdownDefaults\\s*=\\s*\\{[^}]*preset\\s*:\\s*['\"]([A-Za-z]+)['\"]", .albers_all_presets)
  # 1.x scripts add the classes together: classList.add("palette-teal", "preset-homage", ...)
  if (is.na(fam)) fam <- pick("classList\\.add\\([^)]*[\"']palette-([a-z]+)[\"']", .albers_families)
  if (is.na(pre)) pre <- pick("classList\\.add\\([^)]*[\"']preset-([a-z]+)[\"']", .albers_all_presets)
  if (is.na(fam) && is.na(pre)) NULL else list(family = fam, preset = pre)
}

# For use_albersdown() called without `family`/`preset`: what the package
# already uses (its vignettes first, then its site defaults), so a re-run or
# a 2.0 migration keeps the look instead of resetting it to red/homage.
# Returns list(value, from, note) per key in `keys`.
.albers_infer_choice <- function(keys = c("family", "preset"), site_first = FALSE) {
  files <- c(Sys.glob("vignettes/*.Rmd"), Sys.glob("vignettes/*.rmd"))
  vig <- Filter(Negate(is.null), stats::setNames(lapply(files, .albers_vignette_choice), basename(files)))
  site <- list(
    "pkgdown/extra.js" = .albers_site_choice(file.path("pkgdown", "extra.js")),
    "_pkgdown.yml" = .albers_site_choice("_pkgdown.yml")
  )
  out <- list()
  for (key in keys) {
    from_vig <- NULL
    vals <- vapply(vig, function(v) v[[key]] %||% NA_character_, character(1))
    vals <- vals[!is.na(vals)]
    if (length(vals)) {
      counts <- table(factor(vals, levels = unique(vals)))
      note <- if (length(counts) > 1) {
        sprintf("vignettes disagree (%s); using the most common", paste(sprintf("%s: %d", names(counts), as.integer(counts)), collapse = ", "))
      } else ""
      from_vig <- list(value = names(counts)[which.max(counts)],
                       from = sprintf("vignettes (%s)", paste(names(vals), collapse = ", ")), note = note)
    }
    from_site <- NULL
    for (src in names(site)) {
      v <- site[[src]][[key]]
      if (!is.null(v) && !is.na(v)) {
        from_site <- list(value = v, from = src, note = "")
        break
      }
    }
    # the vignettes' choice, unless only the site is being set up
    # (apply_to = "new"): then the site default is what is being re-set
    pick <- if (site_first) list(from_site, from_vig) else list(from_vig, from_site)
    pick <- Filter(Negate(is.null), pick)
    if (!length(pick)) next
    chosen <- pick[[1]]
    if (length(pick) > 1 && !identical(pick[[2]]$value, chosen$value)) {
      other <- sprintf("%s says %s", pick[[2]]$from, pick[[2]]$value)
      chosen$note <- if (nzchar(chosen$note)) paste0(chosen$note, "; ", other) else other
    }
    out[[key]] <- chosen
  }
  out
}
