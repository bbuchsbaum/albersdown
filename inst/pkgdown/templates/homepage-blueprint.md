# Albersdown Homepage Blueprint

Use this as a starting structure for `README.md` (which pkgdown renders as the home page)
when you want a high-contrast editorial layout with clear information hierarchy.

```markdown
<div class="albers-composition" data-seed="home" data-density="7" aria-hidden="true"></div>

## Why This Package {.overview}

- One sentence on the problem the package solves.
- One sentence on what makes your approach distinctive.
- One sentence on expected user outcomes.

<div class="hr-notch" role="presentation"></div>

## Quick Start

```r
# install.packages("yourpkg")
library(yourpkg)

result <- yourpkg::main_function(example_input)
print(result)
```

## Core Building Blocks

<div class="theme-lab__chips">
  <span class="albers-chip">Data IO</span>
  <span class="albers-chip">Modeling</span>
  <span class="albers-chip">Visualization</span>
  <span class="albers-chip">Diagnostics</span>
</div>

## Design Principles {.overview}

- Prefer simple defaults and explicit overrides.
- Keep one visual family per page for coherence.
- Use callouts for decisions, not decoration.

<div class="callout callout-insight">
Most packages improve readability by reducing visual noise, not adding more UI.
</div>

## Learn More

- `articles/getting-started.html`
- `reference/index.html`
```
