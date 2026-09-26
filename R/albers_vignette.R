#' Albers vignette output format
#'
#' A drop-in replacement for [rmarkdown::html_vignette()] that applies the
#' albersdown theme with no files to copy into `vignettes/`. The stylesheet,
#' the fonts for the chosen direction, and the page script are taken from the
#' installed package and embedded in the self-contained HTML, so the result is
#' CRAN-safe (no network requests).
#'
#' Use it in a vignette's YAML header:
#'
#' ```yaml
#' output:
#'   albersdown::albers_vignette:
#'     family: teal
#'     preset: interaction
#' ```
#'
#' The format sets the page's family and direction before any content is
#' drawn (no restyle on load), sets knitr defaults suited to the theme
#' (`collapse = TRUE`, `comment = "#>"`, retina figures at full column width,
#' the `ragg` device when available), and, when `plot_theme = TRUE` and
#' ggplot2 is installed, sets [theme_albers()] as the ggplot2 theme for the
#' duration of the render.
#'
#' `albers_vignette()` is new in albersdown 2.1.0. A package whose vignettes
#' use it should declare `albersdown (>= 2.1.0)` in `Suggests` (as
#' [use_albersdown()] writes). If building a vignette fails with
#' `'albers_vignette' is not an exported object from 'namespace:albersdown'`,
#' the albersdown installed is 2.0.0 or older: update it.
#'
#' @param family Accent family: one of `"red"`, `"lapis"`, `"ochre"`,
#'   `"teal"`, `"green"`, `"violet"`. While the vignette renders, the
#'   `albersdown.family` and `albersdown.preset` options are set, so
#'   [scale_color_albers()], [scale_fill_albers()] and [theme_albers()] follow
#'   it without repeating the family.
#' @param preset Direction: `"homage"` (warm, serif body) or `"interaction"`
#'   (cool, grotesk, dark code). Legacy presets are accepted.
#' @param fonts Which bundled typefaces to embed: `"direction"` (default) embeds
#'   only the chosen direction's faces; `"both"` embeds homage's and
#'   interaction's, for a page that previews both (about 130 KB more).
#' @param style Weight of the structural marks: `"minimal"` (default),
#'   `"balanced"` or `"assertive"`.
#' @param toc,toc_depth Table of contents, passed to [rmarkdown::html_vignette()].
#' @param fig_width,fig_height Default figure size in inches.
#' @param plot_theme If `TRUE`, set [theme_albers()] (matching `family` and
#'   `preset`) as the ggplot2 theme while the vignette renders.
#' @param dark_figures If `TRUE` (and `plot_theme` is on), each auto-printed
#'   ggplot is also rendered with `theme_albers(mode = "dark")`; the page shows
#'   that version in dark mode instead of a light plot on a dark page. This
#'   adds one image per plot to the HTML. Plots in chunks with
#'   `fig.show = "hold"`, `"animate"` or `"hide"` get no dark version and stay
#'   light in dark mode.
#' @param phone_figures If `TRUE`, each plot (ggplot2, grid or base
#'   graphics) is also drawn at phone width (3.6 in, the same aspect ratio),
#'   so its text is legible in a phone's column; the page shows that drawing
#'   while the figure is displayed narrower than about 470 CSS px, in light
#'   and dark mode alike (the dark version is drawn when `dark_figures` is
#'   on). Printing and the enlarged view use the full figure. Figures
#'   narrower than 4.5 in, figures whose `out.width` is not a percentage,
#'   animations and non-PNG devices are left as they are.
#' @param math_method How equations are rendered. The default `"mathml"`
#'   has pandoc write native MathML, which browsers display without any
#'   download, so vignettes with math stay offline. Use `"mathjax"` (fetched
#'   from a CDN when the page is read) for heavier TeX.
#' @param css Additional stylesheets, applied after the theme.
#' @param includes Additional [rmarkdown::includes()]; combined with the
#'   theme's own head and body includes.
#' @param ... Further arguments passed to [rmarkdown::html_vignette()].
#' @return An R Markdown output format.
#' @export
#' @examples
#' \dontrun{
#' rmarkdown::render("my-vignette.Rmd",
#'   output_format = albersdown::albers_vignette(family = "teal"))
#' }
albers_vignette <- function(
  family = "red",
  preset = "homage",
  style = c("minimal", "balanced", "assertive"),
  toc = TRUE,
  toc_depth = 3,
  fig_width = 6.6,
  fig_height = 4.1,
  plot_theme = TRUE,
  dark_figures = TRUE,
  phone_figures = TRUE,
  math_method = "mathml",
  fonts = c("direction", "both"),
  css = NULL,
  includes = NULL,
  ...
) {
  if (!requireNamespace("rmarkdown", quietly = TRUE)) {
    stop("albers_vignette() requires the 'rmarkdown' package.", call. = FALSE)
  }
  family <- .albers_choice(family, .albers_families, "family", "albers_vignette")
  preset <- .albers_choice(preset, .albers_all_presets, "preset", "albers_vignette")
  style <- .albers_choice(style, c("minimal", "balanced", "assertive"), "style", "albers_vignette")

  asset <- function(...) {
    path <- system.file(..., package = "albersdown")
    if (!nzchar(path)) stop("albersdown asset not found: ", file.path(...), call. = FALSE)
    path
  }
  fonts <- .albers_choice(fonts, c("direction", "both"), "fonts", "albers_vignette")
  fonts_css <- if (identical(fonts, "both")) {
    c("albers-fonts-homage.css", "albers-fonts-interaction.css")
  } else if (identical(preset, "interaction")) "albers-fonts-interaction.css" else "albers-fonts-homage.css"
  theme_css <- c(asset("format", "albers-core.min.css"), vapply(fonts_css, function(f) asset("format", f), ""))

  # The page script is inlined into <head>; the body classes are stamped as
  # the first thing inside <body>, before any content is parsed.
  head_file <- tempfile("albers-head-", fileext = ".html")
  writeLines(c("<script>", readLines(asset("format", "albers.min.js"), warn = FALSE), "</script>"), head_file)
  body_file <- tempfile("albers-body-", fileext = ".html")
  writeLines(sprintf(
    '<script>document.body.classList.add("albers-vignette","palette-%s","preset-%s","style-%s");</script>',
    family, preset, style
  ), body_file)

  own <- rmarkdown::includes(in_header = head_file, before_body = body_file)
  if (!is.null(includes)) {
    own$in_header <- c(own$in_header, includes$in_header)
    own$before_body <- c(own$before_body, includes$before_body)
    own$after_body <- c(own$after_body, includes$after_body)
  }

  dev <- if (requireNamespace("ragg", quietly = TRUE)) "ragg_png" else "png"

  fmt <- rmarkdown::html_vignette(
    fig_width = fig_width,
    fig_height = fig_height,
    dev = dev,
    css = c(theme_css, css),
    toc = toc,
    toc_depth = toc_depth,
    includes = own,
    math_method = math_method,
    ...
  )

  fmt$knitr$opts_chunk <- utils::modifyList(
    fmt$knitr$opts_chunk %||% list(),
    list(
      collapse = TRUE,
      comment = "#>",
      fig.retina = 2,
      dpi = 96,
      out.width = "100%",
      fig.align = "center"
    )
  )

  # After pandoc: write the classes into <body> itself (correct first paint,
  # and correct without JavaScript), and drop the MathJax loader that
  # html_vignette adds to every page when this one has no math.
  base_post_processor <- fmt$post_processor
  fmt$post_processor <- function(metadata, input_file, output_file, clean, verbose) {
    if (is.function(base_post_processor)) {
      output_file <- base_post_processor(metadata, input_file, output_file, clean, verbose)
    }
    .albers_finish_html(output_file, sprintf("albers-vignette palette-%s preset-%s style-%s", family, preset, style))
    output_file
  }

  # An empty <html lang> leaves screen readers guessing; default to English
  # unless the vignette's YAML sets `lang`.
  base_pre_processor <- fmt$pre_processor
  fmt$pre_processor <- function(metadata, input_file, runtime, knit_meta, files_dir, output_dir) {
    # pkgdown articles (vignettes/articles/) have no \VignetteIndexEntry, so
    # rmarkdown's title check would warn on every render; real vignettes keep it
    no_entry <- tryCatch(!nzchar(tools::vignetteInfo(input_file)[["title"]]), error = function(e) FALSE)
    if (isTRUE(no_entry)) {
      op <- options(rmarkdown.html_vignette.check_title = FALSE)
      on.exit(options(op), add = TRUE)
    }
    args <- if (is.function(base_pre_processor)) {
      base_pre_processor(metadata, input_file, runtime, knit_meta, files_dir, output_dir)
    } else character()
    if (is.null(metadata$lang)) args <- c(args, "--metadata", "lang=en")
    args
  }

  # Scales and themes called without a family follow the vignette's family.
  # A knitr document hook also writes the class stamp into the body text, so
  # the article keeps its family and direction when pkgdown renders it with
  # its own output format (which drops the before_body include).
  old_opts <- NULL
  old_doc_hook <- NULL
  old_chunk_opts <- NULL
  old_base_hook <- NULL
  old_palette <- NULL
  old_opts_hook <- NULL
  # Put knitr back as it was: a value that was unset is deleted, not set to
  # NULL (a NULL option hook left behind makes knitr warn in later renders).
  restore_knitr <- function() {
    if (!requireNamespace("knitr", quietly = TRUE)) return(invisible())
    put <- function(obj, name, value) {
      if (is.null(value) && is.function(obj$delete)) obj$delete(name)
      else obj$set(stats::setNames(list(value), name))
    }
    put(knitr::knit_hooks, "document", old_doc_hook)
    put(knitr::knit_hooks, "albers.base", old_base_hook)
    put(knitr::opts_hooks, "albers.base", old_opts_hook)
    for (nm in names(old_chunk_opts)) put(knitr::opts_chunk, nm, old_chunk_opts[[nm]])
    if (length(old_palette)) grDevices::palette(old_palette)
  }
  # 96 dpi at 6.6 in draws plots at the column's own width, so 1 plot point
  # is about 1 CSS px and plot text sits at the page's scale
  chunk_defaults <- list(collapse = TRUE, comment = "#>", fig.retina = 2, dpi = 96, out.width = "100%",
                         fig.align = "center", fig.width = fig_width, fig.height = fig_height)
  stamp <- sprintf(paste0(
    '<script>(function(b){b.className=b.className.replace(/\\b(palette|preset|style)-[a-z]+\\b/g,"").trim();',
    'b.classList.add("palette-%s","preset-%s","style-%s");',
    'document.documentElement.setAttribute("data-albers-marks","");})(document.body);</script>'
  ), family, preset, style)
  base_pre_knit0 <- fmt$pre_knit
  fmt$pre_knit <- function(input, ...) {
    if (requireNamespace("knitr", quietly = TRUE)) {
      old_doc_hook <<- knitr::knit_hooks$get("document")
      knitr::knit_hooks$set(document = function(x) {
        if (is.function(old_doc_hook)) x <- old_doc_hook(x)
        .albers_insert_after_front_matter(x, stamp)
      })
      # pkgdown renders articles with its own format, which drops this
      # format's knitr defaults; set them here too, for the render only.
      chunk_names <- c(names(chunk_defaults), "albers.base")
      old_chunk_opts <<- stats::setNames(lapply(chunk_names, function(n) knitr::opts_chunk$get(n)), chunk_names)
      knitr::opts_chunk$set(chunk_defaults)
      # Base graphics: the page's ground, ink and family palette per chunk.
      old_base_hook <<- knitr::knit_hooks$get("albers.base")
      knitr::knit_hooks$set(albers.base = .albers_scalar_sizes(.albers_base_graphics_hook(family, preset)))
      knitr::opts_chunk$set(albers.base = TRUE)
      old_palette <<- grDevices::palette()
      # pkgdown applies its own figure size after pre_knit; an option hook
      # (run per chunk, after all options are merged) restores the format's
      # size unless the chunk set its own.
      old_opts_hook <<- knitr::opts_hooks$get("albers.base")
      knitr::opts_hooks$set(albers.base = function(options) {
        .albers_wrap_message_hook()
        base <- knitr::opts_chunk$get()
        if (identical(options$fig.width, base$fig.width)) options$fig.width <- fig_width
        if (identical(options$fig.height, base$fig.height)) options$fig.height <- fig_height
        if (identical(options$dpi, base$dpi)) options$dpi <- 96
        # held figures narrower than the column sit side by side, which
        # needs knitr's default alignment (centring makes each a block)
        if (identical(options$fig.show, "hold") && !is.null(options$out.width) &&
            !identical(options$out.width, "100%") && identical(options$fig.align, "center")) {
          options$fig.align <- "default"
        }
        if (isTRUE(phone_figures)) {
          .albers_wrap_plot_hook()
          options <- .albers_phone_options(options)
        }
        options
      })
    }
    old_opts <<- options(
      # R's printed output fits the code block after the 3-character "#> "
      # prefix (interaction sets its wider mono a little smaller, so both
      # directions fit 67 columns)
      width = 67L,
      albersdown.family = family,
      albersdown.preset = preset,
      albersdown.dark_figures = isTRUE(plot_theme) && isTRUE(dark_figures)
    )
    if (isTRUE(plot_theme) && isTRUE(dark_figures) &&
        requireNamespace("ggplot2", quietly = TRUE) && requireNamespace("knitr", quietly = TRUE)) {
      registerS3method("knit_print", "ggplot", .albers_knit_print_ggplot, envir = asNamespace("knitr"))
    }
    if (is.function(base_pre_knit0)) base_pre_knit0(input, ...)
  }
  if (!isTRUE(plot_theme)) {
    base_on_exit0 <- fmt$on_exit
    fmt$on_exit <- function() {
      options(old_opts)
      restore_knitr()
      if (is.function(base_on_exit0)) base_on_exit0()
    }
  }

  if (isTRUE(plot_theme)) {
    old_theme <- NULL
    base_pre_knit <- fmt$pre_knit
    fmt$pre_knit <- function(input, ...) {
      if (is.function(base_pre_knit)) base_pre_knit(input, ...)
      if (requireNamespace("ggplot2", quietly = TRUE)) {
        if (requireNamespace("systemfonts", quietly = TRUE)) {
          try(albers_register_fonts(), silent = TRUE)
        }
        # 12pt at 96 dpi is 16px: axis labels just under body text
        old_theme <<- ggplot2::theme_set(theme_albers(family = family, preset = preset, base_size = 12))
      }
    }
    base_on_exit <- fmt$on_exit
    fmt$on_exit <- function() {
      if (!is.null(old_theme)) ggplot2::theme_set(old_theme)
      options(old_opts)
      restore_knitr()
      if (is.function(base_on_exit)) base_on_exit()
    }
  }

  fmt
}

