
When(/^visit the path '\/'$/) do
    visit('/')
end

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

Then(/^I input "([^"]*)" as the name of the board$/) do|board_name| 
  fill_in('board_name', :with=>"#{board_name}")
end


Given(/^there is no "([^"]*)" dashboard in my JU application$/) do |board_name|
  FileUtils.rm_f("spec/data/config/#{board_name}.json")
end

Then(/^I should be navigated to a new created board page with the title "([^"]*)"$/) do |board_name|
  expect(page).to have_current_path("/boards/#{board_name}")
end
