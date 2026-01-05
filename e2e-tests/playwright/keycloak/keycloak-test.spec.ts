import { test, expect } from '@playwright/test';
import path from 'path';
import fs from "fs";

const authDir = path.join(__dirname, '../.auth');
const keycloakAuthFile = path.join(authDir, 'keycloak.json');
test.use({ storageState: keycloakAuthFile });

test('Keycloak check clients', async ({ page }) => {
  await page.goto("https://keycloak.127-0-0-1.nip.io/admin/master/console/#/kubrix/clients");

  await expect(page.getByRole('link', { name: 'backstage', exact: true })).toBeVisible();
  await expect(page.getByRole('link', { name: 'vault', exact: true })).toBeVisible();
});