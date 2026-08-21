import { Browser, Page, test as base, expect } from '@playwright/test';
import {
  assertNoBackstageAuthRedirect,
  ensureGithubBackstageAuthState,
  ghAuthFile,
  invalidateGithubAuthHealthCache,
} from '../utils/github-auth-session';

type GithubAuthFixtures = {
  allowAuthSessionExpired: boolean;
  page: Page;
};

function authBrowser(browser: Browser): Browser {
  return new Proxy(browser, {
    get(target, property, receiver) {
      if (property === 'newContext') {
        return (options = {}) =>
          target.newContext({
            ignoreHTTPSErrors: true,
            ...options,
          });
      }

      const value = Reflect.get(target, property, receiver);
      return typeof value === 'function' ? value.bind(target) : value;
    },
  });
}

export const test = base.extend<GithubAuthFixtures>({
  allowAuthSessionExpired: [false, { option: true }],

  storageState: [
    async ({ browser }, use, testInfo) => {
      await ensureGithubBackstageAuthState(authBrowser(browser), testInfo);
      await use(ghAuthFile);
    },
    { timeout: 5 * 60_000 },
  ],

  page: async ({ allowAuthSessionExpired, page }, use, testInfo) => {
    await use(page);

    try {
      await assertNoBackstageAuthRedirect(page, testInfo);
    } catch (error) {
      invalidateGithubAuthHealthCache();
      if (allowAuthSessionExpired) {
        return;
      }
      throw error;
    }
  },
});

export { expect };