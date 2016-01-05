@rack_test
Feature: default home page
As a dashboard user I would like to see a default home page displayed when first time visit the application after the application is installed so that I can start to config the application from there.

Scenario: Open the default page 
When I visit the path '/'
Then I should see the home page with a title "default"
And I should see a link "Config this dashboard" on the page
And I should see a link "Add a new dashboard" on the page
