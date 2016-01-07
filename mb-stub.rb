require 'rest-client'

module JU
  def self.stub(json_file)
    port = ENV['port'] || 4545
    json_response = File.read(json_file)
    data = {
      'port' => port,
      'protocol' => 'http',
      'stubs' => [{
        'responses' => [{ 'is' => { 'body' => json_response } }]
      }]
    }

    RestClient.delete "http://127.0.0.1:2525/imposters/#{port}"

    RestClient.post "http://localhost:2525/imposters", data.to_json, :content_type => :json, :accept => :json 
  end
end

JU.stub(ARGV[0])
