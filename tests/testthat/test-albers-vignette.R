test_that("albers_vignette() builds an html_vignette with the theme assets", {
  skip_if_not_installed("rmarkdown")
  fmt <- albers_vignette(family = "teal", preset = "interaction")
  expect_s3_class(fmt, "rmarkdown_output_format")
  expect_true(isTRUE(fmt$knitr$opts_chunk$collapse))
  expect_identical(fmt$knitr$opts_chunk$comment, "#>")

  expect_error(albers_vignette(family = "puce"), "albers_vignette(): `family` must be one of \"red\", \"lapis\", \"ochre\", \"teal\", \"green\", \"violet\"; got 'puce'.", fixed = TRUE)
  expect_error(albers_vignette(preset = "baroque"), "`preset` must be one of \"homage\", \"interaction\"", fixed = TRUE)
})

test_that("each direction ships only its own fonts", {
  homage <- readLines(system.file("format", "albers-fonts-homage.css", package = "albersdown"))
  interaction <- readLines(system.file("format", "albers-fonts-interaction.css", package = "albersdown"))
  expect_true(any(grepl("Newsreader", homage)))
  expect_false(any(grepl("Hanken|JetBrains|Space Grotesk", homage)))
  expect_true(any(grepl("Hanken Grotesk", interaction)))
  expect_false(any(grepl("Newsreader", interaction)))

  # the shipped (minified) core carries no @font-face: fonts come per direction
  core <- readLines(system.file("format", "albers-core.min.css", package = "albersdown"), warn = FALSE)
  expect_false(any(grepl("@font-face", core, fixed = TRUE)))
  # every font the direction files reference is installed
  urls <- regmatches(c(homage, interaction), regexpr('fonts/[a-z-]+\\.woff2', c(homage, interaction)))
  expect_true(all(nzchar(vapply(urls, function(u) system.file(u, package = "albersdown"), ""))))
})

test_that("a vignette renders self-contained with the family stamped before content", {
  skip_on_cran()
  skip_if_not_installed("rmarkdown")
  skip_if_not(rmarkdown::pandoc_available("2.0"))

  dir <- withr::local_tempdir()
  rmd <- file.path(dir, "demo.Rmd")
  writeLines(c(
    "---", "title: Demo", "vignette: >", "  %\\VignetteIndexEntry{Demo}",
    "  %\\VignetteEngine{knitr::rmarkdown}", "---", "",
    "## One", "", "```{r}", "getOption('albersdown.family')", "1 + 1", "```"
  ), rmd)

  before <- getOption("albersdown.family")
  out <- rmarkdown::render(rmd, output_format = albers_vignette(family = "teal", preset = "homage"), quiet = TRUE)
  html <- paste(readLines(out, warn = FALSE), collapse = "\n")

  # classes are set by the first script inside <body>
  body_start <- regexpr("<body[^>]*>", html)
  stamp <- regexpr('classList.add\\("albers-vignette","palette-teal","preset-homage"', html)
  expect_gt(stamp, body_start)
  expect_lt(stamp, regexpr("<h1", html))
  # the page script is inlined, the fonts embedded, nothing fetched remotely
  expect_match(html, "albersdownDefaults|initOutputLines")
  expect_match(html, "data:font/woff2;base64|data:application/font-woff2;base64|data:[^\"')]*woff2", perl = TRUE)
  expect_false(grepl('url\\("?https?://[^)]*woff2', html))
  # the family option was visible to chunks and restored afterwards
  expect_match(html, "teal")
  expect_identical(getOption("albersdown.family"), before)
})

test_that("the R Markdown template drafts and renders", {
  skip_on_cran()
  skip_if_not_installed("rmarkdown")
  skip_if_not(rmarkdown::pandoc_available("2.0"))
  skip_if_not_installed("ggplot2")

  dir <- withr::local_tempdir()
  withr::local_dir(dir)
  f <- rmarkdown::draft("demo.Rmd", template = "albers_vignette", package = "albersdown", edit = FALSE)
  out <- rmarkdown::render(f, quiet = TRUE)
  expect_true(file.exists(out))
  html <- paste(readLines(out, warn = FALSE), collapse = "\n")
  expect_match(html, "palette-red")
  expect_match(html, 'class="figure"|<figure', perl = TRUE)
})

