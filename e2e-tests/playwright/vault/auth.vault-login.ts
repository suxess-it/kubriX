import { test as setup, expect } from '@playwright/test';
import path from 'path';
import fs from "fs";

const authDir = path.join(__dirname, '../.auth');
fs.mkdirSync(authDir, { recursive: true });
const vaultAuthFile = path.join(authDir, 'vault.json');
const BASE_DOMAIN = process.env.E2E_BASE_DOMAIN ?? '127-0-0-1.nip.io';

setup('authenticate', async ({ page }) => {
  await page.goto(`https://vault.${BASE_DOMAIN}/`);
  await page.getByRole('textbox', { name: 'Token' }).click();
  await page.getByRole('textbox', { name: 'Token' }).fill(process.env.E2E_VAULT_ROOT_TOKEN!);
  await page.getByRole('button', { name: 'Sign in' }).click();

  await page.waitForURL(`https://vault.${BASE_DOMAIN}/ui/vault/dashboard`);
  await page.context().storageState({ path: vaultAuthFile });
});
