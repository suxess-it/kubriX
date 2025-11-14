import { test } from '@playwright/test';
import fs from 'fs';
import path from 'path';

test('authenticate via GitHub and save state', async ({ page }) => {
  await page.goto('https://backstage.127-0-0-1.nip.io/');

  await page.getByRole('listitem').filter({ hasText: 'GitHubSign in using' }).getByRole('button').click();

  await page.getByLabel('Username or email address').fill(process.env.E2E_TEST_GH_USERNAME!);
  await page.getByLabel('Password').fill(process.env.E2E_TEST_GH_PASSWORD!);
  await page.getByRole('button', { name: 'Sign in' }).click();

  const authorizeButton = page.getByRole('button', { name: /authorize/i });
  if (await authorizeButton.isVisible().catch(() => false)) {
    await authorizeButton.click();
  }

  // Wait until you’re clearly logged in
  await page.waitForURL(/backstage.127-0-0-1.nip.io/);
  // maybe wait for some Backstage element that only shows when logged in

  const storagePath = path.join('playwright', '.auth', 'backstage.json');
  fs.mkdirSync(path.dirname(storagePath), { recursive: true });
  await page.context().storageState({ path: storagePath });
});
