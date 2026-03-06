import { defineConfig, devices } from "@playwright/test";

const baseURL = process.env.ALBERSDOWN_VISUAL_BASE_URL ?? "http://127.0.0.1:3456";

export default defineConfig({
  testDir: "./specs",
  retries: 0,
  use: {
    baseURL,
    trace: "retain-on-failure"
  },
  projects: [
    { name: "desktop", use: { ...devices["Desktop Chrome"], viewport: { width: 1440, height: 960 } } },
    { name: "mobile", use: { ...devices["Pixel 7"], viewport: { width: 412, height: 915 } } }
  ]
});
