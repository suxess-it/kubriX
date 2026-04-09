import { test as setup, expect } from '@playwright/test';
import path from 'path';
import fs from "fs";

const authDir = path.join(__dirname, '../.auth');
fs.mkdirSync(authDir, { recursive: true });
const keycloakAuthFile = path.join(authDir, 'keycloak.json');
const BASE_DOMAIN = process.env.E2E_BASE_DOMAIN ?? '127-0-0-1.nip.io';

setup('authenticate', async ({ page }) => {
  await page.goto(`https://keycloak.${BASE_DOMAIN}/`);
  await page.getByRole('textbox', { name: 'username' }).click();
  await page.getByRole('textbox', { name: 'username' }).fill('admin');
  await page.getByRole('textbox', { name: 'password' }).click();
  await page.getByRole('textbox', { name: 'password' }).fill(process.env.E2E_KEYCLOAK_ADMIN_PASSWORD!);
  await page.getByRole('button', { name: 'Sign In' }).click();

  await page.waitForURL(`https://keycloak.${BASE_DOMAIN}/admin/master/console/`);
  await page.context().storageState({ path: keycloakAuthFile });
});
