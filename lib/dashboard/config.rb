module Dashboard
  class Config
    def self.get_board_config(board_name)
      config = JSON.load(File.read("config/#{board_name}.json"))
      config['board'] = board_name 
      config['widges'].each do |widge|
        widge['id'] = canonicalize(widge['name'])
      end
      config
    end
    
    def self.get_widge_config(board_name, widge_id)
      config = Dashboard::Config.get_board_config(board_name)
      config['widges'].find{ |widge| widge['id'] == widge_id }
    end
    
    def self.canonicalize(name)
      name.gsub(' ', '-').gsub('_', '-')
    end
  end
end