# Messages: with collapse = TRUE they merge into the code block as "#>"
# lines, indistinguishable from printed output. Each message line is marked
# with an invisible separator (U+2063) after the prompt; albers.js sets such
# runs as wrapping "Message" blocks and removes the mark. The hook is wrapped
# from the per-chunk option hook, i.e. after rmarkdown (or pkgdown) has set
# its own output hooks, so it applies under pkgdown too; rmarkdown restores
# the knit hooks when the render ends.
# Warnings and errors are marked the same way (U+2064, U+2062), so the page
# knows exactly which "#>" lines are conditions and which are printed output.
.albers_marks <- c(message = "\u2063", warning = "\u2064", error = "\u2062")

.albers_wrap_message_hook <- function() {
  for (kind in names(.albers_marks)) local({
    k <- kind
    old <- knitr::knit_hooks$get(k)
    if (!is.function(old) || isTRUE(attr(old, "albers"))) return()
    new <- function(x, options) old(.albers_mark_message(x, options$comment, .albers_marks[[k]]), options)
    attr(new, "albers") <- TRUE
    knitr::knit_hooks$set(stats::setNames(list(new), k))
  })
  invisible()
}

.albers_mark_message <- function(x, comment = "#>", mark = "\u2063") {
  prefix <- if (is.character(comment) && length(comment) == 1 && !is.na(comment)) comment else ""
  lines <- strsplit(x, "\n", fixed = TRUE)[[1]]
  has <- nzchar(lines) & startsWith(lines, prefix)
  rest <- substring(lines[has], nchar(prefix) + 1L)
  sp <- ifelse(startsWith(rest, " "), " ", "")
  lines[has] <- paste0(prefix, sp, mark, substring(rest, nchar(sp) + 1L))
  out <- paste(lines, collapse = "\n")
  if (endsWith(x, "\n")) out <- paste0(out, "\n")
  out
}

