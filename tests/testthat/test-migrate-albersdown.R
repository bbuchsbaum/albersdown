test_that("migrate_albersdown updates vignette params and theme call", {
  skip_if_not_installed("yaml")

  pkg <- file.path(tempdir(), paste0("albersdown-migrate-", Sys.getpid()))
  dir.create(pkg, recursive = TRUE, showWarnings = FALSE)

  writeLines(c(
    "Package: demo",
    "Version: 0.0.0.9000",
    "Title: Demo",
    "Authors@R: person(\"Demo\", \"User\", email = \"demo@example.com\", role = c(\"aut\", \"cre\"))",
    "Description: Demo package.",
    "License: MIT"
  ), file.path(pkg, "DESCRIPTION"))

  writeLines("# Demo", file.path(pkg, "README.md"))
  dir.create(file.path(pkg, "vignettes"), showWarnings = FALSE)
  writeLines(c(
    "---",
    "title: \"Demo\"",
    "output: rmarkdown::html_vignette",
    "params:",
    "  family: red",
    "vignette: >",
    "  %\\VignetteIndexEntry{Demo}",
    "  %\\VignetteEngine{knitr::rmarkdown}",
    "  %\\VignetteEncoding{UTF-8}",
    "---",
    "",
    "```{r setup, include=FALSE}",
    "library(ggplot2)",
    "if (requireNamespace(\"albersdown\", quietly = TRUE)) {",
    "  ggplot2::theme_set(albersdown::theme_albers(",
    "    family = params$family,",
    "    base_size = 13",
    "  ))",
    "}",
    "```",
    "",
    "Demo text."
  ), file.path(pkg, "vignettes", "demo.Rmd"))

  migrate_albersdown(path = pkg, family = "teal", preset = "midnight", dry_run = FALSE)

  migrated <- readLines(file.path(pkg, "vignettes", "demo.Rmd"), warn = FALSE)
  expect_true(any(grepl("^\\s+preset:\\s+midnight\\s*$", migrated)))
  expect_true(any(grepl("^\\s+family:\\s+teal\\s*$", migrated)))
  expect_true(any(grepl("^\\s+css:\\s+albers\\.css\\s*$", migrated)))
  expect_true(any(grepl("^\\s+in_header:\\s+albers-header\\.html\\s*$", migrated)))
  expect_true(any(grepl("^-\\s+albers-header\\.html\\s*$", migrated)))
  expect_true(any(grepl(
    "theme_set\\(albersdown::theme_albers\\(family = params\\$family, preset = params\\$preset\\)\\)",
    migrated,
    perl = TRUE
  )))
  expect_equal(sum(grepl("^```\\{r albers-classes, echo=FALSE, results='asis'\\}\\s*$", migrated)), 1)
  expect_false(any(grepl("^\\s*base_size\\s*=\\s*13\\s*$", migrated)))
})

test_that("use_albersdown writes renderable html_vignette hooks for non-red families", {
  skip_if_not_installed("yaml")
  skip_if_not_installed("rmarkdown")

  pkg <- file.path(tempdir(), paste0("albersdown-render-", Sys.getpid()))
  dir.create(pkg, recursive = TRUE, showWarnings = FALSE)

  writeLines(c(
    "Package: demo",
    "Version: 0.0.0.9000",
    "Title: Demo",
    "Authors@R: person(\"Demo\", \"User\", email = \"demo@example.com\", role = c(\"aut\", \"cre\"))",
    "Description: Demo package.",
    "License: MIT"
  ), file.path(pkg, "DESCRIPTION"))

  writeLines("# Demo", file.path(pkg, "README.md"))
  dir.create(file.path(pkg, "vignettes"), showWarnings = FALSE)
  writeLines(c(
    "---",
    "title: \"Demo\"",
    "output: rmarkdown::html_vignette",
    "vignette: >",
    "  %\\VignetteIndexEntry{Demo}",
    "  %\\VignetteEngine{knitr::rmarkdown}",
    "  %\\VignetteEncoding{UTF-8}",
    "---",
    "",
    "```{r setup, include=FALSE}",
    "library(ggplot2)",
    "```",
    "",
    "Demo text."
  ), file.path(pkg, "vignettes", "demo.Rmd"))

  use_albersdown(path = pkg, family = "teal", preset = "midnight", apply_to = "all", dry_run = FALSE)

  migrated <- readLines(file.path(pkg, "vignettes", "demo.Rmd"), warn = FALSE)
  expect_true(any(grepl("^vignette:\\s+\\|\\s*$", migrated)))
  expect_false(any(grepl("^vignette:\\s*'", migrated)))

  expect_true(file.exists(file.path(pkg, "pkgdown", "extra.css")))
  expect_true(file.exists(file.path(pkg, "pkgdown", "extra.js")))
  expect_true(any(grepl("@import url\\(\"albers\\.css\"\\);", readLines(file.path(pkg, "pkgdown", "extra.css"), warn = FALSE))))
  extra_js <- readLines(file.path(pkg, "pkgdown", "extra.js"), warn = FALSE)
  expect_true(any(grepl("palette-teal", extra_js, fixed = TRUE)))
  expect_true(any(grepl("preset-midnight", extra_js, fixed = TRUE)))

  old <- setwd(pkg)
  on.exit(setwd(old), add = TRUE)
  old_opt <- options(rmarkdown.html_vignette.check_title = FALSE)
  on.exit(options(old_opt), add = TRUE)
  rmarkdown::render(file.path("vignettes", "demo.Rmd"), output_file = file.path(pkg, "demo.html"), quiet = TRUE)

  html <- readLines(file.path(pkg, "demo.html"), warn = FALSE)
  expect_true(any(grepl("FAMILY_CLASSES|navigator\\.clipboard|data-bs-theme", html)))
  expect_true(any(grepl("palette-teal", html)))
  expect_true(any(grepl("preset-midnight", html)))
  expect_true(any(grepl("albers\\.css|0D4A4A|0d4a4a", html)))
})

