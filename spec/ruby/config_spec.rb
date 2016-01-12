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
    expect(config['widges'][0]['row']).to eq("1")
    expect(config['widges'][0]['col']).to eq("2")
    expect(config['widges'][0]['sizex']).to eq("3")
    expect(config['widges'][0]['sizey']).to eq("4")
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

  it 'should set default layout if not exist when loading board config' do
    FileUtils.rm_f 'spec/data/layout/temp.json' 
    FileUtils.rm_f 'spec/data/config/temp.json' 
    config_data = {'widges' => [
      {'name' => "widge0"},
      {'name' => "widge1"},
      {'name' => "widge2"},
      {'name' => "widge3"},
      {'name' => "widge4"},
      {'name' => "widge5"}
    ]}
    File.open("spec/data/config/temp.json", 'w') { |file| file.write(config_data.to_json) }
    config = Ju::Config.get_board_config('temp')
    expect(config['widges'][0]['name']).to eq('widge0')
    expect(config['widges'][0]['row']).to eq("1")
    expect(config['widges'][0]['col']).to eq("1")
    expect(config['widges'][0]['sizex']).to eq("1")
    expect(config['widges'][0]['sizey']).to eq("1")

    expect(config['widges'][1]['name']).to eq('widge1')
    expect(config['widges'][1]['row']).to eq("1")
    expect(config['widges'][1]['col']).to eq("2")

    expect(config['widges'][2]['name']).to eq('widge2')
    expect(config['widges'][2]['row']).to eq("1")
    expect(config['widges'][2]['col']).to eq("3")

    expect(config['widges'][3]['name']).to eq('widge3')
    expect(config['widges'][3]['row']).to eq("2")
    expect(config['widges'][3]['col']).to eq("1")

    expect(config['widges'][4]['name']).to eq('widge4')
    expect(config['widges'][4]['row']).to eq("2")
    expect(config['widges'][4]['col']).to eq("2")

    expect(config['widges'][5]['name']).to eq('widge5')
    expect(config['widges'][5]['row']).to eq("2")
    expect(config['widges'][5]['col']).to eq("3")
  end
 
  context 'saving widge' do
    before :each do
      FileUtils.rm_f 'spec/data/config/temp.json' 
      FileUtils.rm_f 'spec/data/layout/temp.json' 
      config_data = {'widges' => [
        {'name' => "widge1", 'url' => 'abc', 'type' => 'curl'},
        {'name' => "widge2", 'url' => 'def', 'type' => 'gocd'}
      ]}
      File.open("spec/data/config/temp.json", 'w') { |file| file.write(config_data.to_json) }
    end

    it 'should add new widge' do
      data = {'name' => 'widge3', 'url' => 'ghi'}
      Ju::Config.save_widge('temp', 'gocd', data)
      expect(Ju::Config.get_widge_config('temp', 'widge3')['url']).to eq('ghi')
      expect(Ju::Config.get_widge_config('temp', 'widge1')['url']).to eq('abc')
      expect(Ju::Config.get_widge_config('temp', 'widge2')['url']).to eq('def')
      expect(Ju::Config.get_widge_config('temp', 'widge3')['type']).to eq('gocd')
    end

    it 'should update widge' do
      data = {'name' => 'widge2', 'url' => 'ghi'}
      Ju::Config.save_widge('temp', 'gocd', data)
      expect(Ju::Config.get_widge_config('temp', 'widge2')['url']).to eq('ghi')
      expect(Ju::Config.get_widge_config('temp', 'widge1')['url']).to eq('abc')
    end

  end
end
