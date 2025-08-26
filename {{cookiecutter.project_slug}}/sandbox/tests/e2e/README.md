# E2E Testing with Cypress

This directory contains end-to-end tests for {{ cookiecutter.project_name }} using Cypress.

## 📁 Structure

```
e2e/
├── cypress/
│   └── support/
│       ├── e2e.js          # Support file loaded before tests
│       └── commands.js     # Custom Cypress commands
├── specs/                  # Test specifications
│   └── smoke.cy.js        # Basic smoke tests
├── cypress.config.js       # Cypress configuration
├── package.json           # Node dependencies
└── .gitignore            # Git ignore rules
```

## 🚀 Getting Started

### Prerequisites

1. Node.js and npm installed
2. Django development server running
3. Browser testing dependencies (installed via devcontainer)

### Installation

```bash
# From project root
make e2e-install
```

This will:
- Install npm dependencies
- Download Cypress binary
- Verify installation

## 🧪 Running Tests

### Interactive Mode (Cypress GUI)

```bash
make e2e-open
```

This opens the Cypress Test Runner where you can:
- Select and run individual tests
- Watch tests execute in real-time
- Debug failing tests
- Use time-travel debugging

### Headless Mode (CI/CD)

```bash
make e2e-run
```

Runs all tests in headless mode, perfect for CI/CD pipelines.

### Browser Mode

```bash
make e2e-watch
```

Runs tests with the browser visible for debugging.

### Debug Mode with Recording

```bash
make e2e-debug
```

Runs tests with video recording enabled (requires ffmpeg).

## ✍️ Writing Tests

### Basic Test Structure

```javascript
describe('Feature Name', () => {
  beforeEach(() => {
    // Setup before each test
    cy.visit('/')
  })

  it('should do something', () => {
    // Test implementation
    cy.get('#element').click()
    cy.contains('Expected Text').should('be.visible')
  })
})
```

### Using Custom Commands

```javascript
// Login to admin
cy.adminLogin('admin', 'password')

// Get CSRF token
cy.getCsrfToken().then(token => {
  // Use token
})

// Make API request
cy.apiRequest('POST', '/api/endpoint/', { data: 'value' })

// Wait for Django
cy.waitForDjango()
```

## 🎯 Best Practices

1. **Use data attributes for selectors**
   ```html
   <button data-cy="submit-button">Submit</button>
   ```
   ```javascript
   cy.get('[data-cy=submit-button]').click()
   ```

2. **Keep tests independent**
   - Each test should be able to run on its own
   - Use `beforeEach` for setup
   - Clean up test data after tests

3. **Use custom commands for common actions**
   - Add reusable commands to `commands.js`
   - Keep tests DRY (Don't Repeat Yourself)

4. **Test user journeys, not implementation**
   - Focus on what users do
   - Don't test internal implementation details

5. **Handle async operations properly**
   ```javascript
   // Good
   cy.get('.loading').should('not.exist')
   cy.get('.content').should('be.visible')
   
   // Bad
   cy.wait(5000) // Avoid fixed waits
   ```

## 🔧 Configuration

Edit `cypress.config.js` to customize:
- Base URL
- Viewport size
- Timeouts
- Video/screenshot settings
- Browser preferences

## 🐛 Debugging

### Screenshots
Failed tests automatically capture screenshots in `cypress/screenshots/`

### Videos
Enable video recording:
```bash
CYPRESS_video=true npx cypress run
```

### Browser DevTools
In interactive mode, you can use browser DevTools:
1. Open Cypress GUI
2. Run a test
3. Open DevTools in the test browser

### Cypress Commands Log
The Command Log shows:
- Every command executed
- Command duration
- Command status
- Ability to time-travel

## 📚 Resources

- [Cypress Documentation](https://docs.cypress.io)
- [Best Practices](https://docs.cypress.io/guides/references/best-practices)
- [Writing Your First Test](https://docs.cypress.io/guides/getting-started/writing-your-first-test)
- [Custom Commands](https://docs.cypress.io/api/cypress-api/custom-commands)

## 🤝 Contributing

When adding new E2E tests:
1. Create descriptive test names
2. Group related tests in describe blocks
3. Add comments for complex test logic
4. Update this README if adding new patterns