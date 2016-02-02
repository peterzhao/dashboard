Feature: Create new widget on a dashboard
As a user, I would like to create a new widget on a dashboard so that I can use this widget to get some information.

Scenario: empty widget name and base url
Given a dashboard "white-board" in the JU application
When I go to the "white-board" page
Then I click the link "Create Widget"
Then I click the link "Create gocd pipeline widget"
Then I should be in the page with title "NEW WIDGET"
Then I click the button "Create"
And I should see the error message "Widget Name cannot be empty and should contain only alphanumeric characters, underscore and hyphen."
And I should see the error message "Server base URL is not a valid URL."

Scenario: invalid widget name, pipeline name and base url
Given a dashboard "white-board" in the JU application
When I go to the "white-board" page
Then I click the link "Create Widget"
Then I click the link "Create gocd pipeline widget"
Then I should be in the page with title "NEW WIDGET"
Then I input "my/widget" as the "Widget Name"
Then I input "my/pipeline" as the "Pipeline Name"
And I input "http:\\abc.com" as the "Server Base URL"
Then I click the button "Create"
And I should see the error message "Widget Name cannot be empty and should contain only alphanumeric characters, underscore and hyphen."
And I should see the error message "Pipeline Name cannot be empty and should contain only alphanumeric characters, underscore and period."
And I should see the error message "Server base URL is not a valid URL."

Scenario: Create widget successfully
Given a dashboard "white-board" in the JU application
When I go to the "white-board" page
Then I click the link "Create Widget"
Then I click the link "Create gocd pipeline widget"
Then I should be in the page with title "NEW WIDGET"
Then I input "my-widget" as the "Widget Name"
Then I input "deploy_production" as the "Pipeline Name"
And I input "http://localhost:4545" as the "Server Base URL"
Then I click the button "Create"
And I should be navigated to the board page with the title "white-board"
And I should see the widget "my-widget" on the board

