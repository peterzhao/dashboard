Feature: View dash-board page
As a user, I want view all widgests on a dash-board page.

Scenario: an empty dash board page
Given open an empty dashboard named "white-board" page
When I go to the "white-board" page
Then I shouldn't see any "widget" box.

Scenario: all widget data are correctly shown on a dash-board page.
Given open a dashboard named "Test-board" page with widgets "Pipeline_widget", "Jekins_widget" and "Travis_widget".
When I go to the "Test-board"page
Then I should see the widgets "Pipeline_widget", "Jekins_widget" and "Travis_widget"
When I go to the "white-board" page
Then I shouldn't see any "widget" box.
When I go back to "Test-board" page
Then I should see the widgets "Pipeline_widget", "Jekins_widget" and "Travis_widget".
