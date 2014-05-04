Feature: Admin Vapors
  Background:
    Given I sign in as an admin
    And system has users
    And system has projects
    And system has vapors

  Scenario: On Admin Vapors
    Given I visit admin vapors page
    Then I should see all vapors