test_that("albers_discrete() pairs the family with contrasting partners", {
  cols <- albers_discrete("red")
  expect_length(cols, 6)
  expect_true(all(grepl("^#[0-9A-Fa-f]{6}$", cols)))
  expect_identical(cols[1], unname(albers_palette("red")[["A700"]]))
  expect_identical(cols[2], .albers_mark_contrast(unname(.albers_comp("red")[["comp"]])))
  expect_identical(cols[3], unname(albers_palette(albers_complement("red"))[["A700"]]))
  expect_identical(cols[4], unname(albers_palette("red")[["A900"]]))
  expect_false(anyDuplicated(cols) > 0)

  expect_identical(albers_discrete("teal", type = "family"), unname(albers_palette("teal")))

  withr::local_options(albersdown.family = "violet")
  expect_identical(albers_discrete()[1], unname(albers_palette("violet")[["A700"]]))
})

test_that("family ramps step in lightness so nested squares are distinguishable", {
  lum <- function(hex) {
    rgb <- grDevices::col2rgb(hex)[, 1] / 255
    lin <- ifelse(rgb <= 0.04045, rgb / 12.92, ((rgb + 0.055) / 1.055)^2.4)
    sum(c(0.2126, 0.7152, 0.0722) * lin)
  }
  for (f in c("red", "lapis", "ochre", "teal", "green", "violet")) {
    l <- vapply(albers_palette(f), lum, numeric(1))
    expect_true(all(diff(l) > 0.04), info = f)
  }
})

test_that("theme_albers(mode = 'dark') uses the night ground", {
  skip_if_not_installed("ggplot2")
  light <- theme_albers("teal", "homage")
  dark <- theme_albers("teal", "homage", mode = "dark")
  expect_false(identical(light$plot.background$fill, dark$plot.background$fill))
  expect_identical(dark$plot.background$fill, "#1b1814")
  expect_identical(theme_albers("teal", "interaction", mode = "dark")$plot.background$fill, "#14171c")
})

test_that("night palettes are lighter than day palettes", {
  lum <- function(hex) mean(grDevices::col2rgb(hex))
  for (f in c("red", "lapis", "teal")) {
    expect_gt(lum(albers_discrete(f, mode = "dark")[1]), lum(albers_discrete(f)[1]))
  }
})

test_that("albers_vignette() emits a dark twin per ggplot and restores knitr", {
  skip_on_cran()
  skip_if_not_installed("rmarkdown")
  skip_if_not_installed("ggplot2")
  skip_if_not(rmarkdown::pandoc_available("2.0"))

  dir <- withr::local_tempdir()
  rmd <- file.path(dir, "twin.Rmd")
  writeLines(c(
    "---", "title: Twin", "vignette: >", "  %\\VignetteIndexEntry{Twin}",
    "  %\\VignetteEngine{knitr::rmarkdown}", "---", "",
    "```{r p1, fig.cap = 'Cap.'}",
    "ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg, colour = factor(cyl))) +",
    "  ggplot2::geom_point() + albersdown::scale_color_albers()",
    "```",
    "```{r p2}",
    "ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) + ggplot2::geom_point() + ggplot2::theme_bw()",
    "```"
  ), rmd)
  out <- rmarkdown::render(rmd, output_format = albers_vignette(family = "teal"), quiet = TRUE)
  html <- paste(readLines(out, warn = FALSE), collapse = "\n")
  twins <- gregexpr('class="albers-dark-twin"', html)[[1]]
  # one twin for the themed plot; none for the plot with its own complete theme
  expect_equal(sum(twins > 0), 1)
  expect_false(isTRUE(getOption("albersdown.dark_figures")))

  out2 <- rmarkdown::render(rmd, output_format = albers_vignette(family = "teal", dark_figures = FALSE),
                            quiet = TRUE, output_file = "twin-off.html")
  # the class name also appears in the inlined script, so match the image markup
  expect_false(grepl('class="albers-dark-twin"', paste(readLines(out2, warn = FALSE), collapse = "\n"), fixed = TRUE))
})

