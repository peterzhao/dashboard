module Ju
  class Board
    def self.fill_template_and_style(board_config)
      board_config['styles'] = {}
      board_config['widges'].each do |widge|
        widge['template'] = Ju::Plugin.template(widge['type'], widge)
        board_config['styles'][widge['type']] = Ju::Plugin.style(widge['type'], widge) unless board_config['styles'][widge['type']]
      end
    end
  end
end
