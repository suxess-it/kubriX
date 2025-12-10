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

async function getFreshTotp(totp: OTPAuth.TOTP): Promise<string> {
  // How many ms are left for the current token
  let remainingMs = totp.remaining();

  // If we’re near the end of the window (< 5s left), wait for the next one
  if (remainingMs < 5000) {
    const waitMs = remainingMs + 1500; // wait rest of window + 1.5s safety
    console.log(`[TOTP] Near window end, waiting ${waitMs}ms for a fresh code...`);
    await new Promise(res => setTimeout(res, waitMs));
  }

  const code = totp.generate();
  const afterRemaining = totp.remaining();
  console.log(`[TOTP] Generated code=${code}, remaining=${afterRemaining}ms`);

  return code;
}

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
  // await waitForSafeTotpWindow();
  // const code = totp.generate();
  const code = await getFreshTotp(totp);
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
