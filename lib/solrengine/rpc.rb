require_relative "rpc/version"
require_relative "rpc/configuration"
require_relative "rpc/ssl_http"
require_relative "rpc/client"
require_relative "rpc/engine" if defined?(Rails::Engine)

module Solrengine
  module Rpc
    class Error < StandardError; end

    class << self
      def configuration
        @configuration ||= Configuration.new
      end

      def configure
        yield(configuration)
      end

      def client(rpc_url: nil)
        Client.new(rpc_url: rpc_url || configuration.rpc_url)
      end
    end
  end
end
