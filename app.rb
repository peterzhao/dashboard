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
  redirect to("/boards/#{URI.escape(session['last_board'])}") if session['last_board'] && Ju::Config.get_all_boards.include?(session['last_board'])
  redirect to('/boards/Default')
end

get '/boards/new' do
  erb :new_board
end

get '/boards/:board_name' do
  config = Ju::Config.get_board_config(params['board_name'])
  other_boards = Ju::Config.get_all_boards - [params['board_name']]
  session['last_board'] = params['board_name']
  Ju::Board.fill_template_and_style(config)
  erb :home, :locals => {:config => config, :other_boards => other_boards, :widget_types => Ju::Plugin.types}
end


post '/boards' do
  errors = Ju::Board.validate(params['board_name'])
  if errors.empty? 
    Ju::Board.create params['board_name']
    redirect to("/boards/#{URI.escape(params['board_name'])}"), 303  
  else
    flash.now["error-message"] = errors
    status 400
    erb :new_board
  end
end

get '/boards/:board_name/widgets/new/:widget_type' do
  halt 400 unless Ju::Config.get_all_boards.include?(params['board_name'])
  halt 400 unless Ju::Plugin.types.include?(params['widget_type'])
  erb :new_widget, :locals =>{:settings => Ju::Plugin.config(params['widget_type'])}
end

post '/boards/:board_name/widgets/:widget_type' do
  halt 400 unless Ju::Config.get_all_boards.include?(params['board_name'])
  halt 400 unless Ju::Plugin.types.include?(params['widget_type'])
  settings = Ju::Plugin.config(params['widget_type'])
  errors = Ju::Widget.validate(settings, params)
  if errors.empty? 
    Ju::Widget.create(params['board_name'], params['widget_type'], settings, params)
    redirect to("/boards/#{URI.escape(params['board_name'])}"), 303  
  else
    errors.each_with_index do |error, index|
      flash.now["error-message flash-#{index}"] = error
    end
    status 400
    erb :new_widget, :locals => { :settings => settings }
  end

end

get '/boards/:board_name/widgets/:widget_name/edit' do
  'Under Construction!'
end

get '/boards/:board_name/widgets/:widget_name' do
  widget = Ju::Config.get_widget_config(params['board_name'], params['widget_name'])
  Ju::Plugin.check(widget['type'], widget)
end

post '/boards/:board_name/layout' do
  layout = JSON.parse(request.body.read)
  Ju::Config.save_layout(params['board_name'], layout)
end
