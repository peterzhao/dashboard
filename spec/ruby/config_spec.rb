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
    expect(config['widgets'][0]['name']).to eq('foo')
    expect(config['widgets'][0]['row']).to eq("1")
    expect(config['widgets'][0]['col']).to eq("2")
    expect(config['widgets'][0]['sizex']).to eq("3")
    expect(config['widgets'][0]['sizey']).to eq("4")
  end

  it 'should get widget config' do
    config = Ju::Config.get_widget_config('boo', 'foo')

    expect(config['name']).to eq('foo')
    expect(config['name']).to eq('foo')
    expect(config['type']).to eq('gocd_pipeline')
  end
  
  it 'should save layout' do
    FileUtils.rm_f 'spec/data/layout/temp.json' 
    data = {"widget1" => {"row" => 1, "col" => 2}}
    Ju::Config.save_layout('temp', data)

    expect(File.read('spec/data/layout/temp.json')).to eq(data.to_json)
  end

  it 'should get all dashboard names' do
    expect(Ju::Config.get_all_boards).to include('boo')
  end

  it 'should set default layout if not exist when loading board config' do
    FileUtils.rm_f 'spec/data/layout/temp.json' 
    FileUtils.rm_f 'spec/data/config/temp.json' 
    config_data = {'widgets' => [
      {'name' => "widget0"},
      {'name' => "widget1"},
      {'name' => "widget2"},
      {'name' => "widget3"},
      {'name' => "widget4"},
      {'name' => "widget5"}
    ]}
    File.open("spec/data/config/temp.json", 'w') { |file| file.write(config_data.to_json) }
    config = Ju::Config.get_board_config('temp')
    expect(config['widgets'][0]['name']).to eq('widget0')
    expect(config['widgets'][0]['row']).to eq("1")
    expect(config['widgets'][0]['col']).to eq("1")
    expect(config['widgets'][0]['sizex']).to eq("1")
    expect(config['widgets'][0]['sizey']).to eq("1")

    expect(config['widgets'][1]['name']).to eq('widget1')
    expect(config['widgets'][1]['row']).to eq("1")
    expect(config['widgets'][1]['col']).to eq("2")

    expect(config['widgets'][2]['name']).to eq('widget2')
    expect(config['widgets'][2]['row']).to eq("1")
    expect(config['widgets'][2]['col']).to eq("3")

    expect(config['widgets'][3]['name']).to eq('widget3')
    expect(config['widgets'][3]['row']).to eq("2")
    expect(config['widgets'][3]['col']).to eq("1")

    expect(config['widgets'][4]['name']).to eq('widget4')
    expect(config['widgets'][4]['row']).to eq("2")
    expect(config['widgets'][4]['col']).to eq("2")

    expect(config['widgets'][5]['name']).to eq('widget5')
    expect(config['widgets'][5]['row']).to eq("2")
    expect(config['widgets'][5]['col']).to eq("3")
  end

  it 'should set layout for widgetts which have no layout' do
    FileUtils.rm_f 'spec/data/layout/temp.json' 
    FileUtils.rm_f 'spec/data/config/temp.json' 
    config_data = {'widgets' => [
      {'name' => "widget0"},
      {'name' => "widget1"}
    ]}
    layout = {'widget0' => {'row' => 2, 'col' => 1, 'sizex' => 2, 'sizey' => 3}}
    File.open("spec/data/config/temp.json", 'w') { |file| file.write(config_data.to_json) }
    File.open("spec/data/layout/temp.json", 'w') { |file| file.write(layout.to_json) }
    config = Ju::Config.get_board_config('temp')
    expect(config['widgets'][0]['name']).to eq('widget0')
    expect(config['widgets'][0]['row']).to eq("1")
    expect(config['widgets'][0]['col']).to eq("1")
    expect(config['widgets'][0]['sizex']).to eq("1")
    expect(config['widgets'][0]['sizey']).to eq("1")

    expect(config['widgets'][1]['name']).to eq('widget1')
    expect(config['widgets'][1]['row']).to eq("1")
    expect(config['widgets'][1]['col']).to eq("2")
  end
 
  context 'saving widget' do
    before :each do
      FileUtils.rm_f 'spec/data/config/temp.json' 
      FileUtils.rm_f 'spec/data/layout/temp.json' 
      config_data = {'widgets' => [
        {'name' => "widget1", 'url' => 'abc', 'type' => 'curl'},
        {'name' => "widget2", 'url' => 'def', 'type' => 'gocd'}
      ]}
      File.open("spec/data/config/temp.json", 'w') { |file| file.write(config_data.to_json) }
    end

    it 'should add new widget' do
      data = {'name' => 'widget3', 'url' => 'ghi'}
      Ju::Config.save_widget('temp', 'gocd', data)
      expect(Ju::Config.get_widget_config('temp', 'widget3')['url']).to eq('ghi')
      expect(Ju::Config.get_widget_config('temp', 'widget1')['url']).to eq('abc')
      expect(Ju::Config.get_widget_config('temp', 'widget2')['url']).to eq('def')
      expect(Ju::Config.get_widget_config('temp', 'widget3')['type']).to eq('gocd')
    end

    it 'should update widget' do
      data = {'name' => 'widget2', 'url' => 'ghi'}
      Ju::Config.save_widget('temp', 'gocd', data)
      expect(Ju::Config.get_widget_config('temp', 'widget2')['url']).to eq('ghi')
      expect(Ju::Config.get_widget_config('temp', 'widget1')['url']).to eq('abc')
    end
  end
end
