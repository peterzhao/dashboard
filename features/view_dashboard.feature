 Feature: View dash-board page
   As a user, I want view all widgests on a dash-board page.
 
   Scenario: an empty dash board page
   Given open an empty dashboard named "white-board" page
  When I go to the "white-board" page
   Then I shouldn't see any "widget" box.
  
   Scenario: widgets are correctly shown on a dash-board page.
   Given a dashboard named "test-board" page with widgets
     |widget         | type         |
     |gocd           | gocd_pipeline|
     |jenkins        | jenkins_job|
     |travis         | travis_ci|
   When I go to the "test-board"page
   Then I should see the widgets
       |widget       |
       |gocd         |
       |jenkins      |
       |travis       |
