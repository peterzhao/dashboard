Given(/^open a dashboard name "([^"]*)"page$/) do |board_name|
  File.open("spec/data/config/#{board_name}.json")
end

Then(/^I change the board name to empty$/) do
  fill_in('board_name',:with=>'')
end

Then(/^I input "([^"]*)" as the board name$/) do |value|
  fill_in('board_name',:with=>value)
end

