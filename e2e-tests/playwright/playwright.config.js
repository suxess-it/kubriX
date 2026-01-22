import { defineConfig, devices } from '@playwright/test';

/**
 * Read environment variables from file.
 * https://github.com/motdotla/dotenv
 */
// import dotenv from 'dotenv';
// import path from 'path';
// dotenv.config({ path: path.resolve(__dirname, '.env') });

/**
 * See https://playwright.dev/docs/test-configuration.
 */
export default defineConfig({
  // testDir: './portal',
  /* Maximum time one test can run for. */
  timeout: 30 * 1000,
  expect: {
    /**
     * Maximum time expect() should wait for the condition to be met.
     * For example in `await expect(locator).toHaveText();`
     */
    timeout: 5000
  },
  /* Run tests in files in parallel */
  fullyParallel: true,
  /* Fail the build on CI if you accidentally left test.only in the source code. */
  forbidOnly: !!process.env.CI,
  /* Retry on CI only */
  retries: 0,
  /* Opt out of parallel tests on CI. */
  workers: process.env.CI ? 1 : undefined,
  /* Reporter to use. See https://playwright.dev/docs/test-reporters */
  reporter: 'html',
  /* Shared settings for all the projects below. See https://playwright.dev/docs/api/class-testoptions. */
  use: {
    /* Maximum time each action such as `click()` can take. Defaults to 0 (no limit). */
    actionTimeout: 0,
    /* Base URL to use in actions like `await page.goto('/')`. */
    // baseURL: 'http://localhost:3000',

    /* Collect trace when retrying the failed test. See https://playwright.dev/docs/trace-viewer */
    trace: 'on',
    video: 'on',
    ignoreHTTPSErrors: true,
    // storageState: '.auth/user.json',
  },

  /* Configure projects for major browsers */
  projects: [
    {
      name: 'portal-login',
      testMatch: 'portal/auth.github-keycloak-login.ts',
      // IMPORTANT: it is crucial that we do not enable 'trace' in login project, so kubrixBot password doesn't get leaked in the traces
      use : {trace : 'off'}
    },
    {
      name: 'portal-tests',
      testMatch: /portal\/portal-.*/,
      use: {
        ...devices['Desktop Chrome'],
      },
      dependencies: ['portal-login','argocd-login','kargo-login'],
    },
    {
      name: 'argocd-login',
      testMatch: 'argocd/auth.argocd-login.ts',
    },
    {
      name: 'grafana-login',
      testMatch: 'grafana/auth.grafana-login.ts',
    },
    {
      name: 'keycloak-login',
      testMatch: 'keycloak/auth.keycloak-login.ts',
    },
    {
      name: 'vault-login',
      testMatch: 'vault/auth.vault-login.ts',
    },
    {
      name: 'kargo-login',
      testMatch: 'kargo/auth.kargo-login.ts',
    },
    {
      name: 'argocd-tests',
      testMatch: /argocd\/argocd-.*/,
      use: {
        ...devices['Desktop Chrome'],
      },
      dependencies: ['argocd-login'],
    },
    {
      name: 'grafana-tests',
      testMatch: /grafana\/grafana-.*/,
      use: {
        ...devices['Desktop Chrome'],
      },
      dependencies: ['grafana-login'],
    },
    {
      name: 'keycloak-tests',
      testMatch: /keycloak\/keycloak-.*/,
      use: {
        ...devices['Desktop Chrome'],
      },
      dependencies: ['keycloak-login'],
    },
    {
      name: 'vault-tests',
      testMatch: /vault\/vault-.*/,
      use: {
        ...devices['Desktop Chrome'],
      },
      dependencies: ['vault-login'],
    },
    {
      name: 'kargo-tests',
      testMatch: /kargo\/kargo-.*/,
      use: {
        ...devices['Desktop Chrome'],
      },
      dependencies: ['kargo-login'],
    },
    {
      name: 'prime-tests',
      testMatch: /prime\/prime-.*/,
      use: {
        ...devices['Desktop Chrome'],
      },
      dependencies: ['argocd-login','portal-login','grafana-login','keycloak-login','vault-login','kargo-login'],
    },
    // {
    //   name: 'webkit',
    //   use: { ...devices['Desktop Safari'] },
    // },

    /* Test against mobile viewports. */
    // {
    //   name: 'Mobile Chrome',
    //   use: { ...devices['Pixel 5'] },
    // },
    // {
    //   name: 'Mobile Safari',
    //   use: { ...devices['iPhone 12'] },
    // },

    /* Test against branded browsers. */
    // {
    //   name: 'Microsoft Edge',
    //   use: { channel: 'msedge' },
    // },
    // {
    //   name: 'Google Chrome',
    //   use: { channel: 'chrome' },
    // },
  ],

  /* Folder for test artifacts such as screenshots, videos, traces, etc. */
  outputDir: 'data/artifacts/',

  /* Run your local dev server before starting the tests */
  // webServer: {
  //   command: 'npm run start',
  //   port: 3000,
  // },
});
