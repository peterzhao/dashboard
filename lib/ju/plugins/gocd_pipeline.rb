require 'rest-client'
require 'json'
require 'erb'

module Ju
  class GocdPipeline < Ju::Plugin
    attr_reader :data

    def check
      @data= call_server
      render = ERB.new(template)
      render.result(binding)      
    end

    def template
<<EOS
<%
  pipelines = data['pipelines'] || []
%>
<div class="gocd">
  <div class="gocd-title" title="Pipeline name: <%= options['name'] %>"><%= options['name'] %></div>
  <div class="gocd-pipelines" style="height: <%= options['height'] - const[:title_height] - const[:title_padding_top] %>px">
    <% pipelines.each do |pipeline| %>
      <div class="gocd-pipeline-wrapper" style="height: <%= 1.0/pipelines.count * 100 - 1 %>%; max-height: <%= 1.0/pipelines.count * 100 -1 %>%">
        <div class="gocd-pipeline">
          <div class="vertical-align-block gocd-build-label">
            <div class="gocd-build-number" title="Build label: <%= pipeline['label'] %>"><%= pipeline['label'] %></div>
            <div class="ellipseis gocd-build-label-details" title="Triggered by: <%= pipeline['triggered_by'] %>"><%= pipeline['triggered_by'] %></div>
          </div>
          <div class="gocd-stages" style="width: <%= options['width'] - const[:label_width] %>px">
            <% (pipeline['stages'] || []).each do |stage| %> 
              <div class="gocd-stage-wrapper" style="width: <%= 1.0/(pipeline['stages'] || []).count * 100 -1 %>%">
                <div class="gocd-stage <%= (stage['result'] || '').downcase %> <%= (stage['state'] || '').downcase %>">
                  <div class="vertical-align-block">
                    <div class="ellipseis gocd-stage-name" title="Stage: <%= stage['name'] %>"><%= stage['name'] %></div>
                    <% if stage['scheduled_time'] %>
                    <div class="ellipseis gocd-stage-details" title="Started <%= stage['scheduled_time'] %>"><%= stage['scheduled_time'] %></div>
                    <% end %>
                  </div>
                </div>
              </div>
            <% end %>
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
.gocd-title {
 text-align: center;
 color: black;
 font-weight: 600;
 font-size: 120%;
 padding-top: #{const[:title_padding_top]}px;
 height: #{const[:title_height]}px;
}
.unscheduled {
 visibility: hidden;
}
.gocd-pipeline-wrapper {
  clear: both;
  width: 100%;
}
.gocd-pipeline {
  height: 95%;
}
.gocd-build-label {
  float: left;
  width: #{const[:label_width]}px;
  font-size: 80%;
  line-height: normal; 
  overflow: hidden;
}
.gocd-build-number {
  font-weight: 600;
  font-size: 120%;
}
.gocd-stages {
  float: left;
  height: 100%;
}
.gocd-stage-wrapper {
  height: 100%;
  float: left;
}
.gocd-stage {
  height: 100%;
  width: 98%;
  border-radius: 3px;
  line-height: normal; 
}
.gocd-stage-name {
 font-size: 100%;
}
.gocd-stage-details {
  font-size: 80%;
  color: #333333;
}

EOS
    end

    def config
        [
          {
            'name' => 'base_url',
            'description' => 'Server Base URL',
            'validate' => '^[0-9a-zA-Z\-_:/.]+$',
            'validation_message' => 'Server base URL is not a valid URL'
          },
          {
            'name' => 'user',
            'description' => 'User Name',
            'validate' => '^.*$',
            'validation_message' => 'User Name can be any characters'
          },
          {
            'name' => 'password',
            'description' => 'Password',
            'validate' => '^.*$',
            'validation_message' => 'Password can be any characters'
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
      params = { method: :get, url: "#{options['base_url']}/go/api/pipelines/#{URI.escape(options['name'])}/history"}
      if options['user']
        params[:user] = options['user']
        params[:password] = options['password']
      end
      begin
        response = RestClient::Request.execute(params)
      rescue => e
        #return {'error' => e.message} 
        raise Ju::RemoteConnectionError.new("Failed to get GOCD pipeline information. #{e.message}")
      end
      Transformer.transform(JSON.parse(response), options['number_of_instances'])
    end

    # to avoid constant already defined warning when reloading class
    def const
      {
        title_height: 27, 
        title_padding_top: 3,
        label_width: 80
      }
    end

    class Transformer
      def self.transform(response, number_of_instances)
        response['pipelines'] = response['pipelines'][0..(number_of_instances.to_i - 1)] 
        response['pipelines'].each do |pipeline|
          pipeline['triggered_by'] = "by #{pipeline['stages'].first['approved_by']}"
          pipeline['stages'].each do |stage|
            transform_stage(stage)
          end
        end
        response
      end

      private 

      def self.transform_stage(stage)
        stage['result'] = 'Unknown' unless stage['result']
        if(stage['scheduled'])
          if stage['jobs'].any?{ |job| job['state'] == 'Building' } 
            stage['state'] = 'Building'
          elsif stage['jobs'].all?{ |job| job['state'] == 'Completed' } 
            stage['state'] = 'Completed'
          else
            stage['state'] = 'Scheduled'
          end
          stage['scheduled_time'] = "#{Ju::TimeConverter.ago_in_words(stage['jobs'].map{|j| j['scheduled_date']}.min)} ago"
        else
            stage['state'] = 'Unscheduled'
        end
      end 
    end
  end
end



Ju::Plugin.register('gocd_pipeline', Ju::GocdPipeline)
