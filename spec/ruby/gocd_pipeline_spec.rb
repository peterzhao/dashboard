require 'rspec'
require 'json'
require_relative '../../lib/dashboard'

describe Dashboard::GocdPipeline do
  let(:options){{ 
    'base_url' => 'http://abc.com/gocd',
    'name' => 'billingPipeline',
    'user' => 'pzhao',
    'password' => 'pw',
    'number_of_instances' => 2
   }}

  let(:response){ '{"pipelines": [{"id":"1"}, {"id":"2"}, {"id":"3"} ]}' }

  it 'should check pipelines from given server' do
    expect(RestClient::Request).to receive(:execute) do |request|
      expect(request[:url]).to eq("#{options['base_url']}/go/api/pipelines/#{options['name']}/history")
      expect(request[:method]).to eq(:get)
      expect(request[:user]).to eq(options['user'])
      expect(request[:password]).to eq(options['password'])
    end.and_return(response)

    plugin = Dashboard::GocdPipeline.new(options)
    pipeline_data = plugin.check

    expect(pipeline_data).to eq('{"pipelines":[{"id":"1"},{"id":"2"}]}')
  end

  it 'should return error data when server gives an error' do
    expect(RestClient::Request).to receive(:execute).with(anything()).and_raise('400 error("2")')

    plugin = Dashboard::GocdPipeline.new(options)
    pipeline_data = plugin.check

    expect(pipeline_data).to eq('{"error":"400 error(\"2\")"}')
    expect{JSON.load(pipeline_data)}.not_to raise_error
  end
end
