require 'rspec'
require 'json'
require_relative '../../lib/ju'

describe Ju::GocdPipeline do
  let(:one_minute_ago){ (Time.now.utc.to_i - 60 + 10)*1000 }
  let(:two_minutes_ago){ (Time.now.utc.to_i - 60*2 + 10)*1000 }
  let(:options){{ 
    'base_url' => 'http://abc.com/gocd',
    'name' => 'billing pipeline',
    'user' => 'pzhao',
    'password' => 'pw',
    'number_of_instances' => "2"
   }}

  let(:response){{ "pipelines" => [
    {
      "id" => "3", 
      "stages" => [
                 {
                   "name" => "build", "scheduled" => true, "approved_by" => "guest", "result" => "Failed", "jobs" => [
                                           {"name"=>"compile","result"=>"Passed", "state"=>"Completed", "scheduled_date"=>two_minutes_ago },
                                           {"name"=>"test","result"=>"Unknown", "state"=>"Building", "scheduled_date"=>one_minute_ago }
                                         ]
                 },
                 {
                   "name" => "deploy","scheduled" => false,"approved_by" => "changes", "jobs" => [
                                         ]
                 }
                ]
    },
    {
      "id" => "2", 
      "stages" => [
                 {
                   "name" => "build", "scheduled" => true, "jobs" => [
                                           {"name"=>"compile","result"=>"Passed", "state"=>"Completed", "scheduled_date"=>two_minutes_ago },
                                           {"name"=>"test","result"=>"Failed", "state"=>"Completed", "scheduled_date"=>one_minute_ago }
                                         ]
                 },
                 {
                   "name" => "deploy","scheduled" => true, "jobs" => [
                                           {"name"=>"deploy","result"=>"Passed", "state"=>"Completed", "scheduled_date"=>one_minute_ago }
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
      expect(request[:url]).to eq("#{options['base_url']}/go/api/pipelines/#{URI.escape(options['name'])}/history")
      expect(request[:method]).to eq(:get)
      expect(request[:user]).to eq(options['user'])
      expect(request[:password]).to eq(options['password'])
    end.and_return(response.to_json)

    plugin = Ju::GocdPipeline.new(options)
    pipeline_data = JSON.parse(plugin.check)

    expect(pipeline_data['pipelines'].count).to eq(2)
    expect(pipeline_data['pipelines'][0]['id']).to eq('3')
    expect(pipeline_data['pipelines'][0]['stages'][0]['state']).to eq('Building')
    expect(pipeline_data['pipelines'][0]['stages'][0]['result']).to eq('Failed')
    expect(pipeline_data['pipelines'][0]['stages'][0]['scheduled_time']).to eq('1 minute ago')
    expect(pipeline_data['pipelines'][0]['triggered_by']).to eq('by guest')
    expect(pipeline_data['pipelines'][0]['stages'][1]['state']).to eq('Unscheduled')
    expect(pipeline_data['pipelines'][0]['stages'][1]['result']).to eq('Unknown')
    expect(pipeline_data['pipelines'][0]['stages'][1]['scheduled_time']).to be_nil 
    expect(pipeline_data['pipelines'][1]['stages'][0]['state']).to eq('Completed')
    expect(pipeline_data['pipelines'][1]['id']).to eq('2')
  end

  it 'should return error data when server gives an error' do
    expect(RestClient::Request).to receive(:execute).with(anything()).and_raise('400 error("2")')

    plugin = Ju::GocdPipeline.new(options)
    pipeline_data = plugin.check

    expect(pipeline_data).to eq('{"error":"400 error(\"2\")"}')
    expect{JSON.load(pipeline_data)}.not_to raise_error
  end
end
