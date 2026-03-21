require "minitest/autorun"
require "solrengine/rpc"

Solrengine::Rpc.configure do |config|
  config.network = "devnet"
end
