import { test as setup, expect } from '@playwright/test';
import path from 'path';
import fs from "fs";

const authDir = path.join(__dirname, '../.auth');
fs.mkdirSync(authDir, { recursive: true });
const grafanaAuthFile = path.join(authDir, 'grafana.json');

setup('authenticate', async ({ page }) => {
  await page.goto('https://grafana.127-0-0-1.nip.io/');
  await page.getByRole('textbox', { name: 'user' }).click();
  await page.getByRole('textbox', { name: 'user' }).fill('admin');
  await page.getByRole('textbox', { name: 'password' }).click();
  await page.getByRole('textbox', { name: 'password' }).fill(process.env.E2E_GRAFANA_ADMIN_PASSWORD!);
  await page.getByRole('button', { name: 'submit' }).click();

  await page.waitForURL('https://grafana.127-0-0-1.nip.io/');
  await page.context().storageState({ path: grafanaAuthFile });
});
