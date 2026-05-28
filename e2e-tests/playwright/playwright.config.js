const profile = process.env.KUBRIX_PLAYWRIGHT_PROFILE ?? 'oss';
const configFile = profile === 'prime'
  ? './playwright.prime.config.js'
  : './playwright.oss.config.js';

const configModule = require(configFile);

module.exports = configModule.default ?? configModule;
