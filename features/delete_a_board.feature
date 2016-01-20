Feature: Delete dashboard
As a user, I would like to delete a board so that I can clean up my application

Scenario: deletion submitted
Given a dashboard named "test-board"
When I goto the dashboard "test-board" page
Then I click "Edit Board"
Then I should be on the "Edit dashboard" page 
Then I click "DELETE THIS BOARD" button
Then I comfirm the action
Then I should be on the "Default" dashboard page
When I click the "Default" link
And there is no "test-board" dashboard existing in the drop down list

Scenario: deletion canceled
Given a dashboard named "test-board"
When I goto the dashboard "test-board" page
Then I click "Edit Board"
Then I should be on the "Edit dashboard" page 
Then I click "DELETE THIS BOARD" button
Then I cancel the action
Then I should be on the "test-board" dashboard page

