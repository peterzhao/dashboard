Given(/^a dashboard "([^"]*)" with a widget "([^"]*)"$/) do |board_name, widget_name|
  File.open("spec/data/config/#{board_name}.json","w"){|file|file.write({'widgets'=>[{'name'=>widget_name,"pipeline"=>"build", "type"=>"gocd_pipeline","base_url"=>"http://localhost:4545","col"=>1,"row"=>1,"sizex"=>2,"sizey"=>3}]}.to_json)}
end

When(/^I go to the dashboard "([^"]*)" page$/) do |board_name|
  visit ('/boards/'"#{board_name}")
end

Then(/^I change the widget name to empty$/) do
  fill_in('name',:with=>'')
end

Then(/^I click the "([^"]*)"$/) do |button|
  click_on(button)
end


