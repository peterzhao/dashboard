require 'rspec'
require 'json'
require_relative '../../lib/ju'

describe Ju::GocdPipeline::Transformer do
  let(:one_minute_ago){ (Time.now.utc.to_i - 60 + 10)*1000 }
  let(:two_minutes_ago){ (Time.now.utc.to_i - 60*2 + 10)*1000 }

  let(:data){{ "pipelines" => [
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

  it 'should transform data' do
    pipeline_data = Ju::GocdPipeline::Transformer.transform(data, 2) 

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
end
