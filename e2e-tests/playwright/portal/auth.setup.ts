import { test } from '@playwright/test';
import fs from 'fs';
import path from 'path';

test('authenticate via GitHub and save state', async ({ page, context }) => {
  await page.goto('https://backstage.127-0-0-1.nip.io/');

  const page1Promise = page.waitForEvent('popup');
  await page.getByRole('listitem').filter({ hasText: 'GitHubSign in using' }).getByRole('button').click();
  const page1 = await page1Promise;
  await page1.getByRole('textbox', { name: 'Username or email address' }).click();
  await page1.getByRole('textbox', { name: 'Username or email address' }).fill(process.env.E2E_TEST_GH_USERNAME!);
  await page1.getByRole('textbox', { name: 'Password' }).click();
  await page1.getByRole('textbox', { name: 'Password' }).fill(process.env.E2E_TEST_GH_PASSWORD!);
  await page1.getByRole('button', { name: 'Sign in' }).click();

});
