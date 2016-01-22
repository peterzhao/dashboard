Given(/^a dashboard named "([^"]*)" with two widgets "([^"]*)" and "([^"]*)"$/) do |board_name,text1, text2|
  File.open("spec/data/config/#{board_name}.json","w"){|file|file.write({'widgets'=>[{'name'=>"#{text1}","type"=>"gocd_pipeline","base_url"=>"http://localhost:4545","col"=>1,"row"=>1,"sizex"=>2,"sizey"=>3},{'name'=>"#{text2}","type"=>"gocd_pipeline","base_url"=>"http://localhost:4545","col"=>2,"row"=>1,"sizex"=>2,"sizey"=>3}]}.to_json)}
end

Then(/^I hover my mouse to the widget "([^"]*)" click edit icon$/) do |element|
  expect(page).to have_content(element)
  find("##{element} .dashboard-widget-content").hover
  click_on("Edit widget")
end

Then(/^I click "([^"]*)" button on the page$/) do |button|
  click_button(button)
end

Then(/^I confirm the delete action$/) do
 page.driver.browser.switch_to.alert.accept
end

Then(/^I should be on the dashboard "([^"]*)" page$/) do |title|
  expect(page).to have_content(title)
end

Then(/^there is no "([^"]*)" widget on the page$/) do |text|
  expect(page).to have_no_content(text)
end

Then(/^I cancel the delete action$/) do
  page.driver.browser.switch_to.alert.dismiss
end

Then(/^I go back to the dashboard "([^"]*)" page$/) do |board_name|
    visit('/boards/'"#{board_name}")
end

Then(/^the "([^"]*)" widget is still shown on the page$/) do |element|
    expect(page).to have_content(element)
end