# ---------------------------------------------------------------------------
# Dark twins of ggplot figures. While an albers_vignette() renders (and
# `dark_figures = TRUE`), each auto-printed ggplot is drawn as usual -- so
# knitr's captions, sizing and numbering apply -- and a second copy is saved
# with theme_albers(mode = "dark") in place of the session theme. albers.js
# swaps the copies when the page switches theme. Plots that set a complete
# theme of their own are left alone.
.albers_twin_counter <- new.env(parent = emptyenv())

.albers_knit_print_ggplot <- function(x, options = NULL, ...) {
  # held or animated plots are laid out by knitr after the chunk, where a twin
  # cannot be paired with its plot: no twin (and no wasted bytes)
  held <- !is.null(options) && isTRUE(options$fig.show %in% c("hold", "animate", "hide"))
  if (!isTRUE(getOption("albersdown.dark_figures")) || is.null(options) || held) {
    print(x)
    return(invisible(NULL))
  }
  twin <- tryCatch(.albers_dark_twin(x, options), error = function(e) NULL)
  print(x)
  if (is.null(twin)) return(invisible(NULL))
  knitr::asis_output(twin)
}

.albers_dark_twin <- function(x, options) {
  th <- tryCatch(x$theme, error = function(e) NULL)
  if (length(th) && isTRUE(attr(th, "complete"))) return(NULL)
  family <- getOption("albersdown.family", "red")
  preset <- getOption("albersdown.preset", "homage")

  old <- ggplot2::theme_set(theme_albers(family = family, preset = preset, base_size = 12, mode = "dark"))
  on.exit(ggplot2::theme_set(old), add = TRUE)

  # Literal neutral colours (geom_line(colour = "grey70"), a black reference
  # line) are mirrored in lightness so they keep their role on the night
  # ground; chromatic literals are left as the author chose them. Layers are
  # copied, so the light figure is untouched.
  x$layers <- lapply(x$layers, function(layer) {
    ap <- layer$aes_params
    keys <- intersect(names(ap), c("colour", "color", "fill"))
    if (!length(keys)) return(layer)
    copy <- ggplot2::ggproto(NULL, layer)
    for (k in keys) ap[[k]] <- .albers_mirror_neutral(ap[[k]])
    copy$aes_params <- ap
    copy
  })

  # albersdown scales are redrawn with night tones (on a copy of the scales)
  scales <- tryCatch(x$scales, error = function(e) NULL)
  if (!is.null(scales) && any(vapply(scales$scales, function(sc) !is.null(sc$albers), logical(1)))) {
    night <- scales$clone()
    for (sc in night$scales) {
      if (!is.null(sc$albers)) sc$palette <- .albers_night_palette(sc$albers)
    }
    x$scales <- night
  }

  label <- options$label %||% "fig"
  n <- (.albers_twin_counter[[label]] %||% 0L) + 1L
  assign(label, n, envir = .albers_twin_counter)
  path <- paste0(options$fig.path %||% "figure/", label, "-dark-", n, ".png")
  dir.create(dirname(path), showWarnings = FALSE, recursive = TRUE)

  # knitr has already multiplied options$dpi by fig.retina; with a phone
  # twin, fig.width and fig.height hold the full and the phone size
  dpi <- options$dpi[1] %||% 72
  device <- if (requireNamespace("ragg", quietly = TRUE)) ragg::agg_png else "png"
  width <- options$fig.width %||% 7
  height <- options$fig.height %||% 5
  ggplot2::ggsave(path, x, width = width[1], height = height[1], units = "in", dpi = dpi, device = device)
  out <- sprintf('\n\n<img class="albers-dark-twin" src="%s" alt="" aria-hidden="true" hidden />\n\n', path)
  # the phone drawing of the dark twin, in its own paragraph (albers.js pairs
  # a dark twin only when it is alone in its paragraph)
  below <- options$albers.phone
  if (is.numeric(below) && length(width) == 2L && length(height) == 2L) {
    phone <- sub("\\.png$", ".phone.png", path)
    ggplot2::ggsave(phone, x, width = width[2], height = height[2], units = "in", dpi = dpi, device = device)
    out <- paste0(out, .albers_phone_img(phone, below, dark = TRUE), "\n\n")
  }
  out
}

