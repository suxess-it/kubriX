import { test, expect } from '@playwright/test';
import path from 'path';
import fs from "fs";

const authDir = path.join(__dirname, '../.auth');
const openbaoAuthFile = path.join(authDir, 'openbao.json');
const BASE_DOMAIN = process.env.E2E_BASE_DOMAIN ?? '127-0-0-1.nip.io';
test.use({ storageState: openbaoAuthFile });

// since the openbao root token won't get stored in the browser we will not be logged in in this test
test('OpenBao login page', async ({ page }) => {
  await page.goto(`https://openbao.${BASE_DOMAIN}/`);
});
