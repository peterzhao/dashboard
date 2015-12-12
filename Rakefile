begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec, :tag)

  require 'jasmine'
  load 'jasmine/tasks/jasmine.rake'
  
  task :default =>[:spec, 'jasmine:ci']
rescue LoadError
  # no rspec or jasmine available
end
