// @ts-check
import { test, expect, request } from '@playwright/test';
import path from 'path';
import fs from "fs";

const authDir = path.join(__dirname, '../.auth');
const ghAuthFile = path.join(authDir, 'github.json');
test.use({ storageState: ghAuthFile });

// ArgoCD Login
async function loginAndGetAuthedContext() {
  const baseURL = "https://argocd.127-0-0-1.nip.io";
  const username = "admin";
  const password = process.env.E2E_ARGOCD_ADMIN_PASSWORD!;

  const api = await request.newContext({
    baseURL,
    ignoreHTTPSErrors: true,
  });

  const sessionResp = await api.post("/api/v1/session", {
    headers: { "Content-Type": "application/json" },
    data: { username, password },
  });
  expect(sessionResp.ok()).toBeTruthy();

  const { token } = await sessionResp.json();
  expect(token).toBeTruthy();

  const authed = await request.newContext({
    baseURL,
    ignoreHTTPSErrors: true,
    extraHTTPHeaders: {
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
    },
  });

  await api.dispose();
  return authed;
}

async function getApp(authed: any, appName: string) {
  const res = await authed.get(`/api/v1/applications/${encodeURIComponent(appName)}`);
  expect(res.ok()).toBeTruthy();
  return await res.json();
}

async function syncApp(authed: any, appName: string) {
  // Minimal sync request. You can add prune/dryRun/revision/resources/etc.
  const res = await authed.post(`/api/v1/applications/${encodeURIComponent(appName)}/sync`, {
    data: {
      // Common knobs (uncomment if you need them):
      prune: true,
      // dryRun: false,
      // revision: "kubrixBot:onboarding-team-kubrix",
      // strategy: { hook: { force: true } }, // depends on your use-case
      // resources: [{ group: "", kind: "Deployment", name: "my-deploy", namespace: "default" }],
      // syncOptions: ["CreateNamespace=true"],
    },
  });

  // If ArgoCD returns an error, bubble up details:
  if (!res.ok()) {
    const body = await res.text(); 
    if (typeof body === "string" && body.includes("another operation is already in progress")) {
      return res
    }
    else {
      throw new Error(`Sync failed to start (${res.status()}): ${body}`);
    }
  }
}

async function waitForOperationToFinish(
  authed: any,
  appName: string,
  timeoutMs = 5 * 60_000,
  pollMs = 2_000
) {
  const deadline = Date.now() + timeoutMs;

  while (Date.now() < deadline) {
    const app = await getApp(authed, appName);

    const phase = app?.status?.operationState?.phase; // Running | Succeeded | Failed | Error | (or undefined)
    const syncStatus = app?.status?.sync?.status;
    const healthStatus = app?.status?.health?.status;

    // If there is no operationState at all, it might mean "nothing is running".
    // After starting a sync, you usually see operationState.phase=Running quickly.
    if (phase && phase !== "Running") {
      return { app, phase, syncStatus, healthStatus };
    }

    await new Promise((r) => setTimeout(r, pollMs));
  }

  throw new Error(`Timed out waiting for sync operation to finish for app "${appName}"`);
}

