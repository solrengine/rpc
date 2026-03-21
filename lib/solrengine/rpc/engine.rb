module Solrengine
  module Rpc
    class Engine < ::Rails::Engine
      isolate_namespace Solrengine::Rpc

      initializer "solrengine-rpc.configure" do
        # Load config from solana.yml if it exists and no explicit config was set
        config_path = Rails.root.join("config", "solana.yml")
        if config_path.exist?
          solana_config = Rails.application.config_for(:solana).deep_stringify_keys
          cfg = Solrengine::Rpc.configuration
          cfg.network = solana_config["network"] if solana_config["network"]

          network_config = solana_config.dig("networks", cfg.network)
          if network_config
            cfg.rpc_url = network_config["rpc_url"] if network_config["rpc_url"]
            cfg.ws_url = network_config["ws_url"] if network_config["ws_url"]
          end
        end
      end
    end
  end
end
