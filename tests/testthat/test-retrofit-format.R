toy_pkg <- function(desc_extra = character(), env = parent.frame()) {
  pkg <- withr::local_tempdir(.local_envir = env)
  dir.create(file.path(pkg, "vignettes"))
  writeLines(c("Package: toy", "Title: Toy", "Version: 0.0.1", "Description: Toy.",
               "License: MIT", desc_extra), file.path(pkg, "DESCRIPTION"))
  pkg
}

html_vig <- function(title = "A") {
  c("---", paste0("title: ", title), "output: rmarkdown::html_vignette",
    "vignette: >", paste0("  %\\VignetteIndexEntry{", title, "}"), "  %\\VignetteEngine{knitr::rmarkdown}",
    "---", "", "Text.")
}

test_that("DESCRIPTION gets a version bound and, for a development version, Remotes", {
  pkg <- toy_pkg(c("Suggests:", "    albersdown,", "    testthat",
                   "Config/Needs/website: albersdown, bbuchsbaum/albersdown"))
  withr::local_dir(pkg)
  suppressMessages(.ensure_vignette_deps(version = "2.0.0.9000"))
  desc <- readLines("DESCRIPTION")
  expect_true("    albersdown (>= 2.0.0.9000)," %in% desc)
  d <- read.dcf("DESCRIPTION")
  expect_identical(trimws(strsplit(d[, "Config/Needs/website"], ",")[[1]]), "bbuchsbaum/albersdown")
  expect_identical(unname(trimws(d[, "Remotes"])), "bbuchsbaum/albersdown")
  expect_identical(d[, "VignetteBuilder"], c(VignetteBuilder = "knitr"))
  # idempotent
  expect_false(suppressMessages(.ensure_vignette_deps(version = "2.0.0.9000")))
  expect_identical(readLines("DESCRIPTION"), desc)

  # the Remotes note is said, with its check NOTE
  writeLines(c("Package: toy", "Title: Toy", "Version: 0.0.1"), "DESCRIPTION")
  msg <- paste(testthat::capture_messages(.ensure_vignette_deps(version = "2.0.0.9000")), collapse = "")
  expect_match(msg, "Remotes: bbuchsbaum/albersdown", fixed = TRUE)
  expect_match(msg, "not on CRAN", fixed = TRUE)
  expect_match(msg, "--as-cran", fixed = TRUE)
})

test_that("a released version gets a plain version bound, with no Remotes or Remotes note", {
  pkg <- toy_pkg(c("Suggests:", "    testthat"))
  withr::local_dir(pkg)
  msg <- paste(testthat::capture_messages(.ensure_vignette_deps(version = "2.1.0")), collapse = "")
  desc <- readLines("DESCRIPTION")
  expect_true("    albersdown (>= 2.1.0)," %in% desc)
  d <- read.dcf("DESCRIPTION")
  expect_false("Remotes" %in% colnames(d))
  expect_identical(d[, "VignetteBuilder"], c(VignetteBuilder = "knitr"))
  expect_no_match(msg, "Remotes: bbuchsbaum/albersdown", fixed = TRUE)
  expect_no_match(msg, "not on CRAN", fixed = TRUE)
  # idempotent
  expect_false(suppressMessages(.ensure_vignette_deps(version = "2.1.0")))
  expect_identical(readLines("DESCRIPTION"), desc)
})

test_that("existing bounds and Remotes are respected; a release adds no Remotes", {
  pkg <- toy_pkg(c("Suggests: knitr, albersdown (>= 1.0), rmarkdown",
                   "Remotes:", "    r-lib/foo,", "    github::bbuchsbaum/albersdown@main"))
  withr::local_dir(pkg)
  suppressMessages(.ensure_vignette_deps(version = "2.0.0.9000"))
  d <- read.dcf("DESCRIPTION")
  expect_identical(d[, "Suggests"], c(Suggests = "knitr, albersdown (>= 2.0.0.9000), rmarkdown"))
  expect_identical(trimws(strsplit(d[, "Remotes"], ",")[[1]]), c("r-lib/foo", "github::bbuchsbaum/albersdown@main"))

  # a higher bound stays; a CRAN release needs no Remotes
  pkg2 <- toy_pkg(c("Suggests: albersdown (>= 3.0)"))
  withr::local_dir(pkg2)
  suppressMessages(.ensure_vignette_deps(version = "2.1.0"))
  d <- read.dcf("DESCRIPTION")
  expect_match(d[, "Suggests"], "albersdown (>= 3.0)", fixed = TRUE)
  expect_false("Remotes" %in% colnames(d))

  # an existing Remotes field is appended to, without reflowing
  pkg3 <- toy_pkg(c("Remotes:", "    r-lib/foo"))
  withr::local_dir(pkg3)
  suppressMessages(.ensure_vignette_deps(version = "2.0.0.9000"))
  desc <- readLines("DESCRIPTION")
  expect_true(all(c("Remotes:", "    r-lib/foo,", "    bbuchsbaum/albersdown") %in% desc))
  expect_identical(sum(grepl("^Remotes:", desc)), 1L)
})

test_that("use_albersdown() writes the bound for the installed version", {
  pkg <- toy_pkg()
  writeLines(html_vig(), file.path(pkg, "vignettes", "a.Rmd"))
  suppressMessages(use_albersdown(pkg))
  d <- read.dcf(file.path(pkg, "DESCRIPTION"))
  v <- utils::packageVersion("albersdown")
  expect_match(d[, "Suggests"], sprintf("albersdown (>= %s)", v), fixed = TRUE)
  expect_identical("Remotes" %in% colnames(d), .albers_is_dev_version(v))
  expect_true(.albers_is_dev_version("2.0.0.9000"))
  expect_false(.albers_is_dev_version("2.1.0"))
})

