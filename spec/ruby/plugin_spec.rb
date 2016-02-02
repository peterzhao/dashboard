require 'rspec'
require_relative '../../lib/ju'

class TestPlugin < Ju::Plugin 
end

describe Ju::Plugin do
  let(:test_plugin) { double('test_plugin') }
  let(:options) { {} }

  before :each do
    allow(TestPlugin).to receive(:new).with(options).and_return(test_plugin)
    Ju::Plugin.register('test_plugin', TestPlugin)
  end
  
  it 'should get plugin types' do
    expect(Ju::Plugin.types).to include('test_plugin')
  end
  it 'should get data from plugin when check' do
    expect(test_plugin).to receive(:check)
    Ju::Plugin.check('test_plugin', options)
  end

  it 'should get style from plugin' do
    expect(test_plugin).to receive(:style)
    Ju::Plugin.style('test_plugin', options)
  end

  it 'should get config ui from plugin' do
    expect(test_plugin).to receive(:config).and_return([{'name' => 'url'}])
    config = Ju::Plugin.config('test_plugin')
    expect(config.find{ |c| c['name'] == 'url' }).not_to be_nil
    expect(config.first).to eq(
          {
            'name' => 'name',
            'description' => 'Widget Name',
            'validate' => '^[0-9a-zA-Z\-_ ]+$',
            'validation_message' => 'Widget Name cannot be empty and should contain only alphanumeric characters, underscore and hyphen.'
          })
    expect(config.last).to eq(
          {
            'name' => 'pull_inteval',
            'description' => 'Pull Inteval',
            'validate' => '^[0-9]+$',
            'validation_message' => 'Pull Inteval must be digits.',
            'default' => 5
          })
  end

  it 'should get error when cannot find the plugin' do
    expect{Ju::Plugin.check('foo', options)}.to raise_error('Could not find the plugin foo!')
  end
end
