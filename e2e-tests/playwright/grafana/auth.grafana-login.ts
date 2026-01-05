import { test as setup, expect } from '@playwright/test';
import path from 'path';
import fs from "fs";

const authDir = path.join(__dirname, '../.auth');
fs.mkdirSync(authDir, { recursive: true });
const grafanaAuthFile = path.join(authDir, 'grafana.json');

setup('authenticate', async ({ page }) => {
  await page.goto('https://grafana.127-0-0-1.nip.io/login');
  await page.locator('input[name="user"]').fill('admin');
  await page.locator('input[name="password"]').fill(process.env.E2E_GRAFANA_ADMIN_PASSWORD!);
  await page.locator('button[type="submit"]').click();

  await page.waitForURL('https://grafana.127-0-0-1.nip.io/');
  await page.context().storageState({ path: grafanaAuthFile });
});
