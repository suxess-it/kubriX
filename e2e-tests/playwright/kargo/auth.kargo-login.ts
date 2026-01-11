import { test as setup, expect } from '@playwright/test';
import path from 'path';
import fs from "fs";

const authDir = path.join(__dirname, '../.auth');
fs.mkdirSync(authDir, { recursive: true });
const kargoAuthFile = path.join(authDir, 'kargo.json');

setup('authenticate', async ({ page }) => {
  await page.goto('https://kargo.127-0-0-1.nip.io/login');
  await page.locator('input[name="password"]').click();
  await page.locator('input[name="password"]').fill(process.env.E2E_KARGO_ADMIN_PASSWORD!);
  await page.getByRole('button', { name: 'Login', exact: true }).click();

  await page.waitForURL('https://kargo.127-0-0-1.nip.io/');
  await page.context().storageState({ path: kargoAuthFile });
});
