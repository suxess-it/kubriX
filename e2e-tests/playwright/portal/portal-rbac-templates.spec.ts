import { test, expect, type Page } from '@playwright/test';
import path from 'path';

const BASE_DOMAIN = process.env.E2E_BASE_DOMAIN ?? '127-0-0-1.nip.io';
const authDir = path.join(__dirname, '../.auth');

// Templates under test
const TEMPLATE_SHARED    = 'Documentation Template';           // owner: kubrix, annotation: kubrix.io/visibility: shared
const TEMPLATE_EDITORS   = 'Documentation Template (editors)'; // owner: editors
const TEMPLATE_VIEWERS   = 'Documentation Template (viewers)'; // owner: viewers
const TEMPLATE_ADMINS    = 'Documentation Template (platform-admins)'; // owner: admins

async function gotoCreatePage(page: Page) {
  await page.goto(`https://backstage.${BASE_DOMAIN}/create`);
  // Wait for the template list to load
  await page.waitForLoadState('networkidle');
}

async function expectTemplateVisible(page: Page, templateTitle: string) {
  await expect(
    page.getByRole('heading', { name: templateTitle, exact: true }),
    `Expected template "${templateTitle}" to be visible`
  ).toBeVisible({ timeout: 10_000 });
}

async function expectTemplateHidden(page: Page, templateTitle: string) {
  await expect(
    page.getByRole('heading', { name: templateTitle, exact: true }),
    `Expected template "${templateTitle}" to be hidden`
  ).toBeHidden({ timeout: 10_000 });
}

async function logout(page: Page) {
  await page.getByTestId('sidebar-root').getByRole('link', { name: 'Settings' }).click();
  await page.getByTestId('user-settings-menu').click();
  await page.getByTestId('sign-out').click();
}

// ── viewers (demoviewer) ───────────────────────────────────────────────────────

test.describe('RBAC template visibility — viewers (demoviewer)', () => {
  test.use({ storageState: path.join(authDir, 'keycloak-demoviewer.json') });

  test('sees shared template', async ({ page }) => {
    await gotoCreatePage(page);
    await expectTemplateVisible(page, TEMPLATE_SHARED);
  });

  test('sees viewers-owned template', async ({ page }) => {
    await gotoCreatePage(page);
    await expectTemplateVisible(page, TEMPLATE_VIEWERS);
  });

  test('does NOT see editors-owned template', async ({ page }) => {
    await gotoCreatePage(page);
    await expectTemplateHidden(page, TEMPLATE_EDITORS);
  });

  test('does NOT see admins-owned template', async ({ page }) => {
    await gotoCreatePage(page);
    await expectTemplateHidden(page, TEMPLATE_ADMINS);
  });

  test('does NOT see Choose action button on shared template', async ({ page }) => {
    await gotoCreatePage(page);
    await expect(
      page.getByRole('heading', { name: TEMPLATE_SHARED, exact: true })
        .locator('xpath=ancestor::*[2]')
        .getByRole('button', { name: 'Choose' }),
      'Expected Choose button to be hidden for viewers'
    ).toBeHidden({ timeout: 10_000 });
  });
});

// ── editors (demoeditor) ────────────────────────────────────────────────────────

test.describe('RBAC template visibility — editors (demoeditor)', () => {
  test.use({ storageState: path.join(authDir, 'keycloak-demoeditor.json') });

  test('sees shared template', async ({ page }) => {
    await gotoCreatePage(page);
    await expectTemplateVisible(page, TEMPLATE_SHARED);
  });

  test('sees editors-owned template', async ({ page }) => {
    await gotoCreatePage(page);
    await expectTemplateVisible(page, TEMPLATE_EDITORS);
  });

  test('does NOT see viewers-owned template', async ({ page }) => {
    await gotoCreatePage(page);
    await expectTemplateHidden(page, TEMPLATE_VIEWERS);
  });

  test('does NOT see admins-owned template', async ({ page }) => {
    await gotoCreatePage(page);
    await expectTemplateHidden(page, TEMPLATE_ADMINS);
  });

  test('can open editors template and sees Choose action button', async ({ page }) => {
    await gotoCreatePage(page);
    await page.getByRole('heading', { name: TEMPLATE_EDITORS, exact: true })
      .locator('xpath=ancestor::*[2]')
      .getByRole('button', { name: 'Choose' })
      .click();
    await expect(page.getByText('Provide documentation details', { exact: true }).first()).toBeVisible();
  });
});

// ── admins (demoadmin) — superuser, sees everything ───────────────────────────

test.describe('RBAC template visibility — admins (demoadmin)', () => {
  test.use({ storageState: path.join(authDir, 'keycloak-demoadmin.json') });

  test('sees shared template', async ({ page }) => {
    await gotoCreatePage(page);
    await expectTemplateVisible(page, TEMPLATE_SHARED);
  });

  test('sees editors-owned template', async ({ page }) => {
    await gotoCreatePage(page);
    await expectTemplateVisible(page, TEMPLATE_EDITORS);
  });

  test('sees viewers-owned template', async ({ page }) => {
    await gotoCreatePage(page);
    await expectTemplateVisible(page, TEMPLATE_VIEWERS);
  });

  test('sees admins-owned template', async ({ page }) => {
    await gotoCreatePage(page);
    await expectTemplateVisible(page, TEMPLATE_ADMINS);
  });

  test('can open admins template and sees Choose action button', async ({ page }) => {
    await gotoCreatePage(page);
    await page.getByRole('heading', { name: TEMPLATE_ADMINS, exact: true })
      .locator('xpath=ancestor::*[2]')
      .getByRole('button', { name: 'Choose' })
      .click();
    await expect(page.getByText('Provide documentation details', { exact: true }).first()).toBeVisible();
  });
});