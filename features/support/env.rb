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
    create_foo_board
    system 'sh stop_server.sh; no_cache=true DATA_PATH=spec/data sh start_server.sh'
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

def create_foo_board
  config = {"widgets"=>[{"name"=>"foo go cd pipeline", "pipeline" => "foo", "type"=>"gocd_pipeline", "base_url"=>"http://localhost:4545", "user"=>nil, "password"=>nil, "pull_inteval"=>5, "number_of_instances"=>3, "row"=>"1", "col"=>"1", "sizex"=>"1", "sizey"=>"1", "pull-inteval"=>10000}], "board"=>"foo"}
  File.open("spec/data/config/foo.json", 'w') { |file| file.write(config.to_json) }
end
