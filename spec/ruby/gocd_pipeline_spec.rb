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

  let(:response){{ "pipelines" => [
    {
      "id" => "3", 
      "stages" => [
                 {
                   "name" => "build", "scheduled" => true, "result" => "Failed", "jobs" => [
                                           {"name"=>"compile","result"=>"Passed", "state"=>"Completed"},
                                           {"name"=>"test","result"=>"Unknown", "state"=>"Building"}
                                         ]
                 },
                 {
                   "name" => "deploy","scheduled" => false, "jobs" => [
                                         ]
                 }
                ]
    },
    {
      "id" => "2", 
      "stages" => [
                 {
                   "name" => "build", "scheduled" => true, "jobs" => [
                                           {"name"=>"compile","result"=>"Passed", "state"=>"Completed"},
                                           {"name"=>"test","result"=>"Failed", "state"=>"Completed"}
                                         ]
                 },
                 {
                   "name" => "deploy","scheduled" => true, "jobs" => [
                                           {"name"=>"deploy","result"=>"Passed", "state"=>"Completed"}
                                         ]
                 }
                ]
    },
    {
      "id" => "1", 
      "stages" => [
                 {
                   "name" => "build", "scheduled" => true, "jobs" => [
                                           {"name"=>"compile","result"=>"Passed", "state"=>"Completed"}
                                         ]
                 }
                ]
    }
  ]}}

  it 'should check pipelines from given server' do
    expect(RestClient::Request).to receive(:execute) do |request|
      expect(request[:url]).to eq("#{options['base_url']}/go/api/pipelines/#{options['name']}/history")
      expect(request[:method]).to eq(:get)
      expect(request[:user]).to eq(options['user'])
      expect(request[:password]).to eq(options['password'])
    end.and_return(response.to_json)

    plugin = Dashboard::GocdPipeline.new(options)
    pipeline_data = JSON.parse(plugin.check)

    expect(pipeline_data['pipelines'].count).to eq(2)
    expect(pipeline_data['pipelines'][0]['id']).to eq('3')
    expect(pipeline_data['pipelines'][1]['id']).to eq('2')
    expect(pipeline_data['pipelines'][0]['stages'][0]['state']).to eq('Building')
    expect(pipeline_data['pipelines'][0]['stages'][0]['result']).to eq('Failed')
    expect(pipeline_data['pipelines'][0]['stages'][1]['state']).to eq('Unscheduled')
    expect(pipeline_data['pipelines'][0]['stages'][1]['result']).to eq('Unknown')
    expect(pipeline_data['pipelines'][1]['stages'][0]['state']).to eq('Completed')
  end

  it 'should return error data when server gives an error' do
    expect(RestClient::Request).to receive(:execute).with(anything()).and_raise('400 error("2")')

    plugin = Dashboard::GocdPipeline.new(options)
    pipeline_data = plugin.check

    expect(pipeline_data).to eq('{"error":"400 error(\"2\")"}')
    expect{JSON.load(pipeline_data)}.not_to raise_error
  end
end
