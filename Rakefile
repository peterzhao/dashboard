begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec, :tag)

  require 'jasmine'
  load 'jasmine/tasks/jasmine.rake'
  
  task :default =>[:spec, 'jasmine:ci']
rescue LoadError
  # no rspec or jasmine available
end

task :start do
  system "ruby app.rb >logs/server 2>&1 &"
end

task :stop do
  system "kill -9 `ps -ef | grep 'app.rb' | awk '{print $2}' | head -n 1`"
end

task :clean do
  system "rm -rf logs/*"
end

task :restart => [:stop, :clean, :start]
