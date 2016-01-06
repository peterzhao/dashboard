require 'capybara/cucumber'
require_relative '../../app'
require 'headless'

Capybara.app = Sinatra::Application
Capybara.app_host = "http://localhost:4567"
Capybara.default_driver = :selenium

Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, :browser => :firefox)
end

Before do
  $setup ||= false
  unless($setup) 
    $headless = Headless.new
    $headless.start
    system 'DATA_PATH=spec/data rake restart'
    system 'rm -rf screenshots/*'
    $setup = true
  end
end

After do |scenario| 
  page.save_screenshot("screenshots/#{scenario.title}.png") if scenario.failed?
end

at_exit do
  $headless.destroy
end
