const { defineConfig } = require('@playwright/test');

module.exports = defineConfig({
  testMatch: 'utils/**/*.unit.spec.ts',
  reporter: 'line',
  workers: 1,
});
