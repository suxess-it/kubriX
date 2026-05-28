import { defineConfig } from '@playwright/test';

import { commonProjects, sharedConfig } from './playwright.base.js';

export default defineConfig({
  ...sharedConfig,
  projects: commonProjects,
});
