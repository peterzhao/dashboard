module Ju
  class Board
    def self.add_style(board_config)
      board_config['styles'] = {}
      board_config['widgets'].each do |widget|
        board_config['styles'][widget['type']] = Ju::Plugin.style(widget['type'], widget) unless board_config['styles'][widget['type']]
      end
    end

    def self.validate(board_name, sizex, sizey, old_name = nil)
      errors = []
      errors << validate_name(board_name, old_name)
      errors << validate_size(sizex, 'X')
      errors << validate_size(sizey, 'Y')
      errors.compact
    end

    def self.save(board_name, sizex, sizey, old_name = nil, widgets = nil)
      Ju::Config.delete_board(old_name) if old_name && board_name.downcase != old_name.downcase
      Ju::Config.save_board(board_name, sizex, sizey, widgets)
    end

    private 

    def self.validate_name(board_name, old_name)
      return 'Dashboard name cannot be empty!' if board_name.empty?
      return 'Dashboard name should only contain alphanumeric characters, space, hyphen and underscore!' unless board_name =~ /^[a-zA-Z0-9\-_ ]+$/
      return  "The dashboard #{board_name} already exists!" if board_name.downcase != "#{old_name}".downcase && Ju::Config.get_all_boards.any?{|name| name.downcase == board_name.downcase } 
    end

    def self.validate_size(size, axis)
      return "Base Widget Size #{axis} can only be digits!" unless size =~ /^[0-9]+$/ 
      return "Base Widget Size #{axis} must be greater than 100." unless size.to_i >= 100 
    end
  end
end
