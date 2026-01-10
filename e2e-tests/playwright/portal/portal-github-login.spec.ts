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
    throw new Error(`Sync failed to start (${res.status()}): ${body}`);
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
  await page.getByRole('textbox', { name: 'Team Organization' }).fill('kubrixBot');
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

  await expect(page.getByRole('button', { name: 'Open Pull-Request' })).toBeVisible({ timeout: 30_000 });
  await expect(page.getByRole('button', { name: 'Open Team-App-Of-Apps Repo' })).toBeVisible({ timeout: 30_000 });

  // set vault secrets for team onboarding
  const vaultURL = "https://vault.127-0-0-1.nip.io";
  const vaultToken = process.env.E2E_VAULT_ROOT_TOKEN!;
  const appsetToken = "blabla";
  const gitPassword = "blabla";

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
  const patchSpecResp = await authed.patch(`/api/v1/applications/sx-team-onboarding`, {
    data: {
      patchType: "merge",
      patch: JSON.stringify({
        spec: {
          source: {
            repoURL: "https://github.com/kubrixBot/kubriX.git",
            targetRevision: "onboarding-team-kubrix",
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
  expect(teamOnboarding.spec.source.repoURL).toBe("https://github.com/kubrixBot/kubriX.git");
  expect(teamOnboarding.spec.source.targetRevision).toBe("onboarding-team-kubrix");

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

  expect(syncStatus).toBe("Synced");

  await api.dispose();
  await authed.dispose();

  // delete kubrix-apps repo in kubrixBot org
  await page.goto('https://github.com/kubrixBot/kubrix-apps');
  await page.getByRole('link', { name: 'Settings' }).click();
  const deleteButton = page.getByRole('button', { name: 'Delete this repository' });
  await deleteButton.scrollIntoViewIfNeeded();
  await deleteButton.click();

  await page.getByRole('button', { name: 'I want to delete this repository' }).click();
  await page.getByRole('button', { name: 'I have read and understand' }).click();
  await page.getByRole('textbox', { name: 'To confirm, type "kubrixBot/' }).fill('kubrixBot/kubrix-apps');
  await page.getByLabel('Delete kubrixBot/kubrix-apps').getByRole('button', { name: 'Delete this repository' }).click();
});

test('ArgoCD team onboarding app', async ({ browser }) => {
  const argocdAuthFile = path.join(authDir, 'argocd.json');
  const context = await browser.newContext({ storageState: argocdAuthFile });
  const page = await context.newPage();
  await page.goto('https://argocd.127-0-0-1.nip.io/applications/sx-team-onboarding')
});

