import { test as setup, expect, Page } from '@playwright/test';
import path from 'path';
import fs from 'fs';
import * as OTPAuth from 'otpauth';
import { reuseStoredAuthState } from '../utils/auth-cache';

const BASE_DOMAIN = process.env.E2E_BASE_DOMAIN ?? '127-0-0-1.nip.io';

if (!process.env.E2E_TEST_GITHUB_OTP) {
  throw new Error('E2E_TEST_GITHUB_OTP must be set to run E2E tests');
}

if (!process.env.E2E_TEST_GH_USERNAME) {
  throw new Error('E2E_TEST_GH_USERNAME must be set to run E2E tests');
}

if (!process.env.E2E_TEST_GH_PASSWORD) {
  throw new Error('E2E_TEST_GH_PASSWORD must be set to run E2E tests');
}

const totp = new OTPAuth.TOTP({
  issuer: 'Raccoon',
  label: 'GitHub',
  algorithm: 'SHA1',
  digits: 6,
  period: 30,
  secret: process.env.E2E_TEST_GITHUB_OTP,
});

async function getFreshTotp(totp: OTPAuth.TOTP): Promise<string> {
  const remainingMs = totp.remaining();

  if (remainingMs < 5000) {
    const waitMs = remainingMs + 1500;
    console.log(`[TOTP] Near window end, waiting ${waitMs}ms for a fresh code...`);
    await new Promise(resolve => setTimeout(resolve, waitMs));
  }

  return totp.generate();
}

async function waitForGithubLoginResult(page: Page, errorText: string): Promise<'success' | 'error'> {
  const deadline = Date.now() + 15_000;

  while (Date.now() < deadline) {
    if (page.url() === 'https://github.com/') {
      return 'success';
    }

    const hasError = await page.getByText(errorText).isVisible().catch(() => false);
    if (hasError) {
      return 'error';
    }

    await page.waitForTimeout(250);
  }

  throw new Error('Timed out waiting for GitHub login result');
}

async function addAntiBotInitScript(page: Page): Promise<void> {
  await page.context().addInitScript(() => {
    Object.defineProperty(navigator, 'webdriver', {
      get: () => undefined,
      configurable: true,
    });

    Object.defineProperty(navigator, 'languages', {
      get: () => ['en-US', 'en'],
      configurable: true,
    });

    Object.defineProperty(navigator, 'plugins', {
      get: () => [1, 2, 3, 4, 5],
      configurable: true,
    });

    Object.defineProperty(window, 'chrome', {
      get: () => ({ runtime: {} }),
      configurable: true,
    });
  });
}

async function completeGithubBackstagePopup(page: Page): Promise<void> {
  const MAX_POPUP_ATTEMPTS = 2;
  const RETRY_WAIT_MS = 5_000;

  for (let attempt = 1; attempt <= MAX_POPUP_ATTEMPTS; attempt++) {
    const popupPromise = page.waitForEvent('popup');
    await page
      .getByRole('listitem')
      .filter({ hasText: 'GitHubSign in using' })
      .getByRole('button')
      .click();

    const popup = await popupPromise;
    await popup.waitForLoadState('domcontentloaded');

    const popupUrl = popup.url();
    console.log(`[GitHub popup] attempt ${attempt}/${MAX_POPUP_ATTEMPTS} url:`, popupUrl);

    if (popupUrl.includes('/api/auth/github/handler/frame')) {
      await expect(page.getByRole('heading', { name: 'Welcome to kubriX' })).toBeVisible({
        timeout: 15_000,
      });
      if (!popup.isClosed()) {
        await popup.close().catch(() => {});
      }
      return;
    }

    const authorize = popup.getByRole('button', { name: 'Authorize kubriX-demo' });
    await expect(authorize).toBeVisible({ timeout: 10_000 });

    try {
      // GitHub keeps the button disabled as bot-detection in headless browsers.
      // Use form.submit() to bypass all JS event handlers — this skips GitHub's
      // click guard entirely and submits directly to the server.
      await popup.evaluate(() => {
        const form = document.querySelector('form') as HTMLFormElement;
        if (!form.querySelector('input[name="authorize"]')) {
          const input = Object.assign(document.createElement('input'), {
            type: 'hidden', name: 'authorize', value: '1',
          });
          form.appendChild(input);
        }
        form.submit();
      });
      await Promise.race([
        popup.waitForEvent('close', { timeout: 20_000 }),
        popup.waitForURL('**/api/auth/github/handler/frame', { timeout: 20_000 }),
      ]);
      if (!popup.isClosed()) await popup.close().catch(() => {});
      await expect(page.getByRole('heading', { name: 'Welcome to kubriX' })).toBeVisible({
        timeout: 15_000,
      });
      return;
    } catch (error) {
      console.warn(
        `[GitHub popup] attempt ${attempt} did not complete normally:`,
        error,
      );

      if (!popup.isClosed()) {
        await popup.close().catch(() => {});
      }

      if (attempt === MAX_POPUP_ATTEMPTS) {
        throw error;
      }

      await page.waitForLoadState('domcontentloaded', { timeout: 15_000 }).catch(() => {});
      await page.reload({ waitUntil: 'domcontentloaded' });
      await expect(page).toHaveTitle(/kubriX/);
      await page.waitForTimeout(RETRY_WAIT_MS);
    }
  }
}

const authDir = path.join(__dirname, '../.auth');
fs.mkdirSync(authDir, { recursive: true });

const ghAuthFile = path.join(authDir, 'github.json');

