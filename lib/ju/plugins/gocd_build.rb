require 'rest-client'
require 'json'
require 'erb'

module Ju
  class GocdBuild < Ju::Plugin
    attr_reader :data

    def check
      @data= call_server
      render = ERB.new(template)
      render.result(binding)      
    end

    def template
<<EOS
<%
  pipeline = data || []
  stage = pipeline['stage'] || []
  build_height = options['height'] - const[:title_height] - const[:title_padding_top]
  state = (stage['result'] || '').downcase + ' ' +  (stage['state'] || '').downcase
%>
<div class="gocdbuild <%= state %>" title="Result: <%= stage['result'] %>">
  <div class="gocdbuild-header" title="Build: <%= options['pipeline'] %>.<%= options['stage']%>"><%= options['name'] %></div>
  <div class="gocdbuild-body" style="height: <%= build_height %>px;">
    <div class="gocdbuild-title">
      <div class="gocdbuild-label" title="Build label: <%= pipeline['label'] %>"><%= pipeline['label'] %></div>
      <% if stage['approved_by'] && stage['approved_by'] != 'changes' %>
        <div class="gocdbuild-title-detail" title="Triggered by <%= stage['approved_by'] %>">by <%= stage['approved_by'] %></div>
      <% end %>
      <% if stage['scheduled_time'] %>
        <div class="gocdbuild-title-detail" title="Started <%= stage['scheduled_time'] %>"><%= stage['scheduled_time'] %></div>
      <% end %>
    </div>
    <div class="gocdbuild-messages">
      <% (pipeline['changes'] || []).each do |change| %>
        <% if change['author'] && change['revision'] %>
          <% title = "Author: " + change['author']+ ", Revision: " + change['revision'] %>
        <% end %>
        <div class="ellipseis gocdbuild-message" title="<%= title %>"><%= change['message'] %></div>
      <% end %>
    </div>
  </div>
</div>
EOS
    end

    def style
<<EOS
.gocdbuild-header {
 text-align: center;
 font-weight: 600;
 font-size: 150%;
 padding-top: #{const[:title_padding_top]}px;
 height: #{const[:title_height]}px;
}
.unscheduled {
  background-color: #cccccc;
  color: #777777;
}
.gocdbuild {
  clear: both;
  width: 100%;
  margin: 0px;
  overflow: hidden;
  border-radius: 3px;
}
.gocdbuild-label {
  font-size: 160%;
  font-weight: 600;
  max-height: #{const[:label_height] *2 }px;
  min-height: #{const[:label_height]}px;
  line-height: normal; 
  overflow: auto;
  float: left;
  margin: 0px 4px 0px 4px;
}
.gocdbuild-title-detail {
  margin: 2px 6px 2px 6px;
  float: left;
  font-style: italic;
}
.gocdbuild-messages {
  clear: both;
  margin: 0px 6px 2px 6px;
}
.gocd-stage-details {
  font-size: 80%;
  margin: 2px 2px 2px 6px;
  float: left;
  line-height: 70%; 
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
            'name' => 'stage',
            'description' => 'Stage Name',
            'validate' => '^[0-9a-zA-Z._]+$',
            'validation_message' => 'Stage Name cannot be empty and should contain only alphanumeric characters, underscore and period.'
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
          }
      ]
    end

    private 

    def call_server
      params = { method: :get, url: "#{options['base_url']}/go/api/pipelines/#{URI.escape(options['pipeline'])}/history", verify_ssl: false}
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
      Transformer.transform(JSON.parse(response), options['stage'])
    end

    # to avoid constant already defined warning when reloading class
    def const
      {
        title_height: 36, 
        title_padding_top: 3,
        label_width: 80,
        label_height: 15,
      }
    end

    class Transformer
      def self.transform(response, stage_name)
        pipeline = response['pipelines'].first
        pipeline['changes'] = transform_changes(pipeline)
        stage = pipeline['stages'].find{ |s| s["name"] == stage_name }
        transform_stage(stage)
        pipeline['stage'] = stage
        pipeline.delete("pipelines")
        pipeline
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

Ju::Plugin.register('gocd_build', Ju::GocdBuild)
