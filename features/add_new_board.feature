Feature: Create new dashboard
As a user, I would like to create a new dashboard so that I can organize my widgets better.

  Scenario: empty board name
    Then I click the link "Create Board"
    Then I should be in the page with title "NEW DASHBOARD"
    Then I click the button "Create"
    And I should see the error message "Dashboard name cannot be empty!"

  Scenario: invalid board name
    Then I click the link "Create Board"
    Then I should be in the page with title "NEW DASHBOARD"
    Then I input "my/board" as the name of the board
    Then I click the button "Create"
    And I should see the error message "Dashboard name cannot contain any special characters!"

  Scenario: board already exists
    Then I click the link "Create Board"
    Then I should be in the page with title "NEW DASHBOARD"
    Then I input "foo" as the name of the board
    Then I click the button "Create"
    And I should see the error message "The dashboard foo already exists!"

  Scenario: create a board successfully
    Given there is no "test-board" in my JU application
    Then I click the link "Create Board"
    Then I should be in the page with title "NEW DASHBOARD"
    Then I input "test-board" as the name of the board
    Then I click the button "Create"
    And I should be navigated to a new created board page with the title "test-board"
  
