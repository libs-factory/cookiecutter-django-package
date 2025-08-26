const { defineConfig } = require('cypress')

module.exports = defineConfig({
  e2e: {
    baseUrl: 'http://localhost:8000',
    specPattern: 'specs/**/*.cy.js',
    supportFile: 'cypress/support/e2e.js',
    viewportWidth: 1280,
    viewportHeight: 720,
    video: false,  // Default off, can be overridden with --config video=true
    screenshotOnRunFailure: true,
    screenshotsFolder: 'cypress/screenshots',
    videosFolder: 'cypress/videos',
    downloadsFolder: 'cypress/downloads',
    // Browser options
    chromeWebSecurity: false,  // Disable web security if needed for cross-origin
    defaultCommandTimeout: 10000,  // Increase timeout for slower operations
    requestTimeout: 10000,
    responseTimeout: 10000,
    watchForFileChanges: true,  // Auto-rerun tests on file changes
    // Test retries
    retries: {
      runMode: 2,  // Retry failed tests in CI
      openMode: 0  // No retries in interactive mode
    }
  },
})