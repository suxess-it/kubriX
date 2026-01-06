import { test, expect } from '@playwright/test';
import path from 'path';
import fs from "fs";

const authDir = path.join(__dirname, '../.auth');
const vaultAuthFile = path.join(authDir, 'vault.json');
test.use({ storageState: vaultAuthFile });

// since the vault root token won't get stored in the browser we will not be logged in in this test
test('Vault login page', async ({ page }) => {
  await page.goto('https://vault.127-0-0-1.nip.io/');
});