# ---------------------------------------------------------------------------
# With a phone twin, a chunk's fig.width and fig.height hold two sizes (the
# full drawing and the phone one); knitr needs both to save the plots, but
# chunk code sees single values, as without phone figures:
# ggiraph::girafe() and `if (opts_current$get("fig.width") > 5)` read them.
.albers_scalar_sizes <- function(hook) {
  function(before, options, envir) {
    if (before && length(options$fig.width) > 1L && is.function(knitr::opts_current$lock)) {
      knitr::opts_current$lock(FALSE)
      on.exit(knitr::opts_current$lock(TRUE), add = TRUE)
      first <- function(x) if (length(x) > 1L) x[[1]] else x
      knitr::opts_current$set(
        fig.width = first(options$fig.width), fig.height = first(options$fig.height),
        out.width.px = first(options$out.width.px), out.height.px = first(options$out.height.px)
      )
    }
    hook(before, options, envir)
  }
}

# Phone twins. A figure drawn for the 6.6 in column and shown in a phone's
# (about 350 CSS px) is scaled to about half, its axis text to 8 px (5-6 px
# glyphs). knitr draws each recorded plot once per entry of fig.width,
# fig.height and fig.ext (sew.recordedplot maps over them), so a second entry
# draws the same plot -- base graphics, grid or ggplot2 -- again at phone
# width, and the plot hook puts it, hidden, after its figure. Titles,
# legends and axes keep their size in points, so the phone drawing is a
# little taller than the full one scaled down (height times the square root
# of the width ratio, never taller than square unless the figure is), or
# its panel would be a sliver. albers.js shows it while the figure is displayed narrower
# than the geometric mean of the two drawing widths, where each drawing is
# equally far from its own scale.
.albers_phone_width <- 3.6

