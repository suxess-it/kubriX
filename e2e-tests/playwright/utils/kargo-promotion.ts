import { expect, type Page } from '@playwright/test';
import { setTimeout as delay } from 'node:timers/promises';

type Commit = { repoURL: string; id: string };
type Freight = { metadata: { name: string }; commits?: Commit[] };
type Promotion = {
  metadata: { name: string };
  spec: { stage: string; freight: string };
  status?: { phase?: string; message?: string; currentStep?: number };
};
type Stage = {
  status?: {
    conditions?: { type: string; status: string }[];
    freightHistory?: { items: Record<string, { name: string; commits?: Commit[] }> }[];
  };
};
type FreightGroups = { groups: Record<string, { items: Freight[] }> };

export function findFreight(data: FreightGroups, repoURL: string, sha: string) {
  return Object.values(data.groups).flatMap(group => group.items)
    .find(freight => freight.commits?.some(commit => commit.repoURL === repoURL && commit.id === sha));
}

export function findPromotion(items: Promotion[], stage: string, freight: string) {
  return items.filter(item => item.spec.stage === stage && item.spec.freight === freight)
    .sort((a, b) => b.metadata.name.localeCompare(a.metadata.name))[0];
}

export function promotionFinished(promotion: Promotion) {
  const phase = promotion.status?.phase;
  if (['Failed', 'Errored', 'Error', 'Aborted'].includes(phase ?? '')) {
    throw new Error(`Promotion ${promotion.metadata.name}: ${JSON.stringify(promotion.status)}`);
  }
  return phase === 'Succeeded';
}

export function stageHasFreight(stage: Stage, freight: string, repoURL: string, sha: string) {
  return Object.values(stage.status?.freightHistory?.[0]?.items ?? {}).some(item =>
    item.name === freight && item.commits?.some(commit => commit.repoURL === repoURL && commit.id === sha));
}

export async function waitForPromotion(read: () => Promise<Promotion>, timeoutMs: number) {
  const deadline = Date.now() + timeoutMs;
  let promotion: Promotion;
  do {
    promotion = await read();
    // Keep this outside expect.poll: terminal errors must fail immediately.
    if (promotionFinished(promotion)) return promotion;
    await delay(Math.min(1_000, Math.max(0, deadline - Date.now())));
  } while (Date.now() < deadline);
  throw new Error(`Timed out waiting for promotion ${promotion.metadata.name}: ${JSON.stringify(promotion.status)}`);
}