setup('Github Login', async ({ page }, testInfo) => {
  testInfo.setTimeout(3 * 60 * 1000);
  if (reuseStoredAuthState(ghAuthFile, 'github-backstage')) return;

  // Important: must happen before any navigation or popup is opened.
  await addAntiBotInitScript(page);

  // Log in to GitHub first
  await page.goto('https://github.com/login');
  await page.getByLabel('Username or email address').fill(process.env.E2E_TEST_GH_USERNAME!);
  await page.getByLabel('Password').fill(process.env.E2E_TEST_GH_PASSWORD!);
  await page.getByRole('button', { name: 'Sign in', exact: true }).click();

  // Handle TOTP
  const TOTP_INPUT = page.getByPlaceholder('XXXXXX');
  const ERROR_TEXT =
    'The two-factor code you entered has already been used or is too old to be used.';
  const MAX_RETRIES = 3;

  for (let attempt = 1; attempt <= MAX_RETRIES; attempt++) {
    await TOTP_INPUT.waitFor({ state: 'visible' });

    const code = await getFreshTotp(totp);
    await TOTP_INPUT.fill(code);

    const result = await waitForGithubLoginResult(page, ERROR_TEXT);

    if (result === 'success') {
      console.log('[GitHub login] Login successful');
      break;
    }

    if (attempt === MAX_RETRIES) {
      throw new Error('TOTP failed too many times');
    }

    console.warn(`[GitHub login] TOTP expired, retrying in 60 seconds (attempt ${attempt})`);
    await TOTP_INPUT.fill('');
    await page.waitForTimeout(60_000);
  }

  // Open Backstage and start GitHub sign-in flow
  await page.goto(`https://backstage.${BASE_DOMAIN}/`);
  await expect(page).toHaveTitle(/kubriX/);
  await completeGithubBackstagePopup(page);

  await expect(page.getByRole('heading', { name: 'Welcome to kubriX' })).toBeVisible();
  await page.context().storageState({ path: ghAuthFile });
});

async function keycloakLogin(
  page: Page,
  username: string,
  password: string,
  authFile: string,
): Promise<void> {
  const MAX_RETRIES = 5;
  const RETRY_WAIT_MS = 30_000;

  for (let attempt = 1; attempt <= MAX_RETRIES; attempt++) {
    console.log(`[Keycloak login] attempt ${attempt}/${MAX_RETRIES} for user '${username}'`);

    await page.goto(`https://backstage.${BASE_DOMAIN}/`);
    await expect(page).toHaveTitle(/kubriX/);

    const popupPromise = page.waitForEvent('popup');
    await page
      .getByRole('listitem')
      .filter({ hasText: 'Keycloak OIDCSign in with' })
      .getByRole('button')
      .click();

    const popup = await popupPromise;
    await popup.waitForLoadState('domcontentloaded');

    try {
      await popup.getByRole('textbox', { name: 'Username' }).waitFor({
        state: 'visible',
        timeout: 10_000,
      });
    } catch {
      const popupUrl = popup.url();
      console.warn(
        `[Keycloak login] attempt ${attempt}: Username field not visible. Popup URL: ${popupUrl}`,
      );
      await popup.close();

      if (attempt === MAX_RETRIES) {
        throw new Error(
          `Keycloak OIDC login failed after ${MAX_RETRIES} attempts (popup never showed login form). Last popup URL: ${popupUrl}`,
        );
      }

      console.log(`[Keycloak login] waiting ${RETRY_WAIT_MS / 1000}s before retry...`);
      await page.waitForTimeout(RETRY_WAIT_MS);
      continue;
    }

    await popup.getByRole('textbox', { name: 'Username' }).fill(username);
    await popup.getByRole('textbox', { name: 'Password' }).fill(password);
    await popup.getByRole('button', { name: 'Sign In' }).click();

    await expect(page.getByRole('heading', { name: 'Welcome to kubriX' })).toBeVisible();
    await page.context().storageState({ path: authFile });

    if (!popup.isClosed()) {
      await popup.close();
    }

    console.log(`[Keycloak login] attempt ${attempt}: success`);
    return;
  }
}

const keycloakDemoadminAuthFile = path.join(authDir, 'keycloak-demoadmin.json');
setup('Keycloak Demoadmin Login', async ({ page }, testInfo) => {
  testInfo.setTimeout(5 * 60 * 1000);
  if (reuseStoredAuthState(keycloakDemoadminAuthFile, 'keycloak-demoadmin')) return;
  await keycloakLogin(
    page,
    'demoadmin',
    process.env.E2E_KEYCLOAK_DEMOADMIN_PASSWORD!,
    keycloakDemoadminAuthFile,
  );
});

const keycloakDemoeditorAuthFile = path.join(authDir, 'keycloak-demoeditor.json');
setup('Keycloak Demoeditor Login', async ({ page }, testInfo) => {
  testInfo.setTimeout(5 * 60 * 1000);
  if (reuseStoredAuthState(keycloakDemoeditorAuthFile, 'keycloak-demoeditor')) return;
  await keycloakLogin(
    page,
    'demoeditor',
    process.env.E2E_KEYCLOAK_DEMOEDITOR_PASSWORD!,
    keycloakDemoeditorAuthFile,
  );
});

const keycloakDemoviewerAuthFile = path.join(authDir, 'keycloak-demoviewer.json');
setup('Keycloak Demoviewer Login', async ({ page }, testInfo) => {
  testInfo.setTimeout(5 * 60 * 1000);
  if (reuseStoredAuthState(keycloakDemoviewerAuthFile, 'keycloak-demoviewer')) return;
  await keycloakLogin(
    page,
    'demoviewer',
    process.env.E2E_KEYCLOAK_DEMOVIEWER_PASSWORD!,
    keycloakDemoviewerAuthFile,
  );
});
