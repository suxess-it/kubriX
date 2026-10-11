import { test, expect } from '@playwright/test';
import path from 'path';
import fs from "fs";

const authDir = path.join(__dirname, '../.auth');
const kargoAuthFile = path.join(authDir, 'kargo.json');
const BASE_DOMAIN = process.env.E2E_BASE_DOMAIN ?? '127-0-0-1.nip.io';
test.use({ storageState: kargoAuthFile });

test('Kargo Check', async ({ page }) => {
  await page.goto(`https://kargo.${BASE_DOMAIN}/`);
  await expect(page.getByRole('complementary')).toContainText('Logout');
});
