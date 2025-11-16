// @ts-check
const { test, expect } = require("@playwright/test");

test("Smoke 1 - has title", async ({ page }) => {
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
});
