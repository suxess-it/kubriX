import { test, expect } from '@playwright/test';
import path from 'path';
import fs from "fs";

const authDir = path.join(__dirname, '../.auth');
const kargoAuthFile = path.join(authDir, 'kargo.json');
test.use({ storageState: kargoAuthFile });

// since the vault root token won't get stored in the browser we will not be logged in in this test
test('Kargo Version Check', async ({ page }) => {
  await page.goto('https://kargo.127-0-0-1.nip.io/');
  await expect(page.getByRole('complementary')).toContainText(process.env.E2E_KARGO_VERSION!);
});