require 'sinatra'
require 'json'
require 'sinatra/flash'
require 'rack/cache'
require_relative 'lib/ju/exception_handling'

use Rack::MethodOverride
use Ju::ExceptionHandling
use Rack::Cache
enable :sessions
set :bind, '0.0.0.0'
set :dump_errors, false
set :raise_errors, true
set :show_exceptions, false

helpers do
  def load_plugins
    load File.expand_path("../lib/ju.rb", __FILE__)
  end

  def save_board(widgets = nil)
    board_name = params['board_name']
    sizex = params['sizex']
    sizey = params['sizey']
    old_name = params['old_board_name']
    errors = Ju::Board.validate(board_name, sizex, sizey, old_name)
    if errors.empty? 
      Ju::Board.save(board_name, sizex, sizey, old_name, widgets)
      redirect to("/boards/#{URI.escape(board_name)}"), 303  
    else
      errors.each_with_index do |error, index|
        flash.now["error-message flash-#{index}"] = error
      end
      status 400
      erb :board_form, :locals => {:action => params['action']}
    end
  end

  def save_widget
    halt 400 unless Ju::Config.get_all_boards.include?(params['board_name'])
    halt 400 unless Ju::Plugin.types.include?(params['widget_type'])
    settings = Ju::Plugin.config(params['widget_type'])
    errors = Ju::Widget.validate(settings, params)
    if errors.empty? 
      Ju::Widget.save(params['board_name'], params['widget_type'], settings, params)
      redirect to("/boards/#{URI.escape(params['board_name'])}"), 303  
    else
      errors.each_with_index do |error, index|
        flash.now["error-message flash-#{index}"] = error
      end
      status 400
      erb :widget_form, :locals => { :settings => settings, :action => params['action'] }
    end
  end
end

before do
  load_plugins
  params.each do |key, value|
    params[key] = value.strip
  end
end

get '/' do
  redirect to("/boards/#{URI.escape(session['last_board'])}") if session['last_board'] && Ju::Config.get_all_boards.include?(session['last_board'])
  redirect to('/boards/Default')
end

get '/boards/new' do
  erb :board_form, :locals => {:action => 'new'}
end

get '/boards/:board_name' do
  cache_control :public, :max_age => 3
  config = Ju::Config.get_board_config(params['board_name'])
  other_boards = Ju::Config.get_all_boards - [params['board_name']]
  session['last_board'] = params['board_name']
  Ju::Board.add_style(config)
  erb :home, :locals => {:config => config, :other_boards => other_boards, :widget_types => Ju::Plugin.types}
end

get '/boards/:board_name/edit' do
  halt 400 unless Ju::Config.get_all_boards.include?(params['board_name'])
  config = Ju::Config.get_board_config(params['board_name'])
  params['sizex'] = config['base_sizex']
  params['sizey'] = config['base_sizey']
  params['old_board_name'] = params['board_name']
  erb :board_form, :locals => {:action => 'edit'}
end

post '/boards/:old_board_name' do
  halt 400 unless Ju::Config.get_all_boards.include?(params['old_board_name'])
  widgets = Ju::Config.get_board_config(params['old_board_name'])['widgets']
  save_board widgets
end

post '/boards' do
  save_board
end

get '/boards/:board_name/widgets/new/:widget_type' do
  halt 400 unless Ju::Config.get_all_boards.include?(params['board_name'])
  halt 400 unless Ju::Plugin.types.include?(params['widget_type'])
  erb :widget_form, :locals =>{:settings => Ju::Plugin.config(params['widget_type']), :action => 'new'}
end

get '/boards/:board_name/widgets/:name/edit' do
  params['old_name'] = params['name']
  halt 400 unless Ju::Config.get_all_boards.include?(params['board_name'])
  widget_config = Ju::Config.get_board_config(params['board_name'])['widgets'].find{ |w| w['name'] == params['name'] }
  halt 400 unless widget_config
  widget_type = widget_config['type']
  halt 400 unless Ju::Plugin.types.include?(widget_type)
  params['widget_type'] = widget_type
  settings = Ju::Plugin.config(widget_type)
  settings.each do |setting|
    params[setting['name']] = widget_config[setting['name']]
  end
  erb :widget_form, :locals =>{:settings => settings , :action => 'edit'}
end

post '/boards/:board_name/widgets/:old_name' do
  save_widget
end

post '/boards/:board_name/widgets' do
  save_widget
end

delete '/boards/:board_name' do
  halt 400 unless Ju::Config.get_all_boards.include?(params['board_name'])
  Ju::Config.delete_board(params['board_name'])
  redirect to("/"), 303
end

delete '/boards/:board_name/widgets/:name' do
  halt 400 unless Ju::Config.get_all_boards.include?(params['board_name'])
  Ju::Config.delete_widget(params['board_name'], params['name'])
  redirect to("/boards/#{URI.escape(params['board_name'])}"), 303
end


get '/boards/:board_name/widgets/:widget_name' do
  cache_control :public, :max_age => 3 # to avoid too much pull to the remote server
  widget = Ju::Config.get_widget_config(params['board_name'], params['widget_name'])
  Ju::Plugin.check(widget['type'], widget)
end

post '/boards/:board_name/layout' do
  layout = JSON.parse(request.body.read)
  Ju::Config.save_layout(params['board_name'], layout)
end
