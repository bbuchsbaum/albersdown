test_that("migrate_albersdown updates vignette params and theme call", {
  skip_if_not_installed("yaml")

  old <- getwd()
  pkg <- file.path(tempdir(), paste0("albersdown-migrate-", Sys.getpid()))
  dir.create(pkg, recursive = TRUE, showWarnings = FALSE)
  on.exit(setwd(old), add = TRUE)
  setwd(pkg)

  writeLines(c(
    "Package: demo",
    "Version: 0.0.0.9000",
    "Title: Demo",
    "Description: Demo package.",
    "License: MIT"
  ), "DESCRIPTION")

  writeLines("# Demo", "README.md")
  dir.create("vignettes", showWarnings = FALSE)
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
  ), file.path("vignettes", "demo.Rmd"))

  migrate_albersdown(family = "teal", preset = "midnight", dry_run = FALSE)

  migrated <- readLines(file.path("vignettes", "demo.Rmd"), warn = FALSE)
  expect_true(any(grepl("^\\s+preset:\\s+midnight\\s*$", migrated)))
  expect_true(any(grepl("^\\s+family:\\s+teal\\s*$", migrated)))
  expect_true(any(grepl(
    "theme_set\\(albersdown::theme_albers\\(family = params\\$family, preset = params\\$preset\\)\\)",
    migrated,
    perl = TRUE
  )))
  expect_false(any(grepl("^\\s*base_size\\s*=\\s*13\\s*$", migrated)))
})
