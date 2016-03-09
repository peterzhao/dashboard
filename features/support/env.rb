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

def get_builds(table)
  pipelines = []
  table.hashes.each do |row|
    pipeline = {
         "build_cause" => {
            "approver" => "anonymous",
            "material_revisions" => [
               {
                  "modifications" => [
                     {
                        "email_address" => nil,
                        "id" => 5,
                        "modified_time" => 1444937921583,
                        "user_name" => "Peter",
                        "comment" => row[:commit_message],
                        "revision" => row[:commit_message]
                     }
                  ],
                  "material" => {
                     "description" => "cf-deployer",
                     "fingerprint" => "1c7afcdd4f36ebb29b74e0f0903d1b3f908c7a5cf26f3207d79c318840b3aed6",
                     "type" => "Pipeline",
                     "id" => 2
                  },
                  "changed" => true
               }
            ],
            "trigger_forced" => false,
            "trigger_message" => "modified by Lindawu168 \u003Clindawu16898@gmail.com\u003E"
         },
         "name" => "foo",
         "natural_order" => 16.0,
         "can_run" => false,
         "comment" => nil,
         "stages" => [
            {
               "name" => row[:result],
               "approved_by" => "anonymous",
               "jobs" => [
                  {
                     "name" => "build",
                     "result" => row[:result],
                     "state" => "Completed",
                     "id" => 31,
                     "scheduled_date" => 1451922467439
                  }
               ],
               "can_run" => false,
               "result" => row[:result],
               "approval_type" => "success",
               "counter" => "1",
               "id" => 31,
               "operate_permission" => true,
               "rerun_of_counter" => nil,
               "scheduled" => true
            }
         ],
         "counter" => 16,
         "id" => 21,
         "preparing_to_schedule" => false,
         "label" => row[:build_label] 
    }
    pipelines << pipeline
  end
  { 'pipelines' => pipelines }
end
