module Ju
  class Widget
    def self.validate(settings, params)
      errors = []
      name = params['name'].strip.downcase
      if params['widget_action'] == 'new' || params['old_widget_name'] != name 
        board_config = Ju::Config.get_board_config(params['board_name'])
        return ["Widget #{params['name']} already exists!"] if board_config['widgets'].any?{ |w| w['name'].strip.downcase == name }
      end
      settings.each do |setting|
        errors << setting['validation_message'] unless params[setting['name']] && params[setting['name']] =~ /#{setting['validate']}/
      end
      errors
    end

    def self.save(board_name, widget_type, settings, params)
      params_to_save = {}
      settings.each do |setting|
        params_to_save[setting['name']] = params[setting['name']].strip
      end
      Ju::Config.save_widget(board_name, widget_type, params_to_save, params['old_widget_name'])
    end
  end
end
