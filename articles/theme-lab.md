# Theme Lab: Tune Family, Preset, and Rhythm

## What Is This Page For?

Use this page to choose a visual direction before you retrofit or create
vignettes. You can tune one parameter at a time and immediately see the
effect on hierarchy, contrast, and page rhythm.

Start with **family** and **preset**, then tune **style**, then adjust
content width. That order gives the fastest path to a coherent page.

## How Do You Use It?

1.  Pick a family for color character.
2.  Pick a preset for ground/surface mood.
3.  Toggle style intensity to set structural emphasis.
4.  Adjust content width to match prose density.

Family red lapis ochre teal green violet

Preset study structural adobe midnight

Style minimal balanced assertive

Content width (ch)

A900 A700 A500 A300

family=red \| preset=study \| style=minimal \| width=80ch

## What Does Each Control Change?

- `family`: accent hue and contrast character for links, rules, and
  highlights.
- `preset`: background/surface/ink system (light analytical to dark
  editorial).
- `style`: structural weight (`minimal`, `balanced`, `assertive`).
- `content_width`: reading measure in `ch` units.

## Can You Validate The Palette Quickly?

``` r
pal <- albersdown::albers_palette(params$family)
stopifnot(
  identical(names(pal), c("A900", "A700", "A500", "A300")),
  all(nzchar(unname(pal)))
)
knitr::kable(data.frame(tone = names(pal), hex = unname(pal)), format = "html")
```

| tone | hex      |
|:-----|:---------|
| A900 | \#C22B23 |
| A700 | \#DC3925 |
| A500 | \#E44926 |
| A300 | \#E35B2D |

## Copy Into YAML

``` yaml
params:
  family: red
  preset: study
  base_size: 13
  content_width: 80
  style: minimal
```

## Example Plot

``` r
mtcars$grp <- factor(mtcars$cyl)
stopifnot(length(levels(mtcars$grp)) >= 3)

ggplot(mtcars, aes(wt, mpg, colour = grp)) +
  geom_point(size = 2.2) +
  labs(
    title = "Theme Lab preview",
    subtitle = "Tune family + preset + style, then copy YAML"
  )
```

![](theme-lab_files/figure-html/example-plot-1.png)