test_that("the pkgdown template links the theme on every page", {
  partial <- readLines(system.file("pkgdown", "templates", "in-header.html", package = "albersdown"))
  expect_true(any(grepl('{{#site}}{{root}}{{/site}}albers.css', partial, fixed = TRUE)))
  expect_true(any(grepl('{{#site}}{{root}}{{/site}}albers.js', partial, fixed = TRUE)))
  # user includes still flow through
  expect_true(any(grepl("{{{in_header}}}", partial, fixed = TRUE)))
})

test_that("use_albersdown() leaves vignettes on albers_vignette() untouched", {
  skip_if_not_installed("yaml")
  pkg <- withr::local_tempdir()
  dir.create(file.path(pkg, "vignettes"))
  writeLines(c("Package: toy", "Title: Toy", "Version: 0.0.1", "Description: Toy.",
               "License: MIT", "Encoding: UTF-8"), file.path(pkg, "DESCRIPTION"))
  vig <- c(
    "---", "title: Toy", "output:",
    "  albersdown::albers_vignette:",
    "    family: teal   # keep this comment",
    "  pdf_document: default",
    "vignette: >", "  %\\VignetteIndexEntry{Toy}", "  %\\VignetteEngine{knitr::rmarkdown}",
    "---", "", "Text."
  )
  writeLines(vig, file.path(pkg, "vignettes", "toy.Rmd"))
  suppressMessages(use_albersdown(path = pkg, family = "teal", apply_to = "all", dry_run = FALSE))
  expect_identical(readLines(file.path(pkg, "vignettes", "toy.Rmd")), vig)
  expect_true("^pkgdown$" %in% readLines(file.path(pkg, ".Rbuildignore")))
  expect_true(any(grepl('family: "teal"', readLines(file.path(pkg, "pkgdown", "extra.js")), fixed = TRUE)))
})

test_that("the class stamp goes after the YAML front matter", {
  yaml <- c("---", "title: x", "output:", "  a: b", "---", "", "# Hi")
  out <- strsplit(.albers_insert_after_front_matter(yaml, "STAMP"), "\n")[[1]]
  expect_identical(out[1:5], yaml[1:5])
  expect_true(which(out == "STAMP") > 5)
  expect_identical(out[1], "---")
  # no front matter: stamp first
  expect_identical(strsplit(.albers_insert_after_front_matter(c("# Hi"), "S"), "\n")[[1]][1], "S")
})

test_that("the rendered page carries its classes and no MathJax loader without math", {
  skip_on_cran()
  skip_if_not_installed("rmarkdown")
  skip_if_not(rmarkdown::pandoc_available("2.0"))
  dir <- withr::local_tempdir()
  rmd <- file.path(dir, "m.Rmd")
  writeLines(c("---", "title: M", "vignette: >", "  %\\VignetteIndexEntry{M}",
               "  %\\VignetteEngine{knitr::rmarkdown}", "---", "", "No math here."), rmd)
  out <- rmarkdown::render(rmd, output_format = albers_vignette(family = "lapis", preset = "interaction"), quiet = TRUE)
  html <- paste(readLines(out, warn = FALSE), collapse = "\n")
  expect_match(html, '<body class="albers-vignette palette-lapis preset-interaction style-minimal">', fixed = TRUE)
  expect_false(grepl("mathjax.rstudio.com", html, fixed = TRUE))

  writeLines(c("---", "title: M", "vignette: >", "  %\\VignetteIndexEntry{M}",
               "  %\\VignetteEngine{knitr::rmarkdown}", "---", "", "Math: $x^2$."), rmd)
  out <- rmarkdown::render(rmd, output_format = albers_vignette(), quiet = TRUE)
  expect_match(paste(readLines(out, warn = FALSE), collapse = "\n"), "<math", fixed = TRUE)
})

