Given(/^open an empty dashboard named "([^"]*)" page$/) do |board_name|
  File.open("spec/data/config/#{board_name}.json","w"){|file| file.write({'widgets'=>[]}.to_json)}
end

 Then(/^I shouldn't see any "([^"]*)" box\.$/) do |text|
   expect(page).to have_no_content(text) 
end

Given(/^open a dashboard named "([^"]*)" page with widgets "([^"]*)", "([^"]*)" and "([^"]*)"\.$/) do |board_name,w1, w2, w3|
   File.open("spec/data/config/#{board_name}.json","w"){|file|file.write({'widgets'=>[{'name'=>"#{w1}","type"=>"gocd_pipeline","base_url"=>"http://localhost:4545","col"=>1,"row"=>1,"sizex"=>1,"sizey"=>2},{'name'=>"#{w2}","type"=>"jenkins_job","base_url"=>"http://acb.com","col"=>2,"row"=>1,"sizex"=>1,"sizey"=>2},{'name'=>"#{w3}","type"=>"travis_ci","base_url"=>"http://acb.com","col"=>3,"row"=>1,"sizex"=>1,"sizey"=>2},]}.to_json)}
end

When(/^I go to the "([^"]*)"page$/) do |board_name|
  visit ('/boards/'"#{board_name}")
end

Then(/^I should see the widgets "([^"]*)", "([^"]*)" and "([^"]*)"$/) do |w1, w2, w3|
  expect(page).to have_content(w1)
  expect(page).to have_content(w2)
  expect(page).to have_content(w3)
end

When(/^I go back to "([^"]*)" page$/) do |board_name|
  visit ('/boards/'"#{board_name}")
end

Then(/^I should see the widgets "([^"]*)", "([^"]*)" and "([^"]*)"\.$/) do |w1, w2, w3|
  expect(page).to have_content(w1)
  expect(page).to have_content(w2)
  expect(page).to have_content(w3)
end
