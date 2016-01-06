@javascript
Feature: display pipelines with gocd widge 
As a user, I would like to see status of build pipelines via gocd widge so that I will be notified when the status of the pipelines are changed.

Scenario: Broken pipelines
    Given a broken gocd pipeline running on a gocd server
     When I visit "/board/foo"
     Then I should see the widge of "foo" is broken

Scenario: Building a pipeline
    Given a building gocd pipeline running on a gocd server
     When I visit "/board/foo"
     Then I should see the widge of "foo" is in process

Scenario: Passed a pipeline
    Given a passed gocd pipeline running on a gocd server
     When I visit "/board/foo"
     Then I should see the widge of "foo" is passed

