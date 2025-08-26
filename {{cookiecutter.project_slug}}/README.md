# {{cookiecutter.project_name}}

{{cookiecutter.description}}

## 🚀 Quick Start

### Installation

```bash
# Setup development environment
make setup
```

### Development

```bash
# Run Django development server
make run-debug-server

# Run Django shell
make run-shell

# Run database migrations
make migrate
```

### Testing

```bash
# Run unit tests with coverage
make test

# Run tests in verbose mode
make test-verbose
```
{% if cookiecutter.use_cypress == "yes" %}

## 🧪 E2E Testing with Cypress

This project includes Cypress for end-to-end testing to ensure your Django package works correctly in a real browser environment.

### Setup E2E Testing

```bash
# Install Cypress and dependencies
make e2e-install
```

### Running E2E Tests

```bash
# Run tests headlessly (CI mode)
make e2e-run

# Open Cypress GUI for interactive testing
make e2e-open

# Run tests with browser visible
make e2e-watch

# Debug mode with video recording
make e2e-debug
```

### Writing E2E Tests

E2E tests are located in `sandbox/tests/e2e/specs/`. To add a new test:

1. Create a new file in `sandbox/tests/e2e/specs/` (e.g., `my-feature.cy.js`)
2. Write your test using Cypress commands
3. Use custom commands from `sandbox/tests/e2e/cypress/support/commands.js`

Example test:
```javascript
describe('My Feature', () => {
  it('should work correctly', () => {
    cy.visit('/my-feature/')
    cy.contains('Expected Content').should('be.visible')
  })
})
```

### Custom Commands Available

- `cy.adminLogin(username, password)` - Login to Django admin
- `cy.getCsrfToken()` - Get Django CSRF token
- `cy.apiRequest(method, url, body)` - Make authenticated API request
- `cy.waitForDjango()` - Wait for Django page to be ready
{% endif %}

## 📦 Project Structure

```
{{cookiecutter.project_slug}}/
├── {{cookiecutter.app_slug}}/      # Main package code
├── sandbox/                         # Django test project
│   ├── config/                      # Django settings
│   ├── tests/                       # Unit tests{% if cookiecutter.use_cypress == "yes" %}
│   │   └── e2e/                     # E2E tests with Cypress{% endif %}
│   └── manage.py                    # Django management
├── requirements/                    # Dependencies
└── Makefile                        # Development commands
```

## 🛠️ Development Commands

Run `make help` to see all available commands.

## 📝 License

Copyright (c) {{cookiecutter.author_name}}
