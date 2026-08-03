import { Browser, Page, TestInfo, expect } from '@playwright/test';
import fs from 'fs';
import path from 'path';
import { createGithubBackstageState } from './github-auth-flow';
import { ghAuthFile, ghAuthLockFile, githubAuthDir } from './github-auth-paths';

const BASE_DOMAIN = process.env.E2E_BASE_DOMAIN ?? '127-0-0-1.nip.io';
const AUTH_HEALTH_TTL_MS = Number(process.env.PW_GITHUB_AUTH_HEALTH_TTL_MS ?? 90_000);
const LOCK_RETRY_MS = 250;
const LOCK_TIMEOUT_MS = 4 * 60_000;
const LOCK_STALE_MS = 5 * 60_000;

export { ghAuthFile };

export type GithubAuthState =
  | 'maybe-authenticated'
  | 'login'
  | 'two-factor'
  | 'verified-device'
  | 'password-confirmation'
  | 'captcha'
  | 'challenge'
  | 'wrong-user';

export type BackstageAuthState = 'catalog' | 'sign-in' | 'auth-redirect' | 'unknown';

export type AuthValidation = {
  githubValid: boolean;
  backstageValid: boolean;
  githubState: GithubAuthState;
  backstageState: BackstageAuthState;
  finalUrl: string;
  title: string;
};

export class AuthHealthCache {
  private healthyAt = 0;

  constructor(private readonly ttlMs: number) {}

  isFresh(now = Date.now()): boolean {
    return this.healthyAt > 0 && now - this.healthyAt <= this.ttlMs;
  }

  markHealthy(now = Date.now()): void {
    this.healthyAt = now;
  }

  invalidate(): void {
    this.healthyAt = 0;
  }
}

const healthCache = new AuthHealthCache(AUTH_HEALTH_TTL_MS);

function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function fileIsNonEmpty(file: string): boolean {
  try {
    const stats = fs.statSync(file);
    return stats.isFile() && stats.size > 0;
  } catch {
    return false;
  }
}

export function classifyGithubAuthState(url: string, title: string, bodyText = ''): GithubAuthState {
  const haystack = `${url}\n${title}\n${bodyText}`.toLowerCase();

  if (haystack.includes('captcha')) return 'captcha';
  if (haystack.includes('/sessions/two-factor') || haystack.includes('/two-factor')) return 'two-factor';
  if (haystack.includes('/verified-device') || haystack.includes('verify your device')) return 'verified-device';
  if (haystack.includes('/password_confirm') || haystack.includes('confirm password')) {
    return 'password-confirmation';
  }
  if (haystack.includes('github.com/login') || haystack.includes('sign in to github')) return 'login';
  if (haystack.includes('challenge') || haystack.includes('security check')) return 'challenge';

  return 'maybe-authenticated';
}

export function classifyBackstageAuthState(
  url: string,
  title: string,
  githubSignInVisible: boolean,
  catalogVisible: boolean,
  protectedCatalogPage = false,
): BackstageAuthState {
  const lowerUrl = url.toLowerCase();
  const lowerTitle = title.toLowerCase();

  if (githubSignInVisible) return 'sign-in';
  if (lowerUrl.includes('/api/auth/') || lowerUrl.includes('/auth/github')) return 'auth-redirect';
  if ((catalogVisible || protectedCatalogPage) && lowerUrl.includes('/catalog')) return 'catalog';
  if (lowerTitle.includes('sign in')) return 'sign-in';

  return 'unknown';
}

async function removeStaleLock(lockFile: string): Promise<void> {
  try {
    const stats = fs.statSync(lockFile);
    if (Date.now() - stats.mtimeMs > LOCK_STALE_MS) {
      fs.rmSync(lockFile, { force: true });
    }
  } catch {
    // Missing or unreadable lock files are handled by the caller's next create attempt.
  }
}

export async function withFileLock<T>(lockFile: string, work: () => Promise<T>): Promise<T> {
  fs.mkdirSync(path.dirname(lockFile), { recursive: true });
  const deadline = Date.now() + LOCK_TIMEOUT_MS;
  let fd: number | undefined;

  while (fd === undefined) {
    try {
      fd = fs.openSync(lockFile, 'wx');
      fs.writeFileSync(fd, `${process.pid}\n${new Date().toISOString()}\n`);
    } catch (error: any) {
      if (error?.code !== 'EEXIST') {
        throw error;
      }
      await removeStaleLock(lockFile);
      if (Date.now() > deadline) {
        throw new Error(`Timed out waiting for auth lock ${lockFile}`);
      }
      await sleep(LOCK_RETRY_MS);
    }
  }

  try {
    return await work();
  } finally {
    fs.closeSync(fd);
    fs.rmSync(lockFile, { force: true });
  }
}