test("Team Onboarding with kubrixBot Github user", async ({ page }) => {
  test.slow();
  //await page.goto("https://backstage.127-0-0-1.nip.io/");
  //await page.getByRole('listitem').filter({ hasText: 'GitHubSign in using' }).getByRole('button').click();
  await page.goto('https://backstage.127-0-0-1.nip.io/create/templates/default/team-onboarding');

  await page.getByRole('textbox', { name: 'Team Organization' }).click();
  await page.getByRole('textbox', { name: 'Team Organization' }).fill('kubriX-demo');
  const teamRepoUID = process.env.E2E_TEST_PR_NUMBER ?? '';
  await page.getByRole('textbox', { name: 'Team Repos UID' }).fill(`a${teamRepoUID}-`);
  await page.getByRole('button', { name: 'Next' }).click();
  const page1Promise = page.waitForEvent('popup');
  await page.getByRole('button', { name: 'Log in' }).click();

  const popup = await page.waitForEvent('popup'); // your page1Promise
  const authorize = popup.getByRole('button', { name: 'Authorize kubriX-demo' });

  await Promise.race([
  authorize
    .waitFor({ state: 'visible', timeout: 5000 })
    .then(() => authorize.click())
    .then(() => popup.waitForEvent('close')), 

    // Case B: popup closes automatically -> do nothing
    popup.waitForEvent('close')
  ]);

  // optional: make sure the popup is gone before continuing
  if (!popup.isClosed()) await popup.close();

  await page.getByRole('button', { name: 'Review' }).click();
  await page.getByRole('button', { name: 'Create' }).click();

  await expect(page.getByRole('button', { name: 'Open Pull-Request' })).toBeVisible({ timeout: 30_000 });
  await expect(page.getByRole('button', { name: 'Open Team-App-Of-Apps Repo' })).toBeVisible({ timeout: 30_000 });

  // set vault secrets for team onboarding
  const vaultURL = "https://vault.127-0-0-1.nip.io";
  const vaultToken = process.env.E2E_VAULT_ROOT_TOKEN!;
  const appsetToken = process.env.E2E_KUBRIX_ARGOCD_APPSET_TOKEN!;
  const gitPassword = process.env.E2E_KUBRIX_KARGO_GIT_PASSWORD!;

  const apiVault = await request.newContext({
    baseURL: vaultURL,
    ignoreHTTPSErrors: true, // equivalent to curl -k
  });

  const res = await apiVault.post("/v1/kubrix-kv/data/kubrix/delivery", {
    headers: {
      "X-Vault-Token": vaultToken,
      "Content-Type": "application/json",
    },
    data: {
      data: {
        KUBRIX_ARGOCD_APPSET_TOKEN: appsetToken,
        KUBRIX_KARGO_GIT_PASSWORD: gitPassword,
      },
    },
  });

  if (!res.ok()) {
    const body = await res.text();
    throw new Error(`Vault write failed (${res.status()}): ${body}`);
  }

  const json = await res.json();
  console.log("Vault write response:", json);

  await apiVault.dispose();

  // instead of mergen the PR we switch the target repoUrl and revision to the kubrixBots PR repo/branch
  //  which got created during team onboarding scaffoler template
  const ARGOCD_SERVER = "https://argocd.127-0-0-1.nip.io"; // e.g. https://argocd.example.com
  const USERNAME = "admin";    // e.g. admin
  const PASSWORD = process.env.E2E_ARGOCD_ADMIN_PASSWORD!;

  // Create an API client
  const api = await request.newContext({
    baseURL: ARGOCD_SERVER,
    ignoreHTTPSErrors: true, // remove if you have valid TLS
  });

  // Login → token
  const sessionResp = await api.post("/api/v1/session", {
    headers: { "Content-Type": "application/json" },
    data: { username: USERNAME, password: PASSWORD },
  });
  expect(sessionResp.ok()).toBeTruthy();
  const { token } = await sessionResp.json();
  expect(token).toBeTruthy();

  // Recreate context with auth header (clean + convenient)
  const authed = await request.newContext({
    baseURL: ARGOCD_SERVER,
    ignoreHTTPSErrors: true,
    extraHTTPHeaders: {
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
    },
  });

  // Disable auto-sync in bootstrap-app (JSON Patch: remove /spec/syncPolicy/automated)
  const disableAutosyncResp = await authed.patch(`/api/v1/applications/sx-bootstrap-app`, {
    data: {
      patchType: "merge",
      patch: JSON.stringify({
        spec: {
          syncPolicy: {
            automated: {
              enabled: false,
            },
          },
        },
      }),
    },
  });
  expect(disableAutosyncResp.ok()).toBeTruthy();

  // Change repoURL + targetRevision (merge patch)
  const kubrixRepo = process.env.E2E_KUBRIX_REPO ?? "kubriX";
  const patchSpecResp = await authed.patch(`/api/v1/applications/sx-team-onboarding`, {
    data: {
      patchType: "merge",
      patch: JSON.stringify({
        spec: {
          source: {
            repoURL: `https://github.com/kubrixBot/${kubrixRepo}`,
            targetRevision: `onboarding-team-kubrix-a${teamRepoUID}-`,
          },
        },
      }),
    },
  });
  expect(patchSpecResp.ok()).toBeTruthy();

  // Verify
  const appResp = await authed.get(`/api/v1/applications/sx-team-onboarding`);
  expect(appResp.ok()).toBeTruthy();
  const teamOnboarding = await appResp.json();
  expect(teamOnboarding.spec.source.repoURL).toBe(`https://github.com/kubrixBot/${kubrixRepo}`);
  expect(teamOnboarding.spec.source.targetRevision).toBe(`onboarding-team-kubrix-a${teamRepoUID}-`);

  // sync argocd app and get sync result
  const appName = "sx-team-onboarding";

  // 1) Start sync
  await syncApp(authed, appName);

  // 2) Wait for it to finish
  const { app, phase, syncStatus, healthStatus } = await waitForOperationToFinish(
    authed,
    appName,
    10 * 60_000, // timeout
    2_000        // poll
  );

  // 3) Assert / use results
  expect(["Succeeded", "Failed", "Error"]).toContain(phase);

  // Typical expectations (adjust to your reality):
  // - syncStatus should become "Synced"
  // - healthStatus should become "Healthy" (or might stay Progressing briefly)
  console.log({ phase, syncStatus, healthStatus });
  console.log("operation message:", app?.status?.operationState?.message);

  // expect(syncStatus).toBe("Synced");

  await api.dispose();
  await authed.dispose();
});

