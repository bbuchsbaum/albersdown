# bs_theme for pkgdown (light/dark aware)

Convenience wrapper exposing core variables; most consumers won't need
this directly if they use `template: { package: albersdown }`.

## Usage

``` r
albers_bs_theme(
  family = "red",
  preset = c("homage", "study", "structural", "adobe", "midnight"),
  accent = NULL,
  bg = NULL,
  fg = NULL
)
```

## Arguments

- family:

  Palette family name (default `"red"`).

- preset:

  Visual preset (default `"homage"`). See
  [`albers_presets()`](https://bbuchsbaum.github.io/albersdown/reference/albers_presets.md).

- accent:

  Primary accent color (default A700 of the chosen family).

- bg:

  Background color (default derived from preset).

- fg:

  Foreground/text color (default derived from preset).

## Value

A
[`bslib::bs_theme`](https://rstudio.github.io/bslib/reference/bs_theme.html)
object.

## Examples

``` r
# \donttest{
if (requireNamespace("bslib", quietly = TRUE)) {
  albers_bs_theme()
}
#> /* Sass Bundle: _utilities, _root, _reboot, _type, _images, _containers, _grid, _tables, _forms, _buttons, _transitions, _dropdown, _button-group, _nav, _navbar, _card, _accordion, _breadcrumb, _pagination, _badge, _alert, _progress, _list-group, _close, _toasts, _modal, _tooltip, _popover, _carousel, _spinners, _offcanvas, _placeholders, _helpers, _api, bs3compat, builtin */
#> @import "/home/runner/work/_temp/Library/bslib/lib/bs5/scss/_functions.scss";
#> @import "/home/runner/work/_temp/Library/bslib/bslib-scss/functions.scss";
#> $enable-rounded: false !default;
#> $enable-shadows: false !default;
#> $border-radius: 0 !default;
#> $border-radius-sm: 0 !default;
#> $border-radius-lg: 0 !default;
#> $headings-font-weight: 700 !default;
#> $font-size-base: 1.05rem !default;
#> $body-secondary-color: #636b76 !default;
#> $body-tertiary-bg: #ffffff !default;
#> $border-color: #d5dae1 !default;
#> $code-bg: #ecf0f4 !default;
#> $font-family-base: 'Avenir Next', 'Gill Sans', system-ui !default;
#> $font-family-monospace: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace !default;
#> $headings-font-family: 'Avenir Next', 'Gill Sans', system-ui !default;
#> $primary: #DC3925 !default;
#> $secondary: #636B76 !default;
#> $white: #F3F5F7 !default;
#> $gray-100: #DDDFE1 !default;
#> $gray-200: #C7C9CB !default;
#> $gray-300: #B1B3B5 !default;
#> $gray-400: #9B9D9F !default;
#> $gray-500: #858688 !default;
#> $gray-600: #6F7072 !default;
#> $gray-700: #595A5C !default;
#> $gray-800: #434446 !default;
#> $gray-900: #2D2E30 !default;
#> $black: #17181A !default;
#> $bslib-preset-type: builtin;
#> $bslib-preset-name: shiny;
#> $web-font-path: "font.css" !default;
#> @import "/home/runner/work/_temp/Library/bslib/builtin/bs5/shiny/_variables.scss";
#> $enable-cssgrid: true !default;
#> @import "/home/runner/work/_temp/Library/bslib/bs3compat/_defaults.scss";
#> @import "/home/runner/work/_temp/Library/bslib/lib/bs5/scss/_variables.scss";
#> @import "/home/runner/work/_temp/Library/bslib/lib/bs5/scss/_variables-dark.scss";
#> $bootstrap-version: 5;
#> $bslib-preset-name: null !default;
#> $bslib-preset-type: null !default;
#> @import "/home/runner/work/_temp/Library/bslib/lib/bs5/scss/_maps.scss";
#> @import "/home/runner/work/_temp/Library/bslib/lib/bs5/scss/_mixins.scss";
#> @import "/home/runner/work/_temp/Library/bslib/bs3compat/_declarations.scss";
#> @import "/home/runner/work/_temp/Library/bslib/builtin/bs5/shiny/_mixins.scss";
#> :root {
#> --bslib-bootstrap-version: #{$bootstrap-version};
#> --bslib-preset-name: #{$bslib-preset-name};
#> --bslib-preset-type: #{$bslib-preset-type};
#> }
#> @import "/home/runner/work/_temp/Library/bslib/lib/bs5/scss/mixins/_banner.scss";
#> @include bsBanner('')
#> @import "/home/runner/work/_temp/Library/bslib/lib/bs5/scss/_utilities.scss";
#> @import "/home/runner/work/_temp/Library/bslib/lib/bs5/scss/_root.scss";
#> @import "/home/runner/work/_temp/Library/bslib/lib/bs5/scss/_reboot.scss";
#> @import "/home/runner/work/_temp/Library/bslib/lib/bs5/scss/_type.scss";
#> @import "/home/runner/work/_temp/Library/bslib/lib/bs5/scss/_images.scss";
#> @import "/home/runner/work/_temp/Library/bslib/lib/bs5/scss/_containers.scss";
#> @import "/home/runner/work/_temp/Library/bslib/lib/bs5/scss/_grid.scss";
#> @import "/home/runner/work/_temp/Library/bslib/lib/bs5/scss/_tables.scss";
#> @import "/home/runner/work/_temp/Library/bslib/lib/bs5/scss/_forms.scss";
#> @import "/home/runner/work/_temp/Library/bslib/lib/bs5/scss/_buttons.scss";
#> @import "/home/runner/work/_temp/Library/bslib/lib/bs5/scss/_transitions.scss";
#> @import "/home/runner/work/_temp/Library/bslib/lib/bs5/scss/_dropdown.scss";
#> @import "/home/runner/work/_temp/Library/bslib/lib/bs5/scss/_button-group.scss";
#> @import "/home/runner/work/_temp/Library/bslib/lib/bs5/scss/_nav.scss";
#> @import "/home/runner/work/_temp/Library/bslib/lib/bs5/scss/_navbar.scss";
#> @import "/home/runner/work/_temp/Library/bslib/lib/bs5/scss/_card.scss";
#> @import "/home/runner/work/_temp/Library/bslib/lib/bs5/scss/_accordion.scss";
#> @import "/home/runner/work/_temp/Library/bslib/lib/bs5/scss/_breadcrumb.scss";
#> @import "/home/runner/work/_temp/Library/bslib/lib/bs5/scss/_pagination.scss";
#> @import "/home/runner/work/_temp/Library/bslib/lib/bs5/scss/_badge.scss";
#> @import "/home/runner/work/_temp/Library/bslib/lib/bs5/scss/_alert.scss";
#> @import "/home/runner/work/_temp/Library/bslib/lib/bs5/scss/_progress.scss";
#> @import "/home/runner/work/_temp/Library/bslib/lib/bs5/scss/_list-group.scss";
#> @import "/home/runner/work/_temp/Library/bslib/lib/bs5/scss/_close.scss";
#> @import "/home/runner/work/_temp/Library/bslib/lib/bs5/scss/_toasts.scss";
#> @import "/home/runner/work/_temp/Library/bslib/lib/bs5/scss/_modal.scss";
#> @import "/home/runner/work/_temp/Library/bslib/lib/bs5/scss/_tooltip.scss";
#> @import "/home/runner/work/_temp/Library/bslib/lib/bs5/scss/_popover.scss";
#> @import "/home/runner/work/_temp/Library/bslib/lib/bs5/scss/_carousel.scss";
#> @import "/home/runner/work/_temp/Library/bslib/lib/bs5/scss/_spinners.scss";
#> @import "/home/runner/work/_temp/Library/bslib/lib/bs5/scss/_offcanvas.scss";
#> @import "/home/runner/work/_temp/Library/bslib/lib/bs5/scss/_placeholders.scss";
#> @import "/home/runner/work/_temp/Library/bslib/lib/bs5/scss/_helpers.scss";
#> @import "/home/runner/work/_temp/Library/bslib/lib/bs5/scss/utilities/_api.scss";
#> .table th[align=left] { text-align: left; }
#> .table th[align=right] { text-align: right; }
#> .table th[align=center] { text-align: center; }
#> @import "/home/runner/work/_temp/Library/bslib/bs3compat/_rules.scss";
#> @import "/home/runner/work/_temp/Library/bslib/bslib-scss/bslib.scss";
#> @import "/home/runner/work/_temp/Library/bslib/builtin/bs5/shiny/_rules.scss";
#> /* *** */
#> 
#> Other Sass Bundle information:
#> List of 2
#>  $ html_deps       :List of 1
#>   ..$ :List of 10
#>   .. ..$ name      : chr "bs3compat"
#>   .. ..$ version   : chr "0.10.0"
#>   .. ..$ src       :List of 1
#>   .. .. ..$ file: chr "bs3compat/js"
#>   .. ..$ meta      : NULL
#>   .. ..$ script    : chr [1:3] "transition.js" "tabs.js" "bs3compat.js"
#>   .. ..$ stylesheet: NULL
#>   .. ..$ head      : NULL
#>   .. ..$ attachment: NULL
#>   .. ..$ package   : chr "bslib"
#>   .. ..$ all_files : logi TRUE
#>   .. ..- attr(*, "class")= chr "html_dependency"
#>  $ file_attachments: Named chr [1:3] "/home/runner/work/_temp/Library/bslib/lib/bs3/assets/fonts" "/home/runner/work/_temp/Library/bslib/builtin/bs5/shiny/font.css" "/home/runner/work/_temp/Library/bslib/fonts"
#>   ..- attr(*, "names")= chr [1:3] "fonts" "font.css" "fonts"
# }
```
