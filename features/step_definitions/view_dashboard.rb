Given(/^open an empty dashboard named "([^"]*)" page$/) do |board_name|
  File.open("spec/data/config/#{board_name}.json","w")
end

Then(/^I shouldn't see any "([^"]*)" box\.$/) do |text|
  expect(page).not_to have_content(text)
end

Transform /^table:widget $/ do |table|
   table.map_headers!{|header|header.downcase.to_sym}
   table.map_column!(:widget){|widget|widget.find_by_name(widget)}
   table.map_column!(:type){|type|type.find_by_name(type)}
   table
end

Given(/^open a dashboard named "([^"]*)" page with a widget table$/) do |board_name,table|
   table.hashes.each do |row|
  File.open("spec/data/config/#{board_name}.json","w"){|file|file.write({'widgets'=>[{'name'=>row[:widget],"type"=>row[:type],"base_url"=>"http://localhost:4545","col"=>1,"row"=>1,"sizex"=>1,"sizey"=>1}]}.to_json)}
   end
end
When(/^I go to the "([^"]*)"page$/) do |board_name|
  visit ('/boards/'"#{board_name}")
end

Then(/^I should see the widgets table$/) do |table|
  table.hashes.each do |row|
    expect(page).to have_content(row[:widget])
  end
end