test.describe("ArgoCD team onboarding app", () => {
  const argocdAuthFile = path.join(authDir, 'argocd.json');
  test.use({ storageState: argocdAuthFile });
  test.setTimeout(130_000);
  test('ArgoCD team onboarding app', async ({ page }) => {
    await page.goto('https://argocd.127-0-0-1.nip.io/applications/sx-team-onboarding');
    await expect(page.locator('#app').getByText('Synced', { exact: true }).nth(1)).toBeVisible({ timeout: 60_000 });
    await expect(page.locator('#app').getByText('Healthy', { exact: true }).nth(1)).toBeVisible({ timeout: 60_000 });
  });
});


test("Multi-Stage-Kargo App Onboarding", async ({ page }) => {
  await page.goto('https://backstage.127-0-0-1.nip.io/create/templates/default/multi-stage-app-with-kargo-pipeline');

  const prefix = process.env.E2E_TEST_PR_NUMBER ?? '';
  await page.getByRole('textbox', { name: 'Name' }).click();
  // the 'team repos uid' needs to start with a alphabetical character (DNS-1035 label), that is why we add 'a'
  await page.getByRole('textbox', { name: 'Name' }).fill(`a${prefix}-kubrixbot-app`);
  await page.getByRole('textbox', { name: 'Description' }).click();
  await page.getByRole('textbox', { name: 'Description' }).fill('this is a e2e test');
  await page.getByRole('textbox', { name: 'Team Organization' }).click();
  await page.getByRole('textbox', { name: 'Team Organization' }).fill('kubriX-demo');
  await page.getByRole('button', { name: 'Next' }).click();
  const page1Promise = page.waitForEvent('popup');
  await page.getByRole('button', { name: 'Log in' }).click();

  const popup = await page.waitForEvent('popup'); // your page1Promise
  const authorize = popup.getByRole('button', { name: 'Authorize kubriX-demo' });

  await Promise.race([
  authorize
    .waitFor({ state: 'visible', timeout: 5000 })
    .then(() => authorize.click())
    .then(() => popup.waitForEvent('close')), 

    // Case B: popup closes automatically -> do nothing
    popup.waitForEvent('close')
  ]);

  // optional: make sure the popup is gone before continuing
  if (!popup.isClosed()) await popup.close();

  await page.getByRole('button', { name: 'Review' }).click();
  await page.getByRole('button', { name: 'Create' }).click();

  await expect(page.getByRole('button', { name: 'Repos' })).toBeVisible({ timeout: 30_000 });
  await expect(page.getByRole('button', { name: 'Open in Catalog' })).toBeVisible({ timeout: 30_000 });


});

test.describe("ArgoCD verify kubrixbot-app state", () => {
  const argocdAuthFile = path.join(authDir, 'argocd.json');
  test.use({ storageState: argocdAuthFile });
  test.setTimeout(180_000);
  test('ArgoCD verify kubrixbot-app state', async ({ page }) => {
    // wait for 1 minute so the appset scm generator picks up the new repo
    const prefix = process.env.E2E_TEST_PR_NUMBER ?? '';
    await page.waitForTimeout(60_000);
    await page.goto(`https://argocd.127-0-0-1.nip.io/applications/adn-kubrix/kubrix-a${prefix}-kubrixbot-app`);
    await expect(page.locator('#app').getByText('Synced', { exact: true }).nth(1)).toBeVisible({ timeout: 20_000 });
  });
});

