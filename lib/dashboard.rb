require_relative 'dashboard/plugin'
Dir[File.expand_path("../dashboard/plugins/*.rb", __FILE__)].each {|file| load file }
