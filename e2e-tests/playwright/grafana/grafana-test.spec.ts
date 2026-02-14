import { test, expect } from '@playwright/test';
import path from 'path';
import fs from "fs";

const authDir = path.join(__dirname, '../.auth');
const grafanaAuthFile = path.join(authDir, 'grafana.json');
test.use({ storageState: grafanaAuthFile });

test('Grafana Check Datasources', async ({ page }) => {
  test.slow();

  await page.goto("https://grafana.127-0-0-1.nip.io/connections/datasources");

  await expect(page.getByRole('link', { name: 'loki' , exact: true })).toBeVisible({ timeout: 20_000 });
  await expect(page.getByRole('link', { name: 'mimir' , exact: true })).toBeVisible({ timeout: 20_000 });
});

test('Grafana Loki Logs', async ({ page }) => {
  test.slow();
  await page.goto("https://grafana.127-0-0-1.nip.io/a/grafana-lokiexplore-app/explore/namespace/grafana/logs?from=now-1h&to=now&var-ds=loki&var-filters=namespace%7C%3D%7Cgrafana&patterns=%5B%5D&var-lineFormat=&var-fields=logger%7C%3D%7C__CV%CE%A9__%7B%22parser%22:%22logfmt%22__gfc__%22value%22:%22settings%22%7D,settings&var-levels=&var-metadata=&var-jsonFields=&var-patterns=&var-lineFilterV2=&var-lineFilters=caseInsensitive,0%7C__gfp__%3D%7CStarting%20Grafana&timezone=browser&var-all-fields=logger%7C%3D%7C__CV%CE%A9__%7B%22parser%22:%22logfmt%22__gfc__%22value%22:%22settings%22%7D,settings&displayedFields=%5B%5D&urlColumns=%5B%5D&visualizationType=%22logs%22&prettifyLogMessage=false&sortOrder=%22Descending%22&wrapLogMessage=false");

  await expect
  .poll(async () => {
    const text = await page.getByText('Total:').textContent();
    return Number(text?.match(/\d+/)?.[0]);
  }, { timeout: 20_000 })
  .toBeGreaterThan(0);
});


test('Grafana CNPG Dashboard', async ({ page }) => {
  test.slow();
  await page.goto("https://grafana.127-0-0-1.nip.io/d/cloudnative-pg/cloudnativepg?orgId=1&from=now-7d&to=now&timezone=browser&var-DS_PROMETHEUS=mimir&var-operatorNamespace=cnpg&var-namespace=keycloak&var-cluster=sx-keycloak-cluster&var-instances=$__all");

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

test('Grafana Vault Dashboard', async ({ page }) => {
  test.slow();

  await page.goto("https://grafana.127-0-0-1.nip.io/d/vaults/grc-hashicorp-vault?orgId=1&from=now-2h&to=now&timezone=browser&var-datasource=default&var-node=10.240.0.98&var-port=&var-mountpoint=$__all");

  await expect(
    page.locator('div[title="sx-vault-active"]').getByText('Active', { exact: true })
  ).toBeVisible({ timeout: 20_000 });

  await expect(
    page.locator('div[title="sx-vault-0"]').getByText('ONLINE', { exact: true })
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

  await page.goto("https://grafana.127-0-0-1.nip.io/d/k8s_views_global/kubernetes-views-global?orgId=1&from=now-2h&to=now&timezone=browser&var-datasource=default&var-node=10.240.0.98&var-port=&var-mountpoint=$__all");

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

    // If virtualized, this helps “discover” it
    for (let i = 0; i < 25 && !(await region.count()); i++) {
      await page.mouse.wheel(0, 800);
    }

    await expect(region).toHaveCount(1, { timeout: 20_000 });

    // Try to bring into view but don't allow long hangs
    await region.scrollIntoViewIfNeeded({ timeout: 5_000 }).catch(() => {});

    await expect(region).toBeVisible({ timeout: 20_000 });

    await expect
      .poll(async () => region.getByText('No data', { exact: true }).count(), { timeout: 20_000 })
      .toBe(0);

  }

  // unfortunately some 'No data' tiles exist
  /*
  await expect
    .poll(async () => await page.getByText('No data', { exact: true }).count())
    .toBe(0);
  */
});
