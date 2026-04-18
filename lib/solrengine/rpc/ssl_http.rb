require "net/http"

module Solrengine
  module Rpc
    # HTTP helper that tolerates SSL certificates with unavailable CRLs.
    # Some Solana and Jupiter endpoints have certs that Ruby's OpenSSL
    # rejects due to missing Certificate Revocation Lists.
    #
    # Connections are pooled per-thread keyed by [host, port, scheme] so
    # repeated RPC calls reuse the same TCP + TLS handshake. Puma serves
    # requests across a threadpool; each thread keeps its own pool to avoid
    # cross-thread races on a single Net::HTTP instance.
    module SslHttp
      KEEP_ALIVE_TIMEOUT = 30
      OPEN_TIMEOUT = 10
      READ_TIMEOUT = 10

      private

      def ssl_http(uri)
        pool = (Thread.current[:solrengine_http_pool] ||= {})
        key = [ uri.host, uri.port, uri.scheme ]
        pool[key] ||= build_http(uri)
      end

      def build_http(uri)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = (uri.scheme == "https")
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        http.verify_callback = ->(_preverify_ok, store_ctx) {
          return true if store_ctx.error == 0
          return true if store_ctx.error == OpenSSL::X509::V_ERR_UNABLE_TO_GET_CRL
          false
        }
        http.open_timeout = OPEN_TIMEOUT
        http.read_timeout = READ_TIMEOUT
        http.keep_alive_timeout = KEEP_ALIVE_TIMEOUT
        http.start
        http
      end

      # Drop and close a pooled connection; used when we hit broken-pipe /
      # EOF errors that suggest the server closed the idle TCP socket.
      def reset_pooled_http(uri)
        pool = Thread.current[:solrengine_http_pool] || {}
        http = pool.delete([ uri.host, uri.port, uri.scheme ])
        http&.finish if http&.started?
      rescue IOError
        # Already closed — nothing to do.
      end
    end
  end
end
