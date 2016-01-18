require 'fileutils'
require 'json'
module Ju
  class Config
    class << self
      def get_board_config(board)
        create_default_board_if_missing if board == 'Default'
        config = JSON.load(File.read("#{data_path}/config/#{board}.json"))
        config['board'] = board 
        Ju::LayoutPacker.pack(config['widgets'])
        config
      end
      
      def get_widget_config(board, widget_name)
        config = get_board_config(board)
        config['widgets'].find{ |widget| widget['name'] == widget_name }
      end

      def save_layout(board, data)
        board_config = get_board_config(board)
        board_config['widgets'].each do |widge|
          layout = data[widge['name']]
          layout.keys.each {|key| widge[key] = layout[key]} if layout
        end
        File.open("#{data_path}/config/#{board}.json", 'w') { |file| file.write(board_config.to_json) }
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

      def save_widget(board, widget_type, data, old_widget_name)
        board_config = get_board_config(board)
        data['type'] = widget_type
        if old_widget_name
          old_widget = board_config['widgets'].find{|widget| widget['name'].strip.downcase == old_widget_name.strip.downcase }
          old_widget.merge!(data)
        else
          board_config['widgets'] << data
        end
        File.open("#{data_path}/config/#{board}.json", 'w') { |file| file.write(board_config.to_json) }
      end

      def delete_widget(board, widget)
        board_config = get_board_config(board)
        widget = board_config['widgets'].find{ |w| w['name'] == widget }
        board_config['widgets'].delete(widget)
        File.open("#{data_path}/config/#{board}.json", 'w') { |file| file.write(board_config.to_json) }
      end
      
      private 

      def set_layout(config)
        widget_without_layout = config['widgets'].find{|widget| widget['row'].nil? ||  widget['col'].nil? }
        return unless widget_without_layout 
        max_row, max_col = get_max_row_col(config['widgets'].select{ |w| w['row'] && w['col'] }) 
        if(max_col < 3)
          widget_without_layout['row'] = max_row
          widget_without_layout['col'] = max_col + 1
        else
          widget_without_layout['row'] = max_row + 1
          widget_without_layout['col'] = 1
        end
        widget_without_layout['sizex'] = 1
        widget_without_layout['sizey'] = 1
        set_layout(config)
      end

      def get_max_row_col(widgets)
        return 1, 0 if widgets.empty?
        bottom_right_points = widgets.map{ |w| [w['row'].to_i * (w['sizey'] || 1).to_i, w['col'].to_i * (w['sizex'] || 1).to_i ] }
        max_row = 1
        max_col = 1
        bottom_right_points.each { |p| max_row = p[0] if p[0] > max_row }
        bottom_right_points.each { |p| max_col = p[1] if p[1] > max_col && p[0] == max_row }
        return max_row, max_col
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
