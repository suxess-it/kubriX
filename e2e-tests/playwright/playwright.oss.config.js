import { devices, defineConfig } from '@playwright/test';

import { sharedConfig } from './playwright.base.js';

const commonProjects = [
  {
    name: 'portal-login',
    testMatch: 'portal/auth.github-keycloak-login.ts',
    use: { trace: 'off' },
  },
  {
    name: 'portal-tests',
    testMatch: /portal\/portal-.*/,
    use: {
      ...devices['Desktop Chrome'],
    },
    dependencies: ['portal-login', 'argocd-login', 'kargo-login'],
  },
  {
    name: 'argocd-login',
    testMatch: 'argocd/auth.argocd-login.ts',
  },
  {
    name: 'grafana-login',
    testMatch: 'grafana/auth.grafana-login.ts',
  },
  {
    name: 'keycloak-login',
    testMatch: 'keycloak/auth.keycloak-login.ts',
  },
  {
    name: 'openbao-login',
    testMatch: 'openbao/auth.openbao-login.ts',
  },
  {
    name: 'kargo-login',
    testMatch: 'kargo/auth.kargo-login.ts',
  },
  {
    name: 'argocd-tests',
    testMatch: /argocd\/argocd-.*/,
    use: {
      ...devices['Desktop Chrome'],
    },
    dependencies: ['argocd-login'],
  },
  {
    name: 'grafana-tests',
    testMatch: /grafana\/grafana-.*/,
    use: {
      ...devices['Desktop Chrome'],
    },
    dependencies: ['grafana-login'],
  },
  {
    name: 'keycloak-tests',
    testMatch: /keycloak\/keycloak-.*/,
    use: {
      ...devices['Desktop Chrome'],
    },
    dependencies: ['keycloak-login'],
  },
  {
    name: 'openbao-tests',
    testMatch: /openbao\/openbao-.*/,
    use: {
      ...devices['Desktop Chrome'],
    },
    dependencies: ['openbao-login'],
  },
  {
    name: 'kargo-tests',
    testMatch: /kargo\/kargo-.*/,
    use: {
      ...devices['Desktop Chrome'],
    },
    dependencies: ['kargo-login'],
  },
];

export default defineConfig({
  ...sharedConfig,
  projects: commonProjects,
  retries: 3,
});
