// @ts-check
import { test, expect, request } from '@playwright/test';
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

  // instead of mergen the PR we switch the target repoUrl and revision to the kubrixBots PR repo/branch
  //  which got created during team onboarding scaffoler template
  const ARGOCD_SERVER = "https://argocd.127-0-0-1.nip.io"; // e.g. https://argocd.example.com
  const USERNAME = "admin";    // e.g. admin
  const PASSWORD = process.env.E2E_ARGOCD_ADMIN_PASSWORD!;

  // 1) Create an API client (optionally ignore TLS issues in test envs)
  const api = await request.newContext({
    baseURL: ARGOCD_SERVER,
    ignoreHTTPSErrors: true, // remove if you have valid TLS
  });

  // 2) Login → token
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

  // 3) Disable auto-sync in bootstrap-app (JSON Patch: remove /spec/syncPolicy/automated)
  const disableAutosyncResp = await authed.patch(`/api/v1/applications/sx-bootstrap-app`, {
    data: {
      patchType: "json",
      patch: JSON.stringify([{ op: "remove", path: "/spec/syncPolicy/automated" }]),
    },
  });
  expect(disableAutosyncResp.ok()).toBeTruthy();

  // 4) Change repoURL + targetRevision (merge patch)
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

  // 5) Verify
  const appResp = await authed.get(`/api/v1/applications/sx-teamonboarding-app`);
  expect(appResp.ok()).toBeTruthy();
  const app = await appResp.json();

  expect(app.spec.source.repoURL).toBe("https://github.com/kubrixBot/kubrix-local-johnny-2.git");
  expect(app.spec.source.targetRevision).toBe("onboarding-team-kubrix");

  await api.dispose();
  await authed.dispose();
});
