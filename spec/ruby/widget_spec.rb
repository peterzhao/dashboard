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
        data = {'name' => 'ff/dd', 'base_url' => '', 'board_name' => 'foo', 'widget_action' => 'new'}
        expect(Ju::Widget.validate(settings, data)).to eq(['Widget Name cannot be empty or contain special characters', 'Server base URL is not a valid URL'])
      end

      it 'given data is valid' do
        allow(Ju::Config).to receive(:get_board_config).with('foo').and_return({'widgets' => []})
        data = {'name' => 'mywidget', 'base_url' => 'http://abc.com/gocd','board_name' => 'foo', 'widget_action' => 'new'}
        expect(Ju::Widget.validate(settings, data)).to be_empty 
      end

      it 'widget already exists' do
        allow(Ju::Config).to receive(:get_board_config).with('foo').and_return({'widgets' => [{'name'=> 'myWidget'}]})
        data = {'name' => 'Mywidget', 'base_url' => 'http://abc.com/gocd', 'board_name' => 'foo', 'widget_action' => 'new'}
        expect(Ju::Widget.validate(settings, data)).to eq(['Widget Mywidget already exists!'])
      end
    end

    context 'edit widget' do
      it 'given data is valid' do
        allow(Ju::Config).to receive(:get_board_config).with('foo').and_return({'widgets' => [{'name' =>'mywidget'}]})
        data = {'name' => 'mywidget', 'base_url' => 'http://abc.com/gocd','board_name' => 'foo', 'widget_action' => 'edit', 'old_widget_name' => 'mywidget'}
        expect(Ju::Widget.validate(settings, data)).to be_empty 
      end

      it 'new widget name already exists' do
        allow(Ju::Config).to receive(:get_board_config).with('foo').and_return({'widgets' => [{'name'=> 'mywidget'}, {'name' => 'newName'}]})
        data = {'name' => 'newName', 'base_url' => 'http://abc.com/gocd', 'board_name' => 'foo', 'widget_action' => 'edit', 'old_widget_name' => 'mywidget'}
        expect(Ju::Widget.validate(settings, data)).to eq(['Widget newName already exists!'])
      end
    end
  end

  it 'save widget' do
    data = {'name' => 'mywidget', 'old_widget_name' => 'old_widget', 'base_url' => 'http://abc.com/gocd', 'other' => 'should not be saved'}
    expect(Ju::Config).to receive(:save_widget).with('boo', 'curl', {'name'=> 'mywidget', 'base_url' => 'http://abc.com/gocd'}, 'old_widget')
    Ju::Widget.save('boo', 'curl', settings, data)
  end
end
