// @ts-check
const { test, expect } = require("@playwright/test");
import path from 'path';
import fs from "fs";

const BASE_DOMAIN = process.env.E2E_BASE_DOMAIN ?? '127-0-0-1.nip.io';

const authDir = path.join(__dirname, '../.auth');
const keycloakDemoeditorAuthFile = path.join(authDir, 'keycloak-demoeditor.json');
test.use({ storageState: keycloakDemoeditorAuthFile });

test('Keycloak Demoeditor Login', async ({ page }) => {

  await page.goto(`https://backstage.${BASE_DOMAIN}/`);

  await expect(page).toHaveTitle(/kubriX OSS/);

  // Open Keycloak Login
  // const popupPromise = page.waitForEvent('popup');
  // await page.getByRole('listitem').filter({ hasText: 'Keycloak OIDCSign in with' }).getByRole('button').click();
  // const page1 = await popupPromise;
  
  await expect(page.getByRole('heading', { name: 'Welcome to kubriX' })).toBeVisible();
  await expect(page.getByRole('link', { name: 'RBAC' })).not.toBeVisible();
  await expect(page.getByRole('link', { name: 'RBAC' })).toBeHidden();

  // Check that the Create button is visible in the catalog for editors
  await page.goto(`https://backstage.${BASE_DOMAIN}/catalog`);
  await expect(page.getByRole('link', { name: 'Create' })).toBeVisible();

  // Check that Choose buttons are visible on the create page for editors
  await page.goto(`https://backstage.${BASE_DOMAIN}/create`);
  await expect(page.getByRole('button', { name: 'Choose' }).first()).toBeVisible();

  // logout
  await page.getByTestId('sidebar-root').getByRole('link', { name: 'Settings' }).click();
  await page.getByTestId('user-settings-menu').click();
  await page.getByTestId('sign-out').click();
});