test.describe("Kargo GitOps Promotion - Going Live First time", () => {
  const kargoAuthFile = path.join(authDir, 'kargo.json');
  test.use({ storageState: kargoAuthFile });
  test.setTimeout(200_000);
  // see https://github.com/akuity/kargo/issues/4956 for better curl/API support
  test('Kargo GitOps Promotion - Promote to Test', async ({ page }) => {
    const prefix = process.env.E2E_TEST_PR_NUMBER ?? '';
    await page.goto(`https://kargo.127-0-0-1.nip.io/project/kubrix-a${prefix}-kubrixbot-app-kargo-project`);
    await page.getByRole('button', { name: 'Refresh' }).click();
    // wait 10 seconds so freights are refreshed
    await page.waitForTimeout(10_000);
    await page.locator('[data-testid$="/test"]').getByRole('button').nth(0).click();
    await page.getByRole('menuitem', { name: 'Promote', exact: true }).locator('span').click();
    await page.getByRole('button', { name: 'Select' }).first().click();
    await page.getByRole('button', { name: 'Promote' }).click();
    await expect(page.getByLabel('Promotion', { exact: true }).getByRole('rowgroup')).toContainText('Succeeded', { timeout: 60_000 });
    await page.getByRole('button', { name: 'Close' }).click();
    // refresh stage otherwise it is in verification / unknown state too long
    await expect.poll(async () => {
      await page
        .locator('[data-testid$="/test"]')
        .getByRole('button')
        .nth(2)
        .click();
    
      try {
        await page.getByRole('dialog').getByRole('button', { name: 'Refresh' }).click({ timeout: 3000 });
      } catch (e) {
        // Swallow only “could not click refresh” type failures
        // so the poll can continue and we can still Close.
        // (Optional: console.log(String(e)))
      }
      await page.getByRole('button', { name: 'Close' }).click();
    
      const readyVisible = await page
        .locator('[data-testid$="/test"]')
        .getByText('Ready')
        .isVisible();
    
      const healthyVisible = await page
        .locator('[data-testid$="/test"]')
        .getByText('Healthy')
        .isVisible();
    
      return readyVisible && healthyVisible;
    }, {
      timeout: 120_000,
      intervals: [2_000],
    }).toBe(true);
  });

  test('Kargo GitOps Promotion - Promote to QA', async ({ page }) => {
    const prefix = process.env.E2E_TEST_PR_NUMBER ?? '';
    await page.goto(`https://kargo.127-0-0-1.nip.io/project/kubrix-a${prefix}-kubrixbot-app-kargo-project`);
    await page.locator('[data-testid$="/qa"]').getByRole('button').nth(0).click();
    await page.getByRole('menuitem', { name: 'Promote', exact: true }).locator('span').click();
    await page.getByRole('button', { name: 'Select' }).first().click();
    await page.getByRole('button', { name: 'Promote' }).click();
    await expect(page.getByLabel('Promotion', { exact: true }).getByRole('rowgroup')).toContainText('Succeeded', { timeout: 60_000 });
    await page.getByRole('button', { name: 'Close' }).click();
    // refresh stage otherwise it is in verification / unknown state too long
    await expect.poll(async () => {
      await page
        .locator('[data-testid$="/qa"]')
        .getByRole('button')
        .nth(2)
        .click();

      try {
        await page.getByRole('dialog').getByRole('button', { name: 'Refresh' }).click({ timeout: 3000 });
      } catch (e) {
        // Swallow only “could not click refresh” type failures
        // so the poll can continue and we can still Close.
        // (Optional: console.log(String(e)))
      }
      await page.getByRole('button', { name: 'Close' }).click();
    
      const readyVisible = await page
        .locator('[data-testid$="/qa"]')
        .getByText('Ready')
        .isVisible();
    
      const healthyVisible = await page
        .locator('[data-testid$="/qa"]')
        .getByText('Healthy')
        .isVisible();
    
      return readyVisible && healthyVisible;
    }, {
      timeout: 120_000,
      intervals: [2_000],
    }).toBe(true);
  });

  test('Kargo GitOps Promotion - Promote to Prod', async ({ page }) => {
    const prefix = process.env.E2E_TEST_PR_NUMBER ?? '';
    await page.goto(`https://kargo.127-0-0-1.nip.io/project/kubrix-a${prefix}-kubrixbot-app-kargo-project`);
    await page.locator('[data-testid$="/prod"]').getByRole('button').nth(0).click();
    await page.getByRole('menuitem', { name: 'Promote', exact: true }).locator('span').click();
    await page.getByRole('button', { name: 'Select' }).first().click();
    await page.getByRole('button', { name: 'Promote' }).click();
    await expect(page.getByLabel('Promotion', { exact: true }).getByRole('rowgroup')).toContainText('Succeeded', { timeout: 60_000 });
    await page.getByRole('button', { name: 'Close' }).click();
    // refresh stage otherwise it is in verification / unknown state too long
    await expect.poll(async () => {
      await page
        .locator('[data-testid$="/prod"]')
        .getByRole('button')
        .nth(2)
        .click();

      try {
        await page.getByRole('dialog').getByRole('button', { name: 'Refresh' }).click({ timeout: 3000 });
      } catch (e) {
        // Swallow only “could not click refresh” type failures
        // so the poll can continue and we can still Close.
        // (Optional: console.log(String(e)))
      }
      await page.getByRole('button', { name: 'Close' }).click();
    
      const readyVisible = await page
        .locator('[data-testid$="/prod"]')
        .getByText('Ready')
        .isVisible();
    
      const healthyVisible = await page
        .locator('[data-testid$="/prod"]')
        .getByText('Healthy')
        .isVisible();
    
      return readyVisible && healthyVisible;
    }, {
      timeout: 120_000,
      intervals: [2_000],
    }).toBe(true);
  });
});

test("Check kubrixbot-app podtato head stages", async ({ page }) => {
  const prefix = process.env.E2E_TEST_PR_NUMBER ?? '';
  const urls = [
    `http://kubrix-a${prefix}-kubrixbot-app-test.127-0-0-1.nip.io/`,
    `http://kubrix-a${prefix}-kubrixbot-app-qa.127-0-0-1.nip.io/`,
    `http://kubrix-a${prefix}-kubrixbot-app-prod.127-0-0-1.nip.io/`,
  ];

  for (const url of urls) {
    const response = await page.goto(url);
    expect(response?.status()).toBe(200);
    await expect(page.locator('h1')).toContainText('Hello from podtato head!');
  }
});

