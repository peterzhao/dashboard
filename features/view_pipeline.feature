Feature: display pipelines with gocd widget
  Scenario: view mixed build results
  Given a gocd pipeline which have the builds
  | build_label | result     | commit_message |
  | 1           | failed     | first commit |
  | 2           | in_process | fix the build |
  | 3           | passed     | clean up |
 And a dashboard 'test-gocd' with a gocd widget 'my-widget' which monitor the gocd pipeline
 When I go the dashboard 'test-gocd'
 And the widget 'my-widget' should contain the build info
  | build_label | result     | commit_message |
  | 1           | failed     | first commit |
  | 2           | in_process | fix the build |
  | 3           | passed     | clean up |
