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

  it 'should get ui template from plugin' do
    expect(test_plugin).to receive(:template)
    Ju::Plugin.template('test_plugin', options)
  end

  it 'should get style from plugin' do
    expect(test_plugin).to receive(:style)
    Ju::Plugin.style('test_plugin', options)
  end

  it 'should get config ui from plugin' do
    expect(test_plugin).to receive(:config)
    Ju::Plugin.config('test_plugin')
  end

  it 'should get error when cannot find the plugin' do
    expect{Ju::Plugin.check('foo', options)}.to raise_error('Could not find the plugin foo!')
  end
end
