import { test, expect, type Page } from '@playwright/test';
import { mergeKargoProductionPr } from './kargo-production-pr';

const idError = 'E2E_TEST_PR_NUMBER must identify the disposable demo repository';
const tokenError = 'E2E_KUBRIX_KARGO_GIT_PASSWORD is required to merge the demo promotion PR';

test('accepts workflow hex IDs and legacy numeric PR IDs', async () => {
  const previousId = process.env.E2E_TEST_PR_NUMBER;
  const previousToken = process.env.E2E_KUBRIX_KARGO_GIT_PASSWORD;
  try {
    delete process.env.E2E_KUBRIX_KARGO_GIT_PASSWORD;
    for (const id of ['a1b2c3d4e5', '0123456789', '3194']) {
      process.env.E2E_TEST_PR_NUMBER = id;
      // Stop at credential validation: no browser, API context, or real token is used.
      await expect(mergeKargoProductionPr({} as Page)).rejects.toThrow(tokenError);
    }
  } finally {
    if (previousId === undefined) delete process.env.E2E_TEST_PR_NUMBER;
    else process.env.E2E_TEST_PR_NUMBER = previousId;
    if (previousToken === undefined) delete process.env.E2E_KUBRIX_KARGO_GIT_PASSWORD;
    else process.env.E2E_KUBRIX_KARGO_GIT_PASSWORD = previousToken;
  }
});

test('rejects missing IDs and IDs containing repository path characters', async () => {
  const previousId = process.env.E2E_TEST_PR_NUMBER;
  try {
    for (const id of [undefined, '', '../repo', '123/other', 'abc?base=main', 'not-a-test-id']) {
      if (id === undefined) delete process.env.E2E_TEST_PR_NUMBER;
      else process.env.E2E_TEST_PR_NUMBER = id;
      await expect(mergeKargoProductionPr({} as Page)).rejects.toThrow(idError);
    }
  } finally {
    if (previousId === undefined) delete process.env.E2E_TEST_PR_NUMBER;
    else process.env.E2E_TEST_PR_NUMBER = previousId;
  }
});