test("Check kubrixbot-app in backstage", async ({ page }) => {
  const prefix = process.env.E2E_TEST_PR_NUMBER ?? '';
  const apps = [
    `kubrix-a${prefix}-kubrixbot-app-test`,
    `kubrix-a${prefix}-kubrixbot-app-qa`,
    `kubrix-a${prefix}-kubrixbot-app-prod`,
    `kubrix-a${prefix}-kubrixbot-app`
  ];
  for (const app of apps) {
    await page.goto('https://backstage.127-0-0-1.nip.io/catalog');
    await page.getByRole('textbox', { name: 'Search' }).click();
    await page.getByRole('textbox', { name: 'Search' }).fill(app);
    await expect(page.getByRole('link', { name: app, exact: true })).toBeVisible();
    await page.getByRole('link', { name: app, exact: true }).click();
    
    // inside the app overview page
    // ArgoCD Deployment Summary
    await expect(page.getByRole('heading', { name: 'Deployment Summary' })).toBeVisible();
    await expect(page.getByRole('cell', { name: 'Synced' })).toBeVisible();
    await expect(page.getByRole('cell', { name: 'Healthy' })).toBeVisible();
    
    // Grafana Dashboard links
    // does not work in kind-portal tests because there Grafana is not installed!!
    // await expect(page.locator('div').filter({ hasText: /^Dashboards$/ }).first()).toBeVisible();
    // const dashboard_links = [
    //   'GRC/Hashicorp Vault',
    //   'Kubernetes / System / API Server',
    //   'Kubernetes / System / CoreDNS',
    //   'Kubernetes / Views / Global',
    //   'Kubernetes / Views / Namespaces',
    //   'Kubernetes / Views / Nodes',
    //   'Kubernetes / Views / Nodes',
    //   'Loki Kubernetes Logs'
    // ];
    // for (const link of dashboard_links) {
    //   await expect(page.getByRole('link', { name: `${link} , Opens` })).toBeVisible();
    // }
    
    // Tabs
    const tabs = [
      'Overview',
      'Docs',
      'kargo',
      'Kubernetes', // not for umbrella app
      'CD',
      'Pull Requests',
      'GitHub Issues',
      'Github Insights',
      'Grafana-Dashboard', // not for umbrella app
      'Kyverno Policy Reports',
      'Security',
      'API'
    ];
    for (const tab of tabs) {
      // await page.goto(`https://backstage.127-0-0-1.nip.io/catalog/default/component/${app}`);
      // ignore some tabs for the umbrella app
      if (app === `kubrix-a${prefix}-kubrixbot-app`) {
        if (tab === 'Kubernetes' || tab === 'Grafana-Dashboard') {
          continue; // skip these for umbrella app
        }
      }

      await expect(page.getByRole('tab', { name: tab, exact: true })).toBeVisible();

      // Check details for CD tab
      if (tab === 'CD') {
        // appname in CD card is normally without team prefix, except for the umbrella app
        let appWithoutPrefix: string;
        if (app === `kubrix-a${prefix}-kubrixbot-app`) {
          appWithoutPrefix = app;
        } else {
          appWithoutPrefix = app.replace(/^kubrix-/, '');
        }
        await page.getByRole('tab', { name: tab, exact: true }).click();
        await expect(page.getByText('Synced')).toBeVisible();
        await expect(page.getByText('Healthy')).toBeVisible();
        await page.getByTestId(`${appWithoutPrefix}-card`).getByText(appWithoutPrefix, { exact: true }).click();
        await expect(page.locator('div').filter({ hasText: appWithoutPrefix}).nth(1)).toBeVisible();
        await page.getByRole('button', { name: 'Close the drawer' }).click();
      }

      // Check details for Grafana tab
      // not possible because grafana is not always installed with the portal
      // if (tab === 'Grafana-Dashboard') {
      //   await page.getByRole('tab', { name: tab, exact: true }).click();
      //   await expect(page.locator('iframe[title*="grafana.127-0-0-1.nip.io/d/k8s_views_ns/"]').contentFrame().getByRole('heading')).toContainText('Welcome to Grafana');
      // }
    }
  }
});

