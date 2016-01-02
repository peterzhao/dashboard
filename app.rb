require 'sinatra'
require 'json'

set :bind, '0.0.0.0'

helpers do
  def load_plugins
    load File.expand_path("../lib/dashboard.rb", __FILE__)
  end
end

get '/' do
  redirect to('/board/default')
end

get '/board/:board_name' do
  load_plugins
  config = Dashboard::Config.get_board_config(params['board_name'])
  Dashboard::Widge.fill_template_and_style(config)
  erb :home, :locals => {:config => config}
end

get '/board/:board_name/widge/:widge_id' do
  load_plugins
  widge = Dashboard::Config.get_widge_config(params['board_name'], params['widge_id'])
  Dashboard::Plugin.check(widge['type'], widge)
end

post '/board/:board_name/layout' do
  layout = JSON.parse(request.body.read)
  Dashboard::Config.save_layout(params['board_name'], layout)
end
