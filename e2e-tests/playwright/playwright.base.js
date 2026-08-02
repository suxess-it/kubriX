import dotenv from 'dotenv';
import path from 'path';

if (!process.env.CI) {
  dotenv.config({ path: path.resolve(__dirname, '../../../.env_play') });
}

export const sharedConfig = {
  timeout: 30 * 1000,
  expect: {
    timeout: 5000,
  },
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  use: {
    browserName: 'chromium',
    headless: true,
    launchOptions: {
      args: ['--disable-blink-features=AutomationControlled', '--disable-popup-blocking'],
    },
    viewport: { width: 1920, height: 1080 },
    actionTimeout: 0,
    trace: 'retain-on-failure',
    video: 'retain-on-failure',
    ignoreHTTPSErrors: true,
  },
  outputDir: 'data/test-results/',
};
