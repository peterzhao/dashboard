require 'sinatra'
require 'json'
require 'sinatra/flash'

enable :sessions
set :bind, '0.0.0.0'

helpers do
  def load_plugins
    load File.expand_path("../lib/ju.rb", __FILE__)
  end
end

before do
  load_plugins
end

get '/' do
  redirect to('/boards/default')
end

get '/boards/:board_name' do
  config = Ju::Config.get_board_config(params['board_name'])
  other_boards = Ju::Config.get_all_boards - [params['board_name']]
  Ju::Board.fill_template_and_style(config)
  erb :home, :locals => {:config => config, :other_boards => other_boards}
end

get '/board/new' do
  erb :new_board
end

post '/board' do
  if "#{params['board_name']}".strip.empty? 
    flash[:'error-message'] = 'Dashboard name cannot be empty!'
    redirect to("/board/new"), 303  
  else
    Ju::Config.new_board params['board_name']
    redirect to("/boards/#{params['board_name']}"), 303  
  end
end

get '/boards/:board_name/widges/:widge_id' do
  widge = Ju::Config.get_widge_config(params['board_name'], params['widge_id'])
  Ju::Plugin.check(widge['type'], widge)
end

post '/boards/:board_name/layout' do
  layout = JSON.parse(request.body.read)
  Ju::Config.save_layout(params['board_name'], layout)
end
