import { Browser, Page, expect } from '@playwright/test';
import fs from 'fs';
import path from 'path';
import * as OTPAuth from 'otpauth';
import { ghAuthFile } from './github-auth-paths';

const BASE_DOMAIN = process.env.E2E_BASE_DOMAIN ?? '127-0-0-1.nip.io';

function requireEnv(name: string): string {
  const value = process.env[name];
  if (!value) {
    throw new Error(`${name} must be set to run E2E tests`);
  }
  return value;
}

function githubTotp(): OTPAuth.TOTP {
  return new OTPAuth.TOTP({
    issuer: 'kubriX',
    label: 'GitHub',
    algorithm: 'SHA1',
    digits: 6,
    period: 30,
    secret: requireEnv('E2E_TEST_GITHUB_OTP'),
  });
}

async function getFreshTotp(totp: OTPAuth.TOTP): Promise<string> {
  const remainingMs = totp.remaining();

  if (remainingMs < 5_000) {
    const waitMs = remainingMs + 1_500;
    console.log(`[TOTP] Near window end, waiting ${waitMs}ms for a fresh code...`);
    await new Promise((resolve) => setTimeout(resolve, waitMs));
  }

  return totp.generate();
}

async function waitForGithubLoginResult(page: Page, errorText: string): Promise<'success' | 'error'> {
  const deadline = Date.now() + 15_000;

  while (Date.now() < deadline) {
    if (page.url() === 'https://github.com/') {
      return 'success';
    }

    if (await page.getByText(errorText).isVisible().catch(() => false)) {
      return 'error';
    }

    await page.waitForTimeout(250);
  }

  throw new Error(`Timed out waiting for GitHub login result. Final URL: ${page.url()}`);
}

export async function addGithubAntiBotInitScript(page: Page): Promise<void> {
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

export async function completeGithubBackstagePopup(page: Page): Promise<void> {
  const maxPopupAttempts = 2;
  const retryWaitMs = 5_000;

  for (let attempt = 1; attempt <= maxPopupAttempts; attempt += 1) {
    const githubSignIn = page
      .getByRole('listitem')
      .filter({ hasText: 'GitHubSign in using' })
      .getByRole('button');
    await githubSignIn.waitFor({
      state: 'visible',
      timeout: 15_000,
    });

    const popupPromise = page.waitForEvent('popup', {
      timeout: 15_000,
    });

    await githubSignIn.click();

    const popup = await popupPromise;
    await popup.waitForLoadState('domcontentloaded');

    const popupUrl = popup.url();
    console.log(`[GitHub popup] attempt ${attempt}/${maxPopupAttempts} url:`, popupUrl);

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
      await popup.evaluate(() => {
        const form = document.querySelector('form') as HTMLFormElement;
        if (!form.querySelector('input[name="authorize"]')) {
          const input = Object.assign(document.createElement('input'), {
            type: 'hidden',
            name: 'authorize',
            value: '1',
          });
          form.appendChild(input);
        }
        form.submit();
      });
      await Promise.race([
        popup.waitForEvent('close', { timeout: 20_000 }),
        popup.waitForURL('**/api/auth/github/handler/frame', { timeout: 20_000 }),
      ]);
      if (!popup.isClosed()) {
        await popup.close().catch(() => {});
      }
      await expect(page.getByRole('heading', { name: 'Welcome to kubriX' })).toBeVisible({
        timeout: 15_000,
      });
      return;
    } catch (error) {
      console.warn(`[GitHub popup] attempt ${attempt} did not complete normally:`, error);

      if (!popup.isClosed()) {
        await popup.close().catch(() => {});
      }

      if (attempt === maxPopupAttempts) {
        throw error;
      }

      await page.waitForLoadState('domcontentloaded', { timeout: 15_000 }).catch(() => {});
      await page.reload({ waitUntil: 'domcontentloaded' });
      await expect(page).toHaveTitle(/kubriX/);
      await page.waitForTimeout(retryWaitMs);
    }
  }
}

export async function loginToGithub(page: Page): Promise<void> {
  const totp = githubTotp();

  await addGithubAntiBotInitScript(page);

  await page.goto('https://github.com/login');
  await page.getByLabel('Username or email address').fill(requireEnv('E2E_TEST_GH_USERNAME'));
  await page.getByLabel('Password').fill(requireEnv('E2E_TEST_GH_PASSWORD'));
  await page.getByRole('button', { name: 'Sign in', exact: true }).click();

  const totpInput = page.getByPlaceholder('XXXXXX');
  const errorText = 'The two-factor code you entered has already been used or is too old to be used.';
  const maxRetries = 3;

  for (let attempt = 1; attempt <= maxRetries; attempt += 1) {
    await totpInput.waitFor({ state: 'visible' });

    const code = await getFreshTotp(totp);
    await totpInput.fill(code);

    const result = await waitForGithubLoginResult(page, errorText);
    if (result === 'success') {
      console.log('[GitHub login] Login successful');
      return;
    }

    if (attempt === maxRetries) {
      throw new Error('TOTP failed too many times');
    }

    console.warn(`[GitHub login] TOTP expired, retrying in 60 seconds (attempt ${attempt})`);
    await totpInput.fill('');
    await page.waitForTimeout(60_000);
  }
}

export async function loginToBackstageWithGithub(page: Page): Promise<void> {
  await addGithubAntiBotInitScript(page);
  await page.goto(`https://backstage.${BASE_DOMAIN}/`);
  await expect(page).toHaveTitle(/kubriX/);
  await completeGithubBackstagePopup(page);
  await expect(page.getByRole('heading', { name: 'Welcome to kubriX' })).toBeVisible();
}

export async function createGithubBackstageState(
  browser: Browser,
  options: { fullGithubLogin: boolean; authFile?: string } = { fullGithubLogin: true },
): Promise<void> {
  const authFile = options.authFile ?? ghAuthFile;
  fs.mkdirSync(path.dirname(authFile), { recursive: true });

  const context = await browser.newContext(
    options.fullGithubLogin ? undefined : { storageState: authFile },
  );
  const page = await context.newPage();
  const tmpAuthFile = `${authFile}.${process.pid}.${Date.now()}.tmp`;

  try {
    if (options.fullGithubLogin) {
      await loginToGithub(page);
    }

    await loginToBackstageWithGithub(page);
    await context.storageState({ path: tmpAuthFile });
    fs.renameSync(tmpAuthFile, authFile);
  } finally {
    if (fs.existsSync(tmpAuthFile)) {
      fs.rmSync(tmpAuthFile, { force: true });
    }
    await context.close();
  }
}
