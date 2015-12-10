require 'rest-client'
require 'json'

module Dashboard
  class GocdPipeline < Dashboard::Plugin
    Stage_margin = '1'
    Pipeline_margin = '3'
    def check
<<EOS
{
  "pipelines": [
    {
      "name": "#{options['name']}",
      "label": 12,
      "stages": [
        {
          "name": "build",
          "state": "Completed",
          "result": "Passed"
        },
        {
          "name": "test",
          "state": "Completed",
          "result": "Passed"
        },
        {
          "name": "deploy",
          "state": "Completed",
          "result": "Passed"
        }
      ]
    },
    {
      "name": "#{options['name']}",
      "label": 11,
      "stages": [
        {
          "name": "build",
          "state": "Completed",
          "result": "Passed"
        },
        {
          "name": "test",
          "state": "Completed",
          "result": "Passed"
        },
        {
          "name": "deploy",
          "state": "Completed",
          "result": "Failed"
        }
      ]
    }
  ]
}
EOS
      #params = { method: :get, url: "#{options['base_url']}/go/api/pipelines/#{options['name']}/history"}
      #if options['user_name']
        #params[:user] = options['user']
        #params[:password] = options['password']
      #end
      #begin
        #response = RestClient::Request.execute params
        #response.to_str 
      #rescue => e
        #{'error' => { 'message' => e.reponse, 'http_code' => e.http_code }}.to_s
      #end
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

Dashboard::Plugin.register('gocd_pipeline', Dashboard::GocdPipeline)
