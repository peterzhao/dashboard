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

Given(/^a dashboard named "([^"]*)" page with widgets$/) do |board_name, table|
  widgets = []
  table.hashes.each_with_index do |row, index|
    widget = case row[:type]
             when 'gocd_pipeline'
               {'name' => row[:widget], 'pipeline' => row[:widget], 'type' => row[:type], 'base_url' => 'http://localhost', 'pull_inteval' => 5, 'number_of_instances' => 3, 'row' => 1, 'col' => index + 1, 'sizex' => 1, 'sizey' => 1}
             when 'jenkins_job'
               {'name' => row[:widget], 'job' => row[:widget], 'type' => row[:type], 'base_url' => 'http://localhost', 'pull_inteval' => 5, 'number_of_builds' => 3, 'row' => 1, 'col' => index + 1, 'sizex' => 1, 'sizey' => 1}
             when 'travis_ci'
               {'name' => row[:widget], 'repo_path' => row[:widget], 'type' => row[:type], 'base_url' => 'http://localhost', 'api_token' => '12345', 'pull_inteval' => 5, 'number_of_instances' => 3, 'row' => 1, 'col' => index + 1, 'sizex' => 1, 'sizey' => 1}
             else 
               {'name' => row[:widget], 'pipeline' => row[:widget], 'type' => row[:type], 'base_url' => 'http://localhost', 'pull_inteval' => 5, 'number_of_instances' => 3, 'row' => 1, 'col' => index + 1, 'sizex' => 1, 'sizey' => 1}
             end
    widgets << widget
  end
  File.open("spec/data/config/#{board_name}.json","w"){ |file| file.write({'widgets'=> widgets}.to_json)}
end

When(/^I go to the "([^"]*)"page$/) do |board_name|
  visit ('/boards/'"#{board_name}")
end

Then(/^I should see the widgets$/) do |table|
  table.hashes.each do |row|
    expect(page).to have_content(row[:widget])
  end
end

