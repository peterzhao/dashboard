require_relative '../../lib/ju' 
require 'rspec'

describe Ju::Board do
  it 'should fill template and style for each widgets on the board' do
    curl_template = double('curl_template')
    gocd_template = double('gocd_template')
    curl_style = double('curl_style')
    gocd_style = double('gocd_style')

    board_config = {'widgets' => [
       {'name' => 'boo', 'type' => 'curl'}, 
       {'name' => 'foo', 'type' => 'gocd'} 
    ]}

    expect(Ju::Plugin).to receive(:template).with('curl', board_config['widgets'][0]).and_return(curl_template)
    expect(Ju::Plugin).to receive(:style).with('curl', board_config['widgets'][0]).and_return(curl_style)
    expect(Ju::Plugin).to receive(:template).with('gocd', board_config['widgets'][1]).and_return(gocd_template)
    expect(Ju::Plugin).to receive(:style).with('gocd', board_config['widgets'][1]).and_return(gocd_style)

    Ju::Board.fill_template_and_style(board_config)
    
    expect(board_config['widgets'][0]['template']).to eq(curl_template)
    expect(board_config['widgets'][1]['template']).to eq(gocd_template)
    expect(board_config['styles']['curl']).to eq(curl_style)
    expect(board_config['styles']['gocd']).to eq(gocd_style)
  end

  it 'should create a new dashboard' do
    expect(Ju::Config).to receive(:save_board).with('foo', '280', '140', nil)
    Ju::Board.save('foo', '280', '140')
  end

  it 'should save a dashboard' do
    widgets = [{'name' => 'widget1'}]
    expect(Ju::Config).to receive(:save_board).with('foo', '280', '140', widgets)
    Ju::Board.save('foo', '280', '140', 'foo', widgets)
  end

  it 'should rename a dashboard' do
    widgets = [{'name' => 'widget1'}]
    expect(Ju::Config).to receive(:delete_board).with('boo')
    expect(Ju::Config).to receive(:save_board).with('foo', '280', '140', widgets)
    Ju::Board.save('foo', '280', '140', 'boo', widgets)
  end
  context 'validation of dashboard' do
    it 'should give errors if dashboard name is empty' do
      expect(Ju::Board.validate('', '280', '140')).to eq(['Dashboard name cannot be empty!'])
    end

    it 'should give errors if dashboard name contains unexpected characters' do
      expect(Ju::Board.validate('ab/cd', '280', '140')).to eq(['Dashboard name can only contain letters, digits, space, hyphen and underscore!'])
      expect(Ju::Board.validate('ab&!@#$%^&*():cd', '280', '140')).to eq(['Dashboard name can only contain letters, digits, space, hyphen and underscore!'])
    end

    it 'should give errors if same name dashboard exists' do
      allow(Ju::Config).to receive(:get_all_boards).and_return(['foO', 'moo'])
      expect(Ju::Board.validate('Foo', '280', '140')).to eq(['The dashboard Foo already exists!'])
    end

    it 'should not give errors if validating an existing board' do
      allow(Ju::Config).to receive(:get_all_boards).and_return(['foO', 'moo'])
      expect(Ju::Board.validate('Foo', '280', '140', 'Foo')).to be_empty 
    end

    it 'should give errors if sizex is invalid' do
      allow(Ju::Config).to receive(:get_all_boards).and_return(['foo', 'moo'])
      expect(Ju::Board.validate('boo', 'abc', '140')).to eq(['Base Widget Size X can only be digits!'])
      expect(Ju::Board.validate('boo', '', '140')).to eq(['Base Widget Size X can only be digits!'])
      expect(Ju::Board.validate('boo', '99', '140')).to eq(['Base Widget Size X must be greater than 100.'])
    end

    it 'should give errors if sizey is invalid' do
      allow(Ju::Config).to receive(:get_all_boards).and_return(['foo', 'moo'])
      expect(Ju::Board.validate('boo', '200', '140pix')).to eq(['Base Widget Size Y can only be digits!'])
      expect(Ju::Board.validate('boo', '200', '')).to eq(['Base Widget Size Y can only be digits!'])
      expect(Ju::Board.validate('boo', '199', '40')).to eq(['Base Widget Size Y must be greater than 100.'])
    end

    it 'should give no errors if board name is valid' do
      allow(Ju::Config).to receive(:get_all_boards).and_return(['foo', 'moo'])

      expect(Ju::Board.validate('Production Applications', '280', '140')).to be_empty 
    end
  end
end
