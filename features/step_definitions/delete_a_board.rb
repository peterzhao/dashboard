Given(/^a dashboard named "([^"]*)"$/) do |board_name|
   File.open("spec/data/config/#{board_name}.json","w"){|file| file.write({'widgets'=>[]}.to_json)}
end
When(/^I goto the dashboard "([^"]*)" page$/) do |board_name|
   visit ('/boards/'"#{board_name}")
end

Then(/^I click "([^"]*)"$/) do |link|
  click_link(link)
end

Then(/^I should be on the "([^"]*)" page$/) do |text|
  expect(page).to have_content(text)
end

Then(/^I click "([^"]*)" button$/) do |button|
  click_button(button)
end

Then(/^I comfirm the action$/) do
  page.driver.browser.switch_to.alert.accept
end

Then(/^I cancel the action$/) do
  page.driver.browser.switch_to.alert.dismiss
end

Then(/^I should be on the "([^"]*)" dashboard page$/) do |title|
  expect(page).to have_content(title)
end

When(/^I click the "([^"]*)" link$/) do |link|
  click_link(link)
end

When(/^there is no "([^"]*)" dashboard existing in the drop down list$/) do |board_name|
  expect(page).to have_no_content(board_name)
end