.albers_phone_options <- function(options) {
  dim <- options$fig.dim
  w <- if (length(dim) == 2L) dim[[1]] else options$fig.width
  h <- if (length(dim) == 2L) dim[[2]] else options$fig.height
  # knitr would set fig.height from fig.asp after this hook, for both drawings
  if (length(dim) != 2L && is.numeric(options$fig.asp) && is.numeric(w)) h <- w * options$fig.asp
  ok <- is.numeric(w) && is.numeric(h) && length(w) == 1L && length(h) == 1L &&
    isTRUE(w >= .albers_phone_width * 1.25) &&
    length(options$dev) == 1L && isTRUE(options$dev %in% c("ragg_png", "png")) &&
    (is.null(options$fig.ext) || identical(options$fig.ext, "png")) &&
    length(options$dpi) == 1L &&
    !isTRUE(options$fig.show %in% c("animate", "hide")) &&
    is.character(options$out.width) && length(options$out.width) == 1L &&
    grepl("%$", options$out.width)
  if (!ok) return(options)
  wp <- .albers_phone_width
  options$fig.dim <- NULL
  options$fig.asp <- NULL
  options$fig.width <- c(w, wp)
  options$fig.height <- c(h, min(h * sqrt(wp / w), wp * max(h / w, 1)))
  options$fig.ext <- c("png", "phone.png")
  options$albers.phone <- round(sqrt(w * wp) * 96)
  options
}