test_that("a created _pkgdown.yml is kept out of the tarball", {
  pkg <- toy_pkg()
  suppressMessages(use_albersdown(pkg, apply_to = "new"))
  expect_true(file.exists(file.path(pkg, "_pkgdown.yml")))
  ign <- readLines(file.path(pkg, ".Rbuildignore"))
  expect_true(all(c("^_pkgdown\\.yml$", "^docs$") %in% ign))
  withr::with_dir(pkg, {
    expect_true(.albers_build_ignored("_pkgdown.yml"))
    expect_true(.albers_build_ignored("docs"))
  })

  # an existing, unignored _pkgdown.yml is added; an equivalent pattern is respected
  pkg2 <- toy_pkg()
  writeLines(c("template:", "  package: albersdown"), file.path(pkg2, "_pkgdown.yml"))
  suppressMessages(use_albersdown(pkg2, apply_to = "new"))
  expect_true("^_pkgdown\\.yml$" %in% readLines(file.path(pkg2, ".Rbuildignore")))
  expect_false("^docs$" %in% readLines(file.path(pkg2, ".Rbuildignore")))

  pkg3 <- toy_pkg()
  writeLines("^_pkgdown\\.ya?ml$", file.path(pkg3, ".Rbuildignore"))
  suppressMessages(use_albersdown(pkg3, apply_to = "new"))
  ign <- readLines(file.path(pkg3, ".Rbuildignore"))
  expect_false("^_pkgdown\\.yml$" %in% ign)
  expect_true("^docs$" %in% ign)
})

legacy_20_vignette <- function(title = "P", body_extra = character()) {
  c(
    "---", paste0("title: ", title), "output:", "  rmarkdown::html_vignette:", "    toc: yes",
    "    toc_depth: 2.0", "    css: albers.css", "    includes:", "      in_header: albers-header.html",
    "params:", "  family: lapis", "  preset: homage",
    "resource_files:", "- albers.css", "- albers.js", "- albers-header.html", "- fonts", "",
    "vignette: |", paste0("  %\\VignetteIndexEntry{", title, "}"), "  %\\VignetteEngine{knitr::rmarkdown}",
    "  %\\VignetteEncoding{UTF-8}", "---", "",
    "```{r setup, include = FALSE}",
    "if (requireNamespace(\"ragg\", quietly = TRUE)) knitr::opts_chunk$set(dev = \"ragg_png\")",
    "if (",
    "  requireNamespace(\"systemfonts\", quietly = TRUE) &&",
    "  requireNamespace(\"albersdown\", quietly = TRUE) &&",
    "  \"albers_register_fonts\" %in% getNamespaceExports(\"albersdown\")",
    ") {",
    "  albersdown::albers_register_fonts()",
    "}",
    "if (requireNamespace(\"ggplot2\", quietly = TRUE) && requireNamespace(\"albersdown\", quietly = TRUE)) ggplot2::theme_set(albersdown::theme_albers(family = params$family, preset = params$preset))",
    "library(ggplot2)",
    "```", "",
    "```{r albers-classes, echo=FALSE, results='asis'}",
    "cat(sprintf('<script>%s %s</script>', params$family, params$preset))",
    "```", "",
    body_extra,
    "## Plots", "", "```{r}", "plot(1)", "```"
  )
}

legacy_20_pkg <- function(env = parent.frame()) {
  pkg <- toy_pkg(c("Suggests:", "    ggplot2,", "    knitr,", "    rmarkdown",
                   "VignetteBuilder: knitr", "Config/Needs/website: albersdown"), env = env)
  writeLines(legacy_20_vignette("P"), file.path(pkg, "vignettes", "plots.Rmd"))
  writeLines(legacy_20_vignette("Q", c("Family: `r params$family`.", "")), file.path(pkg, "vignettes", "uses.Rmd"))
  for (f in c("albers.css", "albers.js", "albers-header.html")) writeLines("/* vendored */", file.path(pkg, "vignettes", f))
  dir.create(file.path(pkg, "vignettes", "fonts"))
  for (f in c("newsreader.woff2", "familjen-grotesk.woff2")) writeLines("x", file.path(pkg, "vignettes", "fonts", f))
  dir.create(file.path(pkg, "pkgdown"))
  writeLines(c("@import url(\"albers.css\");", ""), file.path(pkg, "pkgdown", "extra.css"))
  writeLines(c("/* albersdown pkgdown/extra.js: site default classes + full albers.js. */", "(function () {", "})();"),
             file.path(pkg, "pkgdown", "extra.js"))
  writeLines(c("template:", "  package: albersdown", "  bootstrap: 5.0"), file.path(pkg, "_pkgdown.yml"))
  writeLines(c(
    "# toy", "", "Toy package.", "",
    "<!-- albersdown:theme-note:start -->", "## Albers theme",
    "This package uses the albersdown theme. ... configured via `params$family` and `params$preset` ...",
    "<!-- albersdown:theme-note:end -->"
  ), file.path(pkg, "README.md"))
  # albersdown 2.0 left its own backups
  dir.create(file.path(pkg, ".albersdown.bak"))
  writeLines("2.0's backup", file.path(pkg, ".albersdown.bak", "plots.Rmd"))
  pkg
}

