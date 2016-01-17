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
    expect(Ju::Config).to receive(:new_board).with('foo')
    Ju::Board.create(' foo ')
  end

  context 'validation of dashboard name' do
    it 'should give errors if dashboard name is empty' do
      expect(Ju::Board.validate('  ')).to eq('Dashboard name cannot be empty!')
      expect(Ju::Board.validate(nil)).to eq('Dashboard name cannot be empty!')
    end

    it 'should give errors if dashboard name contains unexpected characters' do
      expect(Ju::Board.validate('ab/cd ')).to eq('Dashboard name can only contain letters, digits, space, hyphen and underscore!')
      expect(Ju::Board.validate('ab&!@#$%^&*():cd ')).to eq('Dashboard name can only contain letters, digits, space, hyphen and underscore!')
    end

    it 'should give errors if same name dashboard exists' do
      allow(Ju::Config).to receive(:get_all_boards).and_return(['foO', 'moo'])

      expect(Ju::Board.validate(' foo ')).to eq('The dashboard  foo  already exists!')
      expect(Ju::Board.validate('Foo')).to eq('The dashboard Foo already exists!')
    end

    it 'should give no errors if board name is valid' do
      allow(Ju::Config).to receive(:get_all_boards).and_return(['foo', 'moo'])

      expect(Ju::Board.validate('Production Applications')).to be_empty 
    end
  end
end
