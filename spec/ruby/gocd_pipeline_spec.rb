require 'rspec'
require 'json'
require_relative '../../lib/ju'

describe Ju::GocdPipeline do
  let(:options){{ 
    'base_url' => 'http://abc.com/gocd',
    'name' => 'Moose Widge',
    'pipeline' => 'Moose',
    'user' => 'pzhao',
    'password' => 'pw',
    'number_of_instances' => "2",
    'width' => 400,
    'height' => 200
   }}
  let(:server_response){ {'pipelines' => []} }
  let(:transformer_response){ {'pipelines' => [
       {'name' => 'foo', 'label' => '17', 'triggered_by' => 'Peter', 'stages' => [
         {'name' => 'build', 'result' => 'Unknown', 'state' => 'Building', 'scheduled_time' => '2 minutes ago'},
         {'name' => 'deploy', 'result' => 'Failed'}
       ]},
       {'name' => 'foo', 'label' => '16'}
  ]}}

  before :each do
    @plugin = Ju::GocdPipeline.new(options)
  end
  
  it 'should check pipelines from given server' do
    expect(RestClient::Request).to receive(:execute) do |request|
      expect(request[:url]).to eq("#{options['base_url']}/go/api/pipelines/Moose/history")
      expect(request[:method]).to eq(:get)
      expect(request[:user]).to eq(options['user'])
      expect(request[:password]).to eq(options['password'])
    end.and_return(server_response.to_json)
    
    expect(Ju::GocdPipeline::Transformer).to receive(:transform).with(server_response, "2").and_return(transformer_response)

    pipeline_data = @plugin.check
    
    expect(pipeline_data).to include('<div class="gocd">') 
    expect(pipeline_data).to include('title="Pipeline name: Moose"') 
    expect(pipeline_data).to include('title="Triggered by: Peter"') 
    expect(pipeline_data).to include('title="Started 2 minutes ago"') 
    expect(pipeline_data).to include('title="Build label: 16"') 
    expect(pipeline_data).to include('title="Build label: 17"') 
    expect(pipeline_data).to include('title="Stage: build"') 
    expect(pipeline_data).to include('title="Stage: deploy"') 
    expect(pipeline_data).to include('style="height: 170px"') 
    expect(pipeline_data).to include('style="width: 320px"') 
    expect(pipeline_data).to include('class="gocd-stage unknown building"') 
    expect(pipeline_data).to include('class="gocd-stage failed "') 
    expect(pipeline_data).to include('style="height: 49.0%; max-height: 49.0%"') 
    expect(pipeline_data).to include('style="width: 49.0%"') 
    expect(@plugin.data).to eq(transformer_response)
  end

  it 'should return error data when server gives an error' do
    error = '400 error("2")'
    expect(RestClient::Request).to receive(:execute).with(anything()).and_raise(error)
    expect{@plugin.check}.to raise_error
  end
end
