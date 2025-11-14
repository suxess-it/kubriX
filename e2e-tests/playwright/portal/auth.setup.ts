import { test, expect } from '@playwright/test';
import path from 'path';

test('authenticate via GitHub and save state', async ({ page, context }) => {
  await page.goto('https://backstage.127-0-0-1.nip.io/');

  // Open GitHub login popup
  const popupPromise = page.waitForEvent('popup');
  await page
    .getByRole('button', { name: /GitHub/i }) // adjust to your real accessible name
    .click();
  const githubPage = await popupPromise;

  // Fill GitHub credentials
  await githubPage.getByRole('textbox', { name: 'Username or email address' }).fill(
    process.env.E2E_TEST_GH_USERNAME!
  );
  await githubPage.getByRole('textbox', { name: 'Password' }).fill(
    process.env.E2E_TEST_GH_PASSWORD!
  );
  await githubPage.getByRole('button', { name: 'Sign in' }).click();

  // Optionally handle “Authorize” screen if it appears
  // const authorizeButton = githubPage.getByRole('button', { name: 'Authorize' });
  // if (await authorizeButton.isVisible()) {
  //   await authorizeButton.click();
  // }

  // Wait for the main app to reflect that we are logged in
  // (Replace selector/text with something real from your Backstage instance)
  await page.waitForLoadState('networkidle');
  await expect(
    page.getByText(/signed in as/i) // or some avatar / profile element
  ).toBeVisible();

  // Save authenticated storage state
  const storagePath = path.join(__dirname, 'auth-state.json');
  await context.storageState({ path: storagePath });
});