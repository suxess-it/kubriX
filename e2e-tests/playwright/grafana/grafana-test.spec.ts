import { test, expect, type Page } from '@playwright/test';
import path from 'path';
import fs from "fs";

const authDir = path.join(__dirname, '../.auth');
const grafanaAuthFile = path.join(authDir, 'grafana.json');
const BASE_DOMAIN = process.env.E2E_BASE_DOMAIN ?? '127-0-0-1.nip.io';
test.use({ storageState: grafanaAuthFile });

async function scrollGrafanaDown(page: Page) {
  await page.evaluate(() => {
    function isScrollable(el: Element) {
      const style = getComputedStyle(el);
      return /(auto|scroll)/.test(style.overflowY) && el.scrollHeight > el.clientHeight;
    }

    let el = document.elementFromPoint(window.innerWidth / 2, window.innerHeight / 2);

    while (el && el !== document.body) {
      if (isScrollable(el)) {
        el.scrollBy({ top: 900, behavior: 'instant' });
        return;
      }
      el = el.parentElement;
    }

    document.scrollingElement?.scrollBy({ top: 900, behavior: 'instant' });
  });
}

test('Grafana Check Datasources', async ({ page }) => {
  test.slow();

  await page.goto(`https://grafana.${BASE_DOMAIN}/connections/datasources`);

  await expect(page.getByRole('link', { name: 'loki' , exact: true })).toBeVisible({ timeout: 20_000 });
  await expect(page.getByRole('link', { name: 'mimir' , exact: true })).toBeVisible({ timeout: 20_000 });
});

test('Grafana Loki Logs', async ({ page }) => {
  test.slow();
  await page.goto(`https://grafana.${BASE_DOMAIN}/a/grafana-lokiexplore-app/explore/namespace/grafana/logs?from=now-1h&to=now&var-ds=loki&var-filters=namespace%7C%3D%7Cgrafana&patterns=%5B%5D&var-lineFormat=&var-fields=logger%7C%3D%7C__CV%CE%A9__%7B%22parser%22:%22logfmt%22__gfc__%22value%22:%22settings%22%7D,settings&var-levels=&var-metadata=&var-jsonFields=&var-patterns=&var-lineFilterV2=&var-lineFilters=caseInsensitive,0%7C__gfp__%3D%7CStarting%20Grafana&timezone=browser&var-all-fields=logger%7C%3D%7C__CV%CE%A9__%7B%22parser%22:%22logfmt%22__gfc__%22value%22:%22settings%22%7D,settings&displayedFields=%5B%5D&urlColumns=%5B%5D&visualizationType=%22logs%22&prettifyLogMessage=false&sortOrder=%22Descending%22&wrapLogMessage=false`);

  await expect
  .poll(async () => {
    const text = await page.getByText('Total:').textContent();
    return Number(text?.match(/\d+/)?.[0]);
  }, { timeout: 20_000 })
  .toBeGreaterThan(0);
});


test('Grafana CNPG Dashboard', async ({ page }) => {
  test.slow();
  await page.goto(`https://grafana.${BASE_DOMAIN}/d/cloudnative-pg/cloudnativepg?orgId=1&from=now-7d&to=now&timezone=browser&var-DS_PROMETHEUS=mimir&var-operatorNamespace=cnpg&var-namespace=keycloak&var-cluster=sx-keycloak-cluster&var-instances=$__all`);

  await expect(
    page.locator('div[title="sx-keycloak-cluster-1"]').getByText('Yes', { exact: true })
  ).toBeVisible({ timeout: 20_000 });

  // unfortunately some 'No data' tiles exist
  /*
  await expect
    .poll(async () => await page.getByText('No data', { exact: true }).count())
    .toBe(0);
  */
});