test_that("a package set up by albersdown 2.0 is migrated to the format", {
  pkg <- legacy_20_pkg()
  suppressMessages(use_albersdown(pkg, family = "teal", preset = "interaction"))

  p <- readLines(file.path(pkg, "vignettes", "plots.Rmd"))
  expect_true(all(c("  albersdown::albers_vignette:", "    family: teal", "    preset: interaction",
                    "    toc: yes", "library(ggplot2)", "```{r setup, include = FALSE}") %in% p))
  expect_false(any(grepl("theme_set|ragg|systemfonts|albers_register_fonts|albers-classes|params|resource_files|albers\\.css", p)))
  # the vignette index entry follows directly
  expect_true("vignette: |" %in% p)

  # a vignette that reads params$family keeps its params
  u <- readLines(file.path(pkg, "vignettes", "uses.Rmd"))
  expect_true(all(c("params:", "  family: lapis") %in% u))
  expect_false(any(grepl("theme_set", u)))

  # vendored assets are moved to the backup store; 2.0's backup is not overwritten
  expect_false(any(file.exists(file.path(pkg, "vignettes", c("albers.css", "albers.js", "albers-header.html", "fonts")))))
  bak <- file.path(pkg, ".albersdown.bak")
  expect_true(all(file.exists(file.path(bak, c("albers.css", "albers.js", "albers-header.html",
                                               "fonts/newsreader.woff2", "fonts/familjen-grotesk.woff2")))))
  expect_identical(readLines(file.path(bak, "plots.Rmd")), "2.0's backup")
  expect_length(list.files(bak, pattern = "^plots\\.Rmd\\."), 1L)

  # 2.0's generated pkgdown files are replaced
  expect_false(file.exists(file.path(pkg, "pkgdown", "extra.css")))
  expect_identical(readLines(file.path(pkg, "pkgdown", "extra.js")),
                   'window.albersdownDefaults = { family: "teal", preset: "interaction", style: "minimal" };')

  # README note describes the format, not 2.0's setup
  readme <- paste(readLines(file.path(pkg, "README.md")), collapse = "\n")
  expect_match(readme, "albersdown::albers_vignette()", fixed = TRUE)
  expect_false(grepl("params$family", readme, fixed = TRUE))
  expect_identical(lengths(regmatches(readme, gregexpr("theme-note:start", readme))), 1L)

  d <- read.dcf(file.path(pkg, "DESCRIPTION"))
  expect_identical(unname(trimws(d[, "Config/Needs/website"])), "bbuchsbaum/albersdown")
  expect_true("^_pkgdown\\.yml$" %in% readLines(file.path(pkg, ".Rbuildignore")))

  # a second run changes nothing
  before <- lapply(list.files(pkg, recursive = TRUE, full.names = TRUE), readLines)
  suppressMessages(use_albersdown(pkg, family = "teal", preset = "interaction"))
  expect_identical(lapply(list.files(pkg, recursive = TRUE, full.names = TRUE), readLines), before)
})

test_that("a vignette already on the format loses 2.0's leftover setup lines", {
  pkg <- toy_pkg()
  v <- legacy_20_vignette("P")
  v <- c(v[1:2], "output:", "  albersdown::albers_vignette:", "    family: teal", v[10:length(v)])
  v <- v[!grepl("css: albers.css|in_header|includes:", v)]
  writeLines(v, file.path(pkg, "vignettes", "p.Rmd"))
  msg <- paste(testthat::capture_messages(use_albersdown(pkg, family = "teal")), collapse = "")
  expect_match(msg, "removed albersdown 2.0's setup lines", fixed = TRUE)
  p <- readLines(file.path(pkg, "vignettes", "p.Rmd"))
  expect_false(any(grepl("theme_set|params", p)))
  expect_true("    family: teal" %in% p)
})

test_that("vendored assets still used by an unconverted vignette stay, and user extra.css stays", {
  pkg <- legacy_20_pkg()
  writeLines(c("a { color: hotpink; }", "@import url(\"albers.css\");"), file.path(pkg, "pkgdown", "extra.css"))
  q <- c("---", "title: Q", "output:", "  html_document: default", "  rmarkdown::html_vignette:",
         "    css: albers.css", "vignette: >", "  %\\VignetteIndexEntry{Q}", "---")
  writeLines(q, file.path(pkg, "vignettes", "q.Rmd"))
  msg <- paste(testthat::capture_messages(use_albersdown(pkg, family = "teal")), collapse = "")
  expect_match(msg, "still used by q.Rmd", fixed = TRUE)
  expect_true(all(file.exists(file.path(pkg, "vignettes", c("albers.css", "fonts/newsreader.woff2")))))
  expect_identical(readLines(file.path(pkg, "pkgdown", "extra.css")), c("a { color: hotpink; }", "@import url(\"albers.css\");"))
})