.albers_phone_img <- function(src, below, dark = FALSE) {
  sprintf(
    '<img class="albers-phone-twin%s" src="%s" alt="" aria-hidden="true" loading="lazy" data-albers-below="%d" hidden />',
    if (dark) " albers-phone-dark" else "", src, as.integer(below)
  )
}

# The plot hook in force (rmarkdown's, or pkgdown's), followed by the phone
# drawing right after the figure's <img>, inside the same block.
.albers_wrap_plot_hook <- function() {
  old <- knitr::knit_hooks$get("plot")
  if (!is.function(old) || isTRUE(attr(old, "albers"))) return(invisible())
  new <- function(x, options) .albers_add_phone_twin(old(x, options), x, options)
  attr(new, "albers") <- TRUE
  knitr::knit_hooks$set(plot = new)
  invisible()
}

.albers_add_phone_twin <- function(out, x, options) {
  below <- options$albers.phone
  if (!is.numeric(below) || !is.character(out) || length(out) != 1L ||
      !is.character(x) || length(x) != 1L || !grepl("\\.png$", x)) return(out)
  phone <- sub("\\.png$", ".phone.png", x)
  if (!file.exists(phone)) return(out)
  at <- regexpr(paste0('src="', x, '"'), out, fixed = TRUE)
  if (at < 0) return(out)
  end <- regexpr(">", substring(out, at), fixed = TRUE)
  if (end < 0) return(out)
  cut <- at + end - 1L
  paste0(substr(out, 1L, cut), .albers_phone_img(phone, below), substring(out, cut + 1L))
}