test_that("migrate_albersdown is idempotent for README note and class hook", {
  skip_if_not_installed("yaml")

  pkg <- file.path(tempdir(), paste0("albersdown-idempotent-", Sys.getpid()))
  dir.create(pkg, recursive = TRUE, showWarnings = FALSE)

  writeLines(c(
    "Package: demo",
    "Version: 0.0.0.9000",
    "Title: Demo",
    "Authors@R: person(\"Demo\", \"User\", email = \"demo@example.com\", role = c(\"aut\", \"cre\"))",
    "Description: Demo package.",
    "License: MIT"
  ), file.path(pkg, "DESCRIPTION"))

  writeLines("# Demo", file.path(pkg, "README.md"))
  dir.create(file.path(pkg, "vignettes"), showWarnings = FALSE)
  writeLines(c(
    "---",
    "title: \"Demo\"",
    "output: rmarkdown::html_vignette",
    "vignette: >",
    "  %\\VignetteIndexEntry{Demo}",
    "  %\\VignetteEngine{knitr::rmarkdown}",
    "  %\\VignetteEncoding{UTF-8}",
    "---",
    "",
    "```{r setup, include=FALSE}",
    "library(ggplot2)",
    "```",
    "",
    "Demo text."
  ), file.path(pkg, "vignettes", "demo.Rmd"))

  migrate_albersdown(path = pkg, family = "teal", preset = "midnight", dry_run = FALSE)
  migrate_albersdown(path = pkg, family = "teal", preset = "midnight", dry_run = FALSE)

  readme <- readLines(file.path(pkg, "README.md"), warn = FALSE)
  migrated <- readLines(file.path(pkg, "vignettes", "demo.Rmd"), warn = FALSE)

  expect_equal(sum(grepl("^<!-- albersdown:theme-note:start -->$", readme)), 1)
  expect_equal(sum(grepl("^<!-- albersdown:theme-note:end -->$", readme)), 1)
  expect_equal(sum(grepl("^```\\{r albers-classes, echo=FALSE, results='asis'\\}\\s*$", migrated)), 1)
})

test_that("migrate_albersdown carries family defaults into the built pkgdown site", {
  skip_if_not_installed("yaml")
  skip_if_not_installed("rmarkdown")
  skip_if_not_installed("pkgdown")

  pkg <- file.path(tempdir(), paste0("albersdown-site-", Sys.getpid()))
  dir.create(pkg, recursive = TRUE, showWarnings = FALSE)

  writeLines(c(
    "Package: demo",
    "Version: 0.0.0.9000",
    "Title: Demo",
    "Authors@R: person(\"Demo\", \"User\", email = \"demo@example.com\", role = c(\"aut\", \"cre\"))",
    "Description: Demo package.",
    "License: MIT"
  ), file.path(pkg, "DESCRIPTION"))

  writeLines("# Demo", file.path(pkg, "README.md"))
  dir.create(file.path(pkg, "vignettes"), showWarnings = FALSE)
  writeLines(c(
    "---",
    "title: \"Demo\"",
    "output: rmarkdown::html_vignette",
    "vignette: >",
    "  %\\VignetteIndexEntry{Demo}",
    "  %\\VignetteEngine{knitr::rmarkdown}",
    "  %\\VignetteEncoding{UTF-8}",
    "---",
    "",
    "```{r setup, include=FALSE}",
    "library(ggplot2)",
    "```",
    "",
    "Demo text."
  ), file.path(pkg, "vignettes", "demo.Rmd"))

  migrate_albersdown(path = pkg, family = "ochre", preset = "homage", dry_run = FALSE)

  old <- setwd(pkg)
  on.exit(setwd(old), add = TRUE)
  old_opt <- options(rmarkdown.html_vignette.check_title = FALSE)
  on.exit(options(old_opt), add = TRUE)

  pkgdown::build_site(new_process = FALSE, install = TRUE, preview = FALSE)

  site_dir <- if (dir.exists(file.path(pkg, "docs"))) "docs" else "site"
  extra_js <- readLines(file.path(site_dir, "extra.js"), warn = FALSE)
  article_html <- readLines(file.path(site_dir, "articles", "demo.html"), warn = FALSE)

  expect_true(any(grepl("palette-ochre", extra_js, fixed = TRUE)))
  expect_true(any(grepl("preset-homage", extra_js, fixed = TRUE)))
  expect_true(any(grepl("extra\\.js", article_html)))
  expect_true(any(grepl("palette-ochre", article_html, fixed = TRUE)))
})
