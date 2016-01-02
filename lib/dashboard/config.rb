require 'fileutils'
require 'json'
module Dashboard
  class Config
    class << self
      def get_board_config(board)
        create_default_board_if_missing if board == 'default'
        config = JSON.load(File.read("#{data_path}/config/#{board}.json"))
        config['board'] = board 
        config['widges'].each do |widge|
          widge['id'] = widge['name']
        end
        get_board_layout(config)
        config
      end
      
      def get_widge_config(board, widge_id)
        config = get_board_config(board)
        config['widges'].find{ |widge| widge['id'] == widge_id }
      end

      def save_layout(board, data)
        File.open("#{data_path}/layout/#{board}.json", 'w') { |file| file.write(data.to_json) }
      end
      
      
      private 
     
      def get_board_layout(config)
        path = "#{data_path}/layout/#{config['board']}.json"
        return unless File.exists?(path)
        layout = JSON.load(File.read(path))
        return unless layout
        config['widges'].each do |widge|
          widge_layout = layout[widge['id']]
          widge_layout.keys.each{ |prop| widge[prop] = widge_layout[prop] } if widge_layout
        end
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
