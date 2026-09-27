png_size <- function(path) {
  # width and height from the PNG header (IHDR)
  con <- file(path, "rb")
  on.exit(close(con))
  bytes <- readBin(con, "raw", 24L)
  c(width = readBin(bytes[17:20], "integer", size = 4L, endian = "big"),
    height = readBin(bytes[21:24], "integer", size = 4L, endian = "big"))
}

test_that("phone options add a second, narrower drawing of the same plot", {
  base <- list(fig.width = 6.6, fig.height = 4.1, dev = "ragg_png", dpi = 96,
               out.width = "100%", fig.show = "asis")
  o <- .albers_phone_options(base)
  expect_identical(o$fig.width, c(6.6, 3.6))
  # taller than the full figure scaled down, by the square root of the ratio
  expect_equal(o$fig.height, c(4.1, 4.1 * sqrt(3.6 / 6.6)))
  expect_identical(o$fig.ext, c("png", "phone.png"))
  expect_identical(o$dev, "ragg_png")                 # recycled by knitr, one device
  expect_identical(o$albers.phone, round(sqrt(6.6 * 3.6) * 96))

  # fig.asp would reset both heights after the hook: it is folded in here
  asp <- .albers_phone_options(utils::modifyList(base, list(fig.asp = 0.5)))
  expect_null(asp$fig.asp)
  expect_equal(asp$fig.height, c(3.3, 3.3 * sqrt(3.6 / 6.6)))
  # fig.dim wins over fig.asp, as in knitr
  dim <- .albers_phone_options(utils::modifyList(base, list(fig.dim = c(8, 8), fig.asp = 0.5)))
  expect_null(dim$fig.dim)
  expect_identical(dim$fig.width, c(8, 3.6))
  # a square figure's phone drawing stays square
  expect_equal(dim$fig.height, c(8, 3.6))

  # left alone: narrow figures, fixed-size or unset out.width, other
  # devices, several devices, animations and hidden plots
  for (change in list(list(fig.width = 4), list(out.width = "300px"), list(out.width = NULL),
                      list(dev = "svg"), list(dev = c("png", "pdf")), list(fig.ext = "jpg"),
                      list(fig.show = "animate"), list(fig.show = "hide"))) {
    o <- .albers_phone_options(utils::modifyList(base, change))
    expect_null(o$albers.phone)
    expect_length(o$fig.width, 1L)
  }
})

test_that("the phone drawing goes right after its figure's image", {
  dir <- withr::local_tempdir()
  withr::local_dir(dir)
  dir.create("fig")
  file.create("fig/p-1.phone.png")
  out <- '<div class="figure"><img src="fig/p-1.png" width="100%" /><p class="caption">C</p></div>'
  res <- .albers_add_phone_twin(out, "fig/p-1.png", list(albers.phone = 468))
  expect_match(res, '<img src="fig/p-1.png" width="100%" /><img class="albers-phone-twin" src="fig/p-1.phone.png"', fixed = TRUE)
  expect_match(res, 'data-albers-below="468" hidden />', fixed = TRUE)
  # no phone file, no option, or no matching <img>: unchanged
  expect_identical(.albers_add_phone_twin(out, "fig/p-2.png", list(albers.phone = 468)), out)
  expect_identical(.albers_add_phone_twin(out, "fig/p-1.png", list()), out)
  expect_identical(.albers_add_phone_twin("![](fig/p-1.png)", "fig/p-1.png", list(albers.phone = 468)), "![](fig/p-1.png)")
})

