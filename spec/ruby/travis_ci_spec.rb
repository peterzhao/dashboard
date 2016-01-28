require 'rspec'
require 'json'
require_relative '../../lib/ju'

describe Ju::TravisCi do
  let(:options){{ 
    'base_url' => 'http://abc.com/',
    'name' => 'Moose',
    'repo_path' => 'pzhao/ju',
    'api_token' => 'abcde',
    'number_of_instances' => "2",
    'width' => 400,
    'height' => 200
   }}
  let(:server_response){ {'builds' => [], 'commits' => []} }
  let(:transformer_response){ {'builds' => [
       {'number' => '76','branch' =>'master', 'author' => 'peter', 'state' => 'passed', 'started_at' => '2 hours ago', 'commit_sha' => 'sh1111'},
       {'number' => '75','branch' =>'master', 'author' => 'joe', 'state' => 'failed', 'started_at' => '3 hours ago', 'commit_sha' => 'sh2222'}
  ]}}

  before :each do
    @plugin = Ju::TravisCi.new(options)
  end
  
  it 'should check builds from given server' do
    expect(RestClient::Request).to receive(:execute) do |request|
      expect(request[:url]).to eq("#{options['base_url']}/repos/pzhao/ju/builds")
      expect(request[:method]).to eq(:get)
      expect(request[:headers]['Authorization']).to eq("token abcde")
    end.and_return(server_response.to_json)
    
    expect(Ju::TravisCi::Transformer).to receive(:transform).with(server_response, "2").and_return(transformer_response)

    builds = @plugin.check
    
    expect(builds).to include('<div class="travis">') 
    expect(builds).to include('title="Repo: pzhao/ju"') 
    expect(builds).to include('title="Triggered by: peter"') 
    expect(builds).to include('title="Started 2 hours ago"') 
    expect(builds).to include('title="Build number: 76"') 
    expect(builds).to include('title="Build number: 75"') 
    expect(builds).to include('style="height: 170px"') 
    expect(builds).to include('commit: sh2222') 
    expect(builds).to include('commit: sh1111') 
    expect(builds).to include('branch: master') 
    expect(builds).to include('class="travis-build failed"') 
    expect(builds).to include('class="travis-build passed"') 
    expect(builds).to include('style="height: 49.0%"') 
    expect(@plugin.data).to eq(transformer_response)
  end

  it 'should return error data when server gives an error' do
    error = '400 error("2")'
    expect(RestClient::Request).to receive(:execute).with(anything()).and_raise(error)
    expect{@plugin.check}.to raise_error
  end
end
