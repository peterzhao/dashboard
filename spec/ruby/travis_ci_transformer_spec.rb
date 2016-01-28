require 'rspec'
require 'json'
require 'time'
require_relative '../../lib/ju'

describe Ju::TravisCi::Transformer do
  let(:one_minute_ago){ (Time.now.utc - 70).iso8601 }
  let(:two_minutes_ago){ (Time.now.utc - 130).iso8601 }

  let(:data){{
    "builds" => [
      {
        "id" => "4", 
        "number" => "68",
        "state" => "created", 
        "commit_id" => "104" 
      },
      {
        "id" => "3", 
        "number" => "67",
        "state" => "started",
        "started_at" => one_minute_ago, 
        "commit_id" => "103" 
      },
      {
        "id" => "2", 
        "number" => "66",
        "state" => "failed", 
        "started_at" => two_minutes_ago, 
        "commit_id" => "102" 
      },
      {
        "id" => "1", 
        "number" => "65",
        "state" => "passed", 
        "started_at" => two_minutes_ago, 
        "commit_id" => "101" 
      }
    ],
    "commits" => [
      {
        "id" => "104",
        "sha" => "sha444444444",
        "branch" => "master",
        "author_name" => "pzhao"
      },
      {
        "id" => "103",
        "sha" => "sha33333333333",
        "branch" => "master",
        "author_name" => "pzhao"
      },
      {
        "id" => "102",
        "sha" => "sha222222222222",
        "branch" => "master",
        "author_name" => "joe"
      },
      {
        "id" => "101",
        "sha" => "sha111111111111",
        "branch" => "master",
        "author_name" => "tom"
      },
    ]
}}
  

  it 'should transform data' do
    output = Ju::TravisCi::Transformer.transform(data, 3) 
    expect(output['builds'].count).to eq(3)
    expect(output['builds'][0]['number']).to eq('68')
    expect(output['builds'][0]['state']).to eq('scheduled')
    expect(output['builds'][0]['author']).to eq('pzhao')
    expect(output['builds'][0]['started_at']).to be_nil 
    expect(output['builds'][0]['branch']).to eq('master')
    expect(output['builds'][0]['commit_sha']).to eq('sha4444')

    expect(output['builds'][1]['number']).to eq('67')
    expect(output['builds'][1]['state']).to eq('building')
    expect(output['builds'][1]['author']).to eq('pzhao')
    expect(output['builds'][1]['started_at']).to eq('1 minute ago')
    expect(output['builds'][1]['branch']).to eq('master')
    expect(output['builds'][1]['commit_sha']).to eq('sha3333')

    expect(output['builds'][2]['number']).to eq('66')
    expect(output['builds'][2]['state']).to eq('failed')
    expect(output['builds'][2]['author']).to eq('joe')
    expect(output['builds'][2]['started_at']).to eq('2 minutes ago')
    expect(output['builds'][2]['branch']).to eq('master')
    expect(output['builds'][2]['commit_sha']).to eq('sha2222')
  end
end
