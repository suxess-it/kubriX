import { test as setup, expect } from '@playwright/test';
import path from 'path';
import fs from "fs";

const authDir = path.join(__dirname, '../.auth');
fs.mkdirSync(authDir, { recursive: true });
const argocdAuthFile = path.join(authDir, 'argocd.json');

setup('authenticate', async ({ page }) => {
  await page.goto('https://argocd.127-0-0-1.nip.io/login?return_url=https%3A%2F%2Fargocd.127-0-0-1.nip.io%2Fapplications');
  await page.getByRole('textbox', { name: 'Username' }).click();
  await page.getByRole('textbox', { name: 'Username' }).fill('admin');
  await page.getByRole('textbox', { name: 'Password' }).click();
  await page.getByRole('textbox', { name: 'Password' }).fill(process.env.E2E_ARGOCD_ADMIN_PASSWORD!);
  await page.getByRole('button', { name: 'Sign In' }).click();

  await page.waitForURL('https://argocd.127-0-0-1.nip.io/applications');
  await page.context().storageState({ path: argocdAuthFile });
});