async function readSafeBodyText(page: Page): Promise<string> {
  return page.locator('body').innerText({ timeout: 2_000 }).catch(() => '');
}

async function expectedGithubUserMatches(page: Page): Promise<boolean> {
  const expected = process.env.E2E_TEST_GH_USERNAME;
  if (!expected) return true;

  const userResponse = await page
    .context()
    .request.get('https://api.github.com/user', {
      headers: {
        Accept: 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28',
      },
    })
    .catch(() => null);
  if (userResponse?.status() === 200) {
    const user = await userResponse.json().catch(() => null);
    return typeof user?.login === 'string'
      && user.login.toLowerCase() === expected.toLowerCase();
  }

  // A browser cookie session does not authenticate api.github.com.
  // Treat 401 or request failures as inconclusive and fall back
  // to browser-visible GitHub metadata below.
  if (userResponse && userResponse.status() !== 401) {
    console.warn(
      `[auth-health] GitHub user API returned ${userResponse.status()}; falling back to browser metadata`,
    );
  }

  const actual = await page
    .locator('meta[name="user-login"]')
    .first()
    .getAttribute('content')
    .catch(() => null);

  if (!actual) return true;
  return actual.toLowerCase() === expected.toLowerCase();
}

export async function validateGithubSession(page: Page): Promise<{ valid: boolean; state: GithubAuthState }> {
  await page.goto('https://github.com/settings/profile', { waitUntil: 'domcontentloaded' });
  const title = await page.title();
  const bodyText = await readSafeBodyText(page);
  let state = classifyGithubAuthState(page.url(), title, bodyText);

  if (state !== 'maybe-authenticated') {
    return { valid: false, state };
  }

  if (!(await expectedGithubUserMatches(page))) {
    state = 'wrong-user';
    return { valid: false, state };
  }

  const signIn = page.getByRole('link', { name: /sign in/i }).first();
  if (await signIn.isVisible({ timeout: 1_500 }).catch(() => false)) {
    return { valid: false, state: 'login' };
  }

  const profileForm = page.locator('form[action="/settings/profile"]').first();
  const userMenu = page
    .locator(
      'button[aria-label*="user navigation" i], button[aria-label*="profile" i], summary[aria-label*="profile" i]',
    )
    .first();

  const protectedSettingsPage =
    page.url().startsWith('https://github.com/settings/');

  const valid =
    protectedSettingsPage ||
    (await profileForm.isVisible({ timeout: 5_000 }).catch(() => false)) ||
    (await userMenu.isVisible({ timeout: 5_000 }).catch(() => false));

  return { valid, state: valid ? 'maybe-authenticated' : 'challenge' };
}

export async function validateBackstageSession(page: Page): Promise<{ valid: boolean; state: BackstageAuthState }> {
  await page.goto(`https://backstage.${BASE_DOMAIN}/catalog`, {
    waitUntil: 'domcontentloaded',
  });

  const githubSignIn = page.getByText('Sign in using GitHub', { exact: true });
  const catalogSearch = page.getByRole('textbox', { name: /search/i });
  const catalogHeading = page.getByRole('heading', { name: /catalog/i }).first();
  const githubSignInVisible = await githubSignIn.isVisible({ timeout: 3_000 }).catch(() => false);
  const catalogVisible =
    (await catalogSearch.isVisible({ timeout: 15_000 }).catch(() => false)) ||
    (await catalogHeading.isVisible({ timeout: 2_000 }).catch(() => false));
  const protectedCatalogPage =
    page.url().startsWith(`https://backstage.${BASE_DOMAIN}/catalog`);
  const state = classifyBackstageAuthState(
    page.url(),
    await page.title(),
    githubSignInVisible,
    catalogVisible,
    !githubSignInVisible && protectedCatalogPage,
  );

  return { valid: state === 'catalog', state };
}

async function attachValidationFailure(page: Page, testInfo: TestInfo | undefined, label: string): Promise<void> {
  if (!testInfo) return;

  const screenshot = await page.screenshot({ fullPage: true }).catch(() => null);
  if (screenshot) {
    await testInfo.attach(`${label}-screenshot`, {
      body: screenshot,
      contentType: 'image/png',
    });
  }

  await testInfo.attach(`${label}-diagnostics`, {
    body: JSON.stringify(
      {
        finalUrl: page.url(),
        title: await page.title().catch(() => ''),
      },
      null,
      2,
    ),
    contentType: 'application/json',
  });
}

