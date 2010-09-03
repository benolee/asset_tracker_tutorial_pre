Feature: Manage projects
  In order to manage projects
  Visitor
  wants a nice management interface

  Scenario: List projects
    Given a client "test client" exists
    And a project exists with name: "test project", client: client "test client"
    When I am on the client's projects page
    Then I should see the following projects:
      |Name|
      |test project|

  Scenario: View a project
    Given a client "test client" exists
    And a project exists with name: "test project", client: client "test client"
    When I am on the client's project's page
    Then I should see a link with text "Tickets" within "#project"

  Scenario: Register new project
    Given a client "test client" exists
    Given I am on the client's new project page
    When I fill in "Name" with "name 1"
    And I press "Create"
    Then I should see "name 1"

#  Scenario: Delete project
#    Given the following projects:
#      |name|
#      |name 1|
#      |name 2|
#      |name 3|
#      |name 4|
#    When I delete the 3rd project
#    Then I should see the following projects:
#      |Name|
#      |name 1|
#      |name 2|
#      |name 4|
