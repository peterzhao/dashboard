require_relative '../../lib/ju' 
require 'rspec'
require 'json'
require 'fileutils'

describe Ju::Config do
  before :each do
    ENV['DATA_PATH'] = 'spec/data'
  end

  after :each do
    ENV['DATA_PATH'] = nil
  end

  it 'should create default config if it does not exist' do
    FileUtils.rm_f 'spec/data/config/Default.json'
    config = Ju::Config.get_board_config('Default')
    expect(config['board']).to eq('Default')
    expect(File.exists?('spec/data/config/Default.json')).to be(true)
  end

  it 'should get board config' do
    config = Ju::Config.get_board_config('boo')

    expect(config['board']).to eq('boo')
    expect(config['widges'][0]['name']).to eq('foo')
    expect(config['widges'][0]['row']).to eq(1)
    expect(config['widges'][0]['col']).to eq(2)
    expect(config['widges'][0]['sizex']).to eq(3)
    expect(config['widges'][0]['sizey']).to eq(4)
  end

  it 'should get widge config' do
    config = Ju::Config.get_widge_config('boo', 'foo')

    expect(config['name']).to eq('foo')
    expect(config['name']).to eq('foo')
    expect(config['type']).to eq('gocd_pipeline')
  end
  
  it 'should save layout' do
    FileUtils.rm_f 'spec/data/layout/temp.json' 
    data = {"widge1" => {"row" => 1, "col" => 2}}
    Ju::Config.save_layout('temp', data)

    expect(File.read('spec/data/layout/temp.json')).to eq(data.to_json)
  end

  it 'should get all dashboard names' do
    expect(Ju::Config.get_all_boards).to include('boo')
  end

end
