require 'rspec'
require 'json'
require_relative '../../lib/ju'

describe Ju::GocdPipeline::Transformer do
  let(:one_minute_ago){ (Time.now.utc.to_i - 60 + 10)*1000 }
  let(:two_minutes_ago){ (Time.now.utc.to_i - 60*2 + 10)*1000 }

  context 'state' do
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
      expect(pipeline_data['pipelines'][0]['stages'][1]['state']).to eq('Unscheduled')
      expect(pipeline_data['pipelines'][0]['stages'][1]['result']).to eq('Unknown')
      expect(pipeline_data['pipelines'][0]['stages'][1]['scheduled_time']).to be_nil 
      expect(pipeline_data['pipelines'][1]['stages'][0]['state']).to eq('Completed')
      expect(pipeline_data['pipelines'][1]['id']).to eq('2')
    end
  end

  context 'triggered by SCM' do
    let(:data){{ 
                "pipelines" => [
                {
                   "build_cause" => {  
                              "material_revisions" => [  
                                 {  
                                    "modifications" => [  
                                       {  
                                          "user_name" => "Peter Zhao",
                                          "comment" => "message1",
                                          "revision" => "r1234567890"
                                       },
                                       {  
                                          "user_name" => "Hellen Smith",
                                          "comment" => "message2",
                                          "revision" => "r2345678901"
                                       }
                                    ],
                                    "material" => {  
                                       "type" => "Git"
                                    },
                                    "changed" => true
                                 }
                              ],
                              "trigger_forced" => false,
                              "trigger_message" => "Modified by Peter Zhao"
                           },
                    "id" => "1", 
                    "stages" => [
                               {
                                 "name" => "build", "scheduled" => true, "approved_by" => "changes", "result" => "Failed", "jobs" => [
                                                         {"name"=>"compile","result"=>"Passed", "state"=>"Completed", "scheduled_date"=>two_minutes_ago }
                                                       ]
                               }
                              ]
                }
              ]
    }}

    it 'should get changes' do
      pipeline_data = Ju::GocdPipeline::Transformer.transform(data, 2) 
      changes = pipeline_data['pipelines'][0]['changes']
      expect(changes[0]['author']).to eq('Peter Zhao')
      expect(changes[0]['message']).to eq('message1')
      expect(changes[0]['revision']).to eq('r123456')
      expect(changes[0]['type']).to eq('Git')
      expect(changes[1]['author']).to eq('Hellen Smith')
      expect(changes[1]['message']).to eq('message2')
      expect(changes[1]['revision']).to eq('r234567')
      expect(changes[1]['type']).to eq('Git')
    end
  end
  context 'triggered by the upstream pipeline' do
    let(:data){{ 
                "pipelines" => [
                {
                   "build_cause" => {  
                              "material_revisions" => [  
                                 {  
                                    "modifications" => [  
                                       {  
                                          "user_name" => "Unknown",
                                          "comment" => "Unknown",
                                          "revision" => "cf-deployer/7/build/1"
                                       }
                                    ],
                                    "material" => {  
                                       "type" => "Pipeline"
                                    },
                                    "changed" => true
                                 }
                              ],
                              "trigger_forced" => false,
                              "trigger_message" => "triggered by cf-deployer/7/build/1"
                           },
                    "id" => "1", 
                    "stages" => [
                               {
                                 "name" => "build", "scheduled" => true, "approved_by" => "changes", "result" => "Failed", "jobs" => [
                                                         {"name"=>"compile","result"=>"Passed", "state"=>"Completed", "scheduled_date"=>two_minutes_ago }
                                                       ]
                               }
                              ]
                }
              ]
    }}

    it 'should get changes' do
      pipeline_data = Ju::GocdPipeline::Transformer.transform(data, 2) 
      changes = pipeline_data['pipelines'][0]['changes']
      expect(changes[0]['author']).to be_nil
      expect(changes[0]['message']).to eq('cf-deployer/7/build/1')
      expect(changes[0]['revision']).to be_nil 
      expect(changes[0]['type']).to eq('Pipeline')
    end
  end

end
