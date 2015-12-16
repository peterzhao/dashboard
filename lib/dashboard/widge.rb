module Dashboard
  class Widge
    def self.fill_template_and_style(board_config)
      board_config['styles'] = {}
      board_config['widges'].each do |widge|
        widge['template'] = Dashboard::Plugin.template(widge['type'], widge)
        board_config['styles'][widge['type']] = Dashboard::Plugin.style(widge['type'], widge) unless board_config['styles'][widge['type']]
      end
    end
  end
end