test_that("use_albersdown(method = 'format') switches vignettes textually", {
  pkg <- withr::local_tempdir()
  dir.create(file.path(pkg, "vignettes"))
  writeLines(c("Package: toy", "Title: Toy", "Version: 0.0.1", "Description: Toy.",
               "License: MIT", "Suggests:", "    testthat"), file.path(pkg, "DESCRIPTION"))
  writeLines(c("# my site config", "url: https://example.org", "home:", "  title: Toy"),
             file.path(pkg, "_pkgdown.yml"))
  writeLines(c(
    "---", "title: A", "output:", "  rmarkdown::html_vignette: default", "  pdf_document: default",
    "vignette: >", "  %\\VignetteIndexEntry{A}", "  %\\VignetteEngine{knitr::rmarkdown}", "---", "", "Text."
  ), file.path(pkg, "vignettes", "a.Rmd"))
  writeLines(c(
    "---", "title: B", "output:", "  rmarkdown::html_vignette:",
    "    toc: true      # keep me", "    css: albers.css", "    includes:", "      in_header: albers-header.html",
    "resource_files:", "- albers.css", "- fonts",
    "vignette: >", "  %\\VignetteIndexEntry{B}", "  %\\VignetteEngine{knitr::rmarkdown}", "---", "", "Text."
  ), file.path(pkg, "vignettes", "b.Rmd"))
  writeLines(c(
    "---", "title: C", "output: rmarkdown::html_vignette",
    "vignette: >", "  %\\VignetteIndexEntry{C}", "  %\\VignetteEngine{knitr::rmarkdown}", "---"
  ), file.path(pkg, "vignettes", "c.Rmd"))

  suppressMessages(use_albersdown(pkg, family = "teal", preset = "interaction"))

  a <- readLines(file.path(pkg, "vignettes", "a.Rmd"))
  expect_true(any(a == "  albersdown::albers_vignette:"))
  expect_true(any(a == "    family: teal") && any(a == "    preset: interaction"))
  expect_true(any(a == "  pdf_document: default"))
  expect_false(any(grepl("html_vignette", a)))

  b <- readLines(file.path(pkg, "vignettes", "b.Rmd"))
  expect_true(any(b == "    toc: true      # keep me"))
  expect_false(any(grepl("albers.css|in_header|resource_files|- fonts", b)))

  c <- readLines(file.path(pkg, "vignettes", "c.Rmd"))
  expect_identical(c[3:6], c("output:", "  albersdown::albers_vignette:", "    family: teal", "    preset: interaction"))

  desc <- readLines(file.path(pkg, "DESCRIPTION"))
  # a lower bound: CRAN albersdown 2.0.0 has no albers_vignette()
  bound <- sprintf("    albersdown (>= %s),", utils::packageVersion("albersdown"))
  expect_true(all(c("    testthat,", bound, "    knitr,", "    rmarkdown") %in% desc))
  expect_true("VignetteBuilder: knitr" %in% desc)

  cfg <- readLines(file.path(pkg, "_pkgdown.yml"))
  expect_identical(cfg[1:4], c("# my site config", "url: https://example.org", "home:", "  title: Toy"))
  expect_true(all(c("template:", "  package: albersdown", "  bootstrap: 5") %in% cfg))

  expect_false(file.exists(file.path(pkg, "vignettes", "albers.css")))
  expect_false(file.exists(file.path(pkg, "README.md")))
  expect_true(file.exists(file.path(pkg, ".albersdown.bak", "a.Rmd")))

  # the switched vignette renders
  skip_on_cran()
  skip_if_not_installed("rmarkdown")
  skip_if_not(rmarkdown::pandoc_available("2.0"))
  out <- rmarkdown::render(file.path(pkg, "vignettes", "c.Rmd"), quiet = TRUE)
  expect_match(paste(readLines(out, warn = FALSE), collapse = "\n"), "palette-teal preset-interaction", fixed = TRUE)
})

