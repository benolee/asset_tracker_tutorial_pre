Feature: Site Settings

  Scenario: Edit the site settings
    Given I am an authenticated user with an admin role
    And site settings exist with overtime_multiplier: 1.5
    When I am on the edit admin site settings page
    And I fill in "admin_site_settings_overtime_multiplier" with "2.00"
    And I press "Update"
    Then I should see "Site Settings updated successfully" within "#flash_notice"
    And the "admin_site_settings_overtime_multiplier" field should contain "2.00"