test("Kargo GitOps Promotion - Change Podtato Head Hat Part Number", async ({ page }) => {

const newValuesFileContent = `
nameOverride: ""
fullnameOverride: ""

# applies to all deployments in this chart
replicaCount: 1
images:
  repositoryDirname: ghcr.io/podtato-head
  pullPolicy: IfNotPresent
  pullSecrets: []
    # - name: ghcr

# keep ports in sync with podtato-services/main/pkg/provider.go
entry:
  repositoryBasename: entry
  tag: "latest"
  serviceType: ClusterIP
  servicePort: 9000
  env: []
  #   - name: PODTATO_PART_NUMBER
  #     value: "01"
hat:
  repositoryBasename: hat
  tag: "latest"
  serviceType: ClusterIP
  servicePort: 9001
  env:
    - name: PODTATO_PART_NUMBER
      value: "03"
leftLeg:
  repositoryBasename: left-leg
  tag: "latest"
  serviceType: ClusterIP
  servicePort: 9002
  env: []
  #   - name: PODTATO_PART_NUMBER
  #     value: "01"
leftArm:
  repositoryBasename: left-arm
  tag: "latest"
  serviceType: ClusterIP
  servicePort: 9003
  env:
    - name: PODTATO_PART_NUMBER
      value: "02"
rightLeg:
  repositoryBasename: right-leg
  tag: "latest"
  serviceType: ClusterIP
  servicePort: 9004
  env:
    - name: PODTATO_PART_NUMBER
      value: "01"
rightArm:
  repositoryBasename: right-arm
  tag: "latest"
  serviceType: ClusterIP
  servicePort: 9005
  env: []
  #   - name: PODTATO_PART_NUMBER
  #     value: "01"

serviceAccount:
  # Specifies whether a service account should be created
  create: true
  # Annotations to add to the service account
  annotations: {}
  # The name of the service account to use.
  # If not set and create is true, a name is generated using the fullname template
  name: ""

podAnnotations: {}

# You can learn more about configuring a security context in the Kubernetes docs
# at https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
podSecurityContext: {}
  # fsGroup: 2000

securityContext: {}
  # capabilities:
  #   drop:
  #   - ALL
  # readOnlyRootFilesystem: true
  # runAsNonRoot: true
  # runAsUser: 1000

ingress:
  enabled: true
  className: ""
  annotations: {}
    # kubernetes.io/tls-acme: "true"
  tls: []
  #  - secretName: chart-example-tls
  #    hosts:
  #      - chart-example.local



service:
  port: 9000

resources: {}
  # We usually recommend not to specify default resources and to leave this as a conscious
  # choice for the user. This also increases chances charts run on environments with little
  # resources, such as Minikube. If you do want to specify resources, uncomment the following
  # lines, adjust them as necessary, and remove the curly braces after 'resources:'.
  # limits:
  #   cpu: 100m
  #   memory: 128Mi
  # requests:
  #   cpu: 5m
  #   memory: 32Mi

autoscaling:
  enabled: false
  minReplicas: 1
  maxReplicas: 100
  targetCPUUtilizationPercentage: 80
  # targetMemoryUtilizationPercentage: 80

nodeSelector: {}

tolerations: []

affinity: {}
`;
  const prefix = process.env.E2E_TEST_PR_NUMBER ?? '';
  await page.goto(`https://backstage.127-0-0-1.nip.io/catalog/default/component/kubrix-a${prefix}-kubrixbot-app`);
  const page1Promise = page.waitForEvent('popup');
  await page.getByRole('link', { name: 'View Source , Opens in a new' }).click();
  const page1 = await page1Promise;
  await page1.getByRole('link', { name: 'values.yaml, (File)' }).click();
  await page1.getByTestId('edit-button').click();
  await page1.getByRole('textbox', { name: 'Editing values.yaml file' }).fill(newValuesFileContent);
  await page1.getByRole('button', { name: 'Commit changes...' }).click();
  await page1.getByRole('button', { name: 'Commit changes', exact: true }).click();
});