test_that("YAML fences follow rmarkdown: trailing blanks and a closing ...", {
  pkg <- toy_pkg()
  mu <- c("---", "title: Mu", "output: rmarkdown::html_vignette",
          "vignette: >", "  %\\VignetteIndexEntry{Mu}", "...", "", "Text.")
  xi <- c("", "--- ", "title: Xi", "output: rmarkdown::html_vignette   ",
          "vignette: >", "  %\\VignetteIndexEntry{Xi}", "---  ", "", "Text.")
  bad <- c("---", "title: Bad", "Text without a closing fence.")
  writeLines(mu, file.path(pkg, "vignettes", "mu.Rmd"))
  writeLines(xi, file.path(pkg, "vignettes", "xi.Rmd"))
  writeLines(bad, file.path(pkg, "vignettes", "bad.Rmd"))
  msg <- paste(testthat::capture_messages(use_albersdown(pkg, family = "teal")), collapse = "")
  expect_match(msg, "Could not find the YAML header delimiters (--- ... --- or ...) in bad.Rmd", fixed = TRUE)
  expect_false(grepl("No YAML header", msg, fixed = TRUE))

  m <- readLines(file.path(pkg, "vignettes", "mu.Rmd"))
  expect_identical(m[1:5], c("---", "title: Mu", "output:", "  albersdown::albers_vignette:", "    family: teal"))
  expect_identical(m[length(m) - 2L], "...")
  x <- readLines(file.path(pkg, "vignettes", "xi.Rmd"))
  expect_identical(x[1:2], c("", "--- "))
  expect_true(all(c("  albersdown::albers_vignette:", "---  ") %in% x))
  expect_identical(readLines(file.path(pkg, "vignettes", "bad.Rmd")), bad)

  # the re-run path (already on the format) reads the same fences
  suppressMessages(use_albersdown(pkg, family = "violet"))
  expect_true("    family: violet" %in% readLines(file.path(pkg, "vignettes", "mu.Rmd")))
  expect_true("    family: violet" %in% readLines(file.path(pkg, "vignettes", "xi.Rmd")))

  expect_identical(.albers_fences(c("---", "a: 1", "...")), c(1L, 3L))
  expect_null(.albers_fences(c("text", "---", "a: 1", "---")))
  expect_null(.albers_fences(c("...", "a: 1", "---")))
})

test_that("a scalar albers_vignette output takes arguments as a map", {
  pkg <- toy_pkg()
  writeLines(c("---", "title: S", "output: albersdown::albers_vignette", "---", "", "Text."),
             file.path(pkg, "vignettes", "s.Rmd"))
  suppressMessages(use_albersdown(pkg))
  expect_identical(readLines(file.path(pkg, "vignettes", "s.Rmd"))[3], "output: albersdown::albers_vignette")
  suppressMessages(use_albersdown(pkg, family = "teal"))
  s <- readLines(file.path(pkg, "vignettes", "s.Rmd"))
  expect_identical(s[3:5], c("output:", "  albersdown::albers_vignette:", "    family: teal"))
  skip_if_not_installed("yaml")
  expect_identical(yaml::yaml.load(paste(s[2:(length(s) - 3)], collapse = "\n"))$output,
                   list(`albersdown::albers_vignette` = list(family = "teal")))
})

test_that("readme = TRUE describes the format for the format method", {
  pkg <- toy_pkg()
  # the format note needs a vignette on the format (else the site-only note)
  writeLines(html_vig(), file.path(pkg, "vignettes", "a.Rmd"))
  writeLines(c("# toy", "", "Toy."), file.path(pkg, "README.md"))
  suppressMessages(use_albersdown(pkg, family = "teal", preset = "interaction", readme = TRUE))
  readme <- paste(readLines(file.path(pkg, "README.md")), collapse = "\n")
  expect_match(readme, "`albersdown::albers_vignette()` output format (family = 'teal', preset = 'interaction'", fixed = TRUE)
  expect_match(readme, "`template: package: albersdown`", fixed = TRUE)
  expect_false(grepl("params$family|extra.css|albers.css", readme))

  # without readme = TRUE, a user's README is left alone
  pkg2 <- toy_pkg()
  writeLines(c("# toy"), file.path(pkg2, "README.md"))
  suppressMessages(use_albersdown(pkg2, family = "teal"))
  expect_identical(readLines(file.path(pkg2, "README.md")), "# toy")
})

test_that("CRLF line endings and a byte-order mark are kept", {
  pkg <- toy_pkg()
  path <- file.path(pkg, "vignettes", "l.Rmd")
  crlf <- function(lines, bom = FALSE) {
    con <- file(path, "wb")
    if (bom) writeBin(as.raw(c(0xef, 0xbb, 0xbf)), con)
    writeLines(lines, con, sep = "\r\n")
    close(con)
  }
  crlf(html_vig("L"), bom = TRUE)
  desc <- file.path(pkg, "DESCRIPTION")
  d <- readLines(desc)
  con <- file(desc, "wb"); writeLines(d, con, sep = "\r\n"); close(con)

  suppressMessages(use_albersdown(pkg, family = "teal"))
  bytes <- readBin(path, "raw", file.size(path))
  expect_identical(bytes[1:3], as.raw(c(0xef, 0xbb, 0xbf)))
  text <- rawToChar(bytes[-(1:3)])
  expect_false(grepl("[^\r]\n", text))
  expect_match(text, "  albersdown::albers_vignette:\r\n    family: teal\r\n", fixed = TRUE)
  dtext <- rawToChar(readBin(desc, "raw", file.size(desc)))
  expect_false(grepl("[^\r]\n", dtext))
  expect_match(dtext, "albersdown (>= ", fixed = TRUE)
})

test_that("the dry run lists ignore-file edits and changes nothing", {
  pkg <- legacy_20_pkg()
  files <- list.files(pkg, recursive = TRUE, all.files = TRUE)
  sums <- tools::md5sum(file.path(pkg, files))
  msg <- paste(testthat::capture_messages(use_albersdown(pkg, family = "teal", dry_run = TRUE)), collapse = "")
  expect_match(msg, "Would add ^_pkgdown\\.yml$ to .Rbuildignore", fixed = TRUE)
  expect_match(msg, "Would add ^\\.albersdown\\.bak$ to .Rbuildignore", fixed = TRUE)
  expect_match(msg, "Would add .albersdown.bak/ to .gitignore", fixed = TRUE)
  expect_match(msg, "Would update DESCRIPTION: ", fixed = TRUE)
  expect_match(msg, "Would move vignettes/albers.css", fixed = TRUE)
  expect_match(msg, "Would remove pkgdown/extra.css", fixed = TRUE)
  expect_match(msg, "and remove albersdown 2.0's setup lines", fixed = TRUE)
  expect_identical(list.files(pkg, recursive = TRUE, all.files = TRUE), files)
  expect_identical(tools::md5sum(file.path(pkg, files)), sums)
})

