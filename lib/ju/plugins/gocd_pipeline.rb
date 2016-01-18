require 'rest-client'
require 'json'

module Ju
  class GocdPipeline < Ju::Plugin

    TITLE_HEIGHT = '27'
    TITLE_PADDING_TOP = '3'
    LABEL_WIDTH = '80'

    def check
      params = { method: :get, url: "#{options['base_url']}/go/api/pipelines/#{URI.escape(options['name'])}/history"}
      if options['user']
        params[:user] = options['user']
        params[:password] = options['password']
      end
      begin
        response = RestClient::Request.execute(params)
      rescue => e
        message = e.message.gsub('"', '\"')
        return "{\"error\":\"#{message}\"}"
      end
      transform(response, options['number_of_instances'])
    end

    def template
<<EOS
<div class="gocd">
  <div class="gocd-title" data-bind="text: $root.id, attr:{ title: 'Pipeline name: ' + $root.id }"></div>
  <div class="gocd-pipelines" data-bind="style: { height: ($root.base_height * $root.sizey - #{TITLE_HEIGHT} - #{TITLE_PADDING_TOP}) + 'px'}">
    <!-- ko foreach: pipelines -->
      <div class="gocd-pipeline-wrapper" data-bind="style: { height: (1/($parent.pipelines.length)*100 - 1 ) + '%', 'max-height': (1/($parent.pipelines.length)*100 - 1 ) + '%' }">
        <div class="gocd-pipeline">
          <div class="vertical-align-block gocd-build-label">
            <div class="gocd-build-number" data-bind="text: label, attr:{ title: 'Build label:' + label }"></div>
            <div class="ellipseis gocd-build-label-details" data-bind="text: triggered_by, attr: { title: 'Triggered ' + triggered_by }"></div>
          </div>
          <div class="gocd-stages" data-bind="style: { width: ($root.base_width * $root.sizex - #{LABEL_WIDTH}) + 'px' }">
            <!-- ko foreach: stages -->
              <div class="gocd-stage-wrapper" data-bind="style: { width: (1/($parent.stages.length)*100 - 1 ) + '%'}">
                <div class="gocd-stage" data-bind="css: {passed: result == 'Passed', failed: result == 'Failed', scheduled: state == 'Scheduled', building: state == 'Building', unscheduled: state == 'Unscheduled'}">
                  <div class="vertical-align-block">
                    <div class="ellipseis gocd-stage-name" data-bind="text: name, attr:{ title: 'Stage: ' + name }"></div>

                    <!-- ko ifnot: typeof(scheduled_time) == 'undefined' -->
                    <div class="ellipseis gocd-stage-details" data-bind="text: scheduled_time, attr:{ title: 'Started ' + scheduled_time }"></div>
                    <!-- /ko -->
                  </div>
                </div>
              </div>
            <!-- /ko --> 
          </div>
        </div>
      </div>
    <!-- /ko --> 
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
 padding-top: #{TITLE_PADDING_TOP}px;
 height: #{TITLE_HEIGHT}px;
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
  width: #{LABEL_WIDTH}px;
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
 font-size: 120%;
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
            'name' => 'name',
            'description' => 'Widget Name',
            'validate' => '^[0-9a-zA-Z\-_ ]+$',
            'validation_message' => 'Widget Name cannot be empty or contain special characters'
          },
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
            'name' => 'pull_inteval',
            'description' => 'Pull Inteval',
            'validate' => '^[0-9]+$',
            'validation_message' => 'Pull Inteval must be digits',
            'default' => 5
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
  end
end

private 

def transform(response_str, number_of_instances)
  response = JSON.parse(response_str)
  response['pipelines'] = response['pipelines'][0..(number_of_instances.to_i - 1)] 
  response['pipelines'].each do |pipeline|
    pipeline['triggered_by'] = "by #{pipeline['stages'].first['approved_by']}"
    pipeline['stages'].each do |stage|
      transform_stage(stage)
    end
  end
  response.to_json
end

def transform_stage(stage)
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

Ju::Plugin.register('gocd_pipeline', Ju::GocdPipeline)
