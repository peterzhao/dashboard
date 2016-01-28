require 'rest-client'
require 'json'
require 'erb'

module Ju
  class TravisCi < Ju::Plugin
    attr_reader :data

    def check
      @data= call_server
      render = ERB.new(template)
      render.result(binding)      
    end

    def template
<<EOS
<%
  builds = data['builds'] || []
%>
<div class="travis">
  <div class="travis-title" title="Repo: <%= options['repo_path'] %>"><%= options['name'] %></div>
  <div class="travis-builds" style="height: <%= options['height'] - const[:title_height] - const[:title_padding_top] %>px">
    <% builds.each do |build| %>
      <div class="travis-build-wrapper" style="height: <%= 1.0/builds.count * 100 - 1 %>%">
        <div class="travis-build <%= build['state'] %>">
          <div class="travis-build-title vertical-align-block">
              <div class="travis-build-number" title="Build number: <%= build['number'] %>"><%= build['number'] %></div>
              <div class="ellipseis travis-build-info" title="Triggered by: <%= build['author'] %>">by <%= build['author'] %></div>
          </div>
          <div class="travis-build-details vertical-align-block">
              <div class="ellipseis travis-build-info" title="Started <%= build['started_at'] %>"><%= build['started_at'] %></div>
              <div class="ellipseis travis-build-info">commit: <%= build['commit_sha'] %></div>
              <div class="ellipseis travis-build-info">branch: <%= build['branch'] %></div>
          </div>
        </div>
      </div>
    <% end %>
  </div>
</div>
EOS
    end

    def style
<<EOS
.travis-title {
 text-align: center;
 color: black;
 font-weight: 600;
 font-size: 120%;
 padding-top: #{const[:title_padding_top]}px;
 height: #{const[:title_height]}px;
}
.travis-build-wrapper {
  clear: both;
  width: 100%;
}
.travis-build {
  height: 95%;
  overflow: hidden;
}
.travis-build-title{
  float: left;
  width: 50%
}
.travis-build-details{
  float: left;
  width: 50%;
}
.travis-build-info {
  font-size: 80%;
  line-height: normal; 
}
.travis-build-number {
  font-weight: 600;
  font-size: 120%;
}
EOS
    end

    def config
        [
          {
            'name' => 'base_url',
            'default' => 'https://api.travis-ci.org',
            'description' => 'Server Base URL',
            'validate' => '^[0-9a-zA-Z\-_:/.]+$',
            'validation_message' => 'Server base URL is not a valid URL'
          },
          {
            'name' => 'repo_path',
            'description' => 'Repository Path',
            'validate' => '^[0-9a-zA-Z\-_/]+$',
            'validation_message' => 'Repository Path can only be letters, digits and slash, eg., boo/foo'
          },
          {
            'name' => 'api_token',
            'description' => 'API Token',
            'validate' => '^[0-9a-zA-Z]+$',
            'validation_message' => 'API Token can only be letters and digits'
          },
          {
            'name' => 'number_of_instances',
            'description' => 'Number of Instances',
            'validate' => '^[0-9]+$',
            'validation_message' => 'Number of Instances must be digits',
            'default' => 3
          }
      ]
    end

    private 

    def call_server
      params = { :method =>  :get, 
                 :url =>  "#{options['base_url']}/repos/#{options['repo_path']}/builds",
                 :headers =>  {
                   'User-Agent' => 'MyClient/1.0.0',
                   'Accept' => 'application/vnd.travis-ci.2+json',
                   'Authorization' => "token #{options['api_token']}" 
                 }
               }
      begin
        response = RestClient::Request.execute(params)
      rescue => e
        #return {'error' => e.message} 
        raise Ju::RemoteConnectionError.new("Failed to get travis-ci build information. #{e.message}")
      end
      Transformer.transform(JSON.parse(response), options['number_of_instances'])
    end

    # to avoid constant already defined warning when reloading class
    def const
      {
        title_height: 27, 
        title_padding_top: 3
      }
    end

    class Transformer
      def self.transform(response, number_of_instances)
        output = { 'builds' => []}
        builds = response['builds'][0..(number_of_instances.to_i - 1)] 
        builds.each do |build|
          commit = response['commits'].find{ |c| c['id'] == build['commit_id'] }
          output['builds'] << transform_build(build, commit)
        end 
        output
      end

      private 

      def self.transform_build(build, commit)
        {
          'number' => build['number'],
          'state' => build['state'],
          'author' => commit['author_name'],
          'started_at' => "#{Ju::TimeConverter.ago_in_words(Time.parse(build['started_at']).to_i * 1000)} ago",
          'branch' => commit['branch'],
          'commit_sha' => commit['sha'][0..6]
        }
      end 
    end
  end
end



Ju::Plugin.register('travis_ci', Ju::TravisCi)