test_that("the format retrofit handles 4-space YAML, comments, and user pkgdown files", {
  pkg <- withr::local_tempdir()
  dir.create(file.path(pkg, "vignettes"))
  dir.create(file.path(pkg, "pkgdown"))
  writeLines(c("Package: toy", "Title: Toy", "Version: 0.0.1", "Description: Toy.", "License: MIT",
               "Config/Needs/website:", "    tidyverse/tidytemplate,", "    ggplot2"),
             file.path(pkg, "DESCRIPTION"))
  writeLines("a { color: hotpink; }", file.path(pkg, "pkgdown", "extra.css"))
  writeLines("console.log('mine');", file.path(pkg, "pkgdown", "extra.js"))
  writeLines(c(
    "---", "title: A", "output:",
    "    rmarkdown::html_vignette:   # the CRAN one",
    "        toc: true",
    "        fig_width: 6",
    "    pdf_document: default",
    "vignette: >", "  %\\VignetteIndexEntry{A}", "  %\\VignetteEngine{knitr::rmarkdown}", "---", "", "Text."
  ), file.path(pkg, "vignettes", "a.Rmd"))

  suppressMessages(use_albersdown(pkg, family = "ochre", preset = "interaction"))

  a <- readLines(file.path(pkg, "vignettes", "a.Rmd"))
  expect_true("    albersdown::albers_vignette: # the CRAN one" %in% a)
  expect_true(all(c("        family: ochre", "        preset: interaction",
                    "        toc: true", "        fig_width: 6", "    pdf_document: default") %in% a))
  expect_false(any(grepl("html_vignette", a)))

  desc <- read.dcf(file.path(pkg, "DESCRIPTION"))
  needs <- trimws(strsplit(desc[, "Config/Needs/website"], ",")[[1]])
  expect_setequal(needs, c("tidyverse/tidytemplate", "ggplot2", "bbuchsbaum/albersdown"))
  # the backup is the original file
  bak <- read.dcf(file.path(pkg, ".albersdown.bak", "DESCRIPTION"))
  expect_false(grepl("albersdown", bak[, "Config/Needs/website"]))

  expect_identical(readLines(file.path(pkg, "pkgdown", "extra.css")), "a { color: hotpink; }")
  js <- readLines(file.path(pkg, "pkgdown", "extra.js"))
  expect_true("console.log('mine');" %in% js)
  expect_true(any(grepl('family: "ochre"', js, fixed = TRUE)))
})

test_that("math renders as MathML by default, with no network", {
  skip_on_cran()
  skip_if_not_installed("rmarkdown")
  skip_if_not(rmarkdown::pandoc_available("2.0"))
  dir <- withr::local_tempdir()
  rmd <- file.path(dir, "m.Rmd")
  writeLines(c("---", "title: M", "vignette: >", "  %\\VignetteIndexEntry{M}",
               "  %\\VignetteEngine{knitr::rmarkdown}", "---", "", "Inline $x^2$ and $$\\frac{1}{2}$$"), rmd)
  out <- rmarkdown::render(rmd, output_format = albers_vignette(), quiet = TRUE)
  html <- paste(readLines(out, warn = FALSE), collapse = "\n")
  expect_match(html, "<math", fixed = TRUE)
  expect_false(grepl("mathjax", html, ignore.case = TRUE))
})

test_that("base graphics take the page's ground and palette, and the session is restored", {
  skip_on_cran()
  skip_if_not_installed("rmarkdown")
  skip_if_not(rmarkdown::pandoc_available("2.0"))
  dir <- withr::local_tempdir()
  rmd <- file.path(dir, "b.Rmd")
  writeLines(c("---", "title: B", "vignette: >", "  %\\VignetteIndexEntry{B}",
               "  %\\VignetteEngine{knitr::rmarkdown}", "---", "",
               "```{r}", "c(bg = par('bg'), c2 = palette()[2])", "plot(1:3, col = 2)", "```"), rmd)
  pal_before <- grDevices::palette()
  out <- rmarkdown::render(rmd, output_format = albers_vignette(family = "teal"), quiet = TRUE)
  html <- paste(readLines(out, warn = FALSE), collapse = "\n")
  expect_match(html, "#FBF7EE|#fbf7ee", perl = TRUE)                # sheet colour as par("bg")
  expect_match(html, toupper(albers_discrete("teal")[2]), fixed = TRUE)
  expect_identical(grDevices::palette(), pal_before)
})

