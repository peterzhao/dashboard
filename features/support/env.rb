require 'capybara/cucumber'
require 'headless'
require 'fileutils'
require_relative '../../lib/ju/mb_stub'

Capybara.app_host = "http://localhost:4567"
Capybara.default_driver = :selenium

Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, :browser => :firefox)
end

Before do
  $setup ||= false
  unless($setup) 
    if RUBY_PLATFORM =~ /linux/
      $headless = Headless.new
      $headless.start
    end
    system 'DATA_PATH=spec/data rake restart'
    FileUtils.rm_rf(Dir.glob("screenshots/*"))
    $setup = true
  end
end

After do |scenario| 
  page.save_screenshot("screenshots/#{scenario.title}.png") if scenario.failed?
end

at_exit do
  $headless.destroy if $headless
end