export async function promoteCommit(page: Page, baseDomain: string, prefix: string, stage: string, sha: string, promotionTimeoutMs: number) {
  const project = `kubrix-a${prefix}-kubrixbot-app-kargo-project`;
  const repoURL = `https://github.com/kubriX-demo/kubrix-a${prefix}-kubrixbot-app`;
  const projectURL = `https://kargo.${baseDomain}/project/${project}`;
  const apiURL = `https://kargo.${baseDomain}/v1beta1/projects/${project}`;
  // Reuse the UI's credentials without relying on Kargo's localStorage internals.
  const authRequest = page.waitForRequest(req => req.url().startsWith(`${apiURL}/stages`), { timeout: 30_000 });
  await page.goto(projectURL, { timeout: 15_000 });
  const authorization = await (await authRequest).headerValue('authorization');
  expect(authorization, 'Kargo UI request must be authenticated').toBeTruthy();
  const get = async (endpoint: string) => {
    const response = await page.request.get(`${apiURL}${endpoint}`, {
      headers: { Authorization: authorization! }, timeout: 15_000,
    });
    expect(response.ok(), `Kargo ${endpoint}: HTTP ${response.status()}`).toBeTruthy();
    return response.json();
  };

  // A click alone does not await the request; navigation used to cancel this POST.
  const [refresh] = await Promise.all([
    page.waitForResponse(res => res.url().startsWith(`${apiURL}/warehouses/`)
      && res.url().endsWith('/refresh') && res.request().method() === 'POST', { timeout: 30_000 }),
    page.getByRole('button', { name: 'Refresh', exact: true }).click({ timeout: 10_000 }),
  ]);
  expect(refresh.ok(), `Warehouse refresh: HTTP ${refresh.status()}`).toBeTruthy();

  let freight: Freight | undefined;
  await expect.poll(async () => {
    const data: FreightGroups = await get('/freight');
    freight = findFreight(data, repoURL, sha);
    const available = Object.values(data.groups).flatMap(group => group.items)
      .flatMap(item => item.commits?.map(commit => `${commit.repoURL}@${commit.id}`) ?? []);
    return freight ? 'found' : `Available commits: ${available.join(', ')}`;
  }, { timeout: 120_000, intervals: [1_000, 2_000, 5_000], message: `Waiting for Freight ${repoURL}@${sha}` }).toBe('found');

  const freightName = freight!.metadata.name;
  const promotions = await get(`/promotions?stage=${encodeURIComponent(stage)}`);
  let promotion = findPromotion(promotions.items, stage, freightName);
  if (!promotion) {
    // Reload only after refresh and discovery completed (Kargo UI issue #5932).
    // Reopen the selector if its UI state was stale; never create another promotion here.
    await expect(async () => {
      await page.goto(projectURL, { timeout: 15_000 });
      await page.locator(`[data-testid$="/${stage}"]`).locator('button.ant-dropdown-trigger').click({ timeout: 5_000 });
      await page.getByRole('menuitem', { name: 'Promote', exact: true }).click({ timeout: 5_000 });
      const commitLink = page.locator(`a[href="${repoURL}/commit/${sha}"]`);
      const card = page.locator('div').filter({ has: commitLink })
        .filter({ has: page.getByRole('button', { name: 'Select', exact: true }) }).last();
      await card.getByRole('button', { name: 'Select', exact: true }).click({ timeout: 5_000 });
      await expect(page.getByRole('button', { name: 'Promote', exact: true })).toBeEnabled({ timeout: 5_000 });
    }).toPass({ timeout: 30_000, intervals: [1_000] });
    const [created] = await Promise.all([
      page.waitForResponse(res => res.url() === `${apiURL}/stages/${stage}/promotions`
        && res.request().method() === 'POST', { timeout: 30_000 }),
      page.getByRole('button', { name: 'Promote', exact: true }).click({ timeout: 5_000 }),
    ]);
    expect(created.ok(), `Create promotion: HTTP ${created.status()}`).toBeTruthy();
    promotion = await created.json();
  }
  expect(promotion!.spec.stage).toBe(stage);
  expect(promotion!.spec.freight).toBe(freightName);
  const promotionName = promotion!.metadata.name;
  console.log(`Following promotion ${promotionName} for ${stage}: ${sha}`);
  await waitForPromotion(() => get(`/promotions/${encodeURIComponent(promotionName)}`), promotionTimeoutMs);

  await expect.poll(async () => {
    const current: Stage = await get(`/stages/${stage}`);
    return stageHasFreight(current, freightName, repoURL, sha)
      && ['Ready', 'Healthy'].every(type => current.status?.conditions?.some(condition =>
        condition.type === type && condition.status === 'True'));
  }, { timeout: 120_000, message: `${stage} must deploy ${sha}` }).toBe(true);
  await page.goto(projectURL, { timeout: 15_000 });
  const stageCard = page.locator(`[data-testid$="/${stage}"]`);
  await expect(stageCard.getByText('Ready', { exact: true })).toBeVisible({ timeout: 10_000 });
  await expect(stageCard.getByText('Healthy', { exact: true })).toBeVisible({ timeout: 10_000 });
  await expect(stageCard.locator(`a[href="${repoURL}/commit/${sha}"]`)).toBeVisible({ timeout: 10_000 });
}
