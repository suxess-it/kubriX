const { defineConfig } = require("cypress");

module.exports = defineConfig({
  e2e: {
    baseUrl: "https://backstage.demo.kubrix.cloud/",
    supportFile: false
  },
});