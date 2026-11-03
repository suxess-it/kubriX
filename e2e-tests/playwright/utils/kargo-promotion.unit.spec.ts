import { test, expect } from '@playwright/test';
import { findFreight, findPromotion, promotionFinished, stageHasFreight, waitForPromotion } from './kargo-promotion';

const repo = 'https://github.com/example/app';
const freight = (name: string, id: string, repoURL = repo) => ({
  metadata: { name }, commits: [{ repoURL, id }],
});
const promotion = (name: string, stage: string, freight: string, phase: string) => ({
  metadata: { name }, spec: { stage, freight }, status: { phase },
});

test('selects the exact commit and repository even when the old freight comes first', () => {
  expect(findFreight({ groups: { '': { items: [
    freight('old', 'old-sha'), freight('other-repo', 'new-sha', 'other'), freight('new', 'new-sha'),
  ] } } }, repo, 'new-sha')?.metadata.name).toBe('new');
  expect(findFreight({ groups: { '': { items: [freight('old', 'old-sha')] } } }, repo, 'new-sha')).toBeUndefined();
});

test('reuses only promotions for the requested stage and freight, including terminal failures', () => {
  const items = [promotion('1', 'qa', 'new', 'Running'), promotion('2', 'test', 'old', 'Succeeded'),
    promotion('3', 'test', 'new', 'Pending'), promotion('4', 'test', 'new', 'Failed')];
  expect(findPromotion(items, 'test', 'new')?.metadata.name).toBe('4');
  expect(findPromotion(items.slice(0, 3), 'test', 'new')?.metadata.name).toBe('3');
  expect(findPromotion(items, 'prod', 'new')).toBeUndefined();
});

test('waits through pending and running and rejects failed promotions immediately', () => {
  for (const phase of ['', 'Pending', 'Running']) {
    expect(promotionFinished(promotion('test.1', 'test', 'new', phase))).toBe(false);
  }
  expect(promotionFinished(promotion('test.1', 'test', 'new', 'Succeeded'))).toBe(true);
  for (const phase of ['Failed', 'Errored', 'Aborted']) {
    expect(() => promotionFinished({ ...promotion('test.1', 'test', 'new', phase),
      status: { phase, message: 'git push failed' } })).toThrow(/test.1.*git push failed/);
  }
});

test('requires the current stage freight and commit, not a healthy historical deployment', () => {
  const stage = { status: { freightHistory: [
    { items: { warehouse: { name: 'new', commits: [{ repoURL: repo, id: 'new-sha' }] } } },
    { items: { warehouse: { name: 'old', commits: [{ repoURL: repo, id: 'old-sha' }] } } },
  ] } };
  expect(stageHasFreight(stage, 'new', repo, 'new-sha')).toBe(true);
  expect(stageHasFreight(stage, 'old', repo, 'old-sha')).toBe(false);
  expect(stageHasFreight(stage, 'new', repo, 'wrong-sha')).toBe(false);
});


test('follows one promotion through Pending and Running until success', async () => {
  const phases = ['Pending', 'Running', 'Succeeded'];
  let reads = 0;
  const result = await waitForPromotion(async () => promotion('same-promotion', 'test', 'new', phases[reads++]), 5_000);
  expect(result.metadata.name).toBe('same-promotion');
  expect(result.status?.phase).toBe('Succeeded');
  expect(reads).toBe(3);
});

test('does not retry a terminal promotion failure', async () => {
  let reads = 0;
  await expect(waitForPromotion(async () => {
    reads++;
    return { ...promotion('failed-promotion', 'test', 'new', 'Errored'),
      status: { phase: 'Errored', message: 'git push rejected' } };
  })).rejects.toThrow(/failed-promotion.*git push rejected/);
  expect(reads).toBe(1);
});

test('reports the exact promotion and last status on timeout', async () => {
  await expect(waitForPromotion(async () => promotion('slow-promotion', 'test', 'new', 'Running'), 5))
    .rejects.toThrow(/slow-promotion.*Running/);
});
