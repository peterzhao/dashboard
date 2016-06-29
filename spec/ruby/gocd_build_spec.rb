require 'rspec'
require 'json'
require_relative '../../lib/ju'

describe Ju::GocdBuild do
  let(:options){{ 
    'base_url' => 'http://abc.com/gocd',
    'name' => 'Moose Widge',
    'pipeline' => 'Moose',
    'stage' => 'build',
    'user' => 'pzhao',
    'password' => 'pw',
    'width' => 400,
    'height' => 200
   }}
  let(:server_response){ {'pipelines' => []} }
  let(:transformer_response){ 
       {'name' => 'foo', 'label' => '17', 'triggered_by' => 'Peter', 'stage' => 
         {'name' => 'build', 'result' => 'Unknown', 'state' => 'Building', 'scheduled_time' => '2 minutes ago'}
       }
  }

  before :each do
    @plugin = Ju::GocdBuild.new(options)
  end
  
  it 'should check build from given server' do
    expect(RestClient::Request).to receive(:execute) do |request|
      expect(request[:url]).to eq("#{options['base_url']}/go/api/pipelines/Moose/history")
      expect(request[:method]).to eq(:get)
      expect(request[:user]).to eq(options['user'])
      expect(request[:password]).to eq(options['password'])
    end.and_return(server_response.to_json)
    
    expect(Ju::GocdBuild::Transformer).to receive(:transform).with(server_response, "build").and_return(transformer_response)

    pipeline_data = @plugin.check
    
    expect(pipeline_data).to include('<div class="gocdbuild unknown building"') 
    expect(pipeline_data).to include('title="Build: Moose.build"') 
    expect(pipeline_data).to include('title="Started 2 minutes ago"') 
    expect(pipeline_data).to include('title="Build label: 17"') 
    expect(@plugin.data).to eq(transformer_response)
  end

  it 'should return error data when server gives an error' do
    error = '400 error("2")'
    expect(RestClient::Request).to receive(:execute).with(anything()).and_raise(error)
    expect{@plugin.check}.to raise_error
  end
end
