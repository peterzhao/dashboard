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
      
      def get_widget_config(board, widget_name)
        config = get_board_config(board)
        config['widgets'].find{ |widget| widget['name'] == widget_name }
      end

      def save_layout(board, data)
        File.open("#{data_path}/layout/#{board}.json", 'w') { |file| file.write(data.to_json) }
      end

      def new_board(board_name)
        data = <<EOS
{
  "widgets": []
}
EOS
        File.open("#{data_path}/config/#{board_name}.json", 'w') { |file| file.write(data) }
      end

      def get_all_boards
        Dir.glob("#{data_path}/config/*.json").select{ |e| File.file? e }.map{|f| File.basename(f, '.json')} 
      end

      def save_widget(board, widget_type, data)
        board_config = get_board_config(board)
        data['type'] = widget_type
        widget = board_config['widgets'].find{|widget| widget['name'] == data['name']}
        board_config['widgets'].delete(widget) if widget
        board_config['widgets'] << data
        File.open("#{data_path}/config/#{board}.json", 'w') { |file| file.write(board_config.to_json) }
      end
      
      private 
     
      def get_board_layout(config)
        path = "#{data_path}/layout/#{config['board']}.json"
        if File.exists?(path)
          layout = JSON.load(File.read(path))
          if layout.keys.count == config['widgets'].length
            config['widgets'].each do |widget|
              widget_layout = layout[widget['name']]
              widget_layout.keys.each{ |prop| widget[prop] = widget_layout[prop] } if widget_layout
            end
          return
          end
        end
        set_default_layout(config)
      end

      def set_default_layout(config)
        config['widgets'].each_with_index do |widget, index|
          widget['row'] = ((index/3) + 1).to_s 
          widget['col'] = ((index%3) + 1).to_s 
          widget['sizex'] = "1" 
          widget['sizey'] = "1" 
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
