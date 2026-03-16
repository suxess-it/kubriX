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
  // console.log(`[TOTP] Generated code=${code}, remaining=${afterRemaining}ms`);

  return code;
}

const authDir = path.join(__dirname, '../.auth');
fs.mkdirSync(authDir, { recursive: true });

const ghAuthFile = path.join(authDir, 'github.json');
setup('Github Login', async ({ page }, testInfo) => {
  // extend timeout because when TOTP retry needs to be made
  testInfo.setTimeout(3 * 60 * 1000);
  // Perform authentication steps
  await page.goto('https://github.com/login');
  await page.getByLabel('Username or email address').fill(process.env.E2E_TEST_GH_USERNAME!);
  await page.getByLabel('Password').fill(process.env.E2E_TEST_GH_PASSWORD!);
  await page.getByRole('button', { name: 'Sign in', exact: true }).click();
  
  // fill in tfa
  const TOTP_INPUT = page.getByPlaceholder("XXXXXX");
  const ERROR_TEXT = 'The two-factor code you entered has already been used or is too old to be used.';

  const MAX_RETRIES = 3;

  for (let attempt = 1; attempt <= MAX_RETRIES; attempt++) {
    await TOTP_INPUT.waitFor({ state: 'visible' });

    const code = await getFreshTotp(totp);
    await TOTP_INPUT.fill(code);

    const result = await Promise.race([
      page.waitForURL('https://github.com/', { timeout: 15000 }).then(() => 'success'),
      page.getByText(ERROR_TEXT).waitFor({ timeout: 15000 }).then(() => 'error'),
    ]);

    if (result === 'success') {
      console.log('Login successful');
      break;
    }

    if (attempt === MAX_RETRIES) {
      throw new Error('TOTP failed too many times');
    }

    console.warn(`TOTP expired, retrying in 60 seconds (attempt ${attempt})`);

    // Clear input before retry
    await TOTP_INPUT.fill('');

    // Wait for next TOTP window
    await page.waitForTimeout(60_000);
  }

  // Login in Backstage
  await page.goto("https://backstage.127-0-0-1.nip.io/");
  await expect(page).toHaveTitle(/kubriX/);

  // Open GitHub login popup
  await page.getByRole('listitem').filter({ hasText: 'GitHubSign in using' }).getByRole('button').click();

  const popup = await page.waitForEvent('popup'); // your page1Promise
  const authorize = popup.getByRole('button', { name: 'Authorize kubriX-demo' });

  await Promise.race([
  authorize
    .waitFor({ state: 'visible', timeout: 5000 })
    .then(() => authorize.click())
    .then(() => popup.waitForEvent('close')), 

    // Case B: popup closes automatically -> do nothing
    popup.waitForEvent('close')
  ]);

  // optional: make sure the popup is gone before continuing
  if (!popup.isClosed()) await popup.close();

  await expect(page.getByRole('heading', { name: 'Welcome to kubriX' })).toBeVisible();
  await page.context().storageState({ path: ghAuthFile });
})

async function keycloakLogin(page: any, username: string, password: string, authFile: string) {
  const MAX_RETRIES = 5;
  const RETRY_WAIT_MS = 30_000;

  for (let attempt = 1; attempt <= MAX_RETRIES; attempt++) {
    console.log(`[Keycloak login] attempt ${attempt}/${MAX_RETRIES} for user '${username}'`);

    await page.goto("https://backstage.127-0-0-1.nip.io/");
    await expect(page).toHaveTitle(/kubriX/);

    const popupPromise = page.waitForEvent('popup');
    await page.getByRole('listitem').filter({ hasText: 'Keycloak OIDCSign in with' }).getByRole('button').click();
    const page1 = await popupPromise;

    try {
      await page1.getByRole('textbox', { name: 'Username' }).waitFor({ state: 'visible', timeout: 10_000 });
    } catch {
      const popupUrl = page1.url();
      console.warn(`[Keycloak login] attempt ${attempt}: Username field not visible. Popup URL: ${popupUrl}`);
      await page1.close();
      if (attempt === MAX_RETRIES) throw new Error(`Keycloak OIDC login failed after ${MAX_RETRIES} attempts (popup never showed login form). Last popup URL: ${popupUrl}`);
      console.log(`[Keycloak login] waiting ${RETRY_WAIT_MS / 1000}s before retry...`);
      await page.waitForTimeout(RETRY_WAIT_MS);
      continue;
    }

    await page1.getByRole('textbox', { name: 'Username' }).click();
    await page1.getByRole('textbox', { name: 'Username' }).fill(username);
    await page1.getByRole('textbox', { name: 'Password' }).click();
    await page1.getByRole('textbox', { name: 'Password' }).fill(password);
    await page1.getByRole('button', { name: 'Sign In' }).click();

    await page.context().storageState({ path: authFile });
    await page1.close();
    await expect(page.getByRole('heading', { name: 'Welcome to kubriX' })).toBeVisible();
    console.log(`[Keycloak login] attempt ${attempt}: success`);
    return;
  }
}

const keycloakDemoadminAuthFile = path.join(authDir, 'keycloak-demoadmin.json');
setup('Keycloak Demoadmin Login', async ({ page }, testInfo) => {
  testInfo.setTimeout(5 * 60 * 1000);
  await keycloakLogin(page, 'demoadmin', process.env.E2E_KEYCLOAK_DEMOADMIN_PASSWORD!, keycloakDemoadminAuthFile);
});

const keycloakDemouserAuthFile = path.join(authDir, 'keycloak-demouser.json');
setup('Keycloak Demouser Login', async ({ page }, testInfo) => {
  testInfo.setTimeout(5 * 60 * 1000);
  await keycloakLogin(page, 'demouser', process.env.E2E_KEYCLOAK_DEMOUSER_PASSWORD!, keycloakDemouserAuthFile);
});
