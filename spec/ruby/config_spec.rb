require_relative '../../lib/dashboard' 
require 'rspec'
require 'fileutils'

describe Dashboard::Config do
  it 'should create default config if it does not exist' do
    expect(File).to receive(:exists?).with('data/config/default.json').and_return(false)
    expect(FileUtils).to receive(:cp)
    allow(File).to receive(:read).with('data/config/default.json').and_return('{"widges": [{"name": "boo widge"}]}')
    config = Dashboard::Config.get_board_config('default')
    expect(config['board']).to eq('default')
  end

  it 'should get board config' do
    allow(File).to receive(:read).with('data/config/boo.json').and_return('{"widges": [{"name": "boo widge"}]}')
    config = Dashboard::Config.get_board_config('boo')

    expect(config['board']).to eq('boo')
    expect(config['widges'][0]['id']).to eq('boo-widge')
  end

  it 'should get widge config' do
    allow(File).to receive(:read).with('data/config/boo.json').and_return('{"widges": [{"name":"foo"},{"name": "my widge"}]}')
    config = Dashboard::Config.get_widge_config('boo', 'my-widge')

    expect(config['name']).to eq('my widge')
    expect(config['id']).to eq('my-widge')
  end
end
