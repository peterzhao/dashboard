begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec, :tag)

  require 'jasmine'
  load 'jasmine/tasks/jasmine.rake'

  require 'cucumber/rake/task'
  Cucumber::Rake::Task.new do |t|
      t.cucumber_opts = "features --format pretty"
  end

  task :default =>[:spec, 'jasmine:ci']
  task :test =>[:spec, 'jasmine:ci', :cucumber]
rescue LoadError
  # no rspec or jasmine available
end

task :start do
  system "sh start_server.sh"
end

task :stop do
  system "sh stop_server.sh"
end

task :clean do
  system "rm -rf logs/*"
end

task :restart => [:stop, :start]
