require 'rspec'
require 'json'
require_relative '../../lib/ju'

describe Ju::JenkinsJob::Transformer do
  let(:one_minute_ago){ (Time.now.utc.to_i - 60 - 10)*1000 }
  let(:two_minutes_ago){ (Time.now.utc.to_i - 60*2 - 10)*1000 }

  let(:data){{ "builds" => [
    {
       "building" => true,
       "number" => 5,
       "result" => nil, 
       "timestamp" =>  one_minute_ago,
       "actions" => [  
              {  
                 "causes" => [  
                    {  
                       "shortDescription" => "Started by user Tom"
                    },
                    {  
                       "shortDescription" => "Started by an SCM change"
                    }
                 ]
              },
              {},
              {},
              {}
           ],
       "changeSet" => {
          "items" => [
             {
                "author" => {
                   "fullName" => "peter"
                },
                "commitId" =>  "929178967534sd23erer",
                "msg" => "refactoring unit test"
             },
             {
                "author" => {
                   "fullName" => "joe"
                },
                "commitId" =>  "829178967534sd23erer",
                "msg" => "add validation"
             }
          ]
       }
    },
    {
       "building" => false,
       "number" => 4,
       "result" =>  'SUCCESS',
       "timestamp" =>  two_minutes_ago,
       "actions" => [  
              {  
                 "causes" => [  
                    {  
                       "shortDescription" => "Started by an SCM change"
                    }
                 ]
              },
              {},
              {},
              {}
           ],
       "changeSet" => {
          "items" => [
             {
                "author" => {
                   "fullName" => "joe"
                },
                "commitId" =>  "ab9178967534sd23erer",
                "msg" => "fix build"
             }
          ]
       }
    },
    {
       "building" => false,
       "number" => 3,
       "result" =>  'FAILURE',
       "timestamp" =>  two_minutes_ago,
       "actions" => [  
              {  
                 "causes" => [  
                    {  
                       "shortDescription" => "Started by an SCM change"
                    }
                 ]
              },
              {},
              {},
              {}
           ],
       "changeSet" => {
          "items" => [
             {
                "author" => {
                   "fullName" => "tom"
                },
                "commitId" =>  "cf9178967534sd23erer",
                "msg" => "add more test"
             }
          ]
       }
    }
  ]}}

  it 'should transform data' do
    pipeline_data = Ju::JenkinsJob::Transformer.transform(data) 
    expect(pipeline_data['builds'].count).to eq(3)
    expect(pipeline_data['builds'][0]['state']).to eq('building')
    expect(pipeline_data['builds'][0]['number']).to eq(5)
    expect(pipeline_data['builds'][0]['started']).to eq('1 minute ago')
    expect(pipeline_data['builds'][0]['causes'][0]).to eq('Started by user Tom')
    expect(pipeline_data['builds'][0]['causes'][1]).to eq('Started by an SCM change')
    expect(pipeline_data['builds'][0]['changes'][0]['author']).to eq('peter')
    expect(pipeline_data['builds'][0]['changes'][0]['message']).to eq('refactoring unit test')
    expect(pipeline_data['builds'][0]['changes'][0]['commitId']).to eq('9291789')
    expect(pipeline_data['builds'][0]['changes'][1]['author']).to eq('joe')
    expect(pipeline_data['builds'][0]['changes'][1]['message']).to eq('add validation')
    expect(pipeline_data['builds'][0]['changes'][1]['commitId']).to eq('8291789')

    expect(pipeline_data['builds'][1]['number']).to eq(4)
    expect(pipeline_data['builds'][1]['started']).to eq('2 minutes ago')
    expect(pipeline_data['builds'][1]['state']).to eq('passed')
    expect(pipeline_data['builds'][1]['causes'][0]).to eq('Started by an SCM change')

    expect(pipeline_data['builds'][2]['state']).to eq('failed')
    expect(pipeline_data['builds'][2]['number']).to eq(3)
  end
end
