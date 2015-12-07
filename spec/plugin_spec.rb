require 'rspec'
require_relative '../lib/dashboard'

class TestPlugin < Dashboard::Plugin 
end

describe Dashboard::Plugin do
  let(:test_plugin) { double('test_plugin') }
  let(:options) { {} }

  before :each do
    allow(TestPlugin).to receive(:new).with(options).and_return(test_plugin)
    Dashboard::Plugin.register('test_plugin', TestPlugin)
  end

  it 'should get data from plugin when check' do
    expect(test_plugin).to receive(:check)
    Dashboard::Plugin.check('test_plugin', options)
  end

  it 'should get ui template from plugin' do
    expect(test_plugin).to receive(:template)
    Dashboard::Plugin.template('test_plugin', options)
  end

  it 'should get config ui from plugin' do
    expect(test_plugin).to receive(:config)
    Dashboard::Plugin.config('test_plugin', options)
  end

  it 'should get error when cannot find the plugin' do
    expect{Dashboard::Plugin.check('foo', options)}.to raise_error('Could not find the plugin foo!')
  end
end
