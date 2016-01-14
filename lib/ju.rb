require_relative 'ju/config'
require_relative 'ju/board'
require_relative 'ju/widget'
require_relative 'ju/plugin'
require_relative 'ju/layout_packer'
Dir[File.expand_path("../ju/plugins/*.rb", __FILE__)].each {|file| load file }
