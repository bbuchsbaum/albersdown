import { expect, test, type Page } from "@playwright/test";

const familyA900: Record<string, string> = {
  red: "#c22b23",
  lapis: "#1b2a74",
  ochre: "#6f5200",
  teal: "#0d4a4a",
  green: "#1b5e20"
};

const presetTheme: Record<string, "light" | "dark"> = {
  study: "light",
  structural: "light",
  adobe: "light",
  midnight: "dark"
};

const themeLabStates = [
  { family: "red", preset: "study" },
  { family: "lapis", preset: "midnight" },
  { family: "ochre", preset: "adobe" },
  { family: "teal", preset: "study" }
];

const proofPages = [
  { path: "articles/proof-teal-study.html", family: "teal", preset: "study" },
  { path: "articles/proof-ochre-structural.html", family: "ochre", preset: "structural" }
];

async function expectAppliedTheme(page: Page, state: { family: string; preset: string }) {
  await expect(page.locator("body")).toBeVisible();
  await expect(page.locator("body")).toHaveClass(new RegExp(`\\bpalette-${state.family}\\b`));
  await expect(page.locator("body")).toHaveClass(new RegExp(`\\bpreset-${state.preset}\\b`));
  await expect
    .poll(async () =>
      page.evaluate(() => getComputedStyle(document.body).getPropertyValue("--A900").trim().toLowerCase())
    )
    .toBe(familyA900[state.family]);
  await expect(page.locator("body")).toHaveAttribute("data-bs-theme", presetTheme[state.preset]);
}

test.describe("theme lab state matrix", () => {
  for (const state of themeLabStates) {
    test(`theme-lab [${state.family}/${state.preset}]`, async ({ page }, testInfo) => {
      const url = `articles/theme-lab.html?family=${state.family}&preset=${state.preset}&style=minimal&width=80`;

      await page.goto(url, { waitUntil: "networkidle" });
      await expect(page.locator("[data-albers-control='family']")).toBeVisible();
      await expectAppliedTheme(page, state);
      await expect
        .poll(async () =>
          page.evaluate(() => getComputedStyle(document.documentElement).getPropertyValue("--content").trim())
        )
        .toBe("80ch");

      await page.screenshot({
        path: testInfo.outputPath(`articles-theme-lab-${state.family}-${state.preset}.png`),
        fullPage: true
      });
    });
  }
});

test.describe("proof article theme application", () => {
  for (const state of proofPages) {
    test(state.path, async ({ page }, testInfo) => {
      await page.goto(state.path, { waitUntil: "networkidle" });
      await expectAppliedTheme(page, state);

      await page.screenshot({
        path: testInfo.outputPath(`${state.path.replace(/[/.]/g, "-")}.png`),
        fullPage: true
      });
    });
  }
});
