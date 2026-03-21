# SolRengine RPC

Solana JSON-RPC client for Ruby. Handles balance queries, token accounts, signatures, transactions, and blockhash — with SSL CRL tolerance and multi-network support.

Part of the [SolRengine](https://github.com/solrengine) framework.

## Install

```ruby
gem "solrengine-rpc"
```

## Usage

```ruby
client = Solrengine::Rpc.client

client.get_balance("Abc...xyz")           # => 2.5 (SOL)
client.get_token_accounts("Abc...xyz")    # => [{ mint:, ui_amount:, ... }]
client.get_recent_signatures("Abc...xyz") # => [{ signature:, block_time:, ... }]
client.get_latest_blockhash               # => "abc123..."
client.get_signature_status("sig...")     # => { "confirmationStatus" => "finalized" }
client.get_transaction("sig...")          # => { full tx details }
```

## Configuration

```ruby
Solrengine::Rpc.configure do |config|
  config.network = "mainnet"  # or "devnet", "testnet"
  config.rpc_url = "https://mainnet.helius-rpc.com/?api-key=YOUR_KEY"
  config.ws_url  = "wss://mainnet.helius-rpc.com/?api-key=YOUR_KEY"
end
```

Or via environment variables:

```
SOLANA_NETWORK=devnet
SOLANA_RPC_URL=https://mainnet.helius-rpc.com/?api-key=xxx
SOLANA_WS_URL=wss://mainnet.helius-rpc.com/?api-key=xxx
SOLANA_RPC_DEVNET_URL=https://devnet.helius-rpc.com/?api-key=xxx
```

In a Rails app, you can also use `config/solana.yml` — the engine loads it automatically.

## License

MIT
