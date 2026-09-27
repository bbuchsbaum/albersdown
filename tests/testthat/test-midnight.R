test_that("midnight grounds are tinted per family", {
  fams <- c("red", "lapis", "ochre", "teal", "green", "violet")
  grounds <- vapply(fams, function(f) albersdown:::.preset_colors("midnight", f)$bg, "")
  expect_equal(length(unique(grounds)), length(fams))
  expect_equal(unname(grounds[["red"]]), "#1e0d0e")
  expect_equal(unname(grounds[["lapis"]]), "#0c1223")
  # every midnight ground is dark and carries readable ink
  for (f in fams) {
    cols <- albersdown:::.preset_colors("midnight", f)
    expect_true(albersdown:::.contrast_ratio(cols$fg, cols$bg) >= 7, info = f)
    expect_true(albersdown:::.contrast_ratio(cols$fg, cols$surface) >= 7, info = f)
  }
})

test_that("midnight without a known family falls back to red's grounds", {
  red <- albersdown:::.preset_colors("midnight", "red")
  expect_identical(albersdown:::.preset_colors("midnight"), red)
  expect_identical(albersdown:::.preset_colors("midnight", "not-a-family"), red)
  expect_identical(albersdown:::.preset_colors_night("midnight", "teal"),
                   albersdown:::.preset_colors("midnight", "teal"))
})

test_that("other presets ignore the family", {
  for (p in c("homage", "interaction", "study", "structural", "adobe")) {
    expect_identical(albersdown:::.preset_colors(p, "teal"), albersdown:::.preset_colors(p), info = p)
  }
})

test_that("theme_albers() puts midnight plots on the family's ground", {
  skip_if_not_installed("ggplot2")
  for (f in c("red", "teal")) {
    th <- theme_albers(family = f, preset = "midnight")
    expect_equal(th$plot.background$fill,
                 albersdown:::.preset_colors("midnight", f)$surface, info = f)
  }
})

test_that("the doctor's contrast report checks each family's midnight ground", {
  r <- albersdown:::.doctor_contrast_report()
  skip_if(is.na(r$ok))
  expect_true(r$ok)
  expect_true(all(paste0("body-midnight-", c("red", "teal")) %in% r$checked))
})
