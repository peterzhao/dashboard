require 'rest-client'
require 'json'
module Dashboard
  class GocdPipeline

    def check(options)
      params = { method: :get, url: "#{options['base_url']}/go/api/pipelines/#{options['name']}/history"}
      if options['user_name']
        params[:user] = options['user']
        params[:password] = options['password']
      end
      begin
        response = RestClient::Request.execute params
        response.to_str 
      rescue => e
        {'error' => { 'message' => e.reponse, 'http_code' => e.http_code }}.to_s
      end
    end

    def template(options)

    end

    def config(options)

    end
  end
end

Dashboard::Plugin.register('gocd_pipeline', Dashboard::GocdPipeline)
