require "faraday"

module Faraday
  class Faraday::Encoding < Faraday::Middleware
    def call(environment)
      @app.call(environment).on_complete do |env|
        if /;\s*charset=\s*(.+?)\s*(;|$)/.match(env[:response_headers][:content_type])
          content_charset = ::Encoding.find $1 rescue nil
        end
        env[:body].force_encoding content_charset if content_charset
      end
    end
  end
end

Faraday::Response.register_middleware encoding: Faraday::Encoding
