require_relative '../../lib/dashboard' 
require 'rspec'
require 'json'
require 'fileutils'

describe Dashboard::Config do
  before :each do
    ENV['DATA_PATH'] = 'spec/data'
  end

  after :each do
    ENV['DATA_PATH'] = nil
  end

  it 'should create default config if it does not exist' do
    FileUtils.rm_f 'spec/data/config/default.json'
    config = Dashboard::Config.get_board_config('default')
    expect(config['board']).to eq('default')
    expect(File.exists?('spec/data/config/default.json')).to be(true)
  end

  it 'should get board config' do
    config = Dashboard::Config.get_board_config('boo')

    expect(config['board']).to eq('boo')
    expect(config['widges'][0]['id']).to eq('foo')
    expect(config['widges'][0]['row']).to eq(1)
    expect(config['widges'][0]['col']).to eq(2)
    expect(config['widges'][0]['sizex']).to eq(3)
    expect(config['widges'][0]['sizey']).to eq(4)
  end

  it 'should get widge config' do
    config = Dashboard::Config.get_widge_config('boo', 'foo')

    expect(config['name']).to eq('foo')
    expect(config['id']).to eq('foo')
    expect(config['type']).to eq('gocd_pipeline')
  end
  
  it 'should save layout' do
    FileUtils.rm_f 'spec/data/layout/temp.json' 
    data = {"widge1" => {"row" => 1, "col" => 2}}
    Dashboard::Config.save_layout('temp', data)

    expect(File.read('spec/data/layout/temp.json')).to eq(data.to_json)
  end
end
