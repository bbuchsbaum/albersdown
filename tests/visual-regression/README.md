# Visual Regression Scaffold

This suite captures a page matrix (desktop + mobile) to detect visual drift while evolving
albersdown aesthetics.

## Local run

1. Build docs:

```bash
Rscript -e 'pkgdown::build_site(new_process = FALSE, install = FALSE)'
```

2. Serve docs:

```bash
python -m http.server 3456 --directory docs
```

3. In another terminal:

```bash
cd tests/visual-regression
npm install
npx playwright install --with-deps chromium
npm run test
```

Screenshots are written to Playwright output folders. Converting these into hard snapshot
assertions is straightforward once preferred baselines are committed.
