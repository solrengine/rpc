require "json"

module Solrengine
  module Rpc
    class Client
      include SslHttp

      def initialize(rpc_url: nil)
        @rpc_url = rpc_url || Solrengine::Rpc.configuration.rpc_url
      end

      def get_balance(wallet_address, commitment: "confirmed")
        result = rpc_request("getBalance", [ wallet_address, { "commitment" => commitment } ])
        lamports = result.dig("result", "value")
        return nil unless lamports

        lamports.to_f / 1_000_000_000
      end

      def get_token_accounts(wallet_address, program_id: "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA")
        result = rpc_request("getTokenAccountsByOwner", [
          wallet_address,
          { "programId" => program_id },
          { "encoding" => "jsonParsed" }
        ])

        accounts = result.dig("result", "value") || []

        accounts.filter_map do |account|
          info = account.dig("account", "data", "parsed", "info")
          next unless info

          token_amount = info["tokenAmount"]
          amount = token_amount["uiAmount"].to_f
          next if amount.zero?

          {
            mint: info["mint"],
            balance: token_amount["amount"],
            decimals: token_amount["decimals"],
            ui_amount: amount,
            ui_amount_string: token_amount["uiAmountString"]
          }
        end
      end

      def get_recent_signatures(wallet_address, limit: 10)
        result = rpc_request("getSignaturesForAddress", [
          wallet_address,
          { "limit" => limit }
        ])

        signatures = result.dig("result") || []

        signatures.map do |sig|
          {
            signature: sig["signature"],
            slot: sig["slot"],
            block_time: sig["blockTime"] ? Time.at(sig["blockTime"]) : nil,
            error: sig["err"],
            memo: sig["memo"],
            confirmation_status: sig["confirmationStatus"]
          }
        end
      end

      def get_latest_blockhash(commitment: "finalized")
        result = rpc_request("getLatestBlockhash", [ { "commitment" => commitment } ])
        value = result.dig("result", "value")
        return nil unless value

        {
          blockhash: value["blockhash"],
          last_valid_block_height: value["lastValidBlockHeight"]
        }
      end

      def get_signature_status(signature)
        result = rpc_request("getSignatureStatuses", [ [ signature ] ])
        result.dig("result", "value", 0)
      end

      def get_transaction(signature)
        result = rpc_request("getTransaction", [
          signature,
          { "encoding" => "jsonParsed", "maxSupportedTransactionVersion" => 0 }
        ])

        result["result"]
      end

      # Generic RPC call for methods not covered above
      def request(method, params = [])
        rpc_request(method, params)
      end

      private

      def rpc_request(method, params = [])
        uri = URI.parse(@rpc_url)
        body = {
          jsonrpc: "2.0",
          id: 1,
          method: method,
          params: params
        }.to_json

        attempts = 0
        begin
          attempts += 1
          http = ssl_http(uri)
          request = Net::HTTP::Post.new(uri.request_uri.empty? ? "/" : uri.request_uri)
          request["Content-Type"] = "application/json"
          request.body = body
          response = http.request(request)
          JSON.parse(response.body)
        rescue Errno::EPIPE, Errno::ECONNRESET, EOFError, IOError => e
          # Pooled connection may have been closed by the server; drop and
          # retry once with a fresh connection.
          reset_pooled_http(uri)
          retry if attempts < 2
          rescue_rpc_error(e)
        rescue => e
          rescue_rpc_error(e)
        end
      end

      def rescue_rpc_error(error)
        if defined?(Rails)
          Rails.logger.error("Solrengine RPC error: #{error.class} - #{error.message}")
        end
        {}
      end
    end
  end
end
