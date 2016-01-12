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
              'widges' => [ {'type' => 'gocd', 'id' => 'foo', 'name' => 'foo'} ]
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
    get '/boards/new'
    expect(last_response.status).to eq(200)
    expect(last_response.body).to match(/New Dashboard/) 
  end


  it "should create a new board whose name contains space" do
    expect(Ju::Board).to receive(:validate).with('good one').and_return([])
    expect(Ju::Board).to receive(:create).with('good one')
    post '/boards', :board_name => 'good one'
    expect(last_response.status).to eq(303)
    expect(last_response.header['Location']).to match(/boards\/good%20one$/) 
  end


  it "should not create a new board if the board validate has errors" do
    expect(Ju::Board).to receive(:validate).with('bad one').and_return(['not good'])
    expect(Ju::Board).not_to receive(:create).with('bad one')
    post '/boards', :board_name => 'bad one'

    expect(last_response.status).to eq(400)
  end

  it "should get a new widge form" do
    allow(Ju::Config).to receive(:get_all_boards).and_return(['boo'])
    allow(Ju::Plugin).to receive(:types).and_return(['gocd_pipeline'])
    expect(Ju::Plugin).to receive(:config).with('gocd_pipeline').and_return([])
    get '/boards/boo/widges/new/gocd_pipeline'
    expect(last_response.status).to eq(200)
  end

  it "should get an error when getting a new widge form for an unexisting board" do
    allow(Ju::Config).to receive(:get_all_boards).and_return(['Default'])
    get '/boards/boo/widges/new/gocd_pipeline'
    expect(last_response.status).to eq(400)
  end

  it "should get an error when getting a new widge form of an unexisting widge type" do
    allow(Ju::Config).to receive(:get_all_boards).and_return(['boo'])
    allow(Ju::Plugin).to receive(:types).and_return(['curl'])
    get '/boards/boo/widges/new/gocd_pipeline'
    expect(last_response.status).to eq(400)
  end

  it "should get an error when creating a new widge of an unexisting board" do
    allow(Ju::Config).to receive(:get_all_boards).and_return([])
    post '/boards/boo/widges/gocd_pipeline'
    expect(last_response.status).to eq(400)
  end

  it "should get an error when creating a new widge of an unexisting widge type" do
    allow(Ju::Config).to receive(:get_all_boards).and_return(['boo'])
    allow(Ju::Plugin).to receive(:types).and_return(['curl'])
    post '/boards/boo/widges/gocd_pipeline'
    expect(last_response.status).to eq(400)
  end

  it "should create a new widge" do
    allow(Ju::Config).to receive(:get_all_boards).and_return(['boo'])
    allow(Ju::Plugin).to receive(:types).and_return(['curl'])

    settings = [{'name' => 'url'}]
    params = {'name' => 'mywidge'}
    allow(Ju::Plugin).to receive(:config).with('curl').and_return(settings)
    allow(Ju::Widge).to receive(:validate).with(settings, anything).and_return([])
    expect(Ju::Widge).to receive(:create).with('boo', 'curl', settings, anything)
    post '/boards/boo/widges/curl', params

    expect(last_response.status).to eq(303)
    expect(last_response.header['Location']).to match(/boards\/boo$/) 
  end

  it "should not create a new widge when validation failed" do
    allow(Ju::Config).to receive(:get_all_boards).and_return(['boo'])
    allow(Ju::Plugin).to receive(:types).and_return(['curl'])

    settings = [{'name' => 'url'}]
    params = {'name' => 'mywidge'}
    allow(Ju::Plugin).to receive(:config).with('curl').and_return(settings)
    allow(Ju::Widge).to receive(:validate).with(settings, anything).and_return(['something wrong'])
    expect(Ju::Widge).not_to receive(:create)

    post '/boards/boo/widges/curl', params

    expect(last_response.status).to eq(400)
  end
end
