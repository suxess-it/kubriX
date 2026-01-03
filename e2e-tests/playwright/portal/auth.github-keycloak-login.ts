import { test as setup, expect } from '@playwright/test';
import path from 'path';
import fs from "fs";
import * as OTPAuth from "otpauth";

if (!process.env.E2E_TEST_GITHUB_OTP) {
  throw new Error("E2E_TEST_GITHUB_OTP must be set to run E2E tests");
}

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

const ghAuthFile = path.join(authDir, 'github.json');
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

  await page.context().storageState({ path: ghAuthFile });
});

const keycloakDemoadminAuthFile = path.join(authDir, 'keycloak-demoadmin.json');
setup('Keycloak Demoadmin Login', async ({ page }) => {
  await page.goto("https://backstage.127-0-0-1.nip.io/");

  await expect(page).toHaveTitle(/kubriX/);

  // Open Keycloak Login
  const popupPromise = page.waitForEvent('popup');
  await page.getByRole('listitem').filter({ hasText: 'Keycloak OIDCSign in with' }).getByRole('button').click();
  const page1 = await popupPromise;
  await page1.getByRole('textbox', { name: 'Username' }).click();
  await page1.getByRole('textbox', { name: 'Username' }).fill('demoadmin');
  await page1.getByRole('textbox', { name: 'Password' }).click();
  await page1.getByRole('textbox', { name: 'Password' }).fill(process.env.E2E_KEYCLOAK_DEMOADMIN_PASSWORD!);
  await page1.getByRole('button', { name: 'Sign In' }).click();

  await page.context().storageState({ path: keycloakDemoadminAuthFile });

  await page1.close();
  await expect(page.getByRole('heading', { name: 'Welcome to kubriX' })).toBeVisible();
});

const keycloakDemouserAuthFile = path.join(authDir, 'keycloak-demouser.json');
setup('Keycloak Demouser Login', async ({ page }) => {
  await page.goto("https://backstage.127-0-0-1.nip.io/");

  await expect(page).toHaveTitle(/kubriX/);

  // Open Keycloak Login
  const popupPromise = page.waitForEvent('popup');
  await page.getByRole('listitem').filter({ hasText: 'Keycloak OIDCSign in with' }).getByRole('button').click();
  const page1 = await popupPromise;
  await page1.getByRole('textbox', { name: 'Username' }).click();
  await page1.getByRole('textbox', { name: 'Username' }).fill('demouser');
  await page1.getByRole('textbox', { name: 'Password' }).click();
  await page1.getByRole('textbox', { name: 'Password' }).fill(process.env.E2E_KEYCLOAK_DEMOUSER_PASSWORD!);
  await page1.getByRole('button', { name: 'Sign In' }).click();

  await page.context().storageState({ path: keycloakDemouserAuthFile });
  
  await page1.close();
  await expect(page.getByRole('heading', { name: 'Welcome to kubriX' })).toBeVisible();
});
