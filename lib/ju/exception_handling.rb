require_relative 'remote_connection_error'
module Ju
  class ExceptionHandling
    def initialize(app)
      @app = app
    end

    def call(env)
      begin
        @app.call env
      rescue Ju::RemoteConnectionError => ex
        [500, {'Content-Type' => 'application/json'}, [{ message: ex }.to_json ]]
      rescue => ex
        env['rack.errors'].puts ex
        env['rack.errors'].puts ex.backtrace.join("\n")
        env['rack.errors'].flush
        [500, {'Content-Type' => 'application/json'}, [{ message: ex }.to_json]]
      end
    end
  end
end
