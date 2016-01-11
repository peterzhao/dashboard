require 'fileutils'
require 'json'
module Ju
  class Config
    class << self
      def get_board_config(board)
        create_default_board_if_missing if board == 'Default'
        config = JSON.load(File.read("#{data_path}/config/#{board}.json"))
        config['board'] = board 
        get_board_layout(config)
        config
      end
      
      def get_widge_config(board, widge_name)
        config = get_board_config(board)
        config['widges'].find{ |widge| widge['name'] == widge_name }
      end

      def save_layout(board, data)
        File.open("#{data_path}/layout/#{board}.json", 'w') { |file| file.write(data.to_json) }
      end

      def new_board(board_name)
        data = <<EOS
{
  "widges": []
}
EOS
        File.open("#{data_path}/config/#{board_name}.json", 'w') { |file| file.write(data) }
      end

      def get_all_boards
        Dir.glob("#{data_path}/config/*.json").select{ |e| File.file? e }.map{|f| File.basename(f, '.json')} 
      end
      
      private 
     
      def get_board_layout(config)
        path = "#{data_path}/layout/#{config['board']}.json"
        if File.exists?(path)
          layout = JSON.load(File.read(path))
          return unless layout
          config['widges'].each do |widge|
            widge_layout = layout[widge['name']]
            widge_layout.keys.each{ |prop| widge[prop] = widge_layout[prop] } if widge_layout
          end
        else
          config['widges'].each_with_index do |widge, index|
            widge['row'] = ((index/3) + 1).to_s 
            widge['col'] = ((index%3) + 1).to_s 
            widge['sizex'] = "1" 
            widge['sizey'] = "1" 
          end 
        end
      end

      def data_path
        return ENV['DATA_PATH'] if ENV['DATA_PATH']
        'data'
      end
      
      def create_default_board_if_missing
        path = "#{data_path}/config/Default.json"
        return if(File.exists?(path))
        template = File.expand_path('../../../data/templates/default.json', __FILE__)
        FileUtils.cp(template, "#{data_path}/config/Default.json")
      end
    end
  end
end