export async function validateStoredGithubBackstageState(
  browser: Browser,
  testInfo?: TestInfo,
): Promise<AuthValidation> {
  if (!fileIsNonEmpty(ghAuthFile)) {
    return {
      githubValid: false,
      backstageValid: false,
      githubState: 'login',
      backstageState: 'unknown',
      finalUrl: 'storage-state-missing',
      title: '',
    };
  }

  const context = await browser.newContext({ storageState: ghAuthFile });
  const page = await context.newPage();

  try {
    const github = await validateGithubSession(page);
    const backstage = github.valid
      ? await validateBackstageSession(page)
      : { valid: false, state: 'unknown' as const };
    const result = {
      githubValid: github.valid,
      backstageValid: backstage.valid,
      githubState: github.state,
      backstageState: backstage.state,
      finalUrl: page.url(),
      title: await page.title(),
    };

    if (!result.githubValid || !result.backstageValid) {
      await attachValidationFailure(page, testInfo, 'github-auth-validation');
    }

    return result;
  } finally {
    await context.close();
  }
}

function logValidationResult(prefix: string, result: AuthValidation): void {
  console.log(
    `[auth-health] ${prefix}: github=${result.githubState} backstage=${result.backstageState} ` +
      `finalUrl=${result.finalUrl} title=${JSON.stringify(result.title)}`,
  );
}

export function invalidateGithubAuthHealthCache(): void {
  healthCache.invalidate();
}

async function recoverGithubBackstageState(browser: Browser, validation: AuthValidation): Promise<void> {
  if (validation.githubValid && !validation.backstageValid) {
    console.log('[auth-health] GitHub session valid but Backstage session invalid; refreshing Backstage OAuth only.');
    await createGithubBackstageState(browser, { fullGithubLogin: false });
    return;
  }

  console.log('[auth-health] GitHub session invalid; refreshing GitHub login and Backstage OAuth.');
  await createGithubBackstageState(browser, { fullGithubLogin: true });
}

export async function ensureGithubBackstageAuthState(browser: Browser, testInfo?: TestInfo): Promise<void> {
  if (healthCache.isFresh()) {
    return;
  }

  fs.mkdirSync(githubAuthDir, { recursive: true });
  const initialValidation = await validateStoredGithubBackstageState(browser, testInfo);
  logValidationResult('pre-test validation', initialValidation);
  if (initialValidation.githubValid && initialValidation.backstageValid) {
    healthCache.markHealthy();
    return;
  }

  healthCache.invalidate();
  await withFileLock(ghAuthLockFile, async () => {
    const lockedValidation = await validateStoredGithubBackstageState(browser, testInfo);
    logValidationResult('locked validation', lockedValidation);
    if (lockedValidation.githubValid && lockedValidation.backstageValid) {
      healthCache.markHealthy();
      return;
    }

    await recoverGithubBackstageState(browser, lockedValidation);

    const recoveredValidation = await validateStoredGithubBackstageState(browser, testInfo);
    logValidationResult('post-recovery validation', recoveredValidation);
    expect(
      recoveredValidation.githubValid,
      `GitHub auth recovery failed; state=${recoveredValidation.githubState}; final URL=${recoveredValidation.finalUrl}; title=${recoveredValidation.title}`,
    ).toBeTruthy();
    expect(
      recoveredValidation.backstageValid,
      `Backstage auth recovery failed; state=${recoveredValidation.backstageState}; final URL=${recoveredValidation.finalUrl}; title=${recoveredValidation.title}`,
    ).toBeTruthy();
    healthCache.markHealthy();
  });
}

export async function assertStoredGithubBackstageState(browser: Browser): Promise<void> {
  const result = await validateStoredGithubBackstageState(browser);
  logValidationResult('assertion', result);

  expect(result.githubValid, `GitHub session invalid; final URL: ${result.finalUrl}`).toBeTruthy();
  expect(
    result.backstageValid,
    `Backstage GitHub session invalid; final URL: ${result.finalUrl}; title: ${result.title}`,
  ).toBeTruthy();
}

export async function assertNoBackstageAuthRedirect(page: Page, testInfo?: TestInfo): Promise<void> {
  const url = page.url();
  if (!url.includes(`backstage.${BASE_DOMAIN}`)) {
    return;
  }

  const githubSignInVisible = await page
    .getByText('Sign in using GitHub', { exact: true })
    .isVisible({ timeout: 500 })
    .catch(() => false);
  const catalogVisible = await page
    .getByRole('textbox', { name: /search/i })
    .isVisible({ timeout: 500 })
    .catch(() => false);
  const state = classifyBackstageAuthState(
    url,
    await page.title().catch(() => ''),
    githubSignInVisible,
    catalogVisible,
  );

  if (state === 'sign-in' || state === 'auth-redirect') {
    healthCache.invalidate();
    await attachValidationFailure(page, testInfo, 'auth-session-expired');
    throw new Error(
      `AUTH_SESSION_EXPIRED: Backstage redirected to ${state}; retry will start with a freshly validated GitHub auth state. Final URL: ${url}`,
    );
  }
}
