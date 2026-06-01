const fs = require('fs');
const path = require('path');

const profile = process.env.KUBRIX_PLAYWRIGHT_PROFILE ?? 'oss';
const configFile = profile === 'prime'
  ? './playwright.prime.config.js'
  : './playwright.oss.config.js';
const resolvedConfigFile = fs.existsSync(path.join(__dirname, configFile))
  ? configFile
  : './playwright.oss.config.js';

const configModule = require(resolvedConfigFile);

module.exports = configModule.default ?? configModule;
