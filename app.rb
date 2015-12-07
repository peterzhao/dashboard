require 'sinatra'
require 'json'
require_relative 'lib/dashboard'

set :bind, '0.0.0.0'

helpers do
  def widge_id(widge_name)
    widge_name.gsub(' ', '-').gsub('_', '-')
  end
end

get '/' do
  redirect to('/board/default')
end

get '/board/:board_name' do
  config = JSON.load(File.read("config/#{params['board_name']}.json"))
  config['styles'] = {}
  config['board'] = params['board_name'] 
  config['widges'].each do |widge|
    widge['id'] = widge_id(widge['name'])
    widge['template'] = Dashboard::Plugin.template(widge['type'], widge)
    config['styles'][widge['type']] = Dashboard::Plugin.style(widge['type'], widge) unless config['styles'][widge['type']]
  end
  erb :home, :locals => {:config => config}
end

get '/board/:board_name/widge/:widge_id' do
  config = JSON.load(File.read("config/#{params['board_name']}.json"))
  widge = config['widges'].find{ |widge| widge_id(widge['name']) == params['widge_id'] }
  Dashboard::Plugin.check(widge['type'], widge)
end
