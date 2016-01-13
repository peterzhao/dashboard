require_relative '../../lib/ju' 
require 'rspec'

describe Ju::Widget do
  let(:settings) {
    [
      {
        'name' => 'name',
        'description' => 'widget Name',
        'validate' => '^[0-9a-zA-Z\-_ ]+$',
        'validation_message' => 'widget Name cannot be empty or contain special characters'
      },
      {
        'name' => 'base_url',
        'description' => 'Server Base URL',
        'validate' => '^[0-9a-zA-Z\-_:/.]+$',
        'validation_message' => 'Server base URL is not a valid URL'
      }
    ]
  }

  context 'valiation' do
    it 'given data is invalid' do
      data = {'name' => 'ff/dd', 'base_url' => ''}
      expect(Ju::Widget.validate(settings, data)).to eq(['widget Name cannot be empty or contain special characters', 'Server base URL is not a valid URL'])
    end

    it 'given data is valid' do
      data = {'name' => 'mywidget', 'base_url' => 'http://abc.com/gocd'}
      expect(Ju::Widget.validate(settings, data)).to be_empty 
    end
  end

  it 'create widget' do
    data = {'name' => 'mywidget', 'base_url' => 'http://abc.com/gocd', 'other' => 'should not be saved'}
    expect(Ju::Config).to receive(:save_widget).with('boo', 'curl', {'name'=> 'mywidget', 'base_url' => 'http://abc.com/gocd'})
    Ju::Widget.create('boo', 'curl', settings, data)
  end
end
