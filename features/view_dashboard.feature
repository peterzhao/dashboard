 Feature: View dash-board page
   As a user, I want view all widgests on a dash-board page.
 
   Scenario: an empty dash board page
   Given open an empty dashboard named "white-board" page
  When I go to the "white-board" page
   Then I shouldn't see any "widget" box.
  
   Scenario: a pipeline widget is correctly shown on a dash-board page.
     Given open a dashboard named "Test-board" page with a widget table
     |widget         | type         |
     |Pipeline_widget| gocd_pipeline|
  When I go to the "Test-board"page
  Then I should see the widgets table
       |widget         |
       |Pipeline_widget|

 Scenario: a jekins widget is correctly shown on a dash-board page.
      Given open a dashboard named "Test-board" page with a widget table
      |widget         | type         |
      |Jekins_widget  | jenkins_job  |
   When I go to the "Test-board"page
   Then I should see the widgets table
        |widget         |
        |Jekins_widget|

 Scenario: a travis widget is correctly shown on a dash-board page.
      Given open a dashboard named "Test-board" page with a widget table
      |widget         | type         |
      |Travis_widget  | travis_ci    |
   When I go to the "Test-board"page
   Then I should see the widgets table
        |widget         |
        |Travis_widget  |

