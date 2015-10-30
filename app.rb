require 'sinatra'
require 'json'

set :bind, '0.0.0.0'

get '/' do
  config = JSON.load(File.read('config/main.json'))
  erb :home, :locals => {:config => config}
end
