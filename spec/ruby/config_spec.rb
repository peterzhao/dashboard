require_relative '../../lib/ju' 
require 'rspec'
require 'json'
require 'fileutils'

describe Ju::Config do
  before :each do
    ENV['DATA_PATH'] = 'spec/data'
    config_data = {'widgets' => [
      {'name' => "widget1", "type" => "gocd_pipeline", "base_url" => "http://abc.com/", "col" => 1, "row" => 1, "sizex" => 2, "sizey" => 3},
      {'name' => "widget2", "type" => "curl", "base_url" => "http://cde.com/", "col" => 2, "row" => 1, "sizex" => 2, "sizey" => 3}
    ],
    'base_sizex' => '280',
    'base_sizey' => '140'
    }
    File.open("spec/data/config/temp.json", 'w') { |file| file.write(config_data.to_json) }
  end

  after :each do
    ENV['DATA_PATH'] = nil
    FileUtils.rm_f 'spec/data/config/temp.json' 
  end

  it 'should delete board' do
    Ju::Config.delete_board('temp')
    expect(Ju::Config.get_all_boards).not_to include('temp')
  end

  it 'should delete widiget' do
    Ju::Config.delete_widget('temp', 'widget2')
    expect(Ju::Config.get_board_config('temp')['widgets'].find{ |w| w['name'] == 'widget2' }).to be_nil
  end

  it 'should create default config if it does not exist' do
    FileUtils.rm_f 'spec/data/config/Default.json'
    config = Ju::Config.get_board_config('Default')
    expect(config['board']).to eq('Default')
    expect(File.exists?('spec/data/config/Default.json')).to be(true)
  end

  it 'should get board config' do
    config = Ju::Config.get_board_config('temp')
    expect(config['board']).to eq('temp')
    expect(config['widgets'][0]['name']).to eq('widget1')
    expect(config['widgets'][0]['type']).to eq('gocd_pipeline')
    expect(config['widgets'][0]['base_url']).to eq('http://abc.com/')
    expect(config['widgets'][0]['row']).to eq(1)
    expect(config['widgets'][0]['col']).to eq(1)
    expect(config['widgets'][0]['sizex']).to eq(2)
    expect(config['widgets'][0]['sizey']).to eq(3)
    expect(config['widgets'][1]['name']).to eq('widget2')
    expect(config['widgets'][1]['type']).to eq('curl')
    expect(config['widgets'][1]['base_url']).to eq('http://cde.com/')
    expect(config['widgets'][1]['row']).to eq(1)
    expect(config['widgets'][1]['col']).to eq(2)
    expect(config['widgets'][1]['sizex']).to eq(2)
    expect(config['widgets'][1]['sizey']).to eq(3)
  end

  it 'should get widget config' do
    config = Ju::Config.get_widget_config('temp', 'widget1')

    expect(config['name']).to eq('widget1')
    expect(config['type']).to eq('gocd_pipeline')
  end
  
  it 'should save layout' do
    data = {
      "widget1" => {"row" => 1, "col" => 2, "sizex" => 2, "sizey" => 3},
      "widget2" => {"row" => 2, "col" => 3, "sizex" => 3, "sizey" => 4}
    }
    Ju::Config.save_layout('temp', data)
    widget1 = Ju::Config.get_widget_config('temp', 'widget1')
    widget2 = Ju::Config.get_widget_config('temp', 'widget2')
    expect(widget1['row']).to eq(1)
    expect(widget1['col']).to eq(2)
    expect(widget1['sizex']).to eq(2)
    expect(widget1['sizey']).to eq(3)
    expect(widget2['row']).to eq(2)
    expect(widget2['col']).to eq(3)
    expect(widget2['sizex']).to eq(3)
    expect(widget2['sizey']).to eq(4)
  end

  it 'should get all dashboard names' do
    expect(Ju::Config.get_all_boards).to include('temp')
  end
 
  context 'saving widget' do
    it 'should add new widget' do
      data = {'name' => 'widget3', 'url' => 'http://woo.com'}
      Ju::Config.save_widget('temp',data)
      expect(Ju::Config.get_widget_config('temp', 'widget3')['url']).to eq('http://woo.com')
    end
  end

  it 'should save a board' do
    FileUtils.rm_f 'spec/data/config/temp.json' 
    Ju::Config.save_board('temp', '330', '200')
    config = Ju::Config.get_board_config('temp')
    expect(config['board']).to eq('temp')
    expect(config['base_sizex']).to eq('330')
    expect(config['base_sizey']).to eq('200')
    expect(config['widgets']).to eq([])
  end

  it 'should save a board with widgets' do
    widgets = [{'name' => 'widget1'}]
    FileUtils.rm_f 'spec/data/config/temp.json' 
    Ju::Config.save_board('temp', '330', '200', widgets)
    config = Ju::Config.get_board_config('temp')
    expect(config['board']).to eq('temp')
    expect(config['base_sizex']).to eq('330')
    expect(config['base_sizey']).to eq('200')
    expect(config['widgets'][0]['name']).to eq(widgets[0]['name'])
  end
end
