Given(/^a broken gocd pipeline running on a gocd server$/) do 
  system 'ruby mb-stub.rb spec/mb-fixtures/gocd-foo-failed.json' 
end

When(/^I visit "([^"]*)"$/) do |path|
  visit path
end

Then(/^I should see the widge of "([^"]*)" is broken$/) do |title|
  expect(page).to have_content(title);
  expect(page).to have_selector('.gocd-stage.failed')
end
