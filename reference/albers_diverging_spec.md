# Build a 5-stop diverging spec from two families

Build a 5-stop diverging spec from two families

## Usage

``` r
albers_diverging_spec(
  low_family = "red",
  high_family = albers_complement(low_family),
  neutral = "#e5e7eb"
)
```

## Arguments

- low_family:

  family driving the low side

- high_family:

  family driving the high side

- neutral:

  hex color at the midpoint (defaults to CSS border tone)

## Value

list(colours, values)
