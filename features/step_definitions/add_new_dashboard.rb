
Then(/^I click the link "([^"]*)"$/) do |link|
  click_link(link)
end

Then(/^I should be in the page with title "([^"]*)"$/) do |title|
  expect(page).to have_content(title)
end

Then(/^I click the button "([^"]*)"$/) do |button|
  click_button(button)
end

Then(/^I should see the error message "([^"]*)"$/) do|text| 
  expect(page).to have_content(text)
end

Then(/^I input "([^"]*)" as the name of the board$/) do 
  pending # Write code here that turns the phrase above into concrete actions
end

Given(/^there is no "([^"]*)" in my JU application$/) do |arg1|
  pending # Write code here that turns the phrase above into concrete actions
end

Then(/^I should be navigated to a new created board page with the title "([^"]*)"$/) do |arg1|
  pending # Write code here that turns the phrase above into concrete actions
end
