require 'rspec'
require 'json'
require_relative '../../lib/ju'

describe Ju::JenkinsJob do
  let(:options){{ 
    'base_url' => 'http://abc.com',
    'name' => 'Moose',
    'job' => 'Moose',
    'user' => 'pzhao',
    'password' => 'pw',
    'number_of_builds' => "3",
    'width' => 400,
    'height' => 200
   }}
  let(:server_response){ {'pipelines' => []} }
  let(:transformer_response){ {'builds' => [
    {
      "number" => 5,
      "state" => "building",
      "started" => "2 minutes ago",
      "changes" => [ 
        {
          "author" => "pzhao",
          "commitId" => "a654321",
          "message" => "add tests"
        },
        {
          "author" => "joe",
          "commitId" => "i654321",
          "message" => "merge conflict"
        }
      ]
    },
    {
      "number" => 4,
      "state" => "passed",
      "started" => "4 minutes ago",
      "changes" => [ 
        {
          "author" => "pzhao",
          "commitId" => "b654321",
          "message" => "refactoring"
        }
      ]
    },
    {
      "number" => 3,
      "state" => "failed",
      "started" => "21 minutes ago",
      "changes" => [ 
        {
          "author" => "pzhao",
          "commitId" => "c654321",
          "message" => "add validation"
        }
      ]
    }
  ]}}

  before :each do
    @plugin = Ju::JenkinsJob.new(options)
  end
  
  it 'should check builds from given server' do
    expect(RestClient::Request).to receive(:execute) do |request|
      expect(request[:url]).to eq("#{options['base_url']}/job/Moose/api/json?tree=builds[number,url,result,timestamp,building,actions[causes[shortDescription]],changeSet[items[msg,commitId,author[fullName]]]]%7B0,3%7D")
      expect(request[:method]).to eq(:get)
      expect(request[:user]).to eq(options['user'])
      expect(request[:password]).to eq(options['password'])
    end.and_return(server_response.to_json)
    
    expect(Ju::JenkinsJob::Transformer).to receive(:transform).with(server_response).and_return(transformer_response)

    pipeline_data = @plugin.check
    
    expect(pipeline_data).to include('<div class="jenkins">') 
    expect(pipeline_data).to include('title="Job: Moose"') 
    expect(pipeline_data).to include('title="Started 2 minutes ago"') 
    expect(pipeline_data).to include('title="Build number: 5"') 
    expect(pipeline_data).to include('title="Build number: 4"') 
    expect(pipeline_data).to include('title="Build number: 3"') 
    expect(pipeline_data).to include('pzhao') 
    expect(pipeline_data).to include('add tests') 
    expect(pipeline_data).to include('a654321') 
    expect(pipeline_data).to include('style="height: 170px"') 
    expect(@plugin.data).to eq(transformer_response)
  end

  it 'should return error data when server gives an error' do
    error = '400 error("2")'
    expect(RestClient::Request).to receive(:execute).with(anything()).and_raise(error)
    expect{@plugin.check}.to raise_error
  end
end
