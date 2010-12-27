Feature: Dashboard

Scenario: Total hours for each day
    Given I am an authenticated user
    And I have a "Normal" work unit scheduled today for "3.0" hours
    And I have an "Overtime" work unit scheduled today for "2.0" hours
    When I go to the home page
    Then show me the page
    Then I should see "Total: 6.0" within ".calendar_foot"
    Then I should see "Current: 6.0" within "#current_hours"
