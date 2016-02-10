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
  pipelines_height = options['height'] - const[:title_height] - const[:title_padding_top]
  pipeline_height = 1.0/pipelines.count * pipelines_height - 4
  stages_height = pipeline_height - const[:label_height] - 8
%>
<div class="gocd">
  <div class="gocd-title" title="Pipeline name: <%= options['pipeline'] %>"><%= options['name'] %></div>
  <div class="gocd-pipelines" style="height: <%= pipelines_height %>px;">
    <% pipelines.each do |pipeline| %>
      <div class="gocd-pipeline" style="height: <%= pipeline_height %>px;">
        <div class="gocd-build-label">
          <div class="gocd-build-number" title="Build label: <%= pipeline['label'] %>"><%= pipeline['label'] %></div>
          <% (pipeline['changes'] || []).each do |change| %>
            <% if change['author'] && change['revision'] %>
              <% title = "Author: " + change['author']+ ", Revision: " + change['revision'] %>
            <% end %>
            <div class="ellipseis gocd-build-label-details" title="<%= title %>"><%= change['message'] %></div>
          <% end %>
        </div>
        <div class="gocd-stages" style="height: <%= stages_height %>px;">
          <% stage_width = 1.0/(pipeline['stages'] || []).count * 100 - 1 %>
          <% (pipeline['stages'] || []).each_with_index do |stage, index| %> 
            <% state = (stage['result'] || '').downcase + ' ' +  (stage['state'] || '').downcase %>
            <div class="gocd-stage <%= state %>" title="<%= state %>" style="width: <%= stage_width %>%;">
              <div class="vertical-align-block">
                <% stage_name_style = stages_height > 20 ? "" : "font-size: 70%; margin: 0px;" %>
                <div class="ellipseis gocd-stage-name" style="<%= stage_name_style %>" title="Stage: <%= stage['name'] %>"><%= stage['name'] %></div>
                <% if stages_height > 20 %>
                  <% if stage['scheduled_time'] %>
                    <div class="gocd-stage-details" title="Started <%= stage['scheduled_time'] %>"><%= stage['scheduled_time'] %></div>
                  <% end %>
                  <% if stage['approved_by'] %>
                    <div class="gocd-stage-details" title="Triggered by <%= stage['approved_by'] %>">by <%= stage['approved_by'] %></div>
                  <% end %>
                <% end %>
              </div>
            </div>
          <% end %>
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
 font-weight: 600;
 font-size: 120%;
 padding-top: #{const[:title_padding_top]}px;
 height: #{const[:title_height]}px;
}
.unscheduled {
  background-color: #cccccc;
  color: #777777;
}
.gocd-pipeline {
  clear: both;
  width: 100%;
  margin: 2px 0px 2px 0px;
  background-color: #6FBEF3;
  overflow: hidden;
}
.gocd-build-label {
  font-size: 80%;
  max-height: #{const[:label_height] *2 }px;
  min-height: #{const[:label_height]}px;
  line-height: normal; 
  overflow: auto;
}
.gocd-build-number {
  font-weight: 600;
  font-size: 120%;
  float: left;
  margin: 2px 3px 2px 3px;
}
.gocd-build-label-details {
  margin: 2px 2px 2px 2px;
}
.gocd-stages {
  clear: both;
  margin: 0px 0px 4px 4px;
}
.gocd-stage {
  float: left;
  height: 100%;
  border-radius: 3px;
  line-height: normal; 
  margin-right: 2px;
  overflow: hidden;
}
.gocd-stage-name {
  font-size: 100%;
  margin: 2px 2px 2px 2px;
}
.gocd-stage-details {
  font-size: 80%;
  margin: 2px 2px 2px 2px;
}

EOS
    end

    def config
        [
          {
            'name' => 'pipeline',
            'description' => 'Pipeline Name',
            'validate' => '^[0-9a-zA-Z._]+$',
            'validation_message' => 'Pipeline Name cannot be empty and should contain only alphanumeric characters, underscore and period.'
          },
          {
            'name' => 'base_url',
            'description' => 'Server Base URL',
            'validate' => '^[0-9a-zA-Z\-_:/.]+$',
            'validation_message' => 'Server base URL is not a valid URL.'
          },
          {
            'name' => 'user',
            'description' => 'User Name',
            'validate' => '^.*$',
            'validation_message' => 'User Name can be any characters.'
          },
          {
            'name' => 'password',
            'description' => 'Password',
            'validate' => '^.*$',
            'validation_message' => 'Password can be any characters.'
          },
          {
            'name' => 'number_of_instances',
            'description' => 'Number of Instances',
            'validate' => '^[0-9]+$',
            'validation_message' => 'Number of Instances must be digits.',
            'default' => 3
          }
      ]
    end

    private 

    def call_server
      params = { method: :get, url: "#{options['base_url']}/go/api/pipelines/#{URI.escape(options['pipeline'])}/history"}
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
        label_width: 80,
        label_height: 15,
      }
    end

    class Transformer
      def self.transform(response, number_of_instances)
        response['pipelines'] = response['pipelines'][0..(number_of_instances.to_i - 1)] 
        response['pipelines'].each do |pipeline|
          pipeline['changes'] = transform_changes(pipeline)
          pipeline['stages'].each do |stage|
            transform_stage(stage)
          end
        end
        response
      end

      private 

      def self.transform_changes(pipeline)
        changes = []
        pipeline['build_cause'] ||= {}
        revisions = (pipeline['build_cause']['material_revisions'] || []).select{ |r| r['changed'] == true }
        revisions.each do |revision|
          revision['modifications'].each do |modification|
            type = revision['material']['type']
            change = { 'type' => type }
            if type == 'Pipeline'
              change['message'] = modification['revision']
            else
              change['message'] = modification['comment']
              change['author'] = modification['user_name']
              change['revision'] = modification['revision']
              change['revision'] = change['revision'][0..6] if change['type'] == 'Git'
            end
            changes << change
          end
        end
        changes << {'message' => 'no change'} if changes.empty?
        changes
      end

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
