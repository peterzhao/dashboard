module Ju
  class Widget
    def self.validate(settings, params)
      errors = []
      name = params['name'].downcase
      old_name = "#{params['old_name']}".downcase
      if old_name != name 
        board_config = Ju::Config.get_board_config(params['board_name'])
        return ["Widget #{params['name']} already exists!"] if board_config['widgets'].any?{ |w| w['name'].downcase == name }
      end
      settings.each do |setting|
        errors << setting['validation_message'] unless params[setting['name']] && params[setting['name']] =~ /#{setting['validate']}/
      end
      errors
    end

    def self.save(board_name, widget_type, settings, params)
      params_to_save = {}
      settings.each do |setting|
        params_to_save[setting['name']] = params[setting['name']]
      end
      params_to_save['type'] = widget_type
      if params['old_name']
        old_widget_config = Ju::Config.get_widget_config(board_name, params['old_name'])
        params_to_save = old_widget_config.merge(params_to_save) 
        Ju::Config.delete_widget(board_name, params['old_name'])
      end
      Ju::Config.save_widget(board_name, params_to_save)
    end
  end
end
