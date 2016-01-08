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

  it "should redirect to /boards/Default when getting /" do
    get '/'
    expect(last_response.status).to eq(302)
    expect(last_response.header['Location']).to match(/boards\/Default$/) 
  end

  it "should get board" do
    config = {'board' => 'test',
              'styles' => {},
              'widges' => [ {'type' => 'gocd', 'name' => 'foo'} ]
              } 
    expect(Ju::Config).to receive(:get_board_config).with('boo').and_return(config)
    expect(Ju::Board).to receive(:fill_template_and_style).with(config).and_return(config)
    expect(Ju::Config).to receive(:get_all_boards).and_return(['test', 'moo'])
    get '/boards/boo'
    expect(last_response).to be_ok 
  end

  it "should check widge" do
    config = {'type' => 'gocd'}
    expect(Ju::Config).to receive(:get_widge_config).with('boo', 'myApp').and_return(config)
    expect(Ju::Plugin).to receive(:check).with('gocd', config).and_return('good')

    get '/boards/boo/widges/myApp'

    expect(last_response).to be_ok 
    expect(last_response.body).to eq('good')
  end

  it "should save layout for a board" do
    data_str = '{"widge1": {"row":1, "col":1}}'
    data = JSON.parse(data_str)
    expect(Ju::Config).to receive(:save_layout).with('boo', data)
    post '/boards/boo/layout', data_str , "CONTENT_TYPE" => "application/json" 
    expect(last_response).to be_ok 
  end

  it "should get a new board form" do
    get '/board/new'
    expect(last_response.status).to eq(200)
    expect(last_response.body).to match(/New Dashboard/) 
  end


  it "should create a new board whose name contains space" do
    expect(Ju::Board).to receive(:validate).with('good one').and_return([])
    expect(Ju::Board).to receive(:create).with('good one')
    post '/board', :board_name => 'good one'
    expect(last_response.status).to eq(303)
    expect(last_response.header['Location']).to match(/boards\/good%20one$/) 
  end


  it "should not create a new board if the board validate has errors" do
    expect(Ju::Board).to receive(:validate).with('bad one').and_return(['not good'])
    expect(Ju::Board).not_to receive(:create).with('bad one')
    post '/board', :board_name => 'bad one'

    expect(last_response.status).to eq(303)
    expect(last_response.header['Location']).to match(/board\/new/) 
  end

end
