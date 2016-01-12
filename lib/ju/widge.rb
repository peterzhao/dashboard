module Ju
  class Widge
    def self.validate(settings, data)
      errors = []
      settings.each do |setting|
        errors << setting['validation_message'] unless data[setting['name']] && data[setting['name']] =~ /#{setting['validate']}/
      end
      errors
    end

    def self.create(board_name, widge_type, settings, data)
      data_to_save = {}
      settings.each do |setting|
        data_to_save[setting['name']] = data[setting['name']]
      end
      Ju::Config.save_widge(board_name, widge_type, data_to_save)
    end
  end
end
