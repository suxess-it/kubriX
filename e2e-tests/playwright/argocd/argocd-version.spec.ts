import { test, expect } from '@playwright/test';
import path from 'path';
import fs from "fs";

const authDir = path.join(__dirname, '../.auth');
const argocdAuthFile = path.join(authDir, 'argocd.json');
const BASE_DOMAIN = process.env.E2E_BASE_DOMAIN ?? '127-0-0-1.nip.io';
test.use({ storageState: argocdAuthFile });

test('ArgoCD Version Info', async ({ page }) => {
  await page.goto(`https://argocd.${BASE_DOMAIN}/api/version`)
  await expect(page.locator('pre')).toContainText(process.env.E2E_ARGOCD_VERSION!);
});
