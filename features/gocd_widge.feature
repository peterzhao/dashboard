@javascript
Feature: display pipelines with gocd widge 
As a user, I would like to see status of build pipelines via gocd widge so that I will be notified when the status of the pipelines are changed.
Scenario: Broken pipelines 
Given a broken gocd pipeline running on a gocd server 
When I visit "/board/foo"
Then I should see the widge of "foo" is broken 
