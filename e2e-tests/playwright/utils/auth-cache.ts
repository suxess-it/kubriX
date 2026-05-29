import fs from 'fs';

export function reuseStoredAuthState(authFile: string, label: string): boolean {
  // Fresh auth is the default. Set PW_USE_CACHED_AUTH=1 when starting
  // Playwright if you want this run/session to reuse existing .auth files.
  if (process.env.PW_USE_CACHED_AUTH !== '1') {
    return false;
  }

  try {
    const stats = fs.statSync(authFile);
    if (!stats.isFile() || stats.size === 0) {
      return false;
    }

    console.log(`[auth-cache] reusing existing auth state for ${label}: ${authFile}`);
    return true;
  } catch {
    return false;
  }
}