test_that("Quarto vignettes and articles are reported with the reason", {
  pkg <- toy_pkg()
  dir.create(file.path(pkg, "vignettes", "articles"))
  writeLines(html_vig("K"), file.path(pkg, "vignettes", "articles", "kappa.Rmd"))
  writeLines(c("---", "title: Q", "---"), file.path(pkg, "vignettes", "q.qmd"))
  msg <- paste(testthat::capture_messages(use_albersdown(pkg, family = "teal")), collapse = "")
  expect_match(msg, "Not converted: q.qmd (Quarto", fixed = TRUE)
  expect_match(msg, "Not converted: kappa.Rmd in vignettes/articles/ (pkgdown-only articles take the site default", fixed = TRUE)
  expect_match(msg, "`output: albersdown::albers_vignette`", fixed = TRUE)
  expect_identical(readLines(file.path(pkg, "vignettes", "articles", "kappa.Rmd")), html_vig("K"))
})

test_that("a site-only adoption leaves every field R CMD check reads alone", {
  check_fields <- function(pkg) {
    d <- read.dcf(file.path(pkg, "DESCRIPTION"))
    d[, setdiff(colnames(d), "Config/Needs/website"), drop = FALSE]
  }
  # no vignettes at all
  pkg <- toy_pkg()
  unlink(file.path(pkg, "vignettes"), recursive = TRUE)
  before <- check_fields(pkg)
  msg <- paste(testthat::capture_messages(use_albersdown(pkg, family = "green")), collapse = "")
  expect_identical(check_fields(pkg), before)
  expect_identical(unname(read.dcf(file.path(pkg, "DESCRIPTION"))[, "Config/Needs/website"]), "bbuchsbaum/albersdown")
  expect_match(msg, "No vignettes on albersdown::albers_vignette(): DESCRIPTION gets only Config/Needs/website", fixed = TRUE)
  expect_true("^_pkgdown\\.yml$" %in% readLines(file.path(pkg, ".Rbuildignore")))

  # vignettes that all stay on other formats
  pkg2 <- toy_pkg(c("Suggests: bookdown"))
  writeLines(c("---", "title: B", "output: bookdown::html_vignette2", "---"), file.path(pkg2, "vignettes", "b.Rmd"))
  before <- check_fields(pkg2)
  suppressMessages(use_albersdown(pkg2, family = "green"))
  expect_identical(check_fields(pkg2), before)

  # apply_to = "new" converts nothing, so it adds no vignette dependencies either
  pkg3 <- toy_pkg()
  writeLines(html_vig(), file.path(pkg3, "vignettes", "a.Rmd"))
  before <- check_fields(pkg3)
  suppressMessages(use_albersdown(pkg3, family = "green", apply_to = "new"))
  expect_identical(check_fields(pkg3), before)
  expect_identical(readLines(file.path(pkg3, "vignettes", "a.Rmd")), html_vig())

  # ... unless a vignette is already on the format
  writeLines(c("---", "title: F", "output: albersdown::albers_vignette", "---"), file.path(pkg3, "vignettes", "f.Rmd"))
  suppressMessages(use_albersdown(pkg3, family = "green", apply_to = "new"))
  d <- read.dcf(file.path(pkg3, "DESCRIPTION"))
  expect_match(d[, "Suggests"], "albersdown (>= ", fixed = TRUE)
  expect_identical(unname(d[, "VignetteBuilder"]), "knitr")
})

test_that("albersdown in Imports gets the bound there, not a second listing", {
  pkg <- toy_pkg(c("Imports:", "    albersdown (>= 2.0.0)", "Suggests:", "    knitr"))
  withr::local_dir(pkg)
  suppressMessages(.ensure_vignette_deps(version = "2.0.0.9000"))
  d <- read.dcf("DESCRIPTION")
  expect_identical(unname(trimws(d[, "Imports"])), "albersdown (>= 2.0.0.9000)")
  expect_false(grepl("albersdown", d[, "Suggests"]))
  expect_match(d[, "Suggests"], "rmarkdown", fixed = TRUE)
  expect_identical(unname(trimws(d[, "Remotes"])), "bbuchsbaum/albersdown")

  pkg2 <- toy_pkg(c("Depends: R (>= 4.1), albersdown"))
  withr::local_dir(pkg2)
  suppressMessages(.ensure_vignette_deps(version = "2.0.0.9000"))
  d <- read.dcf("DESCRIPTION")
  expect_identical(unname(d[, "Depends"]), "R (>= 4.1), albersdown (>= 2.0.0.9000)")
  expect_identical(unname(trimws(d[, "Suggests"])), "knitr,\nrmarkdown")
})

test_that("a pinned or qualified website reference is not duplicated", {
  for (ref in c("bbuchsbaum/albersdown@main", "github::bbuchsbaum/albersdown", "bbuchsbaum/albersdown#12")) {
    pkg <- toy_pkg(sprintf("Config/Needs/website: %s", ref))
    withr::local_dir(pkg)
    suppressMessages(.ensure_vignette_deps(version = "2.1.0", vignettes = FALSE))
    expect_identical(unname(read.dcf("DESCRIPTION")[, "Config/Needs/website"]), ref)
  }
  expect_identical(.albers_ref_name(c("github::a/b@v1 (>= 1)", "albersdown (>= 2)", "a/b#3")), c("a/b", "albersdown", "a/b"))
})