# Mirror the lightness of near-neutral colours for a dark ground:
# grey70 becomes a dark grey, black becomes near-white; hues are kept.
.albers_mirror_neutral <- function(col) {
  if (!is.character(col) || !length(col)) return(col)
  vapply(col, function(one) {
    if (is.na(one)) return(one)
    rgba <- tryCatch(grDevices::col2rgb(one, alpha = TRUE), error = function(e) NULL)
    if (is.null(rgba)) return(one)
    lab <- grDevices::convertColor(t(rgba[1:3, , drop = FALSE]) / 255, from = "sRGB", to = "Lab")
    if (sqrt(lab[2]^2 + lab[3]^2) > 10) return(one)
    lab[1] <- 18 + (100 - lab[1]) * 0.78
    rgb <- pmin(pmax(grDevices::convertColor(lab, from = "Lab", to = "sRGB"), 0), 1)
    grDevices::rgb(rgb[1], rgb[2], rgb[3], alpha = rgba[4] / 255)
  }, character(1), USE.NAMES = FALSE)
}

# Put `lines` after the YAML front matter of a knitted document (or first,
# when there is none): anything above the opening `---` hides the metadata.
.albers_insert_after_front_matter <- function(x, lines) {
  text <- paste(x, collapse = "\n")
  m <- regexpr("(?s)^\\s*---\\s*\n.*?\n(---|\\.\\.\\.)\\s*(\n|$)", text, perl = TRUE)
  if (m == -1) return(paste(c(lines, "", text), collapse = "\n"))
  end <- m + attr(m, "match.length") - 1
  paste0(substr(text, 1, end), "\n", paste(lines, collapse = "\n"), "\n\n", substr(text, end + 1, nchar(text)))
}

.albers_finish_html <- function(path, body_class) {
  text <- paste(readLines(path, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
  text <- sub("(</head>\\s*)<body>", sprintf('\\1<body class="%s">', body_class), text, perl = TRUE)
  # condition marks (knitr hooks) become empty marker elements, so no
  # invisible character stays in the text without the page script; the
  # <html> attribute says every output line on the page was marked
  kinds <- c(msg = "\u2063", warn = "\u2064", err = "\u2062")
  for (k in names(kinds)) {
    text <- gsub(kinds[[k]], sprintf('<span class="albers-mk" data-k="%s"></span>', k), text, fixed = TRUE)
  }
  text <- sub("<html", '<html data-albers-marks=""', text, fixed = TRUE)
  # pandoc's empty per-line anchors (numbered chunks) are links with no name:
  # keep them out of the tab order and the accessibility tree, script or not
  text <- gsub('<a href="#(cb[0-9]+-[0-9]+)"></a>', '<a href="#\\1" aria-hidden="true" tabindex="-1"></a>', text, perl = TRUE)
  if (!grepl('class="math', text, fixed = TRUE)) {
    text <- gsub(
      "(?s)<!-- dynamically load mathjax for compatibility with self-contained -->\\s*<script>.*?</script>\\s*",
      "", text, perl = TRUE
    )
  }
  con <- file(path, open = "w", encoding = "UTF-8")
  on.exit(close(con))
  writeLines(text, con, useBytes = TRUE)
  invisible(path)
}

# knitr chunk hook: base graphics drawn on the page's sheet colour, in its ink,
# with the family's discrete colours as the palette (col = 1, 2, ...).
.albers_base_graphics_hook <- function(family, preset) {
  function(before, options, envir) {
    if (!before) return(invisible(NULL))
    cols <- .preset_colors(preset, family)
    graphics::par(
      bg = cols$surface, fg = cols$fg, col = cols$fg,
      col.axis = cols$muted, col.lab = cols$fg, col.main = cols$fg, col.sub = cols$muted,
      family = .albers_direction_font(preset), las = 1, bty = "l",
      cex.axis = 0.85, cex.lab = 0.9, cex.main = 1,
      mar = c(4.1, 4.1, 2.1, 1.1)
    )
    grDevices::palette(albers_discrete(family))
    invisible(NULL)
  }
}
