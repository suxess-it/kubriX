import { test as setup, expect, Page } from '@playwright/test';
import path from 'path';
import fs from 'fs';
import { reuseStoredAuthState } from '../utils/auth-cache';
import { createGithubBackstageState } from '../utils/github-auth-flow';
import { ensureGithubBackstageAuthState, ghAuthFile } from '../utils/github-auth-session';

const BASE_DOMAIN = process.env.E2E_BASE_DOMAIN ?? '127-0-0-1.nip.io';

const authDir = path.join(__dirname, '../.auth');
fs.mkdirSync(authDir, { recursive: true });

setup('Github Login', async ({ browser }, testInfo) => {
  testInfo.setTimeout(6 * 60 * 1000);
  if (reuseStoredAuthState(ghAuthFile, 'github-backstage')) {
    await ensureGithubBackstageAuthState(browser, testInfo);
    return;
  }

  await createGithubBackstageState(browser, { fullGithubLogin: true });
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