test_that("the retrofit keeps user css, skips other formats, keeps first backups, validates input", {
  pkg <- withr::local_tempdir()
  dir.create(file.path(pkg, "vignettes"))
  writeLines(c("Package: toy", "Title: Toy", "Version: 0.0.1", "Description: Toy.", "License: MIT"),
             file.path(pkg, "DESCRIPTION"))
  orig_a <- c(
    "---", "title: A", "output:", "  rmarkdown::html_vignette:",
    "    css: [custom.css, albers.css]", "    includes:", "      in_header: albers-header.html",
    "      before_body: mine.html",
    "vignette: >", "  %\\VignetteIndexEntry{A}", "  %\\VignetteEngine{knitr::rmarkdown}", "---"
  )
  writeLines(orig_a, file.path(pkg, "vignettes", "a.Rmd"))
  book <- c("---", "title: B", "output: bookdown::html_vignette2",
            "vignette: >", "  %\\VignetteIndexEntry{B}", "  %\\VignetteEngine{knitr::rmarkdown}", "---")
  writeLines(book, file.path(pkg, "vignettes", "b.Rmd"))

  expect_error(use_albersdown(pkg, family = "blue"), "use_albersdown(): `family` must be one of \"red\", \"lapis\", \"ochre\", \"teal\", \"green\", \"violet\"; got 'blue'.", fixed = TRUE)
  expect_error(use_albersdown(withr::local_tempdir()), "must be an R package")

  suppressMessages(use_albersdown(pkg, family = "teal"))
  a <- readLines(file.path(pkg, "vignettes", "a.Rmd"))
  expect_true(all(c("    css: custom.css", "    includes:", "      before_body: mine.html") %in% a))
  expect_false(any(grepl("albers.css|albers-header", a)))
  expect_identical(readLines(file.path(pkg, "vignettes", "b.Rmd")), book)

  # a second run does not overwrite the original backup
  suppressMessages(use_albersdown(pkg, family = "lapis"))
  expect_identical(readLines(file.path(pkg, ".albersdown.bak", "a.Rmd")), orig_a)
  expect_true("^\\.albersdown\\.bak$" %in% readLines(file.path(pkg, ".Rbuildignore")))
  expect_true(".albersdown.bak/" %in% readLines(file.path(pkg, ".gitignore")))
})

test_that("re-running use_albersdown() changes the family of converted vignettes; non-first html_vignette is refused", {
  pkg <- withr::local_tempdir()
  dir.create(file.path(pkg, "vignettes"))
  writeLines(c("Package: toy", "Title: Toy", "Version: 0.0.1", "Description: Toy.", "License: MIT"),
             file.path(pkg, "DESCRIPTION"))
  writeLines(c("---", "title: A", "output: rmarkdown::html_vignette",
               "vignette: >", "  %\\VignetteIndexEntry{A}", "  %\\VignetteEngine{knitr::rmarkdown}", "---"),
             file.path(pkg, "vignettes", "a.Rmd"))
  second <- c("---", "title: T", "output:", "  html_document: default", "  rmarkdown::html_vignette: default",
              "vignette: >", "  %\\VignetteIndexEntry{T}", "  %\\VignetteEngine{knitr::rmarkdown}", "---")
  writeLines(second, file.path(pkg, "vignettes", "t.Rmd"))

  suppressMessages(use_albersdown(pkg, family = "teal"))
  expect_true("    family: teal" %in% readLines(file.path(pkg, "vignettes", "a.Rmd")))
  expect_identical(readLines(file.path(pkg, "vignettes", "t.Rmd")), second)

  suppressMessages(use_albersdown(pkg, family = "violet", preset = "interaction"))
  a <- readLines(file.path(pkg, "vignettes", "a.Rmd"))
  expect_true(all(c("    family: violet", "    preset: interaction") %in% a))
  expect_false(any(grepl("teal|homage", a)))
})

