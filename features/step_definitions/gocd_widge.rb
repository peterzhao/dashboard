Given(/^a broken gocd pipeline running on a gocd server$/) do
     Ju.mb_stub 'spec/mb-fixtures/gocd-foo-failed.json'
end 

When(/^I visit "([^"]*)"$/) do |path|
      visit path
end

Then(/^I should see the widget of "([^"]*)" is broken$/) do |title|
     expect(page).to have_content(title);
     expect(page).to have_selector('.gocd-stage.failed')
end

Given(/^a building gocd pipeline running on a gocd server$/) do
      Ju.mb_stub 'spec/mb-fixtures/gocd-foo-in-progress.json'
end

Then(/^I should see the widget of "([^"]*)" is in process$/) do |title|
      expect(page).to have_content(title);
      expect(page).to have_selector('.gocd-stage.building')
end 

Given(/^a passed gocd pipeline running on a gocd server$/) do
      Ju.mb_stub 'spec/mb-fixtures/gocd-foo-passed.json'
end

Then(/^I should see the widget of "([^"]*)" is passed$/) do |title|
      expect(page).to have_content(title);
      expect(page).to have_selector('.gocd-stage.passed')
end
