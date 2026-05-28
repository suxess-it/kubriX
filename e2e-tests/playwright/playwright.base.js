import { devices } from '@playwright/test';

import dotenv from 'dotenv';
import path from 'path';

if (!process.env.CI) {
  dotenv.config({ path: path.resolve(__dirname, '../../../.env_play') });
}

export const sharedConfig = {
  timeout: 30 * 1000,
  expect: {
    timeout: 5000,
  },
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  use: {
    browserName: 'chromium',
    headless: true,
    launchOptions: {
      args: ['--disable-blink-features=AutomationControlled', '--disable-popup-blocking'],
    },
    viewport: { width: 1920, height: 1080 },
    actionTimeout: 0,
    trace: 'retain-on-failure',
    video: 'retain-on-failure',
    ignoreHTTPSErrors: true,
  },
  outputDir: 'data/artifacts/',
};

export const commonProjects = [
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

export const primeProjects = [
  {
    name: 'prime-team-onboarding',
    testMatch: 'prime/pipeline/prime-team-onboarding.spec.ts',
    use: { ...devices['Desktop Chrome'] },
    dependencies: ['portal-login', 'argocd-login'],
  },
  {
    name: 'prime-kubrixbot-app',
    testMatch: 'prime/pipeline/prime-kubrixbot-app.spec.ts',
    use: { ...devices['Desktop Chrome'] },
    dependencies: ['prime-team-onboarding', 'kargo-login'],
  },
  {
    name: 'prime-kubevirt',
    testMatch: 'prime/pipeline/prime-portal-kubevirt.spec.ts',
    use: {
      ...devices['Desktop Chrome'],
      viewport: { width: 1920, height: 1080 },
    },
    dependencies: ['prime-kubrixbot-app'],
  },
  {
    name: 'prime-vcluster',
    testMatch: 'prime/pipeline/prime-portal-vcluster.spec.ts',
    use: {
      ...devices['Desktop Chrome'],
      viewport: { width: 1920, height: 1080 },
    },
    dependencies: ['prime-kubrixbot-app', 'prime-openbao-rbac-login', 'grafana-login'],
  },
  {
    name: 'prime-tests',
    testMatch: /prime\/prime-.*/,
    use: {
      ...devices['Desktop Chrome'],
      viewport: { width: 1920, height: 1080 },
    },
    dependencies: ['argocd-login', 'portal-login', 'grafana-login', 'keycloak-login', 'openbao-login', 'kargo-login'],
  },
  {
    name: 'prime-openbao-rbac-login',
    testMatch: 'prime/rbac/auth.openbao-oidc-login.ts',
    dependencies: ['argocd-login'],
  },
  {
    name: 'prime-kargo-rbac-login',
    testMatch: 'prime/rbac/auth.kargo-oidc-login.ts',
    dependencies: ['prime-openbao-rbac-login', 'kargo-login'],
  },
  {
    name: 'prime-rbac-login',
    testMatch: 'prime/rbac/auth.prime-rbac-keycloak-login.ts',
    dependencies: ['prime-kargo-rbac-login'],
  },
  {
    name: 'prime-grafana-rbac-login',
    testMatch: 'prime/rbac/auth.grafana-oidc-login.ts',
    use: {
      ...devices['Desktop Chrome'],
      viewport: { width: 1920, height: 1080 },
    },
    dependencies: ['prime-rbac-login'],
  },
  {
    name: 'prime-pgadmin-rbac-login',
    testMatch: 'prime/rbac/auth.pgadmin-oidc-login.ts',
    use: {
      ...devices['Desktop Chrome'],
      viewport: { width: 1920, height: 1080 },
    },
    dependencies: ['prime-grafana-rbac-login'],
  },
  {
    name: 'prime-pgadmin',
    testMatch: 'prime/features/prime-pgadmin.spec.ts',
    use: { ...devices['Desktop Chrome'] },
    dependencies: ['prime-grafana-rbac-login'],
  },
  {
    name: 'prime-kyverno',
    testMatch: 'prime/features/prime-kyverno.spec.ts',
    use: {
      ...devices['Desktop Chrome'],
      viewport: { width: 1920, height: 1080 },
    },
    dependencies: ['prime-team-onboarding', 'prime-kubrixbot-app', 'prime-kubevirt', 'prime-vcluster'],
  },
  {
    name: 'prime-argocd-rbac-login',
    testMatch: 'prime/rbac/auth.argocd-oidc-login.ts',
    dependencies: ['prime-pgadmin-rbac-login', 'prime-pgadmin', 'argocd-login'],
  },
  {
    name: 'prime-complete-tests',
    testMatch: /prime\/rbac\/prime-.*\.spec\.ts/,
    use: {
      ...devices['Desktop Chrome'],
    },
    dependencies: [
      'prime-rbac-login',
      'prime-argocd-rbac-login',
      'prime-openbao-rbac-login',
      'prime-kargo-rbac-login',
      'prime-grafana-rbac-login',
      'prime-pgadmin-rbac-login',
      'prime-pgadmin',
      'prime-tests',
      'prime-kyverno',
      'prime-kubevirt',
      'prime-vcluster',
    ],
    teardown: 'prime-cleanup-teardown',
  },
  {
    name: 'prime-cleanup-teardown',
    testMatch: 'prime/pipeline/prime-cleanup.spec.ts',
    use: { ...devices['Desktop Chrome'] },
  },
  {
    name: 'prime-cleanup',
    testMatch: 'prime/pipeline/prime-cleanup.spec.ts',
    use: { ...devices['Desktop Chrome'] },
    dependencies: ['portal-login'],
  },
];
