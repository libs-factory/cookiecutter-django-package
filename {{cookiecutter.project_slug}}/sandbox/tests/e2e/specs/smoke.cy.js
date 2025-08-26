describe('{{ cookiecutter.project_name }} Smoke Tests', () => {
  it('should load the admin login page', () => {
    cy.visit('/admin/')
    // Should redirect to login if not authenticated
    cy.url().should('include', '/admin/login/')
    cy.get('#id_username').should('be.visible')
    cy.get('#id_password').should('be.visible')
    cy.get('input[type="submit"]').should('have.value', 'Log in')
  })
})