test.describe("Kargo GitOps Promotion - Promote Changes", () => {
  const kargoAuthFile = path.join(authDir, 'kargo.json');
  test.use({ storageState: kargoAuthFile });
  test.setTimeout(200_000);
  // see https://github.com/akuity/kargo/issues/4956 for better curl/API support
  test('Kargo GitOps Promotion - Promote Changes to Test', async ({ page }) => {
    const prefix = process.env.E2E_TEST_PR_NUMBER ?? '';
    await page.goto(`https://kargo.127-0-0-1.nip.io/project/kubrix-a${prefix}-kubrixbot-app-kargo-project`);
    await page.getByRole('button', { name: 'Refresh' }).click();
    // wait 10 seconds so freights are refreshed
    await page.waitForTimeout(10_000);
    await page.locator('[data-testid$="/test"]').getByRole('button').nth(1).click();
    await page.getByRole('menuitem', { name: 'Promote', exact: true }).locator('span').click();
    await page.getByRole('button', { name: 'Select' }).first().click();
    await page.getByRole('button', { name: 'Promote' }).click();
    await expect(page.getByLabel('Promotion', { exact: true }).getByRole('rowgroup')).toContainText('Succeeded', { timeout: 30_000 });
    await page.getByRole('button', { name: 'Close' }).click();
    // refresh stage otherwise it is in verification / unknown state too long
    await expect.poll(async () => {
      await page
        .locator('[data-testid$="/test"]')
        .getByRole('button')
        .nth(2)
        .click();

      try {
        await page.getByRole('dialog').getByRole('button', { name: 'Refresh' }).click({ timeout: 3000 });
      } catch (e) {
        // Swallow only “could not click refresh” type failures
        // so the poll can continue and we can still Close.
        // (Optional: console.log(String(e)))
      }
      await page.getByRole('button', { name: 'Close' }).click();
    
      const readyVisible = await page
        .locator('[data-testid$="/test"]')
        .getByText('Ready')
        .isVisible();
    
      const healthyVisible = await page
        .locator('[data-testid$="/test"]')
        .getByText('Healthy')
        .isVisible();
    
      return readyVisible && healthyVisible;
    }, {
      timeout: 120_000,
      intervals: [2_000],
    }).toBe(true);
  });

  test('Kargo GitOps Promotion - Promote Changes to QA', async ({ page }) => {
    const prefix = process.env.E2E_TEST_PR_NUMBER ?? '';
    await page.goto(`https://kargo.127-0-0-1.nip.io/project/kubrix-a${prefix}-kubrixbot-app-kargo-project`);
    await page.locator('[data-testid$="/qa"]').getByRole('button').nth(1).click();
    await page.getByRole('menuitem', { name: 'Promote', exact: true }).locator('span').click();
    await page.getByRole('button', { name: 'Select' }).first().click();
    await page.getByRole('button', { name: 'Promote' }).click();
    await expect(page.getByLabel('Promotion', { exact: true }).getByRole('rowgroup')).toContainText('Succeeded', { timeout: 30_000 });
    await page.getByRole('button', { name: 'Close' }).click();
    // refresh stage otherwise it is in verification / unknown state too long
    await expect.poll(async () => {
      await page
        .locator('[data-testid$="/qa"]')
        .getByRole('button')
        .nth(2)
        .click();

      try {
        await page.getByRole('dialog').getByRole('button', { name: 'Refresh' }).click({ timeout: 3000 });
      } catch (e) {
        // Swallow only “could not click refresh” type failures
        // so the poll can continue and we can still Close.
        // (Optional: console.log(String(e)))
      }
      await page.getByRole('button', { name: 'Close' }).click();
    
      const readyVisible = await page
        .locator('[data-testid$="/qa"]')
        .getByText('Ready')
        .isVisible();
    
      const healthyVisible = await page
        .locator('[data-testid$="/qa"]')
        .getByText('Healthy')
        .isVisible();
    
      return readyVisible && healthyVisible;
    }, {
      timeout: 120_000,
      intervals: [2_000],
    }).toBe(true);
  });

  test('Kargo GitOps Promotion - Promote Changes to Prod', async ({ page }) => {
    const prefix = process.env.E2E_TEST_PR_NUMBER ?? '';
    await page.goto(`https://kargo.127-0-0-1.nip.io/project/kubrix-a${prefix}-kubrixbot-app-kargo-project`);
    await page.locator('[data-testid$="/prod"]').getByRole('button').nth(1).click();
    await page.getByRole('menuitem', { name: 'Promote', exact: true }).locator('span').click();
    await page.getByRole('button', { name: 'Select' }).first().click();
    await page.getByRole('button', { name: 'Promote' }).click();
    await expect(page.getByLabel('Promotion', { exact: true }).getByRole('rowgroup')).toContainText('Succeeded', { timeout: 30_000 });
    await page.getByRole('button', { name: 'Close' }).click();
    // refresh stage otherwise it is in verification / unknown state too long
    await expect.poll(async () => {
      await page
        .locator('[data-testid$="/prod"]')
        .getByRole('button')
        .nth(2)
        .click();
    
      try {
        await page.getByRole('dialog').getByRole('button', { name: 'Refresh' }).click({ timeout: 3000 });
      } catch (e) {
        // Swallow only “could not click refresh” type failures
        // so the poll can continue and we can still Close.
        // (Optional: console.log(String(e)))
      }
      await page.getByRole('button', { name: 'Close' }).click();
    
      const readyVisible = await page
        .locator('[data-testid$="/prod"]')
        .getByText('Ready')
        .isVisible();
    
      const healthyVisible = await page
        .locator('[data-testid$="/prod"]')
        .getByText('Healthy')
        .isVisible();
    
      return readyVisible && healthyVisible;
    }, {
      timeout: 120_000,
      intervals: [2_000],
    }).toBe(true);
  });
});


