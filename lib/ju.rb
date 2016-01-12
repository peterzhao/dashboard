require_relative 'ju/config'
require_relative 'ju/board'
require_relative 'ju/widge'
require_relative 'ju/plugin'
Dir[File.expand_path("../ju/plugins/*.rb", __FILE__)].each {|file| load file }
