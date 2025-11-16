import { test as setup, expect } from '@playwright/test';
import path from 'path';
import fs from "fs";
import * as OTPAuth from "otpauth"

const totp = new OTPAuth.TOTP({
  issuer: "Raccoon",
  label: "GitHub",
  algorithm: "SHA1",
  digits: 6,
  period: 30,
  secret: process.env.E2E_TEST_GITHUB_OTP,
})

const authDir = path.join(__dirname, '../.auth');
fs.mkdirSync(authDir, { recursive: true });

const authFile = path.join(authDir, 'user.json');

setup('authenticate', async ({ page }) => {
  // Perform authentication steps. Replace these actions with your own.
  await page.goto('https://github.com/login');
  await page.getByLabel('Username or email address').fill(process.env.E2E_TEST_GH_USERNAME!);
  await page.getByLabel('Password').fill(process.env.E2E_TEST_GH_PASSWORD!);
  await page.getByRole('button', { name: 'Sign in', exact: true }).click();
  
  await page.getByPlaceholder("XXXXXX").waitFor({ state: 'visible' });
  // generate at the last second
  const code = totp.generate();
  await page.getByPlaceholder("XXXXXX").fill(code);
  // await page.getByRole('button', { name: 'Verify', exact: true }).click();
  
  // Wait until the page receives the cookies.
  //
  // Sometimes login flow sets cookies in the process of several redirects.
  // Wait for the final URL to ensure that the cookies are actually set.
  await page.waitForURL('https://github.com/');

  // End of authentication steps.

  await page.context().storageState({ path: authFile });
});
