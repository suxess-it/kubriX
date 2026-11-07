import { expect, request, type Page } from '@playwright/test';

/** Merge only the production PR for this run's disposable demo repository. */
export async function mergeKargoProductionPr(
  page: Page,
  options: { allowNoChanges?: boolean } = {},
): Promise<void> {
  const prefix = process.env.E2E_TEST_PR_NUMBER;
  if (!prefix || !/^[0-9]+$/.test(prefix)) {
    throw new Error('E2E_TEST_PR_NUMBER must identify the disposable demo repository');
  }
  const token = process.env.E2E_KUBRIX_KARGO_GIT_PASSWORD;
  if (!token) throw new Error('E2E_KUBRIX_KARGO_GIT_PASSWORD is required to merge the demo promotion PR');
  const repo = `kubriX-demo/kubrix-a${prefix}-kubrixbot-app`;
  const api = await request.newContext({
    baseURL: 'https://api.github.com',
    extraHTTPHeaders: {
      Authorization: `Bearer ${token}`,
      Accept: 'application/vnd.github+json',
      'X-GitHub-Api-Version': '2022-11-28',
    },
  });
  const promotion = page.getByLabel('Promotion', { exact: true }).getByRole('rowgroup');
  try {
    let pr: any;
    await expect.poll(async () => {
      const response = await api.get(`/repos/${repo}/pulls`, {
        params: { state: 'open', base: 'stages/prod', per_page: 100 },
      });
      expect(response.ok(), `Listing production PRs failed: ${response.status()}`).toBeTruthy();
      const matches = (await response.json()).filter((candidate: any) =>
        candidate.title === 'push changes to prod' &&
        candidate.head.repo?.full_name.toLowerCase() === repo.toLowerCase());
      expect(matches.length, 'Expected at most one Kargo production PR').toBeLessThanOrEqual(1);
      pr = matches[0];
      if (pr) return true;
      // Initial branches already contain main; Kargo legitimately skips an empty PR.
      if (options.allowNoChanges && (await promotion.textContent())?.includes('Succeeded')) return true;
      return false;
    }, { timeout: 60_000, intervals: [1_000, 2_000, 5_000], message: 'Waiting for the Kargo production PR' }).toBe(true);
    if (!pr) return;

    await expect(promotion).not.toContainText('Succeeded');
    const detail = await api.get(`/repos/${repo}/pulls/${pr.number}`);
    expect(detail.ok()).toBeTruthy();
    const openPr = await detail.json();
    expect(openPr.state).toBe('open');
    expect(openPr.merged).toBe(false);
    expect(openPr.base.ref).toBe('stages/prod');
    expect(openPr.head.sha).toBe(pr.head.sha);

    const mainResponse = await api.get(`/repos/${repo}/commits/main`);
    const headResponse = await api.get(`/repos/${repo}/commits/${openPr.head.sha}`);
    expect(mainResponse.ok()).toBeTruthy();
    expect(headResponse.ok()).toBeTruthy();
    expect((await headResponse.json()).commit.tree.sha, 'PR must promote the current demo content')
      .toBe((await mainResponse.json()).commit.tree.sha);

    // Approval is separate from merging. This disposable demo has no required reviews.
    // Pin the merge to the SHA inspected above so a changed PR cannot be merged silently.
    const response = await api.put(`/repos/${repo}/pulls/${pr.number}/merge`, {
      data: { sha: openPr.head.sha, merge_method: 'merge' },
    });
    expect(response.ok(), `Merging production PR #${pr.number} failed: ${await response.text()}`).toBeTruthy();
    const merged = await response.json();
    expect(merged.merged).toBe(true);
    expect(merged.sha).toBeTruthy();
    console.log(`Merged Kargo production PR #${pr.number} at ${merged.sha}`);
  } finally {
    await api.dispose();
  }
}
