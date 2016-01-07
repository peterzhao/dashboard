ENV['RACK_ENV'] = 'test'

require_relative '../../app.rb' 
require_relative '../../lib/ju' 
require 'rspec'
require 'rack/test'

describe 'Ju App' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it "should redirect to /board/default when getting /" do
    get '/'
    expect(last_response.status).to eq(302)
    expect(last_response.header['Location']).to match(/board\/default$/) 
  end

  it "should get board" do
    config = {'board' => 'test',
              'styles' => {},
              'widges' => [ {'type' => 'gocd', 'name' => 'foo'} ]
              } 
    expect(Ju::Config).to receive(:get_board_config).with('boo').and_return(config)
    expect(Ju::Board).to receive(:fill_template_and_style).with(config).and_return(config)
    get '/board/boo'
    expect(last_response).to be_ok 
  end

  it "should check widge" do
    config = {'type' => 'gocd'}
    expect(Ju::Config).to receive(:get_widge_config).with('boo', 'myApp').and_return(config)
    expect(Ju::Plugin).to receive(:check).with('gocd', config).and_return('good')

    get '/board/boo/widge/myApp'

    expect(last_response).to be_ok 
    expect(last_response.body).to eq('good')
  end

  it "should save layout for a board" do
    data_str = '{"widge1": {"row":1, "col":1}}'
    data = JSON.parse(data_str)
    expect(Ju::Config).to receive(:save_layout).with('boo', data)
    post '/board/boo/layout', data_str , "CONTENT_TYPE" => "application/json" 
    expect(last_response).to be_ok 
  end
end