test_that("the README note goes in README.Rmd when that is the source", {
  pkg <- toy_pkg()
  writeLines(html_vig(), file.path(pkg, "vignettes", "a.Rmd"))
  rmd <- c("---", "output: github_document", "---", "", "# toy")
  writeLines(rmd, file.path(pkg, "README.Rmd"))
  writeLines("# toy", file.path(pkg, "README.md"))
  msg <- paste(testthat::capture_messages(use_albersdown(pkg, family = "teal", readme = TRUE)), collapse = "")
  expect_match(msg, "README.Rmd; re-knit it", fixed = TRUE)
  r <- readLines(file.path(pkg, "README.Rmd"))
  expect_identical(r[1:5], rmd)
  expect_true("<!-- albersdown:theme-note:start -->" %in% r)
  expect_identical(readLines(file.path(pkg, "README.md")), "# toy")
})

test_that("a flow-style output map is reported as such, and braces in messages are safe", {
  pkg <- toy_pkg()
  flow <- c("---", "title: F", "output: {rmarkdown::html_vignette: {toc: true}}", "---")
  other <- c("---", "title: O", "output: {bookdown::html_vignette2: default}", "---")
  writeLines(flow, file.path(pkg, "vignettes", "flow.Rmd"))
  writeLines(other, file.path(pkg, "vignettes", "{odd}.Rmd"))
  msg <- paste(testthat::capture_messages(use_albersdown(pkg, family = "teal")), collapse = "")
  expect_match(msg, "flow.Rmd has a flow-style `output: {...}` map; not converted", fixed = TRUE)
  expect_match(msg, "{odd}.Rmd uses an output format other than html_vignette", fixed = TRUE)
  expect_identical(readLines(file.path(pkg, "vignettes", "flow.Rmd")), flow)
  expect_identical(.albers_output_to_format(c("output: {html_vignette: default}"), "red", "homage"), "flow")
  expect_null(.albers_output_to_format(c("output: {pdf_document: default}"), "red", "homage"))
})

test_that("a user's own family/preset params survive without albersdown 2.0's fingerprint", {
  pkg <- toy_pkg()
  fam <- c("---", "title: FamParam", "output: rmarkdown::html_vignette", "params:", "  family: red", "  preset: homage", "  n: 3",
           "---", "", "```{r}", "params$n", "```")
  writeLines(fam, file.path(pkg, "vignettes", "fam.Rmd"))
  msg <- paste(testthat::capture_messages(use_albersdown(pkg, family = "teal")), collapse = "")
  f <- readLines(file.path(pkg, "vignettes", "fam.Rmd"))
  expect_true(all(c("params:", "  family: red", "  preset: homage", "  n: 3") %in% f))
  expect_false(grepl("2.0's setup", msg, fixed = TRUE))
  expect_false(.albers_legacy_fingerprint(fam[2:7], fam[9:12]))
  expect_true(.albers_legacy_fingerprint("    css: albers.css", character()))
})

test_that("removing 2.0's class chunk leaves no double blank line", {
  body <- c("```{r setup}", "library(x)", "```", "", "```{r albers-classes, echo=FALSE}", "cat(1)", "```", "", "## Next")
  expect_identical(.albers_drop_legacy_setup(body), c("```{r setup}", "library(x)", "```", "", "## Next"))
})

test_that("an if block left empty by removing 2.0's theme_set() line goes too", {
  theme <- "ggplot2::theme_set(albersdown::theme_albers(family = params$family, preset = params$preset))"
  guard <- 'if (requireNamespace("ggplot2", quietly = TRUE) && requireNamespace("albersdown", quietly = TRUE))'
  body <- c(
    "```{r setup, include = FALSE}",
    "oldopt <- options(digits = 3)",
    'if (requireNamespace("systemfonts", quietly = TRUE)) albersdown::albers_register_fonts()',
    # the forms in albersdown's own 2.0 vignettes (9854bc1, aab27a1)
    paste0(guard, " {"), paste0("  ", theme), "}",
    'if (requireNamespace("albersdown", quietly = TRUE)) {', paste0("  ", guard, " ", theme), "}",
    "if (TRUE) {", "  if (TRUE) {", paste0("    ", theme), "  }", "}",
    # a block with the user's own code stays, minus the 2.0 line
    "if (interactive()) {", paste0("  ", theme), "  message('hi')", "}",
    "```"
  )
  out <- .albers_drop_legacy_setup(body)
  expect_identical(out, c(
    "```{r setup, include = FALSE}",
    "oldopt <- options(digits = 3)",
    "if (interactive()) {", "  message('hi')", "}",
    "```"
  ))
  # a user's own empty block (no 2.0 line in it) is left alone
  own <- c("```{r}", "if (FALSE) {", "}", "```")
  expect_identical(.albers_drop_legacy_setup(own), own)
})

test_that("the README note on the site-only route describes only the site", {
  pkg <- toy_pkg()
  writeLines(html_vig(), file.path(pkg, "vignettes", "a.Rmd"))
  writeLines("# toy", file.path(pkg, "README.md"))
  suppressMessages(use_albersdown(pkg, family = "teal", preset = "interaction", apply_to = "new", readme = TRUE))
  readme <- paste(readLines(file.path(pkg, "README.md")), collapse = "\n")
  expect_match(readme, "This package's pkgdown site uses the albersdown theme (`template: package: albersdown`, site default family = 'teal', preset = 'interaction'). Its vignettes keep their own output format.", fixed = TRUE)
  expect_false(grepl("albers_vignette", readme, fixed = TRUE))
})

