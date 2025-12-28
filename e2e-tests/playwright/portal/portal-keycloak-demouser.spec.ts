// @ts-check
const { test, expect } = require("@playwright/test");
import path from 'path';
import fs from "fs";

const authDir = path.join(__dirname, '../.auth');
const keycloakDemouserAuthFile = path.join(authDir, 'keycloak-demouser.json');
test.use({ storageState: keycloakDemouserAuthFile });

test('Keycloak Demouser Login', async ({ page }) => {
  
  await page.goto("https://backstage.127-0-0-1.nip.io/");

  await expect(page).toHaveTitle(/kubriX OSS/);

  // Open Keycloak Login
  // const popupPromise = page.waitForEvent('popup');
  // await page.getByRole('listitem').filter({ hasText: 'Keycloak OIDCSign in with' }).getByRole('button').click();
  // const page1 = await popupPromise;
  
  await expect(page.getByRole('heading', { name: 'Welcome to kubriX' })).toBeVisible();
  await expect(page.getByRole('link', { name: 'RBAC' })).not.toBeVisible();
  await expect(page.getByRole('link', { name: 'RBAC' })).toBeHidden();


  // logout
  await page.getByTestId('sidebar-root').getByRole('link', { name: 'Settings' }).click();
  await page.getByTestId('user-settings-menu').click();
  await page.getByTestId('sign-out').click();
});
