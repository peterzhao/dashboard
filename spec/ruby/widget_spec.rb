require_relative '../../lib/ju' 
require 'rspec'

describe Ju::Widget do
  let(:settings) {
    [
      {
        'name' => 'name',
        'description' => 'widget Name',
        'validate' => '^[0-9a-zA-Z\-_ ]+$',
        'validation_message' => 'Widget Name cannot be empty or contain special characters'
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
    context 'new widget' do
      it 'given data is invalid' do
        allow(Ju::Config).to receive(:get_board_config).with('foo').and_return({'widgets' => []})
        data = {'name' => 'ff/dd', 'base_url' => '', 'board_name' => 'foo'}
        expect(Ju::Widget.validate(settings, data)).to eq(['Widget Name cannot be empty or contain special characters', 'Server base URL is not a valid URL'])
      end

      it 'given data is valid' do
        allow(Ju::Config).to receive(:get_board_config).with('foo').and_return({'widgets' => []})
        data = {'name' => 'mywidget', 'base_url' => 'http://abc.com/gocd','board_name' => 'foo'}
        expect(Ju::Widget.validate(settings, data)).to be_empty 
      end

      it 'widget already exists' do
        allow(Ju::Config).to receive(:get_board_config).with('foo').and_return({'widgets' => [{'name'=> 'myWidget'}]})
        data = {'name' => 'Mywidget', 'base_url' => 'http://abc.com/gocd', 'board_name' => 'foo'}
        expect(Ju::Widget.validate(settings, data)).to eq(['Widget Mywidget already exists!'])
      end
    end

    context 'edit widget' do
      it 'given data is valid' do
        allow(Ju::Config).to receive(:get_board_config).with('foo').and_return({'widgets' => [{'name' =>'mywidget'}]})
        data = {'name' => 'mywidget', 'base_url' => 'http://abc.com/gocd','board_name' => 'foo', 'old_name' => 'mywidget'}
        expect(Ju::Widget.validate(settings, data)).to be_empty 
      end

      it 'new widget name already exists' do
        allow(Ju::Config).to receive(:get_board_config).with('foo').and_return({'widgets' => [{'name'=> 'mywidget'}, {'name' => 'newName'}]})
        data = {'name' => 'newName', 'base_url' => 'http://abc.com/gocd', 'board_name' => 'foo', 'old_name' => 'mywidget'}
        expect(Ju::Widget.validate(settings, data)).to eq(['Widget newName already exists!'])
      end
    end
  end

  context 'save widget' do
    let(:old_widget_config){{
      'name' => 'old_widget',
      'base_url' => 'http://bad.com',
      'sizex' => '220'
    }}
    before :each do
      allow(Ju::Config).to receive(:get_widget_config).with('boo', 'old_widget').and_return(old_widget_config)
    end
    it 'rename widget' do
      params = {'name' => 'new_widget', 'old_name' => 'old_widget', 'base_url' => 'http://abc.com/gocd', 'other' => 'should not be saved'}
      expect(Ju::Config).to receive(:delete_widget).with('boo', 'old_widget')
      expect(Ju::Config).to receive(:save_widget).with('boo', {'name'=> 'new_widget', 'base_url' => 'http://abc.com/gocd', 'sizex' => '220', 'type' => 'curl'})
      Ju::Widget.save('boo', 'curl', settings, params)
    end

    it 'save widget' do
      params = {'name' => 'old_widget', 'old_name' => 'old_widget', 'base_url' => 'http://abc.com/gocd', 'other' => 'should not be saved'}
      expect(Ju::Config).to receive(:delete_widget).with('boo', 'old_widget')
      expect(Ju::Config).to receive(:save_widget).with('boo', {'name'=> 'old_widget', 'base_url' => 'http://abc.com/gocd', 'sizex' => '220', 'type' => 'curl'})
      Ju::Widget.save('boo', 'curl', settings, params)
    end

    it 'create widget' do
      params = {'name' => 'new_widget', 'base_url' => 'http://abc.com/gocd', 'other' => 'should not be saved'}
      expect(Ju::Config).not_to receive(:delete_widget)
      expect(Ju::Config).to receive(:save_widget).with('boo', {'name'=> 'new_widget', 'base_url' => 'http://abc.com/gocd', 'type' => 'curl'})
      Ju::Widget.save('boo', 'curl', settings, params)
    end
  end
end
