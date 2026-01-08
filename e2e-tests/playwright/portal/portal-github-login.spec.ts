// @ts-check
import { test, expect } from '@playwright/test';
import path from 'path';
import fs from "fs";

const authDir = path.join(__dirname, '../.auth');
const ghAuthFile = path.join(authDir, 'github.json');
test.use({ storageState: ghAuthFile });

test("Team Onboarding with kubrixBot Github user", async ({ page }) => {
  //await page.goto("https://backstage.127-0-0-1.nip.io/");
  //await page.getByRole('listitem').filter({ hasText: 'GitHubSign in using' }).getByRole('button').click();
  await page.goto("https://backstage.127-0-0-1.nip.io/create/templates/default/team-onboarding");

  await page.getByRole('button', { name: 'Next' }).click();
  const page1Promise = page.waitForEvent('popup');
  await page.getByRole('button', { name: 'Log in' }).click();

  const popup = await page.waitForEvent('popup'); // your page1Promise
  const authorize = popup.getByRole('button', { name: 'Authorize kubriX-demo' });

  await Promise.race([
    // Case A: button shows up -> click it
    authorize.waitFor({ state: 'visible', timeout: 5000 }).then(() => authorize.click()),

    // Case B: popup closes automatically -> do nothing
    popup.waitForEvent('close')
  ]);

  // optional: make sure the popup is gone before continuing
  if (!popup.isClosed()) await popup.close();

  await page.getByRole('button', { name: 'Review' }).click();
  await page.getByRole('button', { name: 'Create' }).click();


});