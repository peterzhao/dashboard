module Ju
  class LayoutPacker
    def self.pack(widgets)
      widget_to_put = widgets.find { |w| w['row'].nil? || w['col'].nil? }
      return unless widget_to_put
      flat = get_flat(widgets.select{ |w| w['row'] && w['col'] })
      row, col = get_next_row_col(flat)
      widget_to_put['row'] = row
      widget_to_put['col'] = col
      widget_to_put['sizex'] = 1
      widget_to_put['sizey'] = 1
      pack(widgets)
    end

    private 

    def self.get_flat(widgets)
      flat = {}
      return flat if widgets.empty?
      widgets.each do |widget|
        widget_row = widget['row'].to_i
        widget_col = widget['col'].to_i
        sizex = (widget['sizex'] || 1).to_i
        sizey = (widget['sizey'] || 1).to_i
        (widget_row..(widget_row + sizey -1 )).each do |row|
          flat[row] ||= []
          (widget_col..(widget_col + sizex -1)).each do |col|
            flat[row] << col
          end
          flat[row].uniq!
        end
      end
      return flat
    end

    def self.get_next_row_col(flat)
      return 1, 1 if flat.keys.empty?
      for row in flat.keys.sort
        for col in 1..3
          return row, col unless flat[row].include?(col)
        end
      end
      return flat.keys.max + 1, 1 
    end
  end
end
