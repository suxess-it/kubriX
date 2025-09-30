const { defineConfig } = require("cypress");

module.exports = defineConfig({
  e2e: {
    baseUrl: "https://backstage.127-0-0-1.nip.io/",
    supportFile: false,
  },
  video: true,
});