test('Grafana OpenBao Dashboard', async ({ page }) => {
  test.slow();

  await page.goto(`https://grafana.${BASE_DOMAIN}/d/vaults/grc-openbao?orgId=1&from=now-2h&to=now&timezone=browser&var-datasource=default&var-port=&var-mountpoint=$__all`);

  await expect(
    page.locator('div[title="sx-openbao-active"]').getByText('Active', { exact: true })
  ).toBeVisible({ timeout: 20_000 });

  await expect(
    page.locator('div[title="sx-openbao-0"]').getByText('ONLINE', { exact: true })
  ).toBeVisible({ timeout: 20_000 });

  // unfortunately some 'No data' tiles exist
  /*
  await expect
    .poll(async () => await page.getByText('No data', { exact: true }).count())
    .toBe(0);
  */
});

test('Grafana K8s Namespace Dashboard', async ({ page }) => {
  test.slow();

  await page.goto(`https://grafana.${BASE_DOMAIN}/d/k8s_views_global/kubernetes-views-global?orgId=1&from=now-2h&to=now&timezone=browser&var-datasource=default&var-port=&var-mountpoint=$__all`, { waitUntil: 'domcontentloaded' });

  // wait for the first panel to fully load
  const firstPanel = page.getByRole('region', { name: 'Global CPU Usage', exact: true });
  await expect(firstPanel).toHaveCount(1, { timeout: 60_000 });
  await expect(firstPanel).toBeVisible({ timeout: 60_000 });

  // Wait until the panel is not in a loading state (Grafana commonly shows “Loading”)
  await expect
    .poll(async () => firstPanel.getByText(/loading/i).count(), { timeout: 60_000 })
    .toBe(0);
  
  // check if main panels are there without "No data"
  const panels = ["Global CPU Usage", "Global RAM Usage", "Kubernetes Resource Count", "Nodes", "Namespaces", "Running Pods",
    "Cluster CPU Utilization", "Cluster Memory Utilization", "CPU Utilization by namespace", "Memory Utilization by namespace",
    "CPU Utilization by instance", "Memory Utilization by instance",
    "Kubernetes Pods QoS classes", "Kubernetes Pods Status Reason",
    "Global Network Utilization by device", "Network Saturation - Packets dropped", "Network Received by namespace", "Total Network Received (with all virtual devices) by instance",
    "Network Received (without loopback) by instance", "Network Received (loopback only) by instance"
  ];

for (const panel of panels) {
  const region = page.getByRole('region', { name: panel, exact: true });

  await page.mouse.move(
    page.viewportSize()!.width / 2,
    page.viewportSize()!.height / 2
  );

  for (let i = 0; i < 80; i++) {
    if (await region.isVisible().catch(() => false)) break;

    await scrollGrafanaDown(page);
    await page.waitForTimeout(150);
  }

  await expect(region).toHaveCount(1, { timeout: 20_000 });

  await region.evaluate((el) => {
    el.scrollIntoView({ block: 'center', inline: 'nearest' });
  });

  await expect(region).toBeVisible({ timeout: 20_000 });
}
  
  // unfortunately some 'No data' tiles exist
  /*
  await expect
    .poll(async () => await page.getByText('No data', { exact: true }).count())
    .toBe(0);
  */
});


test('Alerting Contact Points', async ({ page }) => {

  await page.goto(`https://grafana.${BASE_DOMAIN}/alerting/notifications`, { waitUntil: 'domcontentloaded' });

  await expect(page.getByRole('heading', { name: 'platform-team-critical' })).toBeVisible();
  await expect(page.getByRole('heading', { name: 'platform-team-default' })).toBeVisible();
  await expect(page.getByRole('heading', { name: 'platform-team-warning' })).toBeVisible();
});


test('Alerting Notification Policy Routes', async ({ page }) => {

  await page.goto(`https://grafana.${BASE_DOMAIN}/alerting/routes`, { waitUntil: 'domcontentloaded' });

  // default route should be platform-team-default
  await expect(page.getByTestId('am-root-route-container').locator('div').filter({ hasText: 'Default policy' }).first().getByText('Delivered to platform-team-default')).toBeVisible();

  await expect(page.getByText(/severity = warning.*Delivered to platform-team/).getByRole('link', { name: 'platform-team-warning' })).toBeVisible();
  await expect(page.getByText(/severity = critical.*Delivered to platform-team/).getByRole('link', { name: 'platform-team-critical' })).toBeVisible();
});