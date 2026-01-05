import { test, expect } from '@playwright/test';
import path from 'path';
import fs from "fs";

const authDir = path.join(__dirname, '../.auth');
const grafanaAuthFile = path.join(authDir, 'grafana.json');
test.use({ storageState: grafanaAuthFile });

test('Grafana Loki Logs', async ({ page }) => {
  await page.goto("https://grafana.127-0-0-1.nip.io/a/grafana-lokiexplore-app/explore/namespace/grafana/logs?from=now-3h&to=now&var-ds=loki&var-filters=namespace%7C%3D%7Cgrafana&patterns=%5B%5D&var-lineFormat=&var-fields=logger%7C%3D%7C__CV%CE%A9__%7B%22parser%22:%22logfmt%22__gfc__%22value%22:%22settings%22%7D,settings&var-levels=&var-metadata=&var-jsonFields=&var-patterns=&var-lineFilterV2=&var-lineFilters=caseInsensitive,0%7C__gfp__%3D%7CStarting%20Grafana&timezone=browser&var-all-fields=logger%7C%3D%7C__CV%CE%A9__%7B%22parser%22:%22logfmt%22__gfc__%22value%22:%22settings%22%7D,settings&displayedFields=%5B%5D&urlColumns=%5B%5D&visualizationType=%22logs%22&prettifyLogMessage=false&sortOrder=%22Descending%22&wrapLogMessage=false");

  await expect
  .poll(async () => {
    const text = await page.getByText('Total:').textContent();
    return Number(text?.match(/\d+/)?.[0]);
  })
  .toBeGreaterThan(0);
});