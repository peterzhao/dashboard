When(/^I visit the path '\/'$/) do
  visit('/')
end
Then(/^I should see the home page with a title "([^"]*)"$/) do |title|
  expect(page).to have_content(title)
end

Then(/^I should see a link "([^"]*)" on the page$/) do |title|
  expect(page).to have_link(title)
end


