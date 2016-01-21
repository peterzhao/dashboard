Feature: Delete Widget
As a user, I would like to delete a widget on a board so that I can clean up my application

Scenario: deletion submitted
Given a dashboard named "test-board" with two widgets "widget1" and "widget2"
When I goto the dashboard "test-board" page
Then I hover my mouse to the widget "widget2" click edit icon 
Then I should be on the "EDIT WIDGET" page
Then I click "DELETE THIS WIDGET" button on the page
Then I confirm the delete action
Then I should be on the dashboard "test-board" page
And there is no "widget2" widget on the page

Scenario: deletion canceled
Given a dashboard named "test-board" with two widgets "widget1" and "widget2"
When I goto the dashboard "test-board" page
Then I hover my mouse to the widget "widget2" click edit icon 
Then I should be on the "EDIT WIDGET" page
Then I click "DELETE THIS WIDGET" button on the page
Then I cancel the delete action
Then I go back to the dashboard "test-board" page
And the "widget2" widget is still shown on the page

