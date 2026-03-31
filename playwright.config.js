// Playwright configuration
// Docs: https://playwright.dev/docs/test-configuration
const { defineConfig, devices } = require('@playwright/test');

module.exports = defineConfig({
  testDir: './tests',

  // Run all tests in parallel across spec files
  fullyParallel: true,

  // No retries — failures should be fixed, not hidden
  retries: 0,

  // Concise output in terminal
  reporter: 'list',

  use: {
    // All page.goto() calls use this as the base (can use '/about.html' instead of full URL)
    baseURL: 'http://localhost:8080',

    // Run headless by default (override with `npm run test:headed`)
    headless: true,

    // Capture screenshot on test failure for debugging
    screenshot: 'only-on-failure',
  },

  // Start a static HTTP server before running tests and shut it down after
  webServer: {
    command: 'npx http-server site -p 8080 --silent',
    url: 'http://localhost:8080',
    // Reuse an already-running server locally; always start fresh in CI
    reuseExistingServer: !process.env.CI,
    // Give the server up to 10 seconds to start
    timeout: 10000,
  },

  // Run tests only in Chromium (matches the target deployment environment)
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
  ],
});
