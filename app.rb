require 'sinatra'
require 'json'

set :bind, '0.0.0.0'

helpers do
  def load_plugins
    load File.expand_path("../lib/ju.rb", __FILE__)
  end
end

get '/' do
  redirect to('/board/default')
end

get '/board/:board_name' do
  load_plugins
  config = Ju::Config.get_board_config(params['board_name'])
  Ju::Board.fill_template_and_style(config)
  erb :home, :locals => {:config => config}
end

get '/board/:board_name/widge/:widge_id' do
  load_plugins
  widge = Ju::Config.get_widge_config(params['board_name'], params['widge_id'])
  Ju::Plugin.check(widge['type'], widge)
end

post '/board/:board_name/layout' do
  layout = JSON.parse(request.body.read)
  Ju::Config.save_layout(params['board_name'], layout)
end
