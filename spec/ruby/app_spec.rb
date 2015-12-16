ENV['RACK_ENV'] = 'test'

require_relative '../../app.rb' 
require_relative '../../lib/dashboard' 
require 'rspec'
require 'rack/test'

describe 'Dashboard App' do
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
    expect(Dashboard::Config).to receive(:get_board_config).with('boo').and_return(config)
    expect(Dashboard::Widge).to receive(:fill_template_and_style).with(config).and_return(config)
    get '/board/boo'
    expect(last_response).to be_ok 
  end

  it "should check widge" do
    config = {'type' => 'gocd'}
    expect(Dashboard::Config).to receive(:get_widge_config).with('boo', 'myApp').and_return(config)
    expect(Dashboard::Plugin).to receive(:check).with('gocd', config).and_return('good')

    get '/board/boo/widge/myApp'

    expect(last_response).to be_ok 
    expect(last_response.body).to eq('good')
  end
end