test_that("a YAML comment is not an output format, and the site default follows a return to red", {
  pkg <- withr::local_tempdir()
  dir.create(file.path(pkg, "vignettes"))
  writeLines(c("Package: toy", "Title: Toy", "Version: 0.0.1", "Description: Toy.", "License: MIT"),
             file.path(pkg, "DESCRIPTION"))
  writeLines(c("---", "title: D", "output:", "    # the html format", "    rmarkdown::html_vignette: default",
               "vignette: >", "  %\\VignetteIndexEntry{D}", "  %\\VignetteEngine{knitr::rmarkdown}", "---"),
             file.path(pkg, "vignettes", "d.Rmd"))
  suppressMessages(use_albersdown(pkg, family = "lapis"))
  d <- readLines(file.path(pkg, "vignettes", "d.Rmd"))
  expect_true("    albersdown::albers_vignette:" %in% d)
  expect_true(any(grepl('family: "lapis"', readLines(file.path(pkg, "pkgdown", "extra.js")), fixed = TRUE)))

  suppressMessages(use_albersdown(pkg, family = "red", preset = "homage"))
  js <- readLines(file.path(pkg, "pkgdown", "extra.js"))
  expect_true(any(grepl('family: "red", preset: "homage"', js, fixed = TRUE)))
  expect_false(any(grepl("lapis", js)))
})


test_that("each discrete slot keeps its hue between light and dark", {
  hue <- function(hex) {
    lab <- grDevices::convertColor(t(grDevices::col2rgb(hex)) / 255, from = "sRGB", to = "Lab")
    (atan2(lab[3], lab[2]) * 180 / pi) %% 360
  }
  for (f in c("red", "lapis", "ochre", "teal", "green", "violet")) {
    light <- albers_discrete(f)
    dark <- albers_discrete(f, mode = "dark")
    for (k in 1:5) {
      d <- abs(hue(light[k]) - hue(dark[k]))
      expect_lt(min(d, 360 - d), 35, label = sprintf("%s slot %d hue shift", f, k))
    }
  }
})

test_that("every discrete slot reaches 3:1 against its plot ground", {
  lum <- function(h) {
    v <- grDevices::col2rgb(h)[, 1] / 255
    v <- ifelse(v <= 0.04045, v / 12.92, ((v + 0.055) / 1.055)^2.4)
    sum(c(0.2126, 0.7152, 0.0722) * v)
  }
  ratio <- function(a, b) {
    l <- sort(c(lum(a), lum(b)), decreasing = TRUE)
    (l[1] + 0.05) / (l[2] + 0.05)
  }
  grounds <- list(
    light = vapply(c("homage", "interaction"), function(p) theme_albers(preset = p)$plot.background$fill, ""),
    dark = vapply(c("homage", "interaction"), function(p) theme_albers(preset = p, mode = "dark")$plot.background$fill, "")
  )
  for (f in c("red", "lapis", "ochre", "teal", "green", "violet")) {
    for (m in c("light", "dark")) {
      vals <- albers_discrete(f, mode = m)
      for (k in seq_along(vals)) for (g in grounds[[m]]) {
        expect_gte(ratio(vals[k], g), 3, label = sprintf("%s %s slot %d on %s", f, m, k, g))
      }
    }
  }
})

test_that("message lines are marked after the prompt, other lines untouched", {
  mark <- "\u2063"
  x <- .albers_mark_message("#> Model converged\n#>   in 12 steps\n", "#>")
  expect_identical(x, paste0("#> ", mark, "Model converged\n#> ", mark, "  in 12 steps\n"))
  expect_identical(.albers_mark_message("## hi", "##"), paste0("## ", mark, "hi"))
  expect_identical(.albers_mark_message("plain", NA), paste0(mark, "plain"))
})

