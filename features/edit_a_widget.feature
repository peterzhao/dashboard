Feature: Edit a widget name on a dashboard
  As a user, I would like to change a widget name on a dashboard.

Scenario: empty widget name
  Given a dashboard "my-board" with a widget "widget-1"
  When I go to the dashboard "my-board" page
  Then I hover my mouse to the widget "widget-1" click edit icon
  Then I should be on the "EDIT WIDGET" page
  Then I change the widget name to empty
  Then I click the button "Save"
  And I should see the error message "Widget Name cannot be empty and should contain only alphanumeric characters, underscore and hyphen."

Scenario: invalid widget name
  Given a dashboard "my-board" with a widget "widget-1"
  When I go to the dashboard "my-board" page
  Then I hover my mouse to the widget "widget-1" click edit icon
  Then I should be on the "EDIT WIDGET" page
  Then I input "my/widget" as the "Widget Name"
  Then I click the button "Save"
  And I should see the error message "Widget Name cannot be empty and should contain only alphanumeric characters, underscore and hyphen."
 
Scenario: edit widget successfully
  Given a dashboard "my-board" with a widget "widget-1"
  When I go to the dashboard "my-board" page
  Then I hover my mouse to the widget "widget-1" click edit icon
  Then I should be on the "EDIT WIDGET" page
  Then I input "my-widget" as the "Widget Name"
  Then I click the button "Save"
  And I should be navigated to the board page with the title "my-board"
  And I should see the widget "my-widget" on the board

Scenario: edition cancel
  Given a dashboard "my-board" with a widget "widget-1"
  When I go to the dashboard "my-board" page
  Then I hover my mouse to the widget "widget-1" click edit icon
  Then I should be on the "EDIT WIDGET" page
  Then I input "widgetxxx" as the "Widget Name"
  Then I click the "Cancel"
  And I should be navigated to the board page with the title "my-board"
  And I should see the widget "widget-1" on the board
