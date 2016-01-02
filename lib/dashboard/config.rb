require 'fileutils'
module Dashboard
  class Config
    class << self
      def get_board_config(board_name)
        create_default_board_if_missing if board_name == 'default'
        config = JSON.load(File.read("#{data_path}/config/#{board_name}.json"))
        config['board'] = board_name 
        config['widges'].each do |widge|
          widge['id'] = canonicalize(widge['name'])
        end
        config
      end
      
      def get_widge_config(board_name, widge_id)
        config = get_board_config(board_name)
        config['widges'].find{ |widge| widge['id'] == widge_id }
      end
      
      private 

      def canonicalize(name)
        name.gsub(' ', '-').gsub('_', '-')
      end
     
      def data_path
        return ENV['DATA_PATH'] if ENV['DATA_PATH']
        'data'
      end
      
      def create_default_board_if_missing
        path = "#{data_path}/config/default.json"
        return if(File.exists?(path))
        template = File.expand_path('../../../data/templates/default.json', __FILE__)
        FileUtils.cp(template, "#{data_path}/config/")
      end
    end
  end
end