test_that("a render leaves no albersdown knitr hooks or options behind", {
  skip_if_not_installed("rmarkdown")
  skip_if_not(rmarkdown::pandoc_available())
  dir <- withr::local_tempdir()
  rmd <- file.path(dir, "v.Rmd")
  writeLines(c("---", "title: t", "output: albersdown::albers_vignette",
    "vignette: >", "  %\\VignetteIndexEntry{t}", "  %\\VignetteEngine{knitr::rmarkdown}", "---", "",
    "```{r}", "message('hello')", "1 + 1", "```"), rmd)
  before_hook <- knitr::opts_hooks$get("albers.base")
  before_opt <- knitr::opts_chunk$get("albers.base")
  out <- rmarkdown::render(rmd, quiet = TRUE)
  expect_identical(knitr::opts_hooks$get("albers.base"), before_hook)
  expect_identical(knitr::opts_chunk$get("albers.base"), before_opt)
  html <- paste(readLines(out, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
  # the post-processor turns the knit-time mark into a marker element
  expect_match(html, '<span class="albers-mk" data-k="msg"></span>hello', fixed = TRUE)
  expect_false(grepl("\u2063", html, fixed = TRUE))
})

test_that("an article without a vignette index entry renders without the title warning", {
  skip_if_not_installed("rmarkdown")
  skip_if_not(rmarkdown::pandoc_available())
  dir <- withr::local_tempdir()
  rmd <- file.path(dir, "article.Rmd")
  writeLines(c("---", "title: An article", "output: albersdown::albers_vignette", "---", "", "Text."), rmd)
  withr::local_options(rmarkdown.html_vignette.check_title = TRUE)
  expect_no_warning(rmarkdown::render(rmd, quiet = TRUE))
})

test_that("style = 'balanced' is accepted and stamped on the body", {
  skip_if_not_installed("rmarkdown")
  skip_if_not(rmarkdown::pandoc_available())
  expect_no_error(albers_vignette(style = "balanced"))
  expect_error(albers_vignette(style = "loud"))
  dir <- withr::local_tempdir()
  rmd <- file.path(dir, "b.Rmd")
  writeLines(c("---", "title: b", "vignette: >", "  %\\VignetteIndexEntry{b}", "  %\\VignetteEngine{knitr::rmarkdown}", "---", "", "Text."), rmd)
  out <- rmarkdown::render(rmd, output_format = albers_vignette(style = "balanced"), quiet = TRUE)
  html <- paste(readLines(out, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
  expect_match(html, '<body class="[^"]*style-balanced')
})

test_that("fonts = 'both' embeds both directions' faces; the default only one", {
  skip_if_not_installed("rmarkdown")
  skip_if_not(rmarkdown::pandoc_available())
  dir <- withr::local_tempdir()
  rmd <- file.path(dir, "f.Rmd")
  writeLines(c("---", "title: f", "vignette: >", "  %\\VignetteIndexEntry{f}", "  %\\VignetteEngine{knitr::rmarkdown}", "---", "", "Text."), rmd)
  one <- rmarkdown::render(rmd, output_format = albers_vignette(), output_file = "one.html", quiet = TRUE)
  both <- rmarkdown::render(rmd, output_format = albers_vignette(fonts = "both"), output_file = "both.html", quiet = TRUE)
  read <- function(p) paste(readLines(p, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
  expect_false(grepl('font-family: "Hanken Grotesk"', read(one), fixed = TRUE))
  expect_true(grepl('font-family: "Hanken Grotesk"', read(both), fixed = TRUE))
  expect_true(grepl('font-family: "Newsreader"', read(both), fixed = TRUE))
  expect_error(albers_vignette(fonts = "all"), "fonts")
})

test_that("held plots get no dark twin (it could not be paired)", {
  skip_on_cran()
  skip_if_not_installed("ggplot2")
  skip_if_not_installed("rmarkdown")
  skip_if_not(rmarkdown::pandoc_available())
  dir <- withr::local_tempdir()
  rmd <- file.path(dir, "h.Rmd")
  writeLines(c("---", "title: h", "vignette: >", "  %\\VignetteIndexEntry{h}", "  %\\VignetteEngine{knitr::rmarkdown}", "---", "",
    "```{r, fig.show = 'hold'}", "library(ggplot2)", "p <- ggplot(mtcars, aes(wt, mpg)) + geom_point()", "p", "p", "```",
    "", "```{r}", "p", "```"), rmd)
  out <- rmarkdown::render(rmd, output_format = albers_vignette(), quiet = TRUE)
  html <- paste(readLines(out, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
  # only the last (unheld) chunk's plot has a twin
  expect_identical(lengths(regmatches(html, gregexpr('<img[^>]*class="albers-dark-twin"', html))), 1L)
})
