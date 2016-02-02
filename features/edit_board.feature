 Feature: Rename a dashboard
  As a user, I would like to change a dashboard name.
 
Scenario: change a board name to be empty
  Given open a dashboard name "test-board"page
  When I goto the dashboard "test-board" page
  Then I click "Edit Board"
  Then I should be on the "Edit dashboard" page
  Then I change the board name to empty
  Then I click the button "Save"
  And I should see the error message "Dashboard name cannot be empty!"
 
Scenario: invalid board name
  Given open a dashboard name "test-board"page
  When I goto the dashboard "test-board" page
  Then I click "Edit Board"
  Then I should be on the "Edit dashboard" page
  Then I input "my/board" as the name of the board
  Then I click the button "Save"
And I should see the error message "Dashboard name should only contain alphanumeric characters, space, hyphen and underscore!"
 
Scenario: board already exists
  Given open a dashboard name "test-board"page
  When I goto the dashboard "test-board" page
  Then I click "Edit Board"
  Then I should be on the "Edit dashboard" page
  Then I input "foo" as the name of the board
  Then I click the button "Save"
  And I should see the error message "The dashboard foo already exists!"
 
Scenario: rename a board successfully
  Given open a dashboard name "test-board"page
  When I goto the dashboard "test-board" page
  Then I click "Edit Board"
  Then I should be on the "Edit dashboard" page
  Then I input "test-board1" as the name of the board
  Then I click the button "Save"
  And I should be navigated to the board page with the title "test-board1"
   
Scenario: edition canceled
  Given a dashboard named "test-board"
  When I goto the dashboard "test-board" page
  Then I click "Edit Board"
  Then I should be on the "Edit dashboard" page
  Then I input "xxx" as the board name
  Then I click "Cancel"
  Then I should be on the "test-board" dashboard page
