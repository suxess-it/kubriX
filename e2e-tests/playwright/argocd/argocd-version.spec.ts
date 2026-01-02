import { test, expect } from '@playwright/test';
import path from 'path';
import fs from "fs";

const authDir = path.join(__dirname, '../.auth');
const argocdAuthFile = path.join(authDir, 'argocd.json');
test.use({ storageState: argocdAuthFile });

test('ArgoCD Version Info', async ({ page }) => {
  await page.goto('https://argocd.127-0-0-1.nip.io/api/version')
  await expect(page.locator('pre')).toContainText('"Version":"v3.2.2+8d0dde1"');
});