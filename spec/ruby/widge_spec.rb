require_relative '../../lib/dashboard' 
require 'rspec'

describe Dashboard::Widge do
  it 'should fill template and style for each widges on the board' do
    curl_template = double('curl_template')
    gocd_template = double('gocd_template')
    curl_style = double('curl_style')
    gocd_style = double('gocd_style')

    board_config = {'widges' => [
       {'name' => 'boo', 'type' => 'curl'}, 
       {'name' => 'foo', 'type' => 'gocd'} 
    ]}

    expect(Dashboard::Plugin).to receive(:template).with('curl', board_config['widges'][0]).and_return(curl_template)
    expect(Dashboard::Plugin).to receive(:style).with('curl', board_config['widges'][0]).and_return(curl_style)
    expect(Dashboard::Plugin).to receive(:template).with('gocd', board_config['widges'][1]).and_return(gocd_template)
    expect(Dashboard::Plugin).to receive(:style).with('gocd', board_config['widges'][1]).and_return(gocd_style)

    Dashboard::Widge.fill_template_and_style(board_config)
    
    expect(board_config['widges'][0]['template']).to eq(curl_template)
    expect(board_config['widges'][1]['template']).to eq(gocd_template)
    expect(board_config['styles']['curl']).to eq(curl_style)
    expect(board_config['styles']['gocd']).to eq(gocd_style)

  end
end
