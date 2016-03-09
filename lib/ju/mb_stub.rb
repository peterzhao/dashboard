require 'rest-client'

module Ju
  def self.mb_stub(json_file, port = nil)
    json = File.read(json_file)
    mb_stub_from_json(json, port)
  end
    
  def self.mb_stub_from_json(json, port = nil)
    port ||= (ENV['port'] || 4545)
    data = {
      'port' => port,
      'protocol' => 'http',
      'stubs' => [{
        'responses' => [{ 'is' => { 'body' => json } }]
      }]
    }

    RestClient.delete "http://127.0.0.1:2525/imposters/#{port}"

    RestClient.post "http://localhost:2525/imposters", data.to_json, :content_type => :json, :accept => :json 
  end
end