test_that("albersdown 2.0's README note stays while its vignettes are not on the format", {
  pkg <- legacy_20_pkg()
  note <- readLines(file.path(pkg, "README.md"))
  msg <- paste(testthat::capture_messages(use_albersdown(pkg, family = "teal", apply_to = "new")), collapse = "")
  expect_identical(readLines(file.path(pkg, "README.md")), note)
  expect_match(msg, "README note from albersdown 2.0 left as is", fixed = TRUE)
  # converting the vignettes then replaces it
  suppressMessages(use_albersdown(pkg, family = "teal"))
  expect_match(paste(readLines(file.path(pkg, "README.md")), collapse = "\n"), "albersdown::albers_vignette()", fixed = TRUE)
})

test_that("albersdown's own vignettes carry no albersdown 2.0 leftovers", {
  vig <- test_path("..", "..", "vignettes")
  skip_if_not(dir.exists(vig))
  for (f in list.files(vig, pattern = "\\.Rmd$", full.names = TRUE)) {
    x <- readLines(f, warn = FALSE)
    fence <- .albers_fences(x)
    head <- x[fence[1]:fence[2]]
    expect_true(any(grepl("albersdown::albers_vignette", head, fixed = TRUE)), info = f)
    expect_false(any(grepl("^params\\s*:", head)), info = f)
    expect_false(any(grepl("params\\$(family|preset|content_width|base_size|style)", x)), info = f)
    expect_false(any(grepl("--content\\s*:", x)), info = f)
    expect_false(any(grepl("style: balanced", x, fixed = TRUE)), info = f)
  }
})

test_that("family and preset are validated by name and case-insensitively", {
  expect_identical(.albers_choice("Teal", .albers_families, "family", "f"), "teal")
  expect_identical(.albers_choice(" LAPIS ", .albers_families, "family", "f"), "lapis")
  expect_identical(.albers_choice("inter", .albers_all_presets, "preset", "f"), "interaction")
  expect_identical(.albers_choice(.albers_all_presets, .albers_all_presets, "preset", "f"), "homage")
  expect_error(.albers_choice(c("red", "teal"), .albers_families, "family", "f"), "got c(\"red\", \"teal\")", fixed = TRUE)
  expect_error(.albers_choice(NA_character_, .albers_families, "family", "f"), "`family` must be one of", fixed = TRUE)

  fmt <- albers_vignette(family = "Teal", preset = "INTERACTION")
  expect_s3_class(fmt, "rmarkdown_output_format")
  expect_error(albers_vignette(style = "loud"), "albers_vignette(): `style` must be one of \"minimal\", \"balanced\", \"assertive\"; got 'loud'.", fixed = TRUE)

  pkg <- toy_pkg()
  writeLines(html_vig(), file.path(pkg, "vignettes", "a.Rmd"))
  suppressMessages(use_albersdown(pkg, family = "Teal", preset = "Interaction"))
  a <- readLines(file.path(pkg, "vignettes", "a.Rmd"))
  expect_true(all(c("    family: teal", "    preset: interaction") %in% a))
  expect_error(use_albersdown(pkg, preset = "baroque"), "use_albersdown(): `preset` must be one of", fixed = TRUE)
})

test_that("without family/preset, a 2.0 package keeps its own (from its params)", {
  pkg <- legacy_20_pkg()  # vignettes: params family lapis, preset homage
  msg <- paste(testthat::capture_messages(use_albersdown(pkg)), collapse = "")
  expect_match(msg, "Kept the package's family: lapis (from vignettes (plots.Rmd, uses.Rmd)); pass `family` to change it", fixed = TRUE)
  expect_match(msg, "Kept the package's preset: homage", fixed = TRUE)
  p <- readLines(file.path(pkg, "vignettes", "plots.Rmd"))
  expect_true(all(c("    family: lapis", "    preset: homage") %in% p))
  expect_true(any(grepl('family: "lapis", preset: "homage"', readLines(file.path(pkg, "pkgdown", "extra.js")), fixed = TRUE)))

  # a re-run without arguments keeps it (the vignettes are now on the format)
  suppressMessages(use_albersdown(pkg))
  expect_identical(readLines(file.path(pkg, "vignettes", "plots.Rmd")), p)

  # site-only route on a 2.0 package: the site default follows 2.0's family too
  pkg2 <- legacy_20_pkg()
  suppressMessages(use_albersdown(pkg2, apply_to = "new"))
  expect_true(any(grepl('family: "lapis", preset: "homage"', readLines(file.path(pkg2, "pkgdown", "extra.js")), fixed = TRUE)))
})

