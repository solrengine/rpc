module Solrengine
  module Rpc
    class Configuration
      NETWORKS = %w[mainnet devnet testnet].freeze

      DEFAULT_RPC_URLS = {
        "mainnet" => "https://api.mainnet-beta.solana.com",
        "devnet"  => "https://api.devnet.solana.com",
        "testnet" => "https://api.testnet.solana.com"
      }.freeze

      DEFAULT_WS_URLS = {
        "mainnet" => "wss://api.mainnet-beta.solana.com",
        "devnet"  => "wss://api.devnet.solana.com",
        "testnet" => "wss://api.testnet.solana.com"
      }.freeze

      attr_writer :network, :rpc_url, :ws_url

      def network
        @network ||= ENV.fetch("SOLANA_NETWORK", "mainnet")
      end

      def rpc_url
        @rpc_url ||= env_rpc_url || DEFAULT_RPC_URLS[network]
      end

      def ws_url
        @ws_url ||= env_ws_url || DEFAULT_WS_URLS[network]
      end

      def mainnet?
        network == "mainnet"
      end

      def explorer_base
        mainnet? ? "https://solscan.io" : "https://explorer.solana.com"
      end

      def explorer_cluster
        mainnet? ? "" : "?cluster=#{network}"
      end

      private

      def env_rpc_url
        case network
        when "mainnet" then ENV["SOLANA_RPC_URL"]
        when "devnet"  then ENV["SOLANA_RPC_DEVNET_URL"]
        when "testnet" then ENV["SOLANA_RPC_TESTNET_URL"]
        end
      end

      def env_ws_url
        case network
        when "mainnet" then ENV["SOLANA_WS_URL"]
        when "devnet"  then ENV["SOLANA_WS_DEVNET_URL"]
        when "testnet" then ENV["SOLANA_WS_TESTNET_URL"]
        end
      end
    end
  end
end
