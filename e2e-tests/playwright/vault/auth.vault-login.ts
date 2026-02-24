import { test as setup, expect } from '@playwright/test';
import path from 'path';
import fs from "fs";

const authDir = path.join(__dirname, '../.auth');
fs.mkdirSync(authDir, { recursive: true });
const vaultAuthFile = path.join(authDir, 'vault.json');

setup('authenticate', async ({ page }) => {
  await page.goto('https://vault.127-0-0-1.nip.io/');
  await page.locator('input[name="token"]').waitFor();
  await page.locator('input[name="token"]').fill(process.env.E2E_VAULT_ROOT_TOKEN!);
  await page.locator('#auth-submit').click();

  await page.waitForURL('https://vault.127-0-0-1.nip.io/ui/vault/secrets**');
  await page.context().storageState({ path: vaultAuthFile });
});
