Feature: File Attachment Management
  As a user
  I should be able to view and add file attachments

  Scenario: Add file attachments
    Given I am an authenticated user with an "admin" role
    And a client exists with name: "New client", initials: "NWC"
    When I go to the client's page
    And I follow "Add File Attachment"
    And I attach a file
    And I press "Submit"
    Then show me the page