test_that("without family/preset, site defaults are used when vignettes say nothing", {
  pkg <- toy_pkg()
  writeLines(html_vig(), file.path(pkg, "vignettes", "a.Rmd"))
  dir.create(file.path(pkg, "pkgdown"))
  writeLines('window.albersdownDefaults = { family: "teal", preset: "interaction", style: "minimal" };',
             file.path(pkg, "pkgdown", "extra.js"))
  msg <- paste(testthat::capture_messages(use_albersdown(pkg)), collapse = "")
  expect_match(msg, "Kept the package's family: teal (from pkgdown/extra.js)", fixed = TRUE)
  a <- readLines(file.path(pkg, "vignettes", "a.Rmd"))
  expect_true(all(c("    family: teal", "    preset: interaction") %in% a))

  # the 2.0 extra.js (class adds) and a _pkgdown.yml defaults script are read too
  pkg2 <- toy_pkg()
  writeLines(c("template:", "  includes:", "    in_header: |",
               '      <script>window.albersdownDefaults = { family: "violet", preset: "interaction" };</script>'),
             file.path(pkg2, "_pkgdown.yml"))
  withr::with_dir(pkg2, {
    got <- .albers_infer_choice()
    expect_identical(got$family$value, "violet")
    expect_identical(got$family$from, "_pkgdown.yml")
  })
  pkg3 <- toy_pkg()
  dir.create(file.path(pkg3, "pkgdown"))
  writeLines(c("(function () {", '    if (!hasAny("palette-", FAMILY_CLASSES)) document.body.classList.add("palette-ochre");',
               '    if (!hasAny("preset-", PRESET_CLASSES)) document.body.classList.add("preset-interaction");', "})();"),
             file.path(pkg3, "pkgdown", "extra.js"))
  withr::with_dir(pkg3, {
    got <- .albers_infer_choice()
    expect_identical(c(got$family$value, got$preset$value), c("ochre", "interaction"))
  })

  # nothing found: red/homage, silently
  pkg4 <- toy_pkg()
  writeLines(html_vig(), file.path(pkg4, "vignettes", "a.Rmd"))
  msg <- paste(testthat::capture_messages(use_albersdown(pkg4)), collapse = "")
  expect_false(grepl("Kept the package's", msg, fixed = TRUE))
  expect_true("    family: red" %in% readLines(file.path(pkg4, "vignettes", "a.Rmd")))
})

test_that("disagreeing vignettes give the most common choice, with a warning; explicit arguments win", {
  pkg <- toy_pkg()
  fmt <- function(t, fam) c("---", paste0("title: ", t), "output:", "  albersdown::albers_vignette:",
                            paste0("    family: ", fam), "---")
  writeLines(fmt("A", "lapis"), file.path(pkg, "vignettes", "a.Rmd"))
  writeLines(fmt("B", "lapis"), file.path(pkg, "vignettes", "b.Rmd"))
  writeLines(fmt("C", "teal"), file.path(pkg, "vignettes", "c.Rmd"))
  msg <- paste(testthat::capture_messages(use_albersdown(pkg, dry_run = TRUE)), collapse = "")
  expect_match(msg, "Kept the package's family: lapis (from vignettes (a.Rmd, b.Rmd, c.Rmd); vignettes disagree (lapis: 2, teal: 1); using the most common)", fixed = TRUE)

  # explicit family wins; preset is still inferred (all default homage here)
  suppressMessages(use_albersdown(pkg, family = "green"))
  for (f in c("a", "b", "c")) expect_true("    family: green" %in% readLines(file.path(pkg, "vignettes", paste0(f, ".Rmd"))))
  pkg2 <- legacy_20_pkg()
  msg <- paste(testthat::capture_messages(use_albersdown(pkg2, family = "teal", preset = "interaction")), collapse = "")
  expect_false(grepl("Kept the package's", msg, fixed = TRUE))
  expect_true("    family: teal" %in% readLines(file.path(pkg2, "vignettes", "plots.Rmd")))
})

test_that("a site-only re-run without family keeps the site default (bare vignettes are not evidence)", {
  # e10_bare_site: a vignette on the format with no family:, site set to lapis
  pkg <- toy_pkg()
  writeLines(c("---", "title: A", "output: albersdown::albers_vignette",
               "vignette: >", "  %\\VignetteIndexEntry{A}", "  %\\VignetteEngine{knitr::rmarkdown}", "---", "", "Text."),
             file.path(pkg, "vignettes", "a.Rmd"))
  suppressMessages(use_albersdown(pkg, family = "lapis", apply_to = "new"))
  js <- file.path(pkg, "pkgdown", "extra.js")
  expect_true(any(grepl('family: "lapis"', readLines(js), fixed = TRUE)))
  files <- list.files(pkg, recursive = TRUE, all.files = TRUE)
  sums <- tools::md5sum(file.path(pkg, files))

  msg <- paste(testthat::capture_messages(use_albersdown(pkg, apply_to = "new")), collapse = "")
  expect_match(msg, "Kept the package's family: lapis (from pkgdown/extra.js)", fixed = TRUE)
  expect_identical(list.files(pkg, recursive = TRUE, all.files = TRUE), files)
  expect_identical(tools::md5sum(file.path(pkg, files)), sums)
  # the full route too: the bare vignette states no family, so the site's lapis is kept
  suppressMessages(use_albersdown(pkg))
  expect_true("    family: lapis" %in% readLines(file.path(pkg, "vignettes", "a.Rmd")))
  withr::with_dir(pkg, expect_identical(.albers_vignette_choice("vignettes/a.Rmd")$family, "lapis"))
})

test_that("site and vignettes disagreeing: apply_to = 'new' keeps the site, the full route the vignettes", {
  pkg <- toy_pkg()
  writeLines(c("---", "title: A", "output:", "  albersdown::albers_vignette:", "    family: ochre", "---"),
             file.path(pkg, "vignettes", "a.Rmd"))
  dir.create(file.path(pkg, "pkgdown"))
  writeLines('window.albersdownDefaults = { family: "lapis", preset: "homage", style: "minimal" };',
             file.path(pkg, "pkgdown", "extra.js"))
  msg <- paste(testthat::capture_messages(use_albersdown(pkg, apply_to = "new", dry_run = TRUE)), collapse = "")
  expect_match(msg, "Kept the package's family: lapis (from pkgdown/extra.js; vignettes (a.Rmd) says ochre)", fixed = TRUE)
  msg <- paste(testthat::capture_messages(use_albersdown(pkg, dry_run = TRUE)), collapse = "")
  expect_match(msg, "Kept the package's family: ochre (from vignettes (a.Rmd); pkgdown/extra.js says lapis)", fixed = TRUE)
})
