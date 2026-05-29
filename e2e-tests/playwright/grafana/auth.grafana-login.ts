import { test as setup, expect, Browser } from '@playwright/test';
import path from 'path';
import fs from "fs";
import { reuseStoredAuthState } from '../utils/auth-cache';

const authDir = path.join(__dirname, '../.auth');
fs.mkdirSync(authDir, { recursive: true });
const grafanaAuthFile = path.join(authDir, 'grafana.json');
const BASE_DOMAIN = process.env.E2E_BASE_DOMAIN ?? '127-0-0-1.nip.io';

async function storedGrafanaAuthStillWorks(browser: Browser): Promise<boolean> {
  if (!reuseStoredAuthState(grafanaAuthFile, 'grafana-admin')) {
    return false;
  }

  const context = await browser.newContext({
    ignoreHTTPSErrors: true,
    storageState: grafanaAuthFile,
  });
  const page = await context.newPage();

  try {
    await page.goto(`https://grafana.${BASE_DOMAIN}/`, { waitUntil: 'domcontentloaded' });
    await page.waitForLoadState('networkidle', { timeout: 10_000 }).catch(() => {});
    return !page.url().includes('/login');
  } finally {
    await context.close();
  }
}

setup('authenticate', async ({ page, browser }, testInfo) => {
  testInfo.setTimeout(3 * 60 * 1000);
  if (await storedGrafanaAuthStillWorks(browser)) return;

  const MAX_RETRIES = 3;
  const RETRY_WAIT_MS = 15_000;

  for (let attempt = 1; attempt <= MAX_RETRIES; attempt++) {
    console.log(`[Grafana login] attempt ${attempt}/${MAX_RETRIES}`);

    await page.goto(`https://grafana.${BASE_DOMAIN}/login`, { waitUntil: 'domcontentloaded' });
    await page.locator('input[name="user"]').fill('admin');
    await page.locator('input[name="password"]').fill(process.env.E2E_GRAFANA_ADMIN_PASSWORD!);
    await page.locator('button[type="submit"]').click();

    try {
      await page.waitForURL(`https://grafana.${BASE_DOMAIN}/`, { timeout: 20_000 });
      await page.waitForLoadState('networkidle', { timeout: 10_000 }).catch(() => {});
    } catch {
      console.warn(`[Grafana login] attempt ${attempt}: did not reach home. URL: ${page.url()}`);
      if (attempt === MAX_RETRIES) throw new Error(`Grafana login failed after ${MAX_RETRIES} attempts. Last URL: ${page.url()}`);
      await page.waitForTimeout(RETRY_WAIT_MS);
      continue;
    }

    // Verify the session is actually valid before saving it
    const userResp = await page.context().request.get(`https://grafana.${BASE_DOMAIN}/api/user`).catch(() => null);
    if (!userResp || !userResp.ok()) {
      console.warn(`[Grafana login] attempt ${attempt}: session check failed (status ${userResp?.status() ?? 'no response'})`);
      if (attempt === MAX_RETRIES) throw new Error(`Grafana login succeeded but session is not valid after ${MAX_RETRIES} attempts`);
      await page.waitForTimeout(RETRY_WAIT_MS);
      continue;
    }

    await page.context().storageState({ path: grafanaAuthFile });
    console.log(`[Grafana login] attempt ${attempt}: success`);
    return;
  }
});
