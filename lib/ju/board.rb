module Ju
  class Board
    def self.fill_template_and_style(board_config)
      board_config['styles'] = {}
      board_config['widges'].each do |widge|
        widge['template'] = Ju::Plugin.template(widge['type'], widge)
        board_config['styles'][widge['type']] = Ju::Plugin.style(widge['type'], widge) unless board_config['styles'][widge['type']]
      end
    end

    def self.validate(board_name)
      board_name ||= ''
      return 'Dashboard name cannot be empty!' if board_name.strip.empty?
      return 'Dashboard name cannot contain any special characters!' unless board_name =~ /^[a-zA-Z0-9\-_ ]+$/
      return  "The dashboard #{board_name} already exists!" if Ju::Config.get_all_boards.any?{|name| name.downcase == board_name.downcase } 
      '' 
    end

    def self.create(board_name)
      Ju::Config.new_board board_name
    end
  end
end
