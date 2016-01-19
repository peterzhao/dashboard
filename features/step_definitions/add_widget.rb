Given(/^a dashboard "([^"]*)" in the JU application$/) do |board_name|
   File.open("spec/data/config/#{board_name}.json","w"){|file| file.write({'widgets'=>[]}.to_json)}
end

When(/^I go to the "([^"]*)" page$/) do |board_name|
    visit ('/boards/'"#{board_name}")
end

Then(/^I click the link"([^"]*)"$/) do |link|
   click_link(link)
end

Then(/^I input "([^"]*)" as the "([^"]*)"$/) do |value,field|
   fill_in("#{field}",:with=>"#{value}")
end
 
Then(/^I should be navigated to the board page with the title "([^"]*)"$/) do |title|
   expect(page).to have_content(title)
end
 
Then(/^I should see the widget "([^"]*)" on the board$/) do |text|
    expect(page).to have_content(text)
end
