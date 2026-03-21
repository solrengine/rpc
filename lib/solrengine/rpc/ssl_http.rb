require "net/http"

module Solrengine
  module Rpc
    # HTTP helper that tolerates SSL certificates with unavailable CRLs.
    # Some Solana and Jupiter endpoints have certs that Ruby's OpenSSL
    # rejects due to missing Certificate Revocation Lists.
    module SslHttp
      private

      def ssl_http(uri)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = (uri.scheme == "https")
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        http.verify_callback = ->(_preverify_ok, store_ctx) {
          return true if store_ctx.error == 0
          return true if store_ctx.error == OpenSSL::X509::V_ERR_UNABLE_TO_GET_CRL
          false
        }
        http.open_timeout = 10
        http.read_timeout = 10
        http
      end
    end
  end
end
