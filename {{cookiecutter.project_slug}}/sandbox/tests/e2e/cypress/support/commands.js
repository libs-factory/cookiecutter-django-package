// ***********************************************
// Custom commands for {{ cookiecutter.project_name }} E2E tests
// ***********************************************

// Django Admin login command with session caching
Cypress.Commands.add('adminLogin', (username = 'admin', password = 'adminpassword') => {
  cy.session([username, password], () => {
    cy.visit('/admin/login/')
    cy.get('#id_username').type(username)
    cy.get('#id_password').type(password)
    cy.get('input[type="submit"]').click()
    cy.url().should('include', '/admin/')
    cy.get('body').should('contain', 'Django administration')
  })
})

// Get Django CSRF token
Cypress.Commands.add('getCsrfToken', () => {
  return cy.getCookie('csrftoken').then(cookie => {
    if (cookie) {
      return cookie.value
    }
    // If no cookie, try to get from meta tag
    return cy.get('meta[name="csrf-token"]').then($meta => {
      if ($meta.length) {
        return $meta.attr('content')
      }
      return null
    })
  })
})

// Make authenticated API request
Cypress.Commands.add('apiRequest', (method, url, body = {}) => {
  cy.getCsrfToken().then(csrfToken => {
    cy.request({
      method: method,
      url: url,
      body: body,
      headers: {
        'X-CSRFToken': csrfToken,
        'Content-Type': 'application/json'
      }
    })
  })
})

// Wait for Django page to be ready
Cypress.Commands.add('waitForDjango', () => {
  cy.document().its('readyState').should('eq', 'complete')
  cy.get('body').should('be.visible')
})

// Clean up test data
Cypress.Commands.add('cleanupTestData', () => {
  // Add cleanup logic here if needed
  cy.log('Cleaning up test data...')
})