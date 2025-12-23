// @ts-check
const { test, expect } = require("@playwright/test");

test("Github Login", async ({ page }) => {
  await page.goto("https://backstage.127-0-0-1.nip.io/");

  await expect(page).toHaveTitle(/kubriX OSS/);

  // Open GitHub login popup
  const popupPromise = page.waitForEvent('popup');
  await page.getByRole('listitem').filter({ hasText: 'GitHubSign in using' }).getByRole('button').click();
  const githubPage = await popupPromise;
  // Optionally handle “Authorize” screen if it appears
  // const authorizeButton = githubPage.getByRole('button', { name: 'Authorize' });
  // if (await authorizeButton.isVisible()) {
  //  await authorizeButton.click();
  // }
  await githubPage.close();
  await expect(page.getByRole('heading', { name: 'Welcome to kubriX' })).toBeVisible();
  await page.getByTestId('sidebar-root').getByRole('link', { name: 'Settings' }).click();
  await page.getByTestId('user-settings-menu').click();
  await page.getByTestId('sign-out').click();
});


test('Keycloak Demouser Login', async ({ page }) => {
  await page.goto("https://backstage.127-0-0-1.nip.io/");

  await expect(page).toHaveTitle(/kubriX OSS/);

  // Open Keycloak Login
  const popupPromise = page.waitForEvent('popup');
  await page.getByRole('listitem').filter({ hasText: 'Keycloak OIDCSign in with' }).getByRole('button').click();
  const page1 = await popupPromise;
  await page1.getByRole('textbox', { name: 'Username' }).click();
  await page1.getByRole('textbox', { name: 'Username' }).fill('demoadmin');
  await page1.getByRole('textbox', { name: 'Password' }).click();
  await page1.getByRole('textbox', { name: 'Password' }).fill(process.env.E2E_KEYCLOAK_DEMOADMIN_PASSWORD!);
  await page1.getByRole('button', { name: 'Sign In' }).click();
  await page1.close();
  await expect(page.getByRole('heading', { name: 'Welcome to kubriX' })).toBeVisible();
  await page.getByTestId('sidebar-root').getByRole('link', { name: 'Settings' }).click();
  await page.getByTestId('user-settings-menu').click();
  await page.getByTestId('sign-out').click();
});
