import { expect, test } from "@playwright/test";

const pages = [
  "index.html",
  "articles/getting-started.html",
  "articles/design-notes.html",
  "articles/theme-lab.html"
];

const states = [
  { family: "red", preset: "study" },
  { family: "lapis", preset: "midnight" },
  { family: "ochre", preset: "adobe" }
];

test.describe("theme matrix screenshots", () => {
  for (const pagePath of pages) {
    for (const state of states) {
      test(`${pagePath} [${state.family}/${state.preset}]`, async ({ page }, testInfo) => {
        const suffix = `family=${state.family}&preset=${state.preset}&style=minimal&width=80`;
        const url = pagePath.includes("?") ? `${pagePath}&${suffix}` : `${pagePath}?${suffix}`;

        await page.goto(url, { waitUntil: "networkidle" });
        await expect(page.locator("body")).toBeVisible();

        await page.screenshot({
          path: testInfo.outputPath(`${pagePath.replace(/[/.]/g, "-")}-${state.family}-${state.preset}.png`),
          fullPage: true
        });
      });
    }
  }
});
