require 'rest-client'
require 'json'

module Dashboard
  class GocdPipeline < Dashboard::Plugin
    Stage_margin = '1'
    Pipeline_margin = '3'
    def check
      params = { method: :get, url: "#{options['base_url']}/go/api/pipelines/#{options['name']}/history"}
      if options['user']
        params[:user] = options['user']
        params[:password] = options['password']
      end
      begin
        response = RestClient::Request.execute(params)
      rescue => e
        return { "error" => e.message}.to_json
      end
      remove_unwanted_instances(response, options['number_of_instances'])
    end

    def template
<<EOS
<div class="gocd-widge">
  <div class="title">#{options['name']}</div>
  <div data-bind="foreach: pipelines">
    <div class="pipeline">
      <div class="label left" data-bind="text: label"></div>
      <div class="stages left" data-bind="foreach: stages">
        <div class="stage left" data-bind="css: result">
          <div class="stage-label" data-bind="text: name, style: { height: 1/($parents[1].pipelines.length)*($root.base_height * $root.sizey -#{Pipeline_margin}*$parents[1].pipelines.length - 28) + 'px', width: 1/($parent.stages.length)*($root.base_width * $root.sizex - #{Stage_margin}*$parent.stages.length - 16) + 'px' }"></div>
        </div>
      </div>
    </div>
  </div>
</div>
EOS
    end

    def style
<<EOS
.gocd-widge .title{
 text-align: center;
 padding: 5px;
}
.gocd-widge .Passed{
  background-color: green;
}
.gocd-widge .Failed{
  background-color: red;
}
.gocd-widge .pipeline{
  clear: both;
}
.gocd-widge .stages{
  margin-bottom: #{Pipeline_margin}px
}
.gocd-widge .left{
  float: left;
}
.gocd-widge .stage{
  display: table;
  margin-left: #{Stage_margin}px
}

.gocd-widge .stage-label{
  display: table-cell;
  vertical-align: middle;
  text-align: center;
}
EOS
    end

    def config

    end
  end
end

private 

def remove_unwanted_instances(response_str, number_of_instances)
  response = JSON.parse(response_str)
  response['pipelines'] = response['pipelines'][0..(number_of_instances - 1)] if response['pipelines'] 
  response.to_json
end

Dashboard::Plugin.register('gocd_pipeline', Dashboard::GocdPipeline)