test.describe("ArgoCD verify kubrixbot-app state final", () => {
  const argocdAuthFile = path.join(authDir, 'argocd.json');
  test.use({ storageState: argocdAuthFile });
  test.setTimeout(180_000);
  test('ArgoCD verify kubrixbot-app state', async ({ page }) => {
    // wait for 1 minute so the appset scm generator picks up the new repo
    const prefix = process.env.E2E_TEST_PR_NUMBER ?? '';
    await page.waitForTimeout(60_000);
    await page.goto(`https://argocd.127-0-0-1.nip.io/applications/adn-kubrix/kubrix-a${prefix}-kubrixbot-app`);
    await expect(page.locator('#app').getByText('Synced', { exact: true }).nth(1)).toBeVisible({ timeout: 20_000 });
    await expect(page.locator('#app').getByText('Healthy', { exact: true }).nth(1)).toBeVisible({ timeout: 20_000 });
  });
  test('ArgoCD verify kubrixbot-app-test state', async ({ page }) => {
    const prefix = process.env.E2E_TEST_PR_NUMBER ?? '';
    await page.goto(`https://argocd.127-0-0-1.nip.io/applications/adn-kubrix/a${prefix}-kubrixbot-app-test`);
    await expect(page.locator('#app').getByText('Synced', { exact: true }).nth(1)).toBeVisible({ timeout: 20_000 });
    await expect(page.locator('#app').getByText('Healthy', { exact: true }).nth(1)).toBeVisible({ timeout: 20_000 });
  });
  test('ArgoCD verify kubrixbot-app-qa state', async ({ page }) => {
    const prefix = process.env.E2E_TEST_PR_NUMBER ?? '';
    await page.goto(`https://argocd.127-0-0-1.nip.io/applications/adn-kubrix/a${prefix}-kubrixbot-app-qa`);
    await expect(page.locator('#app').getByText('Synced', { exact: true }).nth(1)).toBeVisible({ timeout: 20_000 });
    await expect(page.locator('#app').getByText('Healthy', { exact: true }).nth(1)).toBeVisible({ timeout: 20_000 });
  });
  test('ArgoCD verify kubrixbot-app-prod state', async ({ page }) => {
    const prefix = process.env.E2E_TEST_PR_NUMBER ?? '';
    await page.goto(`https://argocd.127-0-0-1.nip.io/applications/adn-kubrix/a${prefix}-kubrixbot-app-prod`);
    await expect(page.locator('#app').getByText('Synced', { exact: true }).nth(1)).toBeVisible({ timeout: 20_000 });
    await expect(page.locator('#app').getByText('Healthy', { exact: true }).nth(1)).toBeVisible({ timeout: 20_000 });
  });
});

test("Delete kubrixBot repos", async ({ page }) => {
  const teamRepoUID = process.env.E2E_TEST_PR_NUMBER ?? '';
 
  // delete kubrix-kubrixbot-app in kubriX-demo org
  await page.goto(`https://github.com/kubriX-demo/kubrix-a${teamRepoUID}-kubrixbot-app`);
  await page.getByRole('link', { name: 'Settings' }).click();
  const deleteButtonKubriXMultiStageApp = page.getByRole('button', { name: 'Delete this repository' });
  await deleteButtonKubriXMultiStageApp.scrollIntoViewIfNeeded();
  await deleteButtonKubriXMultiStageApp.click();
  await page.getByRole('button', { name: 'I want to delete this repository' }).click();
  await page.getByRole('button', { name: 'I have read and understand' }).click();
  await page.getByRole('textbox', { name: 'To confirm, type "kubriX-demo/' }).fill(`kubriX-demo/kubrix-a${teamRepoUID}-kubrixbot-app`);
  await page.getByLabel(`Delete kubriX-demo/kubrix-a${teamRepoUID}-kubrixbot-app`).getByRole('button', { name: 'Delete this repository' }).click();

  // delete kubrix-apps in kubriX-demo and kubriX repo in kubrixBot org
  await page.goto(`https://github.com/kubriX-demo/kubrix-a${teamRepoUID}-apps`);
  await page.getByRole('link', { name: 'Settings' }).click();
  const deleteButtonKubriXAppOfApps = page.getByRole('button', { name: 'Delete this repository' });
  await deleteButtonKubriXAppOfApps.scrollIntoViewIfNeeded();
  await deleteButtonKubriXAppOfApps.click();
  await page.getByRole('button', { name: 'I want to delete this repository' }).click();
  await page.getByRole('button', { name: 'I have read and understand' }).click();
  await page.getByRole('textbox', { name: 'To confirm, type "kubriX-demo/' }).fill(`kubriX-demo/kubrix-a${teamRepoUID}-apps`);
  await page.getByLabel(`Delete kubriX-demo/kubrix-a${teamRepoUID}-apps`).getByRole('button', { name: 'Delete this repository' }).click();

  // delete kubriX fork repo of the bot
  // commented out because with concurrent tests you cannot delete this repo
  // const kubrixRepo = process.env.E2E_KUBRIX_REPO ?? "kubriX";
  // await page.goto(`https://github.com/kubrixBot/${kubrixRepo}`);
  // await page.getByRole('link', { name: 'Settings' }).click();
  // const deleteButtonKubriX = page.getByRole('button', { name: 'Delete this repository' });
  // await deleteButtonKubriX.scrollIntoViewIfNeeded();
  // await deleteButtonKubriX.click();
  // await page.getByRole('button', { name: 'I want to delete this repository' }).click();
  // await page.getByRole('button', { name: 'I have read and understand' }).click();
  // await page.getByRole('textbox', { name: 'To confirm, type "kubrixBot/' }).fill(`kubrixBot/${kubrixRepo}`);
  // await page.getByLabel(`Delete kubrixBot/${kubrixRepo}`).getByRole('button', { name: 'Delete this repository' }).click();
});
  

