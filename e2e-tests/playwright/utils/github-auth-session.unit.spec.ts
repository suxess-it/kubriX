import { test, expect } from '@playwright/test';
import fs from 'fs';
import os from 'os';
import path from 'path';
import {
  AuthHealthCache,
  classifyBackstageAuthState,
  classifyGithubAuthState,
  withFileLock,
} from './github-auth-session';

test.describe('GitHub auth state classification', () => {
  test('classifies authenticated and challenged GitHub URLs', () => {
    expect(classifyGithubAuthState('https://github.com/', 'GitHub')).toBe('maybe-authenticated');
    expect(classifyGithubAuthState('https://github.com/login', 'Sign in to GitHub')).toBe('login');
    expect(classifyGithubAuthState('https://github.com/sessions/two-factor', 'Two-factor authentication')).toBe('two-factor');
    expect(classifyGithubAuthState('https://github.com/verified-device', 'Verify your device')).toBe('verified-device');
    expect(classifyGithubAuthState('https://github.com/password_confirm', 'Confirm password')).toBe('password-confirmation');
    expect(classifyGithubAuthState('https://github.com/sessions/verified-device/captcha', 'Captcha')).toBe('captcha');
  });

  test('classifies Backstage protected catalog, sign-in, and auth redirect pages', () => {
    expect(
      classifyBackstageAuthState('https://backstage.example.com/catalog', 'kubriX', false, false, true),
    ).toBe('catalog');
    expect(
      classifyBackstageAuthState('https://backstage.example.com/catalog', 'kubriX', true, true),
    ).toBe('sign-in');
    expect(
      classifyBackstageAuthState('https://backstage.example.com/api/auth/github/start', 'kubriX', false, true),
    ).toBe('auth-redirect');
  });
});

test.describe('GitHub auth health cache and lock', () => {
  test('caches healthy results until invalidated or expired', () => {
    const cache = new AuthHealthCache(100);
    expect(cache.isFresh(1_000)).toBe(false);

    cache.markHealthy(1_000);
    expect(cache.isFresh(1_050)).toBe(true);
    expect(cache.isFresh(1_101)).toBe(false);

    cache.markHealthy(2_000);
    cache.invalidate();
    expect(cache.isFresh(2_001)).toBe(false);
  });

  test('serializes work with a file lock and removes the lock file afterwards', async () => {
    const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'github-auth-lock-'));
    const lockFile = path.join(dir, 'state.lock');
    const events: string[] = [];

    await Promise.all([
      withFileLock(lockFile, async () => {
        events.push('first-start');
        await new Promise((resolve) => setTimeout(resolve, 40));
        events.push('first-end');
      }),
      withFileLock(lockFile, async () => {
        events.push('second-start');
        events.push('second-end');
      }),
    ]);

    expect(events).toEqual(['first-start', 'first-end', 'second-start', 'second-end']);
    expect(fs.existsSync(lockFile)).toBe(false);
  });
});