test_that("albers_vignette() draws phone twins of ggplot and base plots", {
  skip_on_cran()
  skip_if_not_installed("rmarkdown")
  skip_if_not_installed("ggplot2")
  skip_if_not(rmarkdown::pandoc_available("2.0"))

  dir <- withr::local_tempdir()
  rmd <- file.path(dir, "phone.Rmd")
  writeLines(c(
    "---", "title: Phone", "vignette: >", "  %\\VignetteIndexEntry{Phone}",
    "  %\\VignetteEngine{knitr::rmarkdown}", "---", "",
    "```{r gg, fig.cap = 'Cap.'}",
    "ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) + ggplot2::geom_point()",
    "```",
    "```{r base}",
    "plot(1:3)",
    "```",
    "```{r small, fig.width = 4, fig.height = 3}",
    "plot(1:3)",
    "```"
  ), rmd)
  hook_before <- knitr::knit_hooks$get("plot")

  # kept files: the drawings' sizes can be read
  out <- rmarkdown::render(rmd, output_format = albers_vignette(self_contained = FALSE),
                           quiet = TRUE, clean = FALSE)
  html <- paste(readLines(out, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
  figs <- file.path(dir, "phone_files", "figure-html")
  # ggplot: the light phone drawing inside the figure, after its image; the
  # dark phone drawing in the paragraph after the dark twin
  expect_match(html, '<img src="phone_files/figure-html/gg-1.png"[^>]*><img class="albers-phone-twin" src="phone_files/figure-html/gg-1.phone.png"', perl = TRUE)
  expect_match(html, '<img class="albers-phone-twin albers-phone-dark" src="phone_files/figure-html/gg-dark-1.phone.png"', fixed = TRUE)
  # base graphics get the light one (they have no dark twin)
  expect_match(html, 'src="phone_files/figure-html/base-1.phone.png"', fixed = TRUE)
  # a figure already narrow gets none
  expect_false(file.exists(file.path(figs, "small-1.phone.png")))
  expect_match(html, 'data-albers-below="468"', fixed = TRUE)

  # 3.6 in at 96 dpi x retina 2; the full figure is 6.6 in
  full <- png_size(file.path(figs, "gg-1.png"))
  phone <- png_size(file.path(figs, "gg-1.phone.png"))
  expect_equal(unname(full[["width"]]), round(6.6 * 192), tolerance = 1)
  expect_equal(unname(phone[["width"]]), round(3.6 * 192), tolerance = 1)
  expect_equal(unname(phone[["height"]]), round(4.1 * sqrt(3.6 / 6.6) * 192), tolerance = 1)
  expect_identical(png_size(file.path(figs, "gg-dark-1.phone.png")), phone)
  expect_identical(png_size(file.path(figs, "base-1.phone.png")), phone)

  # the plot hook is put back after the render
  expect_identical(knitr::knit_hooks$get("plot"), hook_before)

  off <- rmarkdown::render(rmd, output_format = albers_vignette(phone_figures = FALSE),
                           quiet = TRUE, output_file = "off.html")
  expect_false(grepl('<img class="albers-phone-twin', paste(readLines(off, warn = FALSE), collapse = "\n"), fixed = TRUE))
})

test_that("chunk code sees single figure sizes when phone figures are on", {
  skip_on_cran()
  skip_if_not_installed("rmarkdown")
  skip_if_not(rmarkdown::pandoc_available("2.0"))

  dir <- withr::local_tempdir()
  rmd <- file.path(dir, "sizes.Rmd")
  writeLines(c(
    "---", "title: Sizes", "vignette: >", "  %\\VignetteIndexEntry{Sizes}",
    "  %\\VignetteEngine{knitr::rmarkdown}", "---", "",
    # code that reads the figure size (as ggiraph::girafe() does) needs a scalar
    "```{r sized, results = 'asis'}",
    "w <- knitr::opts_current$get('fig.width')",
    "h <- knitr::opts_current$get('fig.height')",
    "if (w > 5) cat('<p id=\"sizes\">', length(w), length(h), w, '</p>')",
    "plot(1:3)",
    "```"
  ), rmd)
  out <- rmarkdown::render(rmd, output_format = albers_vignette(), quiet = TRUE)
  html <- paste(readLines(out, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
  expect_match(html, '<p id="sizes">\\s*1 1 6.6\\s*</p>', perl = TRUE)
  # ... while the phone drawing is still made
  expect_match(html, 'class="albers-phone-twin"', fixed = TRUE)
})

test_that("ggiraph::girafe() renders with phone figures on", {
  skip_on_cran()
  skip_if_not_installed("rmarkdown")
  skip_if_not_installed("ggplot2")
  skip_if_not_installed("ggiraph")
  skip_if_not(rmarkdown::pandoc_available("2.0"))

  dir <- withr::local_tempdir()
  rmd <- file.path(dir, "gi.Rmd")
  writeLines(c(
    "---", "title: Girafe", "vignette: >", "  %\\VignetteIndexEntry{Girafe}",
    "  %\\VignetteEngine{knitr::rmarkdown}", "---", "",
    "```{r gi}",
    "p <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) + ggiraph::geom_point_interactive(ggplot2::aes(tooltip = rownames(mtcars)))",
    "ggiraph::girafe(ggobj = p)",
    "```"
  ), rmd)
  expect_no_error(rmarkdown::render(rmd, output_format = albers_vignette(), quiet = TRUE))
})
