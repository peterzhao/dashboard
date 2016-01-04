require 'rest-client'
require 'json'

module Dashboard
  class GocdPipeline < Dashboard::Plugin
    TITLE_HEIGHT = '27'
    TITLE_PADDING_TOP = '3'
    LABEL_WIDTH = '30'
    def check
      params = { method: :get, url: "#{options['base_url']}/go/api/pipelines/#{options['name']}/history"}
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
  <div class="gocd-title">#{options['name']}</div>
  <div class="gocd-pipelines" data-bind="style: { height: ($root.base_height * $root.sizey - #{TITLE_HEIGHT} - #{TITLE_PADDING_TOP}) + 'px'}">
    <!-- ko foreach: pipelines -->
      <div class="gocd-pipeline-wrapper" data-bind="style: { height: (1/($parent.pipelines.length)*100 - 1 ) + '%' }">
        <div class="gocd-pipeline">
          <div class="gocd-build-label" data-bind="text: label"></div>
          <div class="gocd-stages" data-bind="style: { width: ($root.base_width * $root.sizex - #{LABEL_WIDTH}) + 'px' }">
            <!-- ko foreach: stages -->
              <div class="gocd-stage-wrapper" data-bind="style: { width: (1/($parent.stages.length)*100 - 1 ) + '%' }, css: state">
                <div class="gocd-stage" data-bind="css: {passed: result == 'Passed', failed: result == 'Failed', building: state == 'Building'}">
                  <div class="display-content" data-bind="text: name"></div>
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
.Unscheduled {
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
  text-align: center;
  width: #{LABEL_WIDTH}px;
  font-size: 80%;
  position: relative;
  top: 50%;
  transform: translateY(-50%);
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
}

EOS
    end

    def config

    end
  end
end

private 

def transform(response_str, number_of_instances)
  response = JSON.parse(response_str)
  response['pipelines'] = response['pipelines'][0..(number_of_instances - 1)] 
  response['pipelines'].each do |pipeline|
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
  else
      stage['state'] = 'Unscheduled'
  end
end 

Dashboard::Plugin.register('gocd_pipeline', Dashboard::GocdPipeline)
