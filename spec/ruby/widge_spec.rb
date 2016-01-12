require_relative '../../lib/ju' 
require 'rspec'

describe Ju::Widge do
  let(:settings) {
    [
      {
        'name' => 'name',
        'description' => 'Widge Name',
        'validate' => '^[0-9a-zA-Z\-_ ]+$',
        'validation_message' => 'Widge Name cannot be empty or contain special characters'
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
      expect(Ju::Widge.validate(settings, data)).to eq(['Widge Name cannot be empty or contain special characters', 'Server base URL is not a valid URL'])
    end

    it 'given data is valid' do
      data = {'name' => 'mywidge', 'base_url' => 'http://abc.com/gocd'}
      expect(Ju::Widge.validate(settings, data)).to be_empty 
    end
  end

  it 'create widge' do
    data = {'name' => 'mywidge', 'base_url' => 'http://abc.com/gocd', 'other' => 'should not be saved'}
    expect(Ju::Config).to receive(:save_widge).with('boo', 'curl', {'name'=> 'mywidge', 'base_url' => 'http://abc.com/gocd'})
    Ju::Widge.create('boo', 'curl', settings, data)
  end
end